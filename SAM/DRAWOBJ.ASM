;;	INCLUDE "../SAM/START.ASM"

;;===============================================================================
; EQUs to remove later
;CRYSTBL	EQU	$4FAA	;SAMTABLE
;;===============================================================================
	
	PUSHORG	ROMSAVE

;;	SUBTTL	DISPLAY ROUTINES

;* erase kill object
EKOBJ	LDX	OIDESC,Y	;> uses A,B,X,Y
	LDA	OHEIGHT,X
	LDB	ODWIDTH,Y
	EORA	#4		;* * * FOR DMA BUG
	EORB	#4		;* * *
	STD	DHIGH
	LDD	OBOTTOM,Y
	STD	DDEST
	LDD	ODSOUR,Y
	STD	DSOUR
	LDB	OLPOSF,Y
	SEX
	ANDA	#DTFL
	ORA	#DWBL+DZSP+DCNS
	STA	DCTRL
	JMP	KOBJECT		;link-out object

;* change image			pass object wsa in Y
	ROUTINE	CHGOBJ
	LDX	OIDESC,Y	;erase old image  > uses A,B,X
	LDA	OHEIGHT,X
	LDB	ODWIDTH,Y
	EORA	#4		;* * * FOR DMA BUG
	EORB	#4		;* * *
	STD	DHIGH
	LDD	OBOTTOM,Y
	STD	DDEST
	LDD	ODSOUR,Y
	STD	DSOUR
	LDB	OLPOSF,Y
	SEX
	ANDA	#DTFL
	ORA	#DWBL+DZSP+DCNS
	STA	DCTRL
	LDD	OLCENT,X	;save old position offset
	LDX	ONIDESC,Y	;get new image descriptor
	STX	OIDESC,Y	;save it
	SUBA	OLCENT,X	;compute change in bottom left position
	SUBB	OSCENT,X
	STB	TEMP+1		;save s change in TEMP
	ADDB	OSVEL,Y		;add to s velocity 
	STB	OSVEL,Y
	CLRB			;convert l change to bytes
	ASRA
	RORB
	STD	TEMP+2		;save l change in TEMP
	ADDD	OLVEL,Y		;add to l velocity
	STD	OLVEL,Y
	LDD	OIMAGE,X	;new source
	STD	ODSOUR,Y
	STD	DSOUR
	LDD	OHEIGHT,X	;new width
	STB	ODWIDTH,Y
	EORA	#4		;* * *
	EORB	#4		;* * *
	STD	DHIGH
	LDD	OPDRWVE,Y	;save post-draw vector in TEMP
	STD	TEMP+4
	LDD	#POSTCHG	;change post-draw vector to POSTCHG
	STD	OPDRWVE,Y
	LDA	OSTATUS,Y	;left clipped?
	BPL	DRAWOBJ
	LDA	OSPOS,Y		;yes, off left edge?
	ADDA	OWIDTH,X
	BCS	DRAWOBJ
	JMP	OBJOFF		;yes
	BRA	DRAWOBJ		;uses normal draw routine

;* display object		pass object wsa in Y
DOBJECT	LDX	OIDESC,Y	;> uses A,B,X
	LDA	OHEIGHT,X
	LDB	ODWIDTH,Y
	EORA	#4		;* * * FOR DMA BUG
	EORB	#4		;* * *
	STD	DHIGH
	LDD	OBOTTOM,Y
	STD	DDEST
	LDD	ODSOUR,Y
	STD	DSOUR
	LDB	OLPOSF,Y
	SEX
	ANDA	#DTFL
	ORA	#DWBL+DZSP+DCNS
	STA	DCTRL
;*                  left-right clipping state transitions:
;*
;*                     /B\             /A\            /C\
;*                     \ V             \ V            \ V
;*      off            left -----D----> on -----F---> right ---I---> off
;*     left <----H---- clip <----E--- screen <--G---- clip          right
;*         <------------J-------------      -----------K----------->
DRAWOBJ	LDX	OIDESC,Y	;ABCDEFGHIJK
	LDD	OSVEL,Y
	ADDD	SSVEL
	BPL	.3S
	ADDD	OSPOS,Y		;ABC E GH J
	STD	OSPOS,Y
	BCS	.2S
	LDB	OSTATUS,Y	;    E    J
	ORB	#$80
	STB	OSTATUS,Y
	CLRB
	STB	OLEFT,Y
	STB	DDEST+1
.1S	STA	TEMP		; B  E  H J
	ADDA	OWIDTH,X
	BCS	.10S
	JMP	OBJOFF		;       H J
.2S	LDB	OSTATUS,Y	;ABC   GH
	BMI	.1S
	STA	OLEFT,Y		;A C   G
	STA	DDEST+1
	BITB	#$40
	BEQ	.11S
	ADDA	OWIDTH,X	;  C   G
	BCS	.4S
	BRA	.8S		;      G
.3S	ADDD	OSPOS,Y		;ABCD F  I K
	STD	OSPOS,Y
	BCS	.5S
	LDB	OSTATUS,Y	;ABC  F    K
	BMI	.9S
	STA	OLEFT,Y		;A C  F    K
	STA	DDEST+1
	BITB	#$40
	BNE	.4S
	ADDA	OWIDTH,X	;A    F
	BCC	.11S
	ORB	#$40		;     F
	STB	OSTATUS,Y
.4S	LDA	OSPOS,Y		;  C  F    K
	COMA
	BLE	.6S
	STA	ODWIDTH,Y	;  C  F
	EORA	#4		;* * * FOR DMA BUG
	STA	DWIDE
	BRA	.11S
.5S	LDB	OSTATUS,Y	;   D    I K
	BMI	.7S
.6S	LDA	#-1		;        I K
	STA	OSPOS,Y
	JMP	OBJOFF
.7S	STA	OLEFT,Y		;   D
	STA	DDEST+1
	LDD	OIMAGE,X
	STD	ODSOUR,Y
	STD	DSOUR
.8S	ANDB	#$3F		;   D  G
	STB	OSTATUS,Y
	LDA	OWIDTH,X
	STA	ODWIDTH,Y
	EORA	#4		;* * * FOR DMA BUG
	STA	DWIDE
	BRA	.11S
.9S	STA	TEMP		; B
	ADDA	OWIDTH,X
.10S	STA	ODWIDTH,Y	; B  E
	EORA	#4		;* * * FOR DMA BUG
	STA	DWIDE
	LDA	TEMP
	NEGA
	LDB	OHEIGHT,X
	MUL
	ADDD	OIMAGE,X
	STD	ODSOUR,Y
	STD	DSOUR
;*                  bottom-top clipping state transitions:
;*
;*                           /B\                 /A\
;*                           \ V                 \ V
;*       off                bottom ------C------> on -------E-----> off
;*      bottom <-----F------ clip <------D----- screen              top
;*            <----------------G----------------
.11S	LDB	OLPOSF,Y	;ABCDEFG
	LDA	OLPOS,Y
	BMI	.12S
	ADDD	OLVEL,Y		;A  DE G
	ADDD	SLVEL
	BMI	.13S
	CMPA	#DINHIB		;A   E
	BLO	.14S
	BRA	OBJOFF
.12S	ADDD	OLVEL,Y		; BC  F
	ADDD	SLVEL
	BPL	.14S
.13S	STA	OLPOS,Y		; B D FG
	STA	DDEST
	ADDA	OHEIGHT,X
	BCS	.15S
	BRA	OBJOFF
.14S	STA	OLPOS,Y		;A C
	STA	DDEST
	ADDA	OHEIGHT,X
	BPL	.15S
	LDA	#$7F
.15S	STA	OTOP,Y		;ABCD
	STB	OLPOSF,Y
	SEX
	ANDA	#DTFL
	ORA	#DWBL+DZSP
	STA	DCTRL
	JMP	[OPDRWVE,Y]	;execute post-display routine, uses A,B,X,U

;* off screen
OBJOFF	LDX	OCHAR,Y
	JMP	[OOFFSCR,X]	;execute scroll off screen routine, uses A,B,X,U

;* change object post draw routine
POSTCHG	LDA	OSVEL,Y		;restore s velocity > uses A,B
	SUBA	TEMP+1
	STA	OSVEL,Y
	LDD	OLVEL,Y		;restore l velocity
	SUBD	TEMP+2
	STD	OLVEL,Y
	LDD	#DOBJECT	;restore draw vector  
	STD	ODRWVEC,Y
	LDD	TEMP+4
	STD	OPDRWVE,Y
	JMP	[OPDRWVE,Y]	;execute post-display routine, uses A,B,X,U

;* draw crystal on worker	pass object wsa in Y, image descriptor in X
DCRYWOR	LDA	OSTATUS,Y	;left or right clipped? > uses A,B,X
	BITA	#$0C0            
	BNE	.1S		;yes, skip crystal
	LDA	OLPOSF,Y	;get worker flavor
	ASLA                    
	LDD	OBOTTOM,Y	;get worker screen address
	ROLA			;convert to pixel address
	ADDD	OLCENT,X	;add center offset
	CMPA	#DINHIB<<1	;crystal off top				;;Fixme was: CMPA #DINHIB!<1 
	BHS	.1S		;yes, skip crystal
	LSRA			;convert back to screen address ( bytes)
	ROR	TEMP		;save flavor
	TFR	D,X             
	JMP	[CRYANI]	;draw it, uses A,B,X
.1S	JMP	NOPOST		;skip crystal

;* crystal animation routines
CRY1ANI	LDA	CRYCOLO		;make pixel 0 random color > uses A,B,X
	STA	OEFFECT,Y
	LDA	OEFFECT+3,Y	;make pixel 1 and 2 like pixel 3
	STA	OEFFECT+1,Y
	STA	OEFFECT+2,Y
	BRA	CRYDRAW		;uses A,B,X
;*
CRY2ANI	LDA	CRYCOLO		;make pixel 1 random color > uses A,B,X
	STA	OEFFECT+1,Y
	LDA	OEFFECT+2,Y	;make pixel 0 and 3 like pixel 2
	STA	OEFFECT,Y
	STA	OEFFECT+3,Y
	BRA	CRYDRAW		;uses A,B,X
;*
CRY3ANI	LDA	CRYCOLO		;make pixel 2 random color > uses A,B,X
	STA	OEFFECT+2,Y
	LDA	OEFFECT+1,Y	;make pixel 0 and 3 like pixel 1
	STA	OEFFECT,Y
	STA	OEFFECT+3,Y
	BRA	CRYDRAW		;uses A,B,X
;*
CRY4ANI	LDA	CRYCOLO		;make pixel 3 random color > uses A,B,X
	STA	OEFFECT+3,Y
	LDA	OEFFECT,Y	;make pixel 1 and 2 like pixel 0
	STA	OEFFECT+1,Y
	STA	OEFFECT+2,Y
	BRA	CRYDRAW
;*
CRYDRAW	LDA	OEFFECT,Y	;combine pixels into 2 bytes > uses A,B,X
	RPT	4,ASLA
	ORA	OEFFECT+1,Y
	LDB	OEFFECT+2,Y
	RPT	4,ASLB
	ORB	OEFFECT+3,Y
	TST	TEMP		;flavor?
	BMI	.1S
	STD	X		;bottom flavor: draw crystal
	BRA	.2S
.1S	STA	CRIMAGE		;top flavor: setup dma image
	STB	CRIMAGE+2
	LDD	#$202!$404	;* * *FOR DMA BUG  set dma size			;;Fixme was: LDD	#202!X404 
	STD	DHIGH
	LDD	#CRIMAGE	;set dma source
	STD	DSOUR
	STX	DDEST		;set dma destination
	LDA	#DTFL+DZSP+DWBL ;draw crystal
	STA	DCTRL
.2S	LDX	#CRYSTBL	;find a random color on the crystal color table
	RANDOM	OSEED1,WORD
	ANDB	#7
	LDA	B,X
	STA	CRYCOLO		;save it
NOPOST	LDA	OSTATUS,Y	;decrement bounce counter
	BITA	#3
	LBEQ	EXEC1
	DEC	OSTATUS,Y
	JMP	EXEC1

;* paste an image on top of a screen object	pass object wsa in Y,
;*	 main image descriptor in X, paste on image descriptor in OEFFECT
	ROUTINE	PASTEON
	LDA	OSTATUS,Y	;left or right clipped? > uses A,B,U
	BITA	#$0C0
	BNE	.2S		;yes, skip extra image
	LDU	OEFFECT,Y	;get image descriptor of image to paste
	LDD	OHEIGHT,U	;get paste image height and width
	EORA	#4		;* * *FOR DMA BUG
	EORB	#4		;* * *FOR DMA BUG
	STD	DHIGH		;setup dma size
	LDD	OIMAGE,U	;get image data address
	STD	DSOUR		;setup dma source
	LDA	OLPOSF,Y	;get object flavor
	ASLA                    
	LDD	OBOTTOM,Y	;get object screen address
	ROLA			;convert to pixel address
	ADDD	OLCENT,X	;add object center offset
	SUBD	OLCENT,U	;subtract paste image center offset
	LSRA			;convert back to screen address ( bytes)
	STD	DDEST		;setup dma destination
	LDA	#DWBL+DZSP	;draw it
	BCC	.1S
	ORA	#DTFL
.1S	STA	DCTRL
.2S	JMP	NOPOST		;continue normal post draw

;* scanner object off screen
SCROFF	LDX	OCHAR,Y		;get char desc table addr > uses A,B,X
	LDD	#VSCAN		;change scanner loop address for visible loop
	TST	OVSCFLG,X	;test visible/invisible on scanner flag
	BNE	.1S
	LDD	#ISCAN		;change scanner loop address for invisible loop
.1S	LDX	[OSCAN,Y]	;get scanner task workspace
	STD	OEXEC,X
	LDD	OLVEL,Y		;compute scanner l velocity
	ADDD	#$20
	RPT	2,ASLB,ROLA
	STA	OSLVEL,X	;save scanner l velocity
	LDD	OSVEL,Y		;compute scanner s velocity
	ADDD	#$20
	RPT	1,ASLB,ROLA
	STA	OSSVEL,X	;save scanner s velocity
	PSHS	Y		;save screen workspace
	TFR	X,Y		;get scanner workspace into Y
	JSR	ERASCAN		;erase scanner image  save Y, uses A,B
	JSR	UPSCAN		;update scanner position  save Y, uses A,B,X,U
	JSR	DRWSCAN		;draw scanner image  save Y, uses A,B,X
	CLRD			;zero screen object workspace address
	STD	OSSCWSA,Y       
	PULS	Y		;restore screen workspace
;* kill object
	ROUTINE	KOBJECT
	LDX	OFLINK,Y	;> uses A,B,X,Y
	LDD	FOBJKEY		;link-out of screen list and on to free list
	STD	OFLINK,Y
	STY	FOBJKEY
	LDY	OBLINK,Y	;and set current to previous
	STX	OFLINK,Y	
	STY	OBLINK,X
	INC	SFREE		;add one free screen object
	JMP	EXEC2		;no swap

	PULLORG	ROMSAVE