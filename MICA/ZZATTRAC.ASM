;	INCLUDE	[SAM]START
;	INCLVER	SAM,SINISTAR.EQU

;KENSMARQ	EQU	1

	PUSHORG	ROMSAVE								;;Fixme was: PUSHORG	ROMSAV

	RADIX	10								;;(decimal values ahead)

	VECTOR	POWVECT
	CLR	HSTDMRQ		;Clear HSTD Page display flag on powerup
	RTS

;******************************************************************************
;*
;* HIGH SCORE TO DATE/MARQUEE PAGES Task
;*   This routine displays the HSTD page, pauses, then draws the SiniMarquee
;*   After a second pause, a jump to IAMODE is taken
;*
;*   This routine is called by Rich's attract mode stuff
;*
;* Expects:  Task Workspace pointer in Y

	ROUTINE	ATTRACT

	LDX	#ALHSTD		;Get operator flag to allow
	JSR	RCMOSA		;  HSTD table
	LBEQ	ATT10S		;  and branch out if not allowed		;;Fixme was: LBEQ  10$ (Had to make global label)
				
	INC	HSTDMRQ		;Set the HSTD/Marquee flag
				
	LDA	#%00110011	;Allow Player 1/2 start, FIRE, SINIBOMB
	STA	PANMASK         
				
	JSR	CLRSCR		;Clear the entire screen
				
	LDA	PMEMCTL		;Get the DMA-Inhibit control byte
	PSHS	A,Y		;  and save it with the ever popular Y register
	ANDA	#~$4		;Turn off the inhibit				;;Fixme was: ANDA  #!N4
	STA	PMEMCTL		;  and store the off-value
 	STA	MEMCTL		;  and de-inhibit the DMA
				
	LDX	#$822E		;Screen address for HIGHEST SCORE
	LDY	#CMOSHSC	;Highest Score itself
	INC	DISSIZ		;If non-zero then DISNUM/INT use 6x8 characters
	JSR	DISNUM		;Display this number
	LEAY	8,Y		;HIGHEST SCORE initials
	LDX	#$826A		;Screen Address for initials
	JSR	DISINT		;Do them
	TEXT	$84,$8A		;Now tell the world that's this is our Sinihero
	PHRASE	RED,68,SINI,STAR
	LEAX	-42,X		;Put the "-" [dash] character			;;Fixme was: LEAX  -42.,X
	LDA	PMEMCTL		;Turn off DMA-inhibit again
	ANDA	#~$4								;;Fixme was: ANDA  #!N4
	STA	PMEMCTL
	STA	MEMCTL
	LDA	#CDASH		;  between SINI
	JSR	OUTCHR		;  and STAR
				
	TEXT	$78,$59		;Now for the CMOS saved scores
	PHRASE	RED,68,SINIMMORTALS
	LDA	PMEMCTL		;Turn off DMA-inhibit again
	ANDA	#~$4								;;Fixme was: ANDA  #!N4
	STA	PMEMCTL
	STA	MEMCTL

	LDX	#$7000		;Starting line for CMOS scores
	LDY	#CMOSHSC	;Starting address of scores
	CLR	DISSIZ		;Now we want 3x5 characters
	JSR	NEXTL		;Go draw the bunch

	TEXT	$43,$50
	PHRASE	RED,68,SURVIVORS,TODAY

	LDX	#$3B00		;Starting line for RAM scores
	LDY	#RAMHSC		;Starting address of scores
	JSR	NEXTL		;Draw this bunch
				
	PULS	A,Y		;Fetch DMA inhibit and workspace pointer
	STA	PMEMCTL		;Restore DMA
	STA	MEMCTL

;* Now, create a task that will force the background to color $48 for
;*   as long as the HSTD page stays up
	NEW_SLEEP	TASK1,MAKBAK,OMTLEN+2
	LDD	#(60*5)		;Let the task live for 5 seconds		;;Fixme was: LDD  #(60.*5)
	STD	OMTLEN,X	;  and let the page stay up for the same
	JSR	TIMER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE	SET	*		;; Save the current address

	ORG	PHRSAV		;; Jump over to PHRSAV to save our pointers
	FDB	_SINI		
	FDB     _STAR		

	FDB     _SINIMMORTALS	
   
	FDB     _SURVIVORS	
	FDB     _TODAY		

PHRSAV	SET	*		;; Mark the new address for PHRSAV to add
				;; more phrases later

	ORG	ROMSAVE		;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;******************************************************************************
;*
;* Marquee Page
;*   By Ken Lantz and Mike Metz
;*
ATT10S	PSHS	Y		;Now resave Y through the next trial		;;Fixme was: 10$  PSHS	Y
				
	LDA	#%00110011	;Set PANMASK to allow
	STA	PANMASK		;  PLAYER 1/2 Start, Fire and Sinibomb buttons
				
	JSR	CLRSCR		;Clear that ol' whole-screen again
	JSR	DCREDITS


	IFDEF	KENSMARQ  ;* Defining this includes Ken's Marquee Display
	JSR	MARQUEE
	ELSE
;* To patch in Ken's Marquee, overwrite this Text/Phrase combination
;*   with a JSR MARQUEE and several NOPs.  
	TEXT	$58,$65
	PHRASE	RED,68,SINISTAR
	TEXT	$54,$99
	PHRASE	RED,35,TM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ROMSAVE	SET	*		;; Save the current address

;	ORG	PHRSAV		;; Jump over to PHRSAV to save our pointers
;	FDB	_TM

;PHRSAV	SET	*		;; Mark the new address for PHRSAV to add
				;; more phrases later

;	ORG	ROMSAVE		;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ENDIF

	LDB	#$CC		;Get message "shadow" color
	LDX	#CMOSOPE	;Cmos location of operator message line 1
	LDY	#$3425		;Screen address for text
	JSR	OPMDRW		;Draw it
	LDB	#$33		;Line 1 "foreground" color
	LEAY	-1,Y		;Bump screen location one left
	JSR	OPMDRW		;Draw text again
				
	LDB	#$CC		;Same as above, but with message line 2
	LDX	#CMOSO2
	LDY	#$2C25
	JSR	OPMDRW
	LDB	#$22
	LEAY	-1,Y
	JSR	OPMDRW


	LDD	#$1C0		;Countdown value
	STD	MARQCNT		;Save it for guess what
				
	PULS	Y		;Restore Y

	CHANGE_SLEEP	TASK1,HERE

	PSHS	Y

	LDD	MARQCNT		;Wake up here.  When MARQCNT bottoms out,
	SUBD	#1		;  restart the system.
	STD	MARQCNT
	BNE	.124S
	CLR	HSTDMRQ
	JMP	IAMODE

.124S	CMPD	#$100		;For the first bunch of passes, leave the screen
	LBHS	FINIT		;  as is.					;;This gets patched over in BOBFIXES ($8183)

.123S	RANDOM	OSEED1,WORD	;Get a random screen location
	CMPA	#$8E
	BHI	.123S
	TFR	D,X
	RANDOM	OSEED2,$C,0	;Get a random color
	LDU	#SINOUT
	LDB	A,U
	LDA	#P_SINISTAR	;Get the Sinistar word value			;;Fixme was: LDA  #.SINISTAR (had to be rename "." PhrNum labels to "P_")
	JSR	OUTP68		;Go print it out


	TEXT	$4A,LEFEDG
	PHRASE	RED,35,COPYRIGHT,1982,WILLIAMS,ELECTRONICS,INC
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	IFNDEF	KENSMARQ	;; If MARQUEE.ASM is not included then add these to PHRSAV
ROMSAVE	SET	*		;; Save the current address

	ORG	PHRSAV		;; Jump over to PHRSAV to save our pointers
	FDB	_TM
	FDB	_COPYRIGHT	
	FDB	_1982		
	FDB	_WILLIAMS	
	FDB	_ELECTRONICS	
	FDB	_INC	
	
PHRSAV	SET	*		;; Mark the new address for PHRSAV to add
				;; more phrases later

	ORG	ROMSAVE		;; Back to our regularly scheduled programming...
;	ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FINIT	JSR	DCREDITS

	PULS	Y
	SLEEP	LOOP	


SINOUT	FCB	$11,$22,$33,$44,$55,$66,$99,$AA,$BB,$CC,$DD,$FF

;******************************************************************************
;* MAKBAK
;*
;*   A task to force the background to stay a certain color
;*
;*   Expects:  Y to point to workspace
;*	      OMTLEN+0/1 to have number of passes to stay alive
;*

MAKBAK	LDD	OMTLEN,Y	;Have we timed out yet?
	SUBD	#1
	STD	OMTLEN,Y
	LBEQ	DIE		;Yes, so die

	JSR	DCREDITS
	LDA	#$48		;Otherwise, force feed that byte to Color 0
	STA	PCRAM
	SLEEP	LOOP		;  and go away


;*******************************************************************************
;* NEXTL
;*   PRINT OUT A COLUMN OF 10 SCORES AT A TIME
;*   UNTIL 30 ARE PRINTED.
;*	X = STARTING SCREEN LINE (LSBYTE S/B 00)
;*	Y = STARTIN/HIGHEST SCORE OF 30
;*
;*	Registers D,X,Y are trashed

NEXTL	CLRA			;Set up counter to zero
	PSHS	A		;  and save on stack

NEXTL2	INC	,S		;Increment our line counter
	LDA	,S

;* Get the tens-component of A into A, the units-component into B
	CLRB
	PSHS	B

.100S	TFR	A,B
	SUBA	#10								;;Fixme was: SUBA  #10.
	BMI	.101S
	INC	,S
	BRA	.100S

.101S	PULS	A

	TSTA			;Is A a digit?
	BNE	.2S		;  if yes then branch
	LDA	#CBLANK		;  else make it a blank
				
.2S	PSHS	D		;Save this divided up digit
	LEAX	$18,X		;SCREEN POS OF NUMBER
;* Ah ... color $63 gives us the wonderful marble effect    =RJM=
	LDB	#$63
	JSR	OUTC35		;Go print the first digit
	LDA	1,S		;Fetch the second digit
	JSR	OUTC35		;  and print that
	LDA	#$2B		;Bracket character
	JSR	OUTC35		;  and print that
				
	LDB	#YELLOW		;Normal Display Color
	CMPY	HSLEN1		;Is this one of the most-recently entered scores
	BEQ	.200S		;Yes, so change the display color
	CMPY	HSLEN2		;Is this perchance the other one?
	BEQ	.200S		;No, so use standard color
	CMPY	HSRLN1		;Is this one of the most-recently entered scores
	BEQ	.200S		;Yes, so change the display color
	CMPY	HSRLN2		;Is this perchance the other one?
	BNE	.201S		;No, so use standard color
				
.200S	LDB	#$47		;Get a magenta color
	STB	PCRAM+$E        
	LDB	#$EE		;Use the special effects color
				
.201S	STB	DISCLR		;Save it where the display routines can get it
				
	LEAX	3,X		;SCREEN POS OF INITIALS
	LEAY	8,Y		;ADDRESS OF INITIALS
	JSR	DISINT		;DIPLAY INITIALS
	LEAX	$10,X		;SCREEN POS OF SCORE
	LEAY	-8,Y		;ADDRESS OF SCORE
	JSR	DISNUM		;DISPLAY NUMBER
	LEAY	SCRSIZ,Y	;POINT TO NEXT SET OF DATA
	PULS	D		;Restore our split digits
	TSTB			;If the second digit has hit zero
	BEQ	.1S		;  we're at the end of the column
	LEAX	-$337,X		;  else goto START OF NEXT LINE
	BRA	NEXTL2		;  and do it all again

.1S	CMPA	#$3		;Wow!  Column done!  Have we finished 3rd col?
	BEQ	.4S		;DID 30, ALL DONE
	LEAX	$1B10,X		;BACK UP TO START OF NEXT COLUMN
	BRA	NEXTL2		;  and go do it all again

.4S	PULS	A,PC		;ALL DONE


;******************************************************************************
;* DISNUM
;*
;* DISPLAY THE SCORE
;*	X = ADDRESS OF SCREEN
;*	Y = ADDRESS OF DATA TO BE DISPLAYED
;*	DISSIZ... 0 = 3X5  >0 = 5X7
;*

DISNUM	PSHS	X,Y,D
	LDB	#4

	EXG	X,Y	;RCMOSA NEEDS DATA ADRESS IN X

.2S	JSR	RCMOSA
	BNE	.1S	;ZEROS
	TST	DISSIZ
	BNE	.200S
	LEAY	8,Y
	BRA	.201S

.200S	LEAY	14,Y								;;Fixme was: LEAY  14.,Y

.201S	DECB
	BNE	.2S
	BRA	.9S

.1S	CMPA	#$0F
	BHI	.3S
	ORA	#$F0	;SUPPRESS FIRST ZERO

.3S	PSHS	B
	EXG	X,Y	;OUT ROUTINES NEED SCREEN ADDRESS BACK IN X
	TST	DISSIZ
	BNE	.4S

	LDB	DISCLR	;Get display color
	JSR	OUTB35	;WRITE TWO DIGITS
	BRA	.5S

.4S	LDB	#WHITE
	JSR	OUTBCD

.5S	PULS	B
	DECB
	BEQ	.9S	;	NO MORE TO DISPLAY
	EXG	X,Y	;RCMOSA NEEDS DATA ADRESS IN X
	JSR	RCMOSA
	BRA	.3S
.9S	PULS	X,Y,D,PC	


;******************************************************************************
;* DISINT
;*
;* DISPLAY THE INITIALS
;*	X = ADDRESS OF SCREEN
;*	Y = ADDRESS OF DATA TO BE DISPLAYED
;*	DISSIZ... 0 = 3X5, >0 = 5X7
;*

DISINT	PSHS	X,Y,D
	LDB	#$3

.1S	EXG	X,Y	;RCMOSA NEEDS DATA ADDRESS IN X
	JSR	RCMOSA
	EXG	X,Y	;OUT ROUTINES NEED SCREEN ADDRESS IN X
	PSHS	B
	TST	DISSIZ
	BNE	.2S

	LDB	DISCLR	;Get current display color
	JSR	OUTC35
	BRA	.3S

.2S	LDB	#WHITE
	JSR	OUTCHR

.3S	PULS	B
	DECB
	BNE	.1S
	PULS	X,Y,D,PC	


;******************************************************************************
;* OPMDRW
;*   Operator Message Drawor
;* ENTRY:
;*	X has address in CMOS of text start
;*	Y has screen address for start of text

OPMDRW	PSHS	D,X,Y

	LDA	#OPENLEN
	PSHS	A

.10S	JSR	RCMOSA
	EXG	X,Y
	LDB	2,S
	JSR	OUTCHR
	EXG	X,Y
	DEC	,S
	BNE	.10S

	LEAS	1,S

	PULS	D,X,Y,PC
	
	RADIX	16								;;(switching back to hex)

	PULLORG	ROMSAVE								;;Fixme was: PULLORG	ROMSAV