;
;	 SSSS  IIIII  N   N  IIIII   SSSS  TTTTT   AAA   RRRR
;	S        I    NN  N    I    S        T    A   A  R   R
;	 SSS     I    N N N    I     SSS     T    AAAAA  RRRR
;	    S    I    N  NN    I        S    T    A   A  R  R
;	SSSS   IIIII  N   N  IIIII  SSSS     T    A   A  R   R
;
;   SINISTAR SOUND ROM (Recreation started by SynaMax - 07/14/2023)
;           Re-targeted for Macroassembler {AS} - 1/15/2024
;   
;   6800 Assembly code to build both Video Sound Rom 9 and 10
;
;   For more info on how this source code was recreated, you watch my
;   documentary on YouTube, "Rescuing the Lost Code and Stereo Sound to Sinistar":
;   https://www.youtube.com/watch?v=ZRDdKZ7V54I
;
;;---------------------------------------------------------------------
;
;   Sinistar's upright cabinet uses VSNDRM9 for mono audio, but
;   the rare cockpit version uses both VSNDRM9 and VSNDRM10 for stereo.
;
;STEREO	EQU	1
;
;   Remove the semi-colon in front of "STEREO EQU 1" to build VSNDRM10.
;
;;---------------------------------------------------------------------
;
;   To build this code, first download Macroassembler {AS}, then place
;   VSNDRM9.ASM in the same directory as ASL and P2BIN. Type in the
;   following in a terminal/command line prompt:
;
;   asl VSNDRM9.ASM -o vsndrm9.p
;
;   Then use P2BIN to generate the binary ROM file:
;
;   p2bin vsndrm9.p -l 00 vsndrm9.bin
;
;;---------------------------------------------------------------------
;
;   I originally wrote this source code for vasm, but after rewriting
;   Sinistar's game code to target Macroassembler {AS}, I realized 
;   that I can do the same for the Sound ROM source so that both can
;   be built with the same assembler.  And I feel that keeping both
;   sources together in the same repository is important. 
;
;   Retargeting the source to {AS} had the nice side-effect of making
;   the Sound ROM source actually easier to assemble, and more accurate
;   to how it was done back in 1982.  My original recreated source had
;   the Walsh synth routine taken out and assembled separately because
;   I was running into errors with vasm.  This is no longer the case, 
;   and for the first time ever, we can build Video Sound ROMs 9 and 10
;   from a single source file, just like Joust's sound rom.
;
;;---------------------------------------------------------------------
;
;   Thanks to historicalsource for preserving the source code
;   to the first four Video Sound ROMs found in the following
;   classic Williams arcade games: Defender, Stargate, Robotron,
;   and Joust.  Sinistar reuses code from all of them. For example,
;   Joust and Sinistar share the Walsh Function routine (which is
;   the most complex synth found in any of these ROMs).
;   If none of these source files existed, my reassembly of
;   Sinistar's sound code would've been impossible.
;
;   Huge thanks also goes out to Will-I-ROMS aka kaputnikGo,
;   you can view their extensive Williams disassembly files here:
;   https://github.com/kaputnikGo/WiLL-i-ROMS/blob/master/Video%20Sound%20ROMS/Video%20Sound%20ROM%209.asm
;
;   Their disassembly of Sinistar's sound ROM was extremely helpful
;   in deciphering much of the code, including unused routines.
;   Their work also led me to discovering the unused Extra Ship
;   sounds found in WALSHT and Mike Metz's corrupted ODDTBL.
;
;   Thanks to mwenge for the inspiration to attempt reassembling
;   Sinistar's sound ROM by showing that it's possible to rebuild
;   Defender's sound code with vasm.  His code fixes to VSNDRM1.SRC
;   helped me at times where I was completely stuck and had no idea
;   where to go.
;
;   A big shout out goes to Daniel Lopez for creating the
;   Defender Sound Studio javascript app.  I highly recommend checking 
;   it out.  His app was very helpful to me when I was struggling to
;   understand how the various synths work.  You can also create or 
;   import your own GWAVE sounds including Sinistar's sfx; fun stuff!
;   http://zapspace.net/defender_sound/
;
;   And last but not least, thanks to my loving spouse for their
;   patience and support during this project.
;
;;---------------------------------------------------------------------
;
;   In order to get this ROM to build correctly, several modifications 
;   had to be made.  When possible, I will point out code differences
;   between Sinistar's sound code and other Williams Sound ROMs.
;
;   Original programmer comments are usually UPPER-CASE and have one
;   semicolon (;).  My comments will have both upper and lower-cases,
;   sometimes with parenthesis and always start with two semicolons.
;									;;(like this)
;
;;---------------------------------------------------------------------

	CPU	6800							;;Macroassembler {AS} needs this

;
;
;
;
;	NAM	JOUST SOUND ROM STARTED 06/15/1982
;	SUBTTL	 
;*COPYRIGHT WILLIAMS ELECTRONICS INC. 1982
;*PROGRAMMERS: EUGENE P. JARVIS, SAM DICKER,RANDY PFEIFFER,JOHN KOTLARIK
;*		PAUL G. DUSSAULT,CARY W. KOLKER,TIM  MURPHY
;*			AND A CAST OF THOUSANDS......

;;SINISTAR SOUND DESIGNER/VIDEO SOUND ROM 9 & 10 PROGRAMMER: MIKE METZ
;;ADDITIONAL SINIBOMB (ED'S SOUND 17) SOUND DESIGN: ED SUCHOCKI

;*
;*
;*
;*SYSTEM CONSTANTS
;*
;*
ROM	EQU	$F000
SOUND	SET	$400
CKORG	EQU	$EF00			;CHECKSUM PROG ORG
ENDRAM	SET	$7F
VECTOR	EQU	$FFF8			;RESET,INT VECTORS
WVELEN	EQU	72
;*
BG1FLG	EQU	$04
NIN	EQU	5
FIF	EQU	6
TACC    EQU    	4               	;TACCATA TEMPO CONSTANT
PHANC   EQU    	3               	;PHANTOM TEMPO CONTANT
TAF     EQU    	34715>>1        	;NOTE TIMES		;;43CD
TA      EQU    	36780>>1
TBF     EQU    	38967>>1
TB      EQU    	41284>>1
TC      EQU    	43739>>1
TCS     EQU    	46340>>1
TD      EQU    	49096>>1
TEF     EQU    	52015>>1
TE      EQU    	55108>>1
TF      EQU    	58385>>1
TFS     EQU    	61857>>1
TG      EQU    	65535>>1
;; Added Constants
RAM	SET	$0000
TALKJMP EQU	$FFF3			;;(speech rom entry for ADDX)
;*
;*
;* TALKING EQUATES
;*
TALK    EQU    	$EFFD			;ENTRY TO TALKING
TALKD   EQU   	$EFFA           	;ENTRY FOR DIAGNOSTICS
;*
;*
;*GLOBALS
;*
;;
;; 	(A dummy global was added for padding.)
;;
	ORG	RAM
;;
DUMMY 	RMB 	1			;;(to help align ram)	
;;
HI	RMB	1			;RANDOM SEED 
LO	RMB	1			;RANDOM SEED
XDECAY	RMB	2						;;($03)
DUMMY2	RMB	1						;;($05)		
;*
;*
;*TEMPORARIES
;*
;;
;;	(TMPRAM originally had *, but vasm doesn't like this
;;	so $0006 was used instead.)
;;
TMPRAM	EQU	$0006			;TEMPORARY RAM
TEMPX	RMB	2			;X TEMPS
XPLAY	RMB	2						;;($08)
XPTR	RMB	2						;;($0A)
TEMPA	RMB	1			;ACCA TEMP		;;($0C)
TEMPB	RMB	1						;;($0D)
;;
;;	(LOCRAM originally had *, but vasm doesn't like this
;;	so $000E was used instead.)
;;
LOCRAM	EQU	$000E					
;*
;*GWAVE PARAMETERS
;*
	ORG	LOCRAM
GECHO	RMB	1			;ECHO FLAG		;;($0E)
GCCNT	RMB	1			;CYCLE COUNT		;;($0F)
GECDEC	RMB	1			;# OF DECAYS PER ECHO	;;($10)
GDFINC	RMB	1			;DELTA FREQ INC		;;($11)
GDCNT	RMB	1			;DELTA FREQ COUNT 	;;($12)
GWFRM	RMB	2			;WAVEFORM ADDRESS	;;($13)
;*TEMPORARY OR COMPUTED PARAMETERS
PRDECA	RMB	1			;PRE-DECAY FACTOR	;;($15)
GWFRQ	RMB	2			;FREQ TABLE ADDR	;;($16)
FRQEND	RMB	2			;END ADDR FREQ TABLE	;;($18)
WVEND	RMB	2			;WAVE END ADDR		;;($1A)
GPER	RMB	1			;PERIOD			;;($1C)
GECNT	RMB	1			;# OF ECHOES COUNTER	;;($1D)
FOFSET	RMB	1			;FREQUENCY OFFSET	;;($1E)
;*
DUMMY3	RMB	1			;;???
;*
;*GWAVE TABLES
;*
GWTAB	RMB	WVELEN			;WAVE TABLE		;;($20)
;*
;*
;*ORGAN PARAMETERS
;*

        ORG   	LOCRAM
ORGFLG	RMB	1						;;($0E)
DUR     RMB    	2               	;NOTE DURATION		;;($0F)
OSCIL   RMB    	1               	;OSCILLATORS		;;($11)
RDELAY  RMB    	60              	;RAM DELAY LOAD		;;($12)
        
;;
;;	These labels had to be modified in order for vasm to build.
;;	"$" have been replaced with "S".
;;
	ORG	LOCRAM+1
FREQS	RMB	1			;START FREQUENCY	;;($0F)
CSFRQ	RMB	1			;CYCLES AT FREQUENCY
DSFRQ	RMB	1			;DELTA FREQUENCY
ESFRQ	RMB	1			;END FREQUENCY
CSAMP	RMB	1			;CYCLES AT AMPLITUDE
DSAMP	RMB	1			;DELTA AMPLITUDE
CSAMPS	RMB	1			;CYCLE COUNTER
CSFRQS	RMB	1			;CYCLE COUNTER		;;($16)
DUMMY4	RMB	1			;;(more padding)
AMP0	RMB	1						;;($18)	
	
;*
;*
;*
;*NOISE/CROWD ROAR ROUTINE PARAMETERS
;*
	ORG	LOCRAM
DECAY	RMB	1						;;($0E)
NAMP	RMB	1						;;($0F)
CYCNT	RMB	1						;;($10)
NFRQ1	RMB	2						;;($11)
NFFLG	RMB	1						;;($13)
LFREQ	RMB	1						;;($14)
DFREQ	RMB	1						;;($15)
GALPAM	EQU	*						;;($16)
CYCNT2	RMB	1						;;($16)
NAMP2	RMB	1						;;($17)
DECAY2	RMB	1						;;($18)
NFFLG2	RMB	1						;;($19)
NFR2	RMB	1						;;($1A)
GALCNT	RMB	1						;;($1B)
WHIS	RMB	1			;CROWD ROAR AMP
WFRQ	RMB	1			;CROWD WHISTLE FREQ
WCNT	RMB	1			;WHISTLE PASSCOUNTER
PTRHI	RMB	2			;WHIS ADR PTR		;;($1F)
WFRQ2	RMB	1						;;($21)
WCNT2	RMB	1						;;($22)
CURVAL	RMB	1			;WHISTLING NOISE OUTPUT
ATP	RMB	1			;INTERM NOISE VAL
MINWIS	RMB	1			;MIN WHISTLE FREQ
CY2	RMB	1			;NOISE CYCLE COUNTER
DFRQ	RMB	1			;WHISTLE FREQ CHANGE
DFRQ2	RMB	1			;INIT WHISTLE FREQ CHANGE
NNOIS	RMB	1			;NEXT NOISE VALUE	;;($29)
NFRQ	RMB	1			;NOISE FREQ		;;($2A)
NFRQ2	RMB	1			;INIT NOISE FREQ	;;($2B)
RCNT2	RMB	1						;;($2C)
	
;*
;*FILTERED NOISE ROUTINE PARAMETERS
;*
        ORG    LOCRAM
FMAX    RMB    	1               	;MAXIMUM_FREQUENCY	;;($0E)
FHI     RMB    	1               	;FREQUENCY		;;($0F)
FLO     RMB    	1						;;($10)
SAMPC   RMB    	2                	;SAMPLE COUNT		;;($11)
FDFLG   RMB    	1                	;FREQUENCY DECREMENT FLAG ;;($13)
DSFLG   RMB    	1                	;DISTORTION FLAG	;;($14)
        
;*
;*
;* MAIN PROGRAM
;*
	ORG	ROM
	FCB	$AA			;CHECKSUM BYTE
;*	
;*
SETUP	SEI				;SET INTERRUPT MASK
	LDS	#ENDRAM			;INITIALIZE STACK POINTER
	LDX	#SOUND			;INDEX TO PIA
	CLR	1,X			;ACCESS DDRA
	CLR	3,X			;ACCESS DDRB
	LDAA	#$FF			;PA0-PA7
	STAA	0,X			;SET SIDE A AS OUTPUTS
	LDAB	#ENDRAM+1		;;(new instruction) (used for clearing RAM)
	STAB	2,X			;;(only found in Sinistar/Bubbles) (Joust has CLR 2,X)
	LDAA	#$37			;CB2 LOW, IRQ ALLOWED
	STAA	3,X			;PROGRAM B CONTROL REG
	LDAA	#$3C			;CA2 SET INIT HIGH, NO IRQS
	STAA	1,X			;PROGRAM A SIDE
	STAB	2,X			;;(new instruction) (store in port B PIA1)
	LDX	#ENDRAM
RAMCLR	CLR 0,X				;;(wipe out the RAM)
	DEX
	BNE	RAMCLR			;;(are we done yet?)
	LDAA	#$3C			;;(grab number for the random generator)	
	STAA	HI			;START RANDOM GENERATOR
	CLI				;CLEAR INTERRUPTS
	BRA	*			;WAIT FOR INTERRUPT
;*
;*ORGAN TUNE
;*
ORGASM	CLR 	ORGFLG
	STAA	TEMPA			;TUNE NUMBER
	;;
	PSHA				;;(this is a new instruction)
	;;
	LDX	#ORGTAB
ORGNT2	LDAA	0,X			;TUNE TABLE LENGTH
	BEQ	ORGNT5			;INVALID TUNE
	DEC 	TEMPA
	BEQ	ORGNT3
	INCA
	JSR	ADDX
	BRA	ORGNT2
ORGNT3	INX
	STX	XPTR			;NOTE POINTER
	JSR	ADDX
	STX	XPLAY			;TUNE END
	LDX	XPTR
ORGNT4	LDAA	0,X			;TUNE LOOP
	STAA 	OSCIL			
	LDAA	1,X
	LDX	2,X
	STX	DUR				
	BSR	ORGANL
	LDX	XPTR
	INX
	INX
	INX
	INX 
	STX	XPTR
	CPX	XPLAY
	BNE	ORGNT4
ORGNT5	PULA				;;(In VSNDRM3, this is just an RTS)
	BRA	BGTEST
;*
;*ORGAN NOTE
;*4 BYTES(MODE,OSCILLATOR MASK HI+1,LO+1,NOTE#)				
;*
;*ORGAN LOADER
;*OSCIL=OSCILLATOR MASK, ACCA=DELAY, DUR=DURATION
;*
ORGANL  LDX	#RDELAY			;;(There's some changes here from VSNDRM3)
LDLP	CMPA	#0			;;(original was:        SUBA	#2)
	BEQ 	LD1			;;(original was: LDLP	BLS	LD1)
	CMPA	#3
	BEQ	LD2
	LDAB	#1			;NOP
	STAB	0,X
	INX
	SUBA	#2
	BRA	LDLP
LD2	LDAB	#$91			;CMPA 0
	STAB	0,X
	CLR	1,X
	INX
	INX
LD1	LDAB	#$7E			;JMP START2
	STAB	0,X
	LDAB   	#ORGAN1>>8 		;;(original was: LDAB #ORGAN1!>8    ;MSB)		
	STAB	1,X
	LDAB  	#ORGAN1&$FF		;;(original was: LDAB #ORGAN1!.$FF  ;LSB)
	STAB	2,X
;*
;*ORGAN ROUTINE
;*DUR=DURATION, OSCILLATOR MASK
;*
ORGAN	LDX	DUR
ORGAN1	CLRA 
	FCB	$F6			;LOAD B EXTND TEMPB
	FDB	TEMPB	
	INCB	
	STAB	TEMPB
	ANDB	OSCIL			;MASK OSCILLATORS
	LSRB
	ADCA	#0
	LSRB
	ADCA	#0
	LSRB
	ADCA	#0
	LSRB
	ADCA	#0
	LSRB
	ADCA	#0	
	LSRB
	ADCA	#0
	LSRB
	ADCA	#0	
;; (Robotron's VSNDRM3 has an ABA opcode here)	
	ASLA
	ASLA
	ASLA
	ASLA		
	ASLA
	STAA	SOUND	
	DEX	
	BEQ	ORGAN2			;NOTE OVER?
	JMP	RDELAY	
ORGAN2	RTS  
;*
;* INTERRUPT PROCESSING
;*
;;
;; 	The sound IDs referenced in the game logic's sound calls
;; 	are actually inverted so $BE = 1, $BD = 2, $BC = 3, etc. 
;; 	We start by loading the input trigger at $0402, invert it,
;; 	then AND it until we get the final number.
;;
IRQ	LDS	#ENDRAM			;RE-INITIALIZE STACK
	LDAA	SOUND+2			;GET INPUT TRIGGER
	CLI				;NOW ALLOW IRQS
	COMA 				;INVERT INPUT
	ANDA 	#$1F			;MASK GARB
	BSR	QMESG			;;(start checking sound ID)
;;
;; 	In the original VSNDRM source code files, the interrupts have
;; 	labels that aren't very descriptive (such as IRQ000).
;; 	To better understand how the interrupts are processed,
;; 	I took the liberty of renaming the labels in this section.
;;
;; 	Some sound effect names have a "Q" in front.  These are symbols
;;	taken from the game logic source code.
;;
;;---------------------------------------------------------------------
;;
;; 	***BGTEST***
;; 	When no sound is playing, BGTEST is constantly
;; 	testing to see if the BG1FLAG is on.  When the weird
;; 	drone flag is enabled, this ensures that it continues 
;; 	playing forever until an interrupt breaks the loop.
;;	When the current sound finishes, we go back to checking this flag.
;;
;;	Sound trigger #4 must be called to mute this sound.
;;
BGTEST	TST 	BG1FLG			;;(Check if drone is on)
	BEQ	BGTEST			;;(No? Check again!)
	JMP 	DROSYN			;;(Yes? Go make some noise)
;;---------------------------------------------------------------------
;;
;;	***SINISTAR SOUND SELECT***
;;
;;	A = Sound ID
;;
;;	The sound effects are cued up by comparing A register's value.
;; 	If it's a bigger number, then we check for the next sound.
;; 	Otherwise, if the value matches, then we proceed with getting
;; 	the synth routine started.
;;
;;---------------------------------------------------------------------
;;
;;  1) WARNING CUE
;;
QMESG	CMPA	#$01			;;(what sound ID is this?)
	BGT 	SINROAR			;;(if it's a bigger number, then check for the next sound)
	JMP 	ORGASM			;;(otherwise, play the organ warning cue)
;;---------------------------------------------------------------------
;;
;;  2) SINISTAR ROAR
;;
SINROAR	CMPA	#$02			;;(check sound ID)
	BGT 	QNEWSH			;;(bigger number? keep going down the line, buddy)
;;
;; 	Sinistar speech is handled outside of the sound rom.
;; 	Any jumps to $EFFD are speech calls that are then handled by code
;; 	located at $EE00 (found in speech IC4).
;;
;; 	Amazingly, because VSNDRM1 is based off of Firepower's sound ROM,
;; 	Defender's sound code has the same speech routines Sinistar uses.
;;		
;;  	While writing the documentation here, I discovered a really awesome
;;	"easter egg"  that Mike Metz left in.  If you disconnect the speech
;; 	board, brand new sounds will play instead of Sinistar's taunts.
;;
;;	During any dialouge, if the $7E opcode is not found, a generic
;;	error sound plays instead (ERROR).
;;
;;	However, if no opcode is found during Sinistar's roar, a new
;;  	LOUD Walsh Function sound plays that tries to emulate the
;;	scary scream (ERROAR).  I wonder if this feature was added so that
;;	the game can still work without the speech board.
;;
;*
;* CHECK FOR PRESENCE OF TALKING PROGRAM
;*
	LDAB    TALK            	;CHECK FOR PROGRAM TO BE THERE
        CMPB    #$7E            	;IS IT?
        BNE     ERROAR          	;NO, SKIP THE TALKING
	LDAA	#$09			;;(load roar speech phrase)
        JMP     TALK            	;GO PLAY OUT 1 PHRASE 
;;---------------------------------------------------------------------
;;
;;  3) EXTRA SHIP / ERROR ROAR
;;
QNEWSH	CMPA	#$03			;;(check sound ID)
	BGT	BGMUTE			;;(if not, keep going)
;;
;;	The Walsh Function sound machine is normally only used for
;;  	the Extra Ship sound.  But if the speech board is disconnected,
;;	then ERROAR is called whenever the Sinistar roars.  Both QNEWSH
;;  	and ERROAR use the A register as the Walsh Table offset.
;;
;;	After subtracting by 2, if A = 0 then play ERROAR.
;;	If A = 1, play QNEWSH.
;;
;; 	In the cockpit-exclusive Video Sound ROM 10, the Walsh synth is
;;	muted by replacing the SUBA and JMP instructions with an RTS.
;; 
ERROAR	IFNDEF	STEREO
	SUBA 	#$02			;;(suba to get WALSHT offset)
	JMP	WALSH			;;(go to Walsh synth)
	ELSE
	RTS				;;(nevermind, skip it)
	ENDIF
;;---------------------------------------------------------------------
;;
;;  4) SHUT UP UNUSED DRONE
;;
BGMUTE	CMPA	#$04
	BGT	DRONE			
	CLR	BG1FLG
	RTS
;;---------------------------------------------------------------------
;;
;;  5) UNUSED DRONE
;;
DRONE	CMPA	#$05			;;(check sound ID)
	BGT	HUNCOW			
	JMP	DRONELD	
;;---------------------------------------------------------------------
;;
;;  6) "I HUNGER COWARD"
;;		
HUNCOW	CMPA	#$06
	BGT	IMPACT			
	LDAB    TALK
        CMPB    #$7E 
	BEQ	HANGRY		
	JMP	ERROR			
HANGRY	LDAA	#$08
        JMP     TALK 
;;---------------------------------------------------------------------
;;
;;  7) IMPACT (QPLDIE)
;;
IMPACT	CMPA	#$07		
	BGT	XPLODE			
	JMP	GUNSHOT
;;---------------------------------------------------------------------
;;
;;  8) PLAYER EXPLOSION (QPLDIE)
;;		
XPLODE	CMPA	#$08
	BGT	NOISE			
	JMP	C4NNON	
;;---------------------------------------------------------------------
;;
;;  9 & 10) TWO UNUSED NOISE EFFECTS
;;		
NOISE	CMPA	#$0A
	BGT	RUNCOW			
	SUBA	#$09
	JMP	NOISELD			
;;---------------------------------------------------------------------
;;
;;  11) "RUN COWARD"
;;	
RUNCOW	CMPA	#$0B
	BGT	QBANG			
 	LDAB    TALK
        CMPB    #$7E
	BNE	ERROR			
	LDAA	#$06
 	JMP   	TALK
;;---------------------------------------------------------------------
;;
;;  12) BANG (Explosion used for Enemies and Planetoids)
;;
QBANG	CMPA	#$0C
	BGT	IAMSINI			
	JMP	CANNON		
;;---------------------------------------------------------------------
;;
;;  13) "I AM SINISTAR"
;;		
IAMSINI	CMPA	#$0D
	BGT	BEWARE			
 	LDAB    TALK
        CMPB    #$7E
	BNE	ERROR			
	LDAA	#$02
 	JMP   	TALK
;;---------------------------------------------------------------------
;;
;;  14) "BEWARE I LIVE"
;;
BEWARE	CMPA	#$0E
	BGT 	HUNGER			
 	LDAB    TALK
        CMPB    #$7E
	BNE	ERROR		
	LDAA	#$03
 	JMP     TALK
;;---------------------------------------------------------------------
;;
;;  15) "I HUNGER"
;;
HUNGER	CMPA	#$0F
	BGT	COWARE			
 	LDAB    TALK
        CMPB    #$7E
	BNE	ERROR			
	LDAA	#$04
 	JMP     TALK
;;---------------------------------------------------------------------
;;
;;  19) "BEWARE COWARD"
;;
COWARE	CMPA	#$13		
	IFNDEF	STEREO	
	BNE 	GWAVSFX	
	ELSE
	BNE	GDELAY
	ENDIF
 	LDAB    TALK
        CMPB    #$7E
	BNE	ERROR		
	LDAA	#$05
 	JMP     TALK
;;---------------------------------------------------------------------
;;
;;  STEREO SEPARATION DELAY (FOR VSNDRM10 ONLY)
;;
;;	In order to create the stereo separation effect for GWAVE
;;	sounds, the rear channel has to start playing shortly after the
;;	front channel.
;;
;; 	This was done by loading $10FF into the X register and then
;; 	decrementing X before continuing.  This adds around
;;	0.097 seconds of delay.
;;
;; 	Changing it to a max value of $FFFF increases the delay to
;;	around 0.644 to 0.692 seconds.
;;
;;	Looking at the disassembly for the Gorgar sound ROM, the same
;;	trick was used to add a delay between the continuous heartbeats.
;;	The instruction can be found at $FA3C and uses $3200 as the
;;	delay amount instead of $10FF.
;;
;; 	These instructions also creates the side effect of muting the
;;	bounce sound effect entirely since it plays so briefly.
;;
GDELAY	IFDEF	STEREO
	LDX	#$10FF
DELAY	DEX
	BNE	DELAY
	ENDIF
;;---------------------------------------------------------------------
;;
;;  16-18, 20-28) GWAVE SOUND EFFECTS
;;
;;	Once the time delay for the stereo separation has finished,
;;	we check for GWAVE sounds.  Sound ID $AF is the first GWAVE
;;	sound in the list, and A register is the offset used to select
;;	the specific parameters from the GWAVE table.
;;
;;	To play all the different GWAVE sounds (including unused ones),
;;	type this in MAME's debugger to trigger the Sinibomb sound ($AF)
;;	when inserting a coin:
;;
;;	maincpu.rw@4dfd = b0af
;;
;;	Then change the value at $F18A so that the soundcpu can pull
;;	up a different sound:
;;
;; 	soundcpu.rb@f18a = 10 (UNUSED WARNING?)
;; 	soundcpu.rb@f18a = 0F (SINISTAR SPEECH ERROR)
;; 	soundcpu.rb@f18a = 0E (AF = SINI-BOMB) (Original value)	(QSFire)
;; 	soundcpu.rb@f18a = 0D (AE = PLAYER FIRE)		(QFIRE)
;; 	soundcpu.rb@f18a = 0C (AD = WARRIOR FIRE)		(QWFIRE)
;; 	soundcpu.rb@f18a = 0B (UNUSED ALTERNATE BOUNCE)
;; 	soundcpu.rb@f18a = 0A (AB = BOUNCE)			(QBOUNCE)
;; 	soundcpu.rb@f18a = 09 (AA = WORKER CRYSTAL PICKUP)	(QWorkCr)
;; 	soundcpu.rb@f18a = 08 (A9 = UNUSED "LANDER" FIRE) 	(FOUND IN DEFENDER VSNDRM1 AS DP1V)
;; 	soundcpu.rb@f18a = 07 (A8 = CRYSTAL BOMB-BAY FULL)	(QFulCr)
;; 	soundcpu.rb@f18a = 06 (A7 = CRYSTAL FLASHING) 		(QCRYFLA)
;; 	soundcpu.rb@f18a = 05 (A6 = PIECE ADDED / GAME OVER)	(QWorkSi/QGamEnd) (Also used in Splat!)
;; 	soundcpu.rb@f18a = 04 (A5 = UNUSED BLASTER "ENERGY CRITICAL" ALARM)
;; 	soundcpu.rb@f18a = 03 (A4 = PLAYER START CUE) 		(QPlStr)
;; 	soundcpu.rb@f18a = 02 (A3 = PLAYER CRYSTAL PICKUP)	(QPlayCr)
;;
;; 	There is a glitch in MAME's debugger that prevents $0B
;; 	from showing up in RAM.  Another way play these sounds is to
;;	set up a breakpoint at $F7E5, then type in:
;;	do x = [SVTAB address]
;;
GWAVSFX	CMPA	#$1C			
	BGT 	RUNRUN		
	SUBA	#$0E
PLAYSFX JSR	GWLD			
	JMP	GWAVE	
;;---------------------------------------------------------------------
;;
;;  29) "RUN RUN RUN"
;;		
RUNRUN	CMPA	#$1D
	BGT 	SHUTUP		
 	LDAB    TALK
        CMPB    #$7E
	BNE	ERROR				
	LDAA	#$07
 	JMP    	TALK
;;---------------------------------------------------------------------
;;
;;  31) SHUT UP SINISTAR
;;	
;;	This is used to mute Sinistar speech.
;;
SHUTUP 	RTS 
;;---------------------------------------------------------------------
;;
;;  NO SPEECH ERROR NOISE
;;
;;	If the speech board is disconnected for VSNDRM9, then play the
;;	Sinistar Error noise.  Since there's no speech board attached
;;	to VSNDRM10's sound board, an RTS replaces the error noise,
;;	muting the sound call entirely.
;;		
	IFNDEF	STEREO		
ERROR	LDAA	#$01
	JMP	PLAYSFX
	ELSE
ERROR	RTS
	ENDIF
;;---------------------------------------------------------------------
;*
;* ADD A TO INDEX REGISTER
;*
ADDX	STX	XPLAY
	ADDA	XPLAY+1
	STAA	XPLAY+1
	LDAA	XPLAY
	ADCA	#0
	STAA	XPLAY
ADDX1	LDX	XPLAY
	RTS
;*
;* DIAGNOSTIC PROCESSING HERE
;*
NMI	SEI
	LDS	#ENDRAM			;RESET THE STACK
	LDX	#$FFFF
	CLRB
NMI1	ADCB	0,X
	DEX
	CPX	#$F000	
	BNE	NMI1
	CMPB	0,X			;;(The checksum should be $AD, but
					;;because it's defined as $AA, the
					;;the checksum fails.)
	BEQ	NMI2
	WAI				;;(test failed, wait forever)
NMI2	JSR	DIAGNOI			;;(play unused Diagnoistic Synth Noise)
	BRA 	NMI			;;(loop forever)
;;---------------------------------------------------------------------
;*
;* NOTE DEFINITIONS AND ALL THAT JAZZ
;*
AF1	EQU	$F847
A1	EQU	$F83F
BF1	EQU	$F837
B1	EQU	$F830
C1	EQU	$F829
CS1	EQU	$F823
D1	EQU	$F81D
EF1	EQU	$F817
E1	EQU	$F812
F1	EQU	$F80D
FS1	EQU	$F808
G2	EQU	$F804
AF2	EQU	$7C47
A2	EQU	$7C3F
BF2	EQU	$7C37
B2	EQU	$7C30
C2	EQU	$7C29
CS2	EQU	$7C23
D2	EQU	$7C1D
EF2	EQU	$7C17
E2	EQU	$7C12
F2	EQU	$7C0D
FS2	EQU	$7C08
G3	EQU	$7C04
AF3	EQU	$3E47
A3	EQU	$3E3F
BF3	EQU	$3E37
B3	EQU	$3E30
C3	EQU	$3E29
CS3	EQU	$3E23
D3	EQU	$3E1D
EF3	EQU	$3E17
E3	EQU	$3E12
F3	EQU	$3E0D
FS3	EQU	$3E08
G4	EQU	$3E04
AF4	EQU	$1F47
A4	EQU	$1F3F
BF4	EQU	$1F37
B4	EQU	$1F30
C4	EQU	$1F29
CS4	EQU	$1F23
D4	EQU	$1F1D
EF4	EQU	$1F17
E4	EQU	$1F12
F4	EQU	$1F0D
FS4	EQU	$1F08
;; (Actual Sinistar Notes)
AF7	EQU	$0347
C7	EQU	$0329
E7	EQU	$0312
;;
RS	EQU	$0004
TR	EQU	TG
;*
;* ORGAN TUNE TABLE
;* OSCILLATOR MASK(1),DELAY(1),DURATION(2)
;*
ORGTAB  FCB  	3*4
;;
;;	(Listed as A Flat in 7th octave (AF7), but it sounds like a G6 note)
;;	$03 = octave, $47 = AF, $05 = delay?, $FC = duration?
;;
        FDB	AF7,$05FC
;;
;;	(Listed as E in 7th octave (E7), but it sounds like a D#7 note)
;;	$03 = octave, $12 = E, $11 = delay?, $F0 = duration?
;;
        FDB	E7,$11F0
;;
;;	(Listed as C in 7th octave (C7), but it sounds like a B6 note)
;;	$03 = octave, $29 = C, $07= delay?, $1E = duration?
;;
        FDB	C7,$071E
;;
;;	Organ note durations are calculated, so it's currently unknown
;;	how to get to these numbers.  The first word for each note is
;;	the Note Time shifted to the right by 1 (TAF, TC, TE).
;;	43CD / ? / ? = 05FC
;;	6BA2 / ? / ? = 11F0
;;	556D / ? / ? = 071E
;;
;;	An example of note durations from VSNDRM3.SRC (Robotron):
;;FIFTH	EQU	*
;;FIF	EQU	6
;;	FDB	G2,TG/FIF/4
;;	FDB	RS,TR/FIF/4
;;	FDB	G2,TG/FIF/4
;;	FDB	RS,TR/FIF/4
;;	FDB	G2,TG/FIF/4
;;	FDB	RS,TR/FIF/4
;;	FDB	EF1,TEF/FIF/2*7
;;	FCB	TUNEND-NINTH
;;
;;	To play this in Defender Sound Studio import the following code:
;;{
;;  "sound": "Music",
;;  "params": ["03,71,1532,\n03,18,4592,\n03,41,1822"]
;;}
;;
;;---------------------------------------------------------------------
;;
;;	***WALSH FUNCTION SOUND MACHINE*** 
;;
;;	(This is where the Walsh Function synth code begins. This routine
;;	is huge and accounts for almost 30% of the entire ROM.  Because
;;	the Walsh Function isn't used in the cockpit rear sound board ROM,
;;	the routine gets skipped completely and never runs!  This means you
;;	could technically build VSNDRM10 without the Walsh routine, but the
;;	checksum would be different.)
;;
;;---------------------------------------------------------------------


	RADIX	10				;;Decimal values ahead

;*SYSTEM CONSTANTS
;*
;;STEREO	EQU	1			;;(use this to build VSNDRM10)
;*
;*	NAM	WALSH FUNCTION SOUND MACHINE V2
;
;* T. MURPHY  11/10/81

MINPER	EQU	25			;6*25 = 150 MICROSECS IS MIN SAMPLE PERIOD
SOUND	SET	$400

WORG						;;Make Walsh routine start here
	ORG	0

	RMB	8			;GLOBALS

FCMDPT	RMB	2			;PTR TO CURRENT FILTER COMMAND (USER INITIALIZED)
PCMDPT	RMB	2			;SAME FOR PITCH PROGRAM
SMPPER	RMB	2			;HI BYTE * 6 IS SAMPLE DELAY
HRMTBL	RMB	2			;PTR TO HARMONIC FN VALUE TABLE

WAVSRT	RMB	16			;WAVEFORM

PERVEL	RMB	2			;ADDED TO SMPPER EACH WAVE (PITCH CONTROL)
GLBPRO	RMB	1			;GLOBAL PERIOD OFFSET
TMPPER	RMB	1			;= SMPPER + GLBPRO
PERACM	RMB	1			;USED TO CALCULATE SMALL PITCH ADJUSTS

PWVCNT	EQU	*			;#OF WAVES TO PLAY BEFORE NEXT PITCH CMD (P PROGRAM)
PSTK	RMB	2			;TOP OF PITCH RETURN/COUNT STACK
PWAVPT	RMB	2			;PTR TO CURRENT SAMPLE BEING PLAYED
PCMD	RMB	1			;CURRENT PITCH CMD
PTEMP	RMB	2

FVECT	RMB	3			;JUMP TO CURRENT FILTER STATE (FILTER PGM CONTROL)
FCNT	EQU	*			;MISC CTR, WAVE DELAY IF <0
FSTK	RMB	2			;TOP OF FILTER RETURN/COUNT STACK
HAPTR	RMB	2			;PTR TO AMPLITUDE OF CURRENT HARMONIC

FWVPTR	RMB	2			;PTS TO WAVE PT BEING ALTERED (FILTER GUTS)
HAMP	RMB	1			;CURRENT HARMONIC AMPLITUDE
FMSK	RMB	1			;BIT MASK SELECTS HARMONIC FN VALUE
;*			NEXT 3 MUST BE IN ORDER
FNHI	RMB	1			;HOLDS CURRENT HARMONIC FN VALUES AS BITS
FNLO	RMB	1			;ALSO USED AS TEMPORARIES
FCMD	RMB	1			;CURRENT INSTRUCTION BEING EXECUTED

FBTM	EQU	*-3			;FILTER STACK GROWS UP

	ORG	95
		
PBTM	EQU	*			;PITCH STACK GROWS DOWN

	RMB	1			;ADD2HA FOR CONST WAVE
ADD2HA	RMB	8			;ADD ADD2HA(8-I)*HARM(I) TO WAVE
CNAMP	RMB	1			;CURRENT AMP OF CONST FUNCTION
CURHA	RMB	8			;CURHA(8-I) = <WAVE!HARM(I)>

ENDRAM	SET	127

	ORG 	WORG

;	SUBTTL	WAVE PLAYER AND PITCH MODIFICATION

;* PLAY A SAMPLE, REMAINING DELAY IN B.  TOTAL DELAY = MIN (60,B*6) MICS.

NTHRVC	SUBB	#13			;LOOP DELAY IS 78 CYCLES
	PSHB
	JSR	FVECT			;(62)
	PULB

NXTSMP	CMPB	#20			;CALL HERE
	BHI	NTHRVC			;MODIFY WAVE IF WE HAVE ENOUGH TIME

	NOP
	LDAA	PERACM
	ADDA	PERVEL+1
	STAA	PERACM
	ADCB	#-10			;MINIMUM DELAY + FRACTION

	DECB				;WASTE SMALL TIME
	BPL	*-1

	LDAA	PWAVPT+1		;PT TO NEXT BYTE OF 16 BYTE WAVE
	INCA
	ANDA	#15
	ORAA	#WAVSRT			;! WAVSRT MUST BE DIVISIBLE BY 16 !
	STAA	PWAVPT+1

	LDX	PWAVPT
	LDAB	0,X
	STAB	SOUND

	ANDA	#15			;0 	;IFF RESTARTING WAVE
	RTS
	
;* PLAYS WAVE AND ALTERS PITCH ACCORDING TO PITCH CMDS.
;* SMPPER IS INITIAL PITCH,  PCMDPT IS START PITCH PROGRAM,
;* FCMDPT IS START WAVE MODIFIER (FILTER) PROGRAM.

WSM	CLRA
	LDX	#WAVSRT
	LDAB	#CURHA+8-WAVSRT
.1S	STAA	0,X									;;Fixme was: 1$
	INX
	DECB
	BNE	.1S
	LDAB	#PBTM
	STAB	PSTK+1
	LDAB	#FBTM
	STAB	FSTK+1
	LDAB	#126
	STAB	FVECT
	LDX	#NXTFCM
	STX	FVECT+1
	LDAB	SMPPER
	STAB	TMPPER
	
PPLPE1	SUBB	#3
PPLPE2	JSR	NXTSMP
	INX

PPLP	LDAB	TMPPER
	SUBB	#2			;LOOP DELAY IS 18-6 = 12
	JSR	NTHRVC
	BNE	PPLP			;ESCAPE ON WAVE BOUNDARY

	LDAB	PERVEL			;7 (ALL TIMES ARE SINCE RTS FROM LAST NXTSMP)
	LDAA	PERVEL+1
	ADDA	SMPPER+1		;UPDATE SAMPLE RATE ONCE EACH WAVE PLAY
	ADCB	SMPPER
	STAA	SMPPER+1
	STAB	SMPPER			;24

	ADDB	GLBPRO
	LDAA	#MINPER			;AVOID SYNC ERRORS BY LIMITING PITCH.
	CBA				;MAX. PITCH ALLOWS AT LEAST 1 FILTER
	BCC	*+3			;CALL PER SAMPLE.
	FCB	129			;;(This disassembles as CMPA #$16)
	TAB				;;
	STAB	TMPPER			;41
	NOP
	SUBB	#9
	JSR	NXTSMP			;54

	LDAA	FCNT			;COUNT WAVE PLAYS FOR FILTER
	TAB				;(ONLY IF <0)
	ASLA
	ADCB	#0
	STAB	FCNT			;13

	LDAB	TMPPER
	SUBB	#5
	LDAA	PWVCNT
	BPL	PAWAKE

	INC	PWVCNT			;UPDATE DELAY COUNT IF <0
	NOP
	BRA	PPLPE1			;37

PAWAKE	DECB				;ELSE WE ARE ALIVE
	JSR	NXTSMP			;36

	LDX	PCMDPT
	LDAA	0,X
	BPL	PPLP1			;MOST CMDS ARE >0

	CMPA	#128
	BEQ	STOPR			;19	EXCEPT FOR END = 128

	INCA
	STAA	PWVCNT			;OR A NEGATIVE NUMBER -N
	INX				;WHICH WAITS N WAVE PLAYS
	FCB	-1,0,PCMDPT		;BEFORE FETCHING THE NEXT COMMAND

PPLP35	LDAB	TMPPER
	SUBB	#6
	JMP	PPLPE1			;43

PPLP1	INX
	LDAB	0,X			;GET NEXT CMD STRING BYTE ON STACK
	PSHB
	INX
	STX	PCMDPT			;35

	STAA	PCMD
	ANDA	#$70
	LSRA
	LSRA
	LSRA
	CLRB

	ADDA	#PCMDJT&255
	ADCB	#PCMDJT/256
	STAA	PTEMP+1
	STAB	PTEMP			;61

	LDAB	TMPPER
	LDAB	TMPPER
	SUBB	#13
	JSR	NXTSMP			;78

	CLRB
	LDX	PTEMP			;EXECUTE CMD
	LDX	0,X
	JMP	0,X			;16
		
;* PITCH COMMAND ROUTINES.  UNLESS OTHERWISE STATED, N IS A SIGNED 8 BIT
;* NUMBER = BYTE FOLLOWING OPCODE.

;* LDP N  IS  SMPPER := N,  ADP N  IS SMPPER := SMPPER + N

LDPR	LDAA	PCMD			;BIT 0 = 1 FOR LOAD
	ASRA
	SBCB	#0
	ANDB	SMPPER
	PULA
	SBA
	ADDA	SMPPER
	STAA	SMPPER			;39
	INX
LDPRE	LDAB	TMPPER
	SUBB	#10
	JMP	PPLPE2			;51

;* LDO N IS  GLBPRO := N,  ADO N IS  GLBPRO := GLBPRO + N

LDOR	LDAA	PCMD			;BIT 0 = 1 FOR LOAD
	ASRA
	SBCB	#0
	ANDB	GLBPRO
	PULA
	SBA
	ADDA	GLBPRO
	STAA	GLBPRO
	BRA	LDPRE

;* ESC EXECUTES MACHINE LANGUAGE IMMEDIATELY FOLLOWING

ESCR	PULA
	LDX	PCMDPT
	DEX
	JMP	0,X			;32

;* STOP EITHER REPEATS A CALL, RETURNS FROM A CALL, OR ENDS SOUND.

STOPR	LDAA	PSTK+1
	CMPA	#PBTM
	BMI	*+3			;28
	RTS

	LDAB	TMPPER
	SUBB	#7
	JSR	NXTSMP			;42
 
	LDX	PSTK
	DEC	2,X
	BMI	PRET			;15	DONE

	LDX	0,X			;ELSE REPEAT
	LDAA	0,X
	PSHA
	INX
	STX	PCMDPT			;39

	FCB	-10,0,TMPPER
	SUBB	#9
	JSR	NXTSMP			;54

	BRA	PTORE1

PRET	LDX	0,X
	INX
	STX	PCMDPT
	LDAA	PSTK+1
	ADDA	#3
	STAA	PSTK+1

	LDAB	TMPPER
	SUBB	#7
	NOP
	JMP	PPLPE1			;49

;* LDV N IS  PERVEL := N,  ADV N IS  PERVEL := PERVEL + N
;* IN THIS CASE  N IS A 12 BIT NUMBER, THE UPPER 4 BITS OF WHICH
;* ARE LO 4 BITS OF THE OPCODE BYTE.

ADVR	INX
	BRA	*+6

LDVR	STAB	PERVEL			;CLEAR PERVEL FOR LOAD
	STAB	PERVEL+1 		;24

	LDAB	PCMD
	ANDB	#15			;SIGN EXTEND
	ADDB	#-8
	EORB	#-8			;34

	PULA
	ADDA	PERVEL+1
	ADCB	PERVEL
	STAA	PERVEL+1
	STAB	PERVEL			;52

	FCB	-10,0,TMPPER
	SUBB	#9
	JMP	PPLPE1			;61	

;* DO R,N  CALLS RTN AT *+N  R TIMES.

PDOR	LDAA	PSTK+1
	SUBA	#3
	STAA	PSTK+1			;25

	LDX	PSTK
	LDAA	PCMDPT+1		;STACK ENTRY PTS TO DISPLACEMENT
	LDAB	PCMDPT
	ADDA	#-1
	ADCB	#-1
	STAB	0,X
	STAA	1,X			;53
	LDAB	PCMD			;LO OPCODE BITS ARE REPEAT CNT
	ANDB	#15
	STAB	2,X			;64

	LDAB	TMPPER
	SUBB	#12
	JSR	NXTSMP			;78

	INX				;SYNC W/NEXT RTN
PTORE1	INX
	INX
	CLRB
	NOP

;* TO N  SETS LOC TO BE *+N.

PTOR	PULA				;20
	ASRA
	ROLA
	SBCB	#0
	ADDA	PCMDPT+1
	ADCB	PCMDPT	
	STAA	PCMDPT+1
	FCB	-9,0,PCMDPT ;41

	LDAB	TMPPER
	SUBB	#7
	JMP	PPLPE1			;49


PCMDJT	FDB		LDPR,LDOR,LDVR,ADVR,LDPR,ESCR,PDOR,PTOR
;*		   	0    1    2    3    4    5  	 6    7
FCMDJT	FDB		ADHR,LDTR,ETBR,HIDR,FINR,ZTBR,FDOR,FTOR


;	SUBTTL	WAVE MODIFICATION

;* FENDR OVERLAY GETS RETURN ADDR FROM STACK.

FRTURN	LDX	FSTK
	LDX	3,X
	INX				;NEXT INSTR IS AFTER DISPLACEMENT BYTE
	STX	FCMDPT			;19
	JSR	FCMDNX			;41
	INX
	RTS

;* REPEAT CALL.

FDOAGN	LDX	0,X			;PT TO DISPLACEMENT BYTE
	STX	FCMDPT			;35
	LDX	#FTOR			;JUMP RTN IS NEXT
	STX	FVECT+1
	NOP
	RTS				;50

;* FIN DOES  REPEAT CALL, RETURN TO CALLER, STOP RTN DEPENDING ON STACK.

FINR	LDAA	FSTK+1
	CMPA	#FBTM
	BLS	ALLDON			;9	LAST END STATEMENT

	LDX	FSTK
	DEC	2,X			;NO, CHECK TOP OF STACK
	BPL	FDOAGN			;24	STILL REPEATING

	SUBA	#3
	STAA	FSTK+1
	LDX	#FRTURN			;ELSE RETURN
	STX	FVECT+1			;38
	TST	0,X
	RTS

ALLDON	LDX	#WAST50
	STX	FVECT+1
	NOP				;19
	BRA	WAST27

WAST50	INX
	INX
	NOP
WAST40	BSR	WAST5
WAST27	BSR	WAST5
WAST14	TST	0,X
WAST7	NOP
WAST5	RTS

;* CALL WITH REPEAT. REPEAT CNT 0(=1) TO 15 (=16) IS LO 4 BITS OF OPCODE.
;* NEXT BYTE IS DISPLACEMENT AS IN GO INSTRUCTION.  THE CTR AND RETURN
;* ADDRESS ARE SAVED ON A STACK.

FDOR	LDX	FSTK
	LDAA	FCMDPT			;SAVE ADDR OF DISPLACEMENT BYTE
	STAA	3,X
	LDAA	FCMDPT+1
	STAA	4,X
	LDAA	FCMD
	ANDA	#15
	STAA	5,X			;33

	INX
	LDX	#.1S
	STX	FVECT+1
	RTS				;50

;* OVERLAY FOR CALL RTN.

.1S	LDAA	FSTK+1								;;Fixme was: 1$
	ADDA	#3
	STAA	FSTK+1
	LDX	#FTOR
	STX	FVECT+1 		;17	GET READY TO JUMP
	NOP
	BRA	WAST27

;* GET NEXT FILTER COMMAND

NXTFCM	TST	FCNT
	BNE	WAST40			;IN A DELAY

	LDX	FCMDPT
	LDAA	0,X
	INX
	STX	FCMDPT
	STAA	FCMD
	BPL	.1S			;36

	STAA	FCNT			;NEGATIVE CMD IS NEG OF WAVE DELAY
	LDAA	0,X
	RTS				;50

.1S	LDX	#EXFCMD			;POSITIVE IS FROM TABLE			;;Fixme was: 1$
	FCB	-1,0,FVECT+1
	RTS				;50


EXFCMD	CLRB
	LDAA	FCMD
	ANDA	#$70			;B4 - B7 IS INSTRUCTION
	LSRA
	LSRA
	LSRA
	ADDA	#FCMDJT&255
;;	ADCB	#FCMDJT/256
	ADCB	#$F3			;;(#FCMDJT/256 was showing up as $F4)
	STAB	FNHI
	STAA	FNLO			;25

	LDX	FNHI	
	LDX	0,X
	STX	FVECT+1
	STX	FVECT+1
	RTS				;50

;* SET UP FOR REPEATED TABLE ADD.

ETBR	LDAA	FCMD
	ANDA	#15
	INCA
	INCA
	STAA	FCNT
	BRA	FHA1			;17

;* LOOK FOR A NONZERO HARMONIC CHANGE AND PERFORM IT.  IF ENTIRE TABLE
;* IS ZERO WE HAVE FINISHED THE LAST COMMAND AND PICK UP THE NEXT ONE.

FINDHA	INC	HAPTR+1
	LDX	HAPTR
	CPX	#CNAMP			;END TABLE?
	BEQ	FHA1			;17
	
	LDAA	0,X			;NO, LOOK AT CURRENT ENTRY
	LDX	#ADDINI
	STAA	HAMP
	BEQ	*+5
	JMP	*+6
	LDX	#FINDHA			;LOOK AGAIN IF 0
	STX	FVECT+1			;SET FOR ADD IF <>0
	INX
	RTS

FHA1	LDAA	#ADD2HA-2		;RESTART TABLE
	FCB	$B7,0,HAPTR+1
	LDX	#FINDHA			;MAYBE REPEAT
	DEC	FCNT
	BEQ	*+5
	JMP	*+6
FCMDNX	LDX	#NXTFCM			;40
	STX	FVECT+1
	RTS

;* RELATIVE JUMP.

FTOR	LDX	FCMDPT
	CLRB
	LDAA	0,X
	INCA				;DISPLACEMENT IS FROM NEXT INSTRUCTION
	ASRA
	ROLA
	SBCB	#0
	ADDA	FCMDPT+1
	ADCB	FCMDPT
	STAA	FCMDPT+1
	STAB	FCMDPT

	BRA	FCMDNX			;37

;* SET UP FOR ADD OF HAMP * HARMONIC TO WAVE.

ADDINI	LDAA	HAPTR+1
	SUBA	#ADD2HA-1
	ASLA
	CLRB
	ADDA	HRMTBL+1		;GET PTR TO HARMONIC IN FNHI, FNLO
	ADCB	HRMTBL
	STAB	FNHI
	STAA	FNLO			;23

	LDAA	#128
	STAA	FMSK
	
	LDX	#.2S
	STX	FVECT+1 		;37
	LDX	#WAVSRT
	STX	FWVPTR
	RTS

.2S	LDX	FNHI			;GET HARMONIC FN TO FNHI,FNLO		;;Fixme was: 2$
	LDX	0,X
	STX	FNHI
	LDX	#ADDLP
	STX	FVECT+1			;23

	LDX	HAPTR
	LDAA	9,X
	ADDA	HAMP
	STAA	9,X			;41	RECORD CHANGE
	INX
	RTS

;* ADD HAMP * HARMONIC FN TO WAVEFORM.

ADDLP	LDAA	FMSK			;MSK PTS TO CURRENT HARMONIC VALUE
	BEQ	.1S			;NEED NEW MASK AFTER 8 SAMPLES

	LSR	FMSK
	LDX	FWVPTR
	LDAB	0,X
	ANDA	FNHI			;ADD/SUBTRACT HAMP FROM SAMPLE ON
	BNE	.2S			;29		SIGN OF HARMONIC.
	FCB	-5,0,HAMP
	STAB	0,X
	INC	FWVPTR+1
	RTS				;50

.2S	FCB	-16,0,HAMP							;;Fixme was: 2$
	STAB	0,X
	INC	FWVPTR+1
	RTS

.1S	LDAB	FWVPTR+1							;;Fixme was: 1$
	CMPB	#WAVSRT+16
	BEQ	.3S			;16	DONE
	LDAB	FNLO
	STAB	FNHI			;ELSE SET FOR NEXT 8 SAMPLES
	LDAB	#128
	FCB	-9,0,FMSK
	BRA	.16S			;34

.3S	LDX	#NXTFCM			;RETURN TO THE RIGHT PLACE		;;Fixme was: 3$
	LDAB	FCNT
	BNE	*+5			;FCNT <>0 MEANS IN TABLE LOOP
	JMP	*+6			;FCNT = 0 MEANS EXECUTING COMMANDS
	LDX	#FINDHA
	STX	FVECT+1 		;34

.16S	TST	0,X								;;Fixme was: 16$
	INX
	RTS

;* ADH H,N  LDH H,N  USE SAME RTN

ADHR
LDHR	LDAA	FCMD
	ANDA	#7			;HARMONIC #
	ADDA	#ADD2HA
	STAA	HAPTR+1

	LDX	FCMDPT
	LDAA	0,X
	INX
	STX	FCMDPT
	STAA	HAMP			;33	SAVE VALUE

	LDX	#.1S
	STX	FVECT+1
	INX
	RTS

.1S	LDX	HAPTR								;;Fixme was: 1$
	CLRB
	LDAA	FCMD
	ADDA	#-8			;CARRY IF LD
	SBCB	#0
	ANDB	9,X			;LD NEW = SUB OLD + ADD NEW
	NEGB
	ADDB	HAMP
	
ADHRE	STAB	HAMP			;27
	LDX	#ADDINI
	STX	FVECT+1
	INX
	INX
	NOP
	RTS	

;* HARMONIC INCREMENT OR DECREMENT

HIDR	LDAB	FCMD
	LSRB
	ANDB	#7
	ORAB	#ADD2HA			;! ADD2HA MUST BE DIVISIBLE BY 8 !
	STAB	HAPTR+1			;PT TO THIS HARMONIC

	LDAB	#-1			;CARRY IF INCREMENT (BIT 0 OF FCMD = 1)
	ADCB	#0
	ADCB	#0
	BRA	ADHRE			;23

;* CLEAR ADD2HA OR ALTER 0TH AMPLITUDE.

ZTBR	LDAA	FCMD			;LO BIT 0 IF ZT
	ASRA
	BCS	ADCR

	LDX	#0
	STX	ADD2HA
	STX	ADD2HA+2
	STX	ADD2HA+4
	STX	ADD2HA+6 		;32
	INX

ATBRE	LDX	#NXTFCM
	FCB	-1,0,FVECT+1
ATBRE1	RTS

ADCR	BITA	#2
	BNE	ESC1			;15	BIT 2 FCMD =1 FOR ESCAPE
	LDAB	#ADD2HA-1
	STAB	HAPTR+1			;21
	LDX	#ADCRO
ADCRE	STX	FVECT+1
	JMP	WAST14

ESC1	FCB	-2,0,FCMDPT
	BRA	ADCRE			;24	

ADCRO	CLRB
	LDAA	FCMD
	ADDA	#-82			;CARRY IF LDH
	SBCB	#0
	ANDB	CNAMP
	LDX	FCMDPT
	LDAA	0,X
	INX
	STX	FCMDPT			;30
	SBA
	STAA	HAMP
	LDX	#ADDINI
	FCB	-1,0,FVECT+1
	RTS

;* CHANGE SOME ADD2HA ENTRIES.

LDTR	LDAB	#ADD2HA			;ASSUME FIRST ENTRY IS H #8
	STAB	HAPTR+1
	LDX	FCMDPT
	LDAB	0,X			;EACH BIT INDICATES PRESENCE OF ENTRY
	STAB	FNHI
	INX
	STX	FCMDPT			;28
	LDAB	FCMD			;LO BIT 1 IF ENTRY FOR 0 IS PRESENT
	LSRB
	BCC	.5S
	LDX	#.6S
	STX	FVECT+1
	RTS

.4S	CLRB										;;Fixme was: 4$
	LDAA	FNLO			;LO BIT 0 IF REPLACE, 1 IF ADD TO CURRENT
	ASRA
	SBCB	#0
	LDX	HAPTR
	ANDB	0,X
	ABA
	STAA	0,X			;26
	INC	HAPTR+1			;PT TO NEXT GUY
	LDAA	0,X

.5S	LDX	#.1S									;;Fixme was: 5$
	STX	FVECT+1
	RTS

.1S	ASL	FNHI									;;Fixme was: 1$
	BCS	.2S
	BEQ	.3S			;NO MORE IF 0
	INC	HAPTR+1
	JMP	WAST27

.3S	JSR	FCMDNX			;36						;;Fixme was: 3$
	TST	0,X
	NOP
	RTS

.6S	DEC	HAPTR+1			;SET FOR 0TH ENTRY				;;Fixme was: 6$
	INX

.2S	LDAA	0,X									;;Fixme was: 2$
	LDX	FCMDPT
	LDAA	0,X
	INX
	STX	FCMDPT			;33
	STAA	FNLO
	LDX	#.4S
	STX	FVECT+1
	RTS
			

;* FILTER TIMING
;* COMMAND	;# OF FILTER CALLS TO EXECUTE

;* LDH, ADH	;24

;* LDT, ADT	;3+(2*N)  (N = # OF ENTRIES ALTERED)

;* ZT		;3

;* DT  R	;	3+(R*{ 9+(22*NZH)})  WHERE
;*		;R IS # OF TABLE REPEATS
;*		;NZH IS # OF NONZERO ADD2HA ENTRIES

;* IH, DH	;23

;* FIN		;4  ( SAME FOR REPEAT AND RETURN)

;* DO		;5

;* TO		;3

;* WAIT N	;1+ (N* WAVE PERIOD)

; NLIST
;* MACROS FOR PITCH AND FILTER COMMANDS MAKE DULL READING.

;C MACRO "C
; LIST
;*			"C
; NLIST
; ENDM


LBL 	MACRO 	L,C						;;Fixme was: LBL 	MACRO "L,"C
; LIST
L	EQU 	*		;"C
; NLIST
	ENDM


ESC	MACRO
; LIST
	FCB	$55		;ESC
; NLIST
	ENDM


WAIT 	MACRO 	N						;;Fixme was: WAIT 	MACRO 	"N
; LIST
	FCB	-N		;WAIT	"N			;;Fixme was: FCB	 -"N
; NLIST
	ENDM


DO 	MACRO 	R,A						;;Fixme was: DO MACRO "R,"A
; LIST
	FCB 95+R,A-*-2		;DO	"R,"A			;;Fixme was: FCB 95+"R,"A-*-2
; NLIST
	ENDM


TO 	MACRO 	A						;;Fixme was: TO MACRO "A
; LIST
	FCB 112,A-*-2		;TO	"A			;;Fixme was: FCB 112,"A-*-2
; NLIST	
	ENDM


;* PITCH COMMANDS


LDP 	MACRO 	N						;;Fixme was: LDP MACRO "N
; LIST
	FCB 	1, N		;LDP	"N			;;Fixme was: FCB 1,"N
; NLIST
	ENDM


ADP 	MACRO 	N						;;Fixme was: ADP MACRO "N
; LIST
	FCB 	0,N		;ADP	"N			;;Fixme was: FCB 0,"N
; NLIST
	ENDM


LDV 	MACRO 	N						;;Fixme was: LDV MACRO "N
ZQ0 	SET 	$2000+(N&$FFF)					;;Fixme was: ZQ0 SET $2000+("N!.$FFF)
; LIST
	FDB 	ZQ0		;LDV	"N
; NLIST
	ENDM
;
ADV	MACRO	N						;;Fixme was: ADV MACRO "N
ZQ0 	SET 	$3000+(N&$FFF)					;;Fixme was: ZQ0 SET $3000+("N!.$FFF)
; LIST
	FDB 	ZQ0		;ADV	"N
; NLIST
	ENDM
;
LDO	MACRO	N						;;Fixme was: LDO MACRO "N
; LIST
	FCB	17,N		;LDO	"N			;;Fixme was: FCB 17,"N
; NLIST
	ENDM
;
ADO	MACRO	N						;;Fixme was: ADO MACRO "N
; LIST
	FCB	16,N		;ADO	"N			;;Fixme was: FCB 16,"N
; NLIST
	ENDM


STOP 	MACRO
; LIST
	FCB 	128		;STOP
; NLIST
	ENDM


NOT	MACRO	N						;;Fixme was: NOT MACRO "N
; LIST
	FCB	N		;NOT	"N			;;Fixme was: FCB 	"N
; NLIST
	ENDM


;* FILTER COMMANDS

FIN 	MACRO
; LIST
	FCB 	64		;FIN
; NLIST
	ENDM


;ADH MACRO "H,"N
; IFE "H
; LIST
; FCB	81,"N		ADH	0,"N
; NLIST
; ELSE
; LIST
; FCB 8-"H,"N		ADH	"H,"N
; NLIST
; ENDIF
; ENDM
;
;LDH MACRO "H,"N
; IFE "H
; LIST
; FCB	83,"N		LDH	0,"N
; NLIST
; ELSE
; LIST
; FCB 16-"H,"N		LDH	"H,"N
; NLIST
; ENDIF
; ENDM
;
;DT MACRO "R
; IFB <"R>
; LIST
; FCB 32			DT
; NLIST
; ELSE
; LIST
; FCB 31+"R		DT	"R
; NLIST
; ENDIF
; ENDM
;
;IH MACRO "H
; LIST
; FCB 65-"H-"H		IH	"H
; NLIST
; ENDM
;
;DH MACRO "H
; LIST
; FCB 64-"H-"H		DH	"H
; NLIST
; ENDM
;
ZT	MACRO
; LIST
	FCB	80		;ZT
; NLIST
	ENDM


;; LT macro doesn't work yet
LT MACRO C,q0,q1,q2,q3,q4,q5,q6,q7,q8				;;Fixme was: LT MACRO "C,"0,"1,"2,"3,"4,"5,"6,"7,"8
ZQ1	SET	16
ZQ2	SET	0
	IRP I,0,1,2,3,4,5,6,7,8					;;Fixme was: IRPC %I,012345678
ZB_I	SET	0						;;Fixme was: ZB%I SET 0
	ENDM							;;Fixme was: ENDR
	LTA 0,q0						;;Fixme was: LTA 0,"0
	LTA 1,q1                                                ;;Fixme was: LTA 1,"1
	LTA 2,q2                                                ;;Fixme was: LTA 2,"2
	LTA 3,q3                                                ;;Fixme was: LTA 3,"3
	LTA 4,q4                                                ;;Fixme was: LTA 4,"4
	LTA 5,q5                                                ;;Fixme was: LTA 5,"5
	LTA 6,q6                                                ;;Fixme was: LTA 6,"6
	LTA 7,q7                                                ;;Fixme was: LTA 7,"7
	LTA 8,q8                                                ;;Fixme was: LTA 8,"8
; LIST                                                          
	FCB	ZQ1,ZQ2		;LT <"0>,<"1>,<"2>,<"3>,<"4>,<"5>,<"6>,<"7>,<"8>
; NLIST
	LT_C							;;Fixme was: LT"C
	ENDM



LTA	MACRO	II,H,A,P					;;Fixme was: LTA MACRO "I,"H,"A,"P (added another I to avoid errors)
ZQ3	SET	0
	IFNB	P						;;Fixme was: IFNB <"P>
ZQ3 	SET 	1
	ENDIF
	IFNB	H						;;Fixme was: IFNB <"H>
	IF	H = 0						;;Fixme was: IFE "H
ZQ1	SET	17
	ELSE
ZQ2 	SET 	ZQ2|(2^(H-1))					;;Fixme was: ZQ2 SET ZQ2!+(2!^("H-1))
	ENDIF
ZB_II 	SET 	A+A+ZQ3						;;Fixme was: ZB"I SET "A+"A+ZQ3
	ENDIF
	ENDM


LT0	MACRO
; LIST
	FCB	ZB_0						;;Fixme was: FCB ZB0
; NLIST
	ENDM


LT1	MACRO
; LIST
	FCB	ZB_0,ZB_1					;;Fixme was: FCB ZB0,ZB1
; NLIST
	ENDM


LT2	MACRO
; LIST
	FCB	ZB_0,ZB_1,ZB_2					;;Fixme was: FCB ZB0,ZB1,ZB2
; NLIST
	ENDM


LT3	MACRO
; LIST
	FCB	ZB_0,ZB_1,ZB_2					;;Fixme was: FCB ZB0,ZB1,ZB2
	FCB	ZB_3						;;Fixme was: FCB ZB3

; NLIST
	ENDM


LT4	MACRO
; LIST
	FCB	ZB_0,ZB_1,ZB_2					;;Fixme was: FCB ZB0,ZB1,ZB2
	FCB	ZB_3,ZB_4					;;Fixme was: FCB ZB3,ZB4
; NLIST
	ENDM


LT5	MACRO
; LIST
	FCB	ZB_0,ZB_1,ZB_2					;;Fixme was: FCB ZB0,ZB1,ZB2
	FCB	ZB_3,ZB_4,ZB_5					;;Fixme was: FCB ZB3,ZB4,ZB5
; NLIST
	ENDM


LT6	MACRO
; LIST
	FCB	ZB_0,ZB_1,ZB_2					;;Fixme was: FCB ZB0,ZB1,ZB2
	FCB	ZB_3,ZB_4,ZB_5					;;Fixme was: FCB ZB3,ZB4,ZB5
	FCB	ZB_6						;;Fixme was: FCB ZB6
; NLIST
	ENDM


LT7	MACRO
; LIST
	FCB	ZB_0,ZB_1,ZB_2					;;Fixme was: FCB ZB0,ZB1,ZB2
	FCB	ZB_3,ZB_4,ZB_5					;;Fixme was: FCB ZB3,ZB4,ZB5
	FCB	ZB_6,ZB_7					;;Fixme was: FCB ZB6,ZB7
; NLIST
	ENDM


LT8	MACRO
; LIST
	FCB	ZB_0,ZB_1,ZB_2					;;Fixme was: FCB ZB0,ZB1,ZB2
	FCB	ZB_3,ZB_4,ZB_5					;;Fixme was: FCB ZB3,ZB4,ZB5
	FCB	ZB_6,ZB_7,ZB_8					;;Fixme was: FCB ZB6,ZB7,ZB8
; NLIST
	ENDM


; LIST
; NCLIST

; SUBTTL SOUND PROGRAMS

;* OPCODES ( ! SEPERATES NYBBLES  SPACES SEPERATE BYTES)

;* COMMON
;* WAIT N	;-N		( 1<= N<= 127)
;* DO R,RTN	;$6!(R-1)  RTN - NEXT LOC
;* TO RTN	;$70   RTN - NEXT LOC
;* ESC		;$55

;* FREQUENCY CONTROL
;* STOP			;$80
;* LDP N		;$01 N
;* ADP N		;$00 N
;* LDV N		;$2!(N&$F00) N&255
;* ADV N		;$3!(N&$F00) N&255
;* LDO N		;$11 N
;* ADO N		;$10 N

;* WAVE CONTROL
;* FIN		;$40
;* ZT		;$50
;* ADH 0,N	;$51 N
;* LDH 0,N	;$53 N
;*	( IN WHAT FOLLOWS 1<=H<=8  HHH = 8-H, A 3 BIT NUMBER)
;* ADH H,N	;$0!0HHH
;* LDH H,N	;$0!1HHH
;* IH H		;$3!HHH1
;* DH H		;$3!HHH0
;* DT R		;$2!(R-1)
;* LT A0,...,A8	;$1!000C 8765!4321 B0,...,B8
;*		;WHERE C=1 IF ENTRY 0 IS ALTERED
;*		;      N=1 IF ENTRY N IS ALTERED (N=1,...,8)
;*		;BN=AN+AN+P WHERE P=1 IF AN IS TO BE ADDED TO ENTRY N
;*		;		 P=0 IF AN REPLACES ENTRY N
;*		;BN IS PRESENT ONLY IF ENTRY N IS TO BE ALTERED

;* HARMONIC FUNCTIONS.  EACH BIT POSITION CORRESPONDS TO A WAVEFORM
;* POSITION.  IF THE BIT = 0, THE VALUE IS +1  IF THE BIT = 1, THE
;* VALUE IS -1.

;* THE HARMONICS ARE TREATED IN ORDER OF DECREASING AVERAGE FREQUENCY.

;;
;;	The ODDTBL defines the waveform for each the 8 harmonics.
;;	Joust's ODDTBL would be reused in Blaster, while Sinistar
;;	uses a corrupted version that has a misplaced fundamental
;;	frequency.
;;
;;	The ODDTBL was then further modified in Splat; this
;;	version would be reused again in Mystic Marathon.
;;
;;JOUST'S ODDTBL (also used in Blaster)
;; FDB %0000000000000000	;0  CONSTANT IS WEIRDO FOR NOW
;; FDB %0101010101010101	;8
;; FDB %1010101001010101	;7
;; FDB %0101101001011010	;6
;; FDB %1001011001101001	;5
;; FDB %0110011001100110	;4
;; FDB %1100110000110011	;3
;; FDB %0011110000111100	;2
;; FDB %0000111111110000	;1
;;
;;JOUST ODDTBL @ $FE88
;;0000 5555 AA55 5A5A 9669 6666 CC33 3C3C 0FF0
;;   0    8    7    6    5    4    3    2    1	(Harmonic Function Number)
;;SINISTAR ODDTBL @ $F5D1
;;0000 0000 AAAA 0FF0 C3F0 18CF C7A1 FF00 00FF
;;   0    8    7    6    5    4    3    2    1	(Harmonic Function Number)

ODDTBL
 FDB %0000000000000000		;0  CONSTANT IS WEIRDO FOR NOW
 FDB %0000000000000000		;8
 FDB %1010101010101010		;7
 FDB %0000111111110000		;6
 FDB %1100001111110000		;5
 FDB %0001100011001111		;4
 FDB %1100011110100001		;3
 FDB %1111111100000000		;2
 FDB %0000000011111111		;1

;;---------------------------------------------------------------------
;;
;;
;;	As it turns out, the last four harmonic functions in Sinistar's
;;	odd table are actually unused and don't make any purposeful
;;	sound other than alising noises when the pitch programs play.
;;
;;	$AAAA (7) and $0FF0 (6) are the only audible harmonics heard in
;;	the Extra Ship noise, which is weird because these values are oddly
;;	specific.  I wonder if Mike modifed the corrupted RAM data by
;;	copying Joust's 1st fundamental frequency and pasting it here to make
;;	it sound better.  You can also see how similar the 7th harmonic function
;;	is compared to the one in Joust ($AA55).  In fact, $5555 and
;;	$AAAA have the same bit pattern but inverted so the output
;;	sounds completely the same to the human ear.  The bit pattern
;;	for $AAAA makes it the highest pitched harmonic possible, with
;;	with $0FF0 being the lowest square wave possible.  This means with
;;	the Extra Ship sound, you're hearing the lowest and highest
;;	harmonics the Walsh function synth can produce.
;;
;;	For the Error Roar noise, harmonic functions 7, 6 and 5 ($C3F0)
;;	are used.  $C3F0 adds a buzzing noise that gives the Sinistar
;;	error roar extra bite (pun intended).  Again, the remaining
;;	entries in the odd table barely make any noise when this plays.
;;	
;;	The unused wave and pitch program maybe a debug preset as it
;;	appears to only play a simple pitch command with just the 7th
;;	harmonic.  You can change the value at $F5D5 to hear all the
;;	harmonic functions individually.
;;
;;	Note that the Sinistar odd table has two entries at the end:
;;	$FF00 and $00FF.  These two, along with $0FF0 all produce the
;;	same frequency since the bit pattern is essentially the same.
;;	This also applies to the values $3333, $6666, and $9999.
;;
;;
;;---------------------------------------------------------------------
;;SPLAT ODDTBL	   (located at $F743)
;;MYSTIC MARATHON  (located at $FE6E)
;;0000 5555 3333 25DA DA25 C731 0000 FFFF 01FE
;;   0    8    7    6    5    4    3    2    1	(Harmonic Function Number)
;;
;;SPLAT/MYSTIC MARATHON'S ODDTBL
;; FDB %0000000000000000	;0  CONSTANT IS WEIRDO FOR NOW
;; FDB %0101010101010101	;8
;; FDB %0011001100110011	;7
;; FDB %0010010111011010	;6
;; FDB %1101101000100101	;5
;; FDB %1100011100110001	;4
;; FDB %0000000000000000	;3
;; FDB %1111111111111111	;2
;; FDB %0000000111111110	;1
;;
;;---------------------------------------------------------------------
;;
;;

;* WAVE PROGRAMS

;;
;;	(Sinistar Error Roar Wave Commands)
;;
EROARW	FDB	$5380		;;LDH	0,128
	FDB	$0888		;;LDH 	8,136
	FDB	$0A10		;;LDH 	6,16
	FDB	$0908		;;LDH 	7,8
	FDB	$0B10		;;LDH 	5,16
	FDB	$0C20 		;;LDH 	4,32
	FDB	$0C05		;;LDH 	4,5
ERLP	FDB	$1080 		;;LT 	0,<8,-15> (3-byte opcode)
	FCB	$F0		;; 	||
	FCB	$23		;;DT 	4
	FDB	$1080		;;LT 	0,<8,10>?
	FCB	$10		;;	||
	FCB	$23		;;DT 	4
	FDB	$70F6		;;TO	ERLP$
;;
;;	(Sinistar Error Roar Pitch Commands)
;;
EROARP	FDB	$962E,$00EC
	FDB	$2200,$EC80 
	FDB	$20F6
	FCB	$80		;;STOP
;;
;;	(Extra Ship Wave Commands)
;;
EXTRAW	FDB	$5300		;;LDH	0,0
	FDB	$0A05		;;LDH 	6,5
	FCB	$FB		;;WAIT	5
	FDB	$5380		;;LDH	0,128
	FDB	$0A1F		;;LDH 	6,31
	FDB	$6F03		;;DO 	16,EXSWLP$
	FDB	$6E01		;;DO 	15,EXSWLP$
	FCB	$40		;;FIN
EXSWLP	FDB	$1060		;;LT ?	
	FDB	$0002		;;	||
	FCB	$23		;;DT 	4
	FDB	$1040 		;;LT 	0,<7,-1>
	FCB	$FE		;;	($1040FE is actually used in Joust)
	FCB	$22		;;DT 	3
	FDB	$1020 		;;LT ?
	FCB	$FE		;;	||
	FCB	$20		;;DT 	1
	FCB	$40		;;FIN
;;
;;	(Extra Ship Pitch Commands)
;;
EXTRAP	FCB	$64		;;(loads into SMPPER, inital pitch)
	FDB	$6F03		;;DO 	16,EXSPLP$
	FDB	$6F01		;;DO 	16,EXSPLP$
	FCB	$80		;;STOP
EXSPLP	FDB	$2100		;;LDV 	256
	FCB	$FC		;;WAIT 	4
	FDB	$2F00		;;LDV 	-256
	FCB	$FC		;;WAIT 	4
	FCB	$80 		;;STOP
;;
;;	(Unused Wave Commands)
;;
UNUSEDW	FDB	$5300,$09FF 
	FDB	$FB6F,$036E 
	FDB	$0140,$1040
	FDB	$FC20,$1041
	FDB	$0002,$2310
	FDB	$01FE,$2350
	FCB	$40
;;
;;	(Unused Pitch Commands)
;;
UNUSEDP	FDB	$7DCE,$CE80

WALSHT	FDB	EROARW,EROARP		;;(Sinistar Error Roar - plays only when speech board is disconnected)
	FDB	EXTRAW,EXTRAP	 	;;(Extra Ship Sound Effect)
	FDB	UNUSEDW,UNUSEDP		;;(Unused Waveform and Pitch Program - Just two notes, same pitch)
	FDB	EXTRAW,UNUSEDP		;;(Unused Pitch Program with Extra Ship Waveform)
	FDB	EXTRAW,EROARP		;;(Unused Alternate Error Roar with Extra Ship Waveform)

WALSH	CLRB
	STAB	SMPPER+1
	ASLA
	ASLA
	ADDA	#WALSHT&255		;;(originally #WALSHT!.255)
;;	ADCB	#WALSHT/256
	ADCB	#$F6			;;(#WALSHT/256 was showing up as $F7)
	STAB	PCMDPT
	STAA	PCMDPT+1
	LDX	PCMDPT
	LDX	0,X			;;(orignally just LDX	X)
	STX	FCMDPT
	LDX	PCMDPT
	LDX	2,X
	LDAB	0,X			;;(orignally just LDAB	X)
	STAB	SMPPER
	INX
	STX	PCMDPT
	LDX	#ODDTBL
	STX	HRMTBL
	JMP	WSM		
;;
;;	(Unused Glitchy Noise Loader)
NOISELD	TAB				;;(we now return to our regularly 
					;;scheduled program...)
	BGT	NOISEB
	ASLB
	ASLB 
 	ASLB  
	ASLB 
	STAB	$03
	TAB
	LDAA	#$04
	SBA
NOILOOP	PSHA
	JSR	NSTART
	LDAB	$03
	ADDB	#$30
	STAB	$03
	JSR	NSTART
	LDAB	$03
	SUBB	#$18
	STAB	$03
	JSR	NSTART
	PULA
	DECA
	BNE	NOILOOP
	RTS
NOISEB	LDAB	#$7F
	JSR 	NOISOUT
	LDAB	#$C0
	JSR 	NOISOUT
	LDAB	#$FF
	JSR 	NOISOUT
	LDAB	#$7F
	JSR 	NOISOUT
	LDAB	#$3F
	JSR 	NOISOUT
	RTS
NSTART	LDAB	$03
NOISOUT	STAB	SOUND
	LDX	#$0040
NDIVLP 	BSR	NOISE1
NDIVLP2 PSHA
	LDAB	#$03
NDIVLP3	BSR	NOISE1
	DECB
	BNE	NDIVLP3
	PULA
	DECA
	BNE	NDIVLP2
	BSR	NOISE1
	CMPA	#$7F
	BGT	NDIVLP
	COM	SOUND
	DEX
	BNE	NDIVLP
	RTS
;;
;;	(Appears to be a general noise routine.  There's similarities to
;;	routines found in other sound roms.  NOISE1 gets called a lot by
;;	a few of the unused noise synth routines.)
;;	
NOISE1 	LDAA	LO 			;GET RANDOM BIT
	LSRA
	EORA	LO
	LSRA 
	LSRA
	ROR	HI
	ROR	LO				
	RTS  
;;---------------------------------------------------------------------
;;
;;	DIAGNOI	EQU	$F6F9
;;
;;	(Will-I-ROMS labeled this as SYNTH28.  It gets called by
;;	Diagnostic Processing for checksum verification. This routine
;;	makes a weird bubbly pitch bend noise)
;;
DIAGNOI	CLRA
	STAA	SOUND
	LDX	#ENDRAM			;;?
DIAGMLP	STX	TEMPA
	LDAA	TEMPB
DIAGLP1	DECA
	PSHA
	PULA
	PSHA
	PULA
	PSHA
	PULA
	BNE	DIAGLP1
	COM	SOUND
	LDAA	TEMPB
DIAGLP2	DECA
	PSHA
	PULA
	PSHA
	PULA
	PSHA
	PULA
	BNE	DIAGLP2
	COM	SOUND
	BSR	NOISE1
	TAB
DIAGBL1	DECB
	BNE	DIAGBL1
	COM	SOUND
	TAB 
DIAGBL2	DECB
	BNE	DIAGBL2
	COM	SOUND
	INC	SOUND
	DEX  
	BNE	DIAGMLP
	RTS
;;---------------------------------------------------------------------
;;
;;	WEIRD	EQU	$F735
;;
;;	(Will-I-ROMS labeled this as SYNTH29.  It doesn't look like this is
;;	called anywhere.  This routine makes an even more weird glitchy
;;	bass stab noise using a similar "stacker" subroutine in DIAGNOI)
;;
WEIRD	CLRA
	STAA	SOUND
	LDX	#$01
WEIRMLP STX	TEMPA
	LDAA	TEMPB
WEIRLP1 DECA
	PSHA
	PULA
	PSHA
	PULA
	PSHA
	PULA
	BNE	WEIRLP1
	COM	SOUND
	LDAA	TEMPB
WEIRLP2 DECA
	PSHA
	PULA
	PSHA
	PULA
	PSHA
	PULA 
	BNE	WEIRLP2
	COM	SOUND
	BSR	NOISE1
WLDBLP1	LDAB	#$20
WDECBL1	DECB
	BNE	WDECBL1
	DECA
	BNE	WLDBLP1
	COM	SOUND
	BSR	NOISE1
WLDBLP2	LDAB	#$20
WDECBL2	DECB 
	BNE	WDECBL2
	DECA 
	BNE	WLDBLP2
	COM	SOUND
	INC	SOUND
	INX
	CMPX	#$0010
	BNE	WEIRMLP
	RTS
;;---------------------------------------------------------------------
;;
;;	(This initializes the unused background drone)	
;;
BGCLRFG	EQU	$0003
BGPITCH	EQU	$05
BGA	EQU	$60
BGB	EQU	$13
;;
DRONELD	CLR	BGCLRFG
	ASLB 
	ASLB 
	ASLB
	STAB	BGPITCH
	LDAA	#$01
	STAA	BG1FLG
	RTS
;;
DROSYN	LDAA	#BGA
	STAA	SOUND
;;
DROLP1	LDAA	BGPITCH
;;
DROA11	LDAB	#BGB
;;
DROB11	DECB
	BNE	DROB11
	DECA
	BNE	DROA11
	COM	SOUND
	LDAA	BGPITCH
;;
DROA12  LDAB	#BGB
;;
DROB12	DECB 
	BNE	DROB12
	DECA
	BNE	DROA12
	COM	SOUND
	INC	SOUND
	LDAA	#$7F
	CMPA	SOUND
	BNE	DROLP1
;;
DROLP2	LDAA	BGPITCH
;;
DROA21	LDAB  	#BGB
;;
DROB21	DECB
	BNE	DROB21
	DECA 
	BNE	DROA21
	COM	SOUND
	LDAA	BGPITCH
;;
DROA22	LDAB 	#BGB
;;
DROB22	DECB
	BNE	DROB22
	DECA
	BNE	DROA22
	COM	SOUND
	DEC	SOUND
	LDAA	#BGA
	CMPA	SOUND
	BNE	DROLP2
	BRA	DROLP1
;;---------------------------------------------------------------------
;*
;*
;*GWAVE LOADER
GWLD	TAB				;MULKT BY 7
	ASLB
	ABA
	ABA
	ABA
	LDX	#SVTAB			;SOUND VECTOR TABLE
	JSR	ADDX
	LDAA	0,X
	TAB
	ANDA	#$F
	STAA	GCCNT			;GET CYCLE COUNT
	LSRB
	LSRB
	LSRB
	LSRB
	STAB	GECHO			;GET #ECHOS
	LDAA	1,X
	TAB
	LSRB
	LSRB
	LSRB
	LSRB
	STAB	GECDEC
	ANDA	#$F			;WAVE #
	STAA	TEMPA			;SAVE
	STX	TEMPX			;SAVE INDEX
	LDX	#GWVTAB			;CALC WAVEFORM ADDR
GWLD2	DEC	TEMPA			;WAVE FORM #
	BMI	GWLD3			;FINIS
	LDAA	0,X
	INCA
	JSR	ADDX
	BRA	GWLD2
GWLD3	STX	GWFRM
	JSR	WVTRAN			;XSFER WAVE TO RAM
	LDX	TEMPX			;RESTORE INDEX
	LDAA	2,X			;GET PREDECAY
	STAA	PRDECA
	JSR	WVDECA			;DECAY IT
	LDX	TEMPX
	LDAA	3,X			;GET FREQ INC
	STAA	GDFINC
	LDAA	4,X			;GET DELTA FREQ COUNT
	STAA	GDCNT
	LDAA	5,X			;GET PATTERN COUNT
	TAB				;SAVE
	LDAA	6,X			;PATTERN OFFSET
	LDX	#GFRTAB
	JSR	ADDX
	TBA				;GET PATTERN LENGTH
	STX	GWFRQ			;FREQ TABLE ADDR
	CLR	FOFSET
	JSR	ADDX
	STX	FRQEND
	RTS
;*
;*GWAVE ROUTINE
;*ACCA= FREQ PATTERN LENGTH, X= FREQ PAT ADDR
;*
GWAVE	LDAA	GECHO
	STAA	GECNT
GWT4	LDX	GWFRQ
	STX	XPLAY
GPLAY	LDX	XPLAY			;GET NEW PERIOD
	LDAA	0,X
	ADDA	FOFSET
	STAA	GPER
	CPX	FRQEND
	BEQ	GEND			;FINISH ON ZERO
	LDAB	GCCNT			;CYCLE COUNT
	INX
	STX	XPLAY
GOUT	LDX	#GWTAB			;SETUP WAVEFORM POINTER
GOUTLP	LDAA	GPER
GPRLP	DECA				;WAIT FOR PERIOD
	BNE	GPRLP
	LDAA	0,X			;OUTPUT SOUND
	;;
	LSRA				;;(new instruction added to VSNDRM9)
	;;
	STAA	SOUND
GPR1	INX
	CPX	WVEND			;END OF WAVE?
	BNE	GOUTLP
	DECB
	BEQ	GPLAY
	INX
	DEX
	INX
	DEX
	INX
	DEX
	INX
	DEX
	NOP
	NOP
	BRA	GOUT			;SYNC 36
GEND	LDAA	GECDEC
	BSR	WVDECA
GEND40	DEC	GECNT			;ECHO ON?
	BNE	GWT4			;YES
	;;
;	BNE	GEND1			;;(this instruction is missing in VSNDRM9)
	;;
GEND50	LDAA	GDFINC			;CONTINUE FOR FREQ MOD SOUNDS
	BEQ	GEND1			;NO
	DEC	GDCNT			;DELTA FREQ OVER?
	BEQ	GEND1			;YES...
	ADDA	FOFSET			;UPDATE FREQ OFFSET
GEND60	STAA	FOFSET
GEND61	LDX	GWFRQ			;GET INDEX
	CLRB				;START FOUND FLAG INIT CLEAR
GW0	LDAA	FOFSET			;INC OR DEC?
	TST	GDFINC
	BMI	GW1			;DEC
	ADDA	0,X			;INC
	BCS	GW2			;CARRY=OVERFLOW
	BRA	GW2A
GW1	ADDA	0,X			;DEC
	BEQ	GW2			;OVERFLOW ON EQ
	BCS	GW2A			;OVERFLOW IF CARRY CLEAR
GW2	TSTB				;FOUND START YET?
	BEQ	GW2B			;NO
	BRA	GW3			;YES, THIS IS THE END
GW2A	TSTB
	BNE	GW2B			;ALREADY FOUND START
	STX	GWFRQ			;FOUND START
	INCB
GW2B	INX
	CPX	FRQEND
	BNE	GW0			;NOT OVER YET
	TSTB				;FOUND START?
	BNE	GW3			;YES
	RTS				;ALL OVER
GW3	STX	FRQEND
	LDAA	GECDEC			;RE:XSFER WAVE?
	BEQ	GEND0			;NO
	BSR	WVTRAN			;XSFER WAVE
	LDAA	PRDECA
	BSR	WVDECA
GEND0	JMP	GWAVE
GEND1	RTS				;TERMINATE
;*
;*WAVE TRANSFER ROUTINE
;*
WVTRAN	LDX	#GWTAB
	STX	XPTR
	LDX	GWFRM
	LDAB	0,X			;GET WAVE LENGTH
	INX
	JSR	TRANS
	LDX	XPTR
	STX	WVEND			;GET END ADDR
	RTS
;*
;*WAVE DECAY ROUTINE/ DECAY AMOUNT IN ACCA(1/16 PER DECAY)
;*
WVDECA	TSTA
	BEQ	WVDCX			;NO DECAY
	LDX	GWFRM			;ROM WAVE INDEX
	STX	XPLAY
	LDX	#GWTAB
	STAA	TEMPB			;DECAY FACTOR
WVDLP	STX	XPTR
	LDX	XPLAY
	LDAB	TEMPB
	STAB	TEMPA			;DECAY FACTOR TEMP
	LDAB	1,X			;OFFSET FOR WAVE LENGTH
	LSRB
	LSRB
	LSRB
	LSRB				;CALC 1/16TH
	INX
	STX	XPLAY
	LDX	XPTR
	LDAA	0,X
WVDLP1	SBA				;DECAY
	DEC	TEMPA
	BNE	WVDLP1
	STAA	0,X
	INX
	CPX	WVEND			;END OF WAVE?
	BNE	WVDLP			;NO
WVDCX	RTS
;;---------------------------------------------------------------------
;*
;*VARI VECTORS
;*
VVECT	EQU	*
;*	NONE AS OF YET			;;(Variwave is not used in VSNDRM9) 
;*
;;---------------------------------------------------------------------
;;
;;   GWAVE WAVEFORM TABLE (GWVTAB)
;;
;;	GWAVE is a a wavetable synthesizer routine written in 1979 by
;;	Eugene Jarvis.  This is arguably the most famous synth heard
;;	in these games, responsible for many well-known noises.  
;;	It relies on three different tables to output sound:
;;
;;	GWAVTAB (wave table)
;;	SVTAB (preset parameters)
;;	GFRTAB (frequency table)
;;
;;	The wave table features several different shapes to produce
;;	different timbres.  The waveform sizes range from as little as
;;	7 bytes, all the way to 72 bytes.  The bigger the size,
;;	the lower the pitch will be.
;;
;*
;*WAVE TABLE
;*1ST BYTE= WAVELENGTH
;*
GWVTAB	EQU	*
;;
;; (SINE WAVE - 2ND OCTAVE)
GS2	FCB	8
	FCB	127,217,255,217,127,36,0,36
;;
;; (SQUARE[ISH] WAVE - 2ND OCTAVE)
GSSQ2	FCB	8
	FCB	0,64,128,0,255,0,128,64
;;
;; (SINE WAVE - 1ST OCTAVE)
GS1	FCB	16
	FCB	127,176,217,245,255,245,217,176
	FCB	127,78,36,9,0,9,36,78
;;
;; NEW WAVEFORM #3 (28-BYTE ROUNDED SQUARE WAVE)
;; (replaces GS12 - SINE WAVE 1ST AND 2ND OCTAVES)
GS28	FCB	28 
	FCB	128,64,41,27,16,9,6,4
	FCB	7,12,18,30,48,73,164,201 
	FCB	223,235,246,251,255,255,251,245 
	FCB	234,221,199,155
;;
;; (SQUARE WAVE - 1ST OCTAVE)
;; (double version of GSQ2)
GSQ22	FCB	16
	FCB	$FF,$FF,$FF,$FF,0,0,0,0
	FCB	$FF,$FF,$FF,$FF,0,0,0,0
;;
;; (72-BYTE SINE WAVE)
;; (NOT USED IN-GAME - WAVEFORM USED BY "LANDER FIRE" aka DP1V)
GS72	FCB	72
	FCB	138,149,160,171,181,191,200,209
	FCB	218,225,232,238,243,247,251,253,254,255
	FCB	254,253,251,247,243,238,232,225,218
	FCB	209,200,191,181,171,160,149,138,127
	FCB	117,106,95,84,74,64,55,46,37,30,23,17,12
	FCB	8,4,2,1,0
	FCB	1,2,4,8,12,17,23,30,37,46,55,64,74,84
	FCB	95,106,117,127
;;
;; NEW WAVEFORM #6 (RANDOM JAGGED SQUARE WAVE)
;; (USED ONLY BY "PLAYER FIRE")
;; (replaces GS1.7 - SINE WAVE AT .7 AMPLITUDE)
	FCB	12
	FCB	0,80,96,176,32,32,240,144 
	FCB	128,192,80,112
;;
;; NEW WAVEFORM #7 (SQUARE WITH DECAY)
	FCB	7
	FCB	64,9,53,12,41,15,32
;;---------------------------------------------------------------------
;;
;;   GWAVE "PRESET" PARAMETERS
;;   aka SOUND VECTOR TABLE (SVTAB)
;;	
;;	BYTE 0: ECHO COUNT, PLAYS PER PERIOD
;;	BYTE 1: ECHO DECAY AMOUNT, WAVEFORM #
;;	BYTE 2: INITIAL DECAY AMOUNT
;;	BYTE 3: BASE PERIOD CHANGE
;;	BYTE 4: NUMBER OF REPEATS
;;	BYTE 5: FREQ PATTERN LENGTH
;;	BYTE 6: FREQ PATTERN OFFSET (starts at GFRTAB)
;;
;;	ECHO repeats the frequency pattern, while ECHO DECAY reduces
;;	the volume on every consecutive echo.  Large echo delay values
;;	introduce wrap-around, perfect for glitchy noises.
;;
;;	PLAYS PER PERIOD acts almost like a tempo control by repeating
;;	waveform periods, making the sound play longer without changing
;;	the pitch.
;;
;;	WAVEFORM #
;;	Pick between 0-7.  VSNDRM9 introduces three new waveforms that
;;	replace two older ones (GS12 and GS1.7) used in all
;;	previous Video Sound Rom source files.
;;	
;;	INITIAL DECAY AMOUNT
;;	Reduces the volume at the beginning of the sound.  Can be
;;	useful as a main volume control.  Combined with echo delay,
;;	this parameter can output interesting wrap-around results!
;;
;;	BASE PERIOD CHANGE
;;	Use this to change the pitch on every repeat.
;;	
;;	FREQ PATTERN LENGTH
;;	The longer the length, the longer the duration will be.
;;
;;	FREQ PATTERN OFFSET
;;	In the source code for the other sound roms, the offset was
;;	put in as the label for the start of the pattern MINUS the
;;	address of the freq table (GFRTAB), like this:
;;
;;	ED17	FCB	$1F,$12,0,$FF,$10,4,SPNR-GFRTAB
;;	
;;	I have put in the labels for the patterns in the freq table
;;	but to make it easier to read, the final hex values are in
;;	the source code	instead of "[SNDLABEL]-GFRTAB".
;;
;;	***PLAYER START CUE***
;;	Mike Metz either created this sound with corruption or by
;;	randomly typing in different values.  There's some numbers here
;;	that don't make any sense.  
;;
;;	$88   $F3  $90  $13  $B7  $04  $00
;;	8,8  15,3  144   19  183    4    0
;;
;;	The number of repeats aka "variable freq count" has a value of
;;	183($B7), however only 2 repeats are heard in-game.  This means
;;	that if the sound plays uninterrupted, it will repeat 183 times!
;;	Base period change aka "GDFINC" is 19($13), so it will decrease
;;	the pitch and speed with every repeat.  This causes the full
;;	duration of the sound to be almost 11 minutes!!
;;
;*
;*GWAVE SOUND VECTOR TABLE
;*VECTOR FORMAT
;*BYTE 0: GECHO,GCCNT
;*BYTE 1: GECDEC,WAVE#
;*BYTE 2: PREDECAY FACTOR
;*BYTE 3: GDFINC
;*BYTE 4: VARIABLE FREQ COUNT
;*BYTE 5: FREQ PATTERN LENGTH
;*BYTE 6: FREQ PATTERN OFFSET
;*
SVTAB	EQU	*
UNUSED0	FCB	$71,$23,$09,$00,$00,$1E,$00	;;UNUSED SOUND (UNUSED WARNING?)
ERRORV	FCB	$74,$00,$09,$00,$00,$1A,$1E	;;SINISTAR SPEECH ERROR
BBSV	FCB	$74,$12,$09,$00,$00,$0A,$38	;;AF = SINI-BOMB ("Big Ben" Bell Sound)			(QSFire)
PFIREV	FCB	$11,$06,$06,$02,$20,$03,$42	;;AE = PLAYER FIRE					(QFIRE)
EFIREV	FCB	$11,$04,$0B,$01,$20,$04,$42	;;AD = WARRIOR FIRE					(QWFIRE)
UNUSED1	FCB	$12,$03,$09,$00,$00,$04,$46	;;UNUSED ALTERNATE BOUNCE (only difference is offset)
BOUNCV	FCB	$12,$03,$09,$00,$00,$04,$4A	;;AB = BOUNCE						(QBOUNCE)
ECRYSV	FCB	$16,$00,$09,$00,$00,$16,$4E	;;AA = WORKER CRYSTAL PICKUP				(QWorkCr)
DP1V	FCB	$11,$05,$11,$01,$0F,$01,$38	;;A9 = UNUSED "LANDER" FIRE (FOUND IN DEFENDER VSNDRM1)
ED17	FCB	$1F,$12,$09,$FF,$05,$04,$64	;;A8 = CRYSTAL BOMB-BAY FULL (ED'S SOUND 17)		(QFulCr)
CRYSFV	FCB	$F1,$07,$09,$00,$00,$0E,$68	;;A7 = CRYSTAL FLASHING					(QCRYFLA)
CLANGV	FCB	$68,$20,$00,$02,$26,$03,$04	;;A6 = SINISTAR PIECE ADDED / GAME OVER CUE		(QWorkSi/QGamEnd)
BLASTV	FCB	$08,$47,$0B,$40,$01,$02,$03	;;A5 = UNUSED BLASTER "ENERGY CRITICAL" ALARM
STARTV	FCB	$88,$F3,$90,$13,$B7,$04,$00	;;A4 = PLAYER START CUE					(QPlStr)
PCRYSV	FCB	$18,$11,$09,$00,$00,$14,$40	;;A3 = PLAYER CRYSTAL PICKUP				(QPlayCr)
;;---------------------------------------------------------------------
;;
;;   GWAVE FREQUENCY PATTERN TABLE (GFRTAB)
;;
;;	Frequency patterns are used to control the pitch of the waveform.
;;	Patterns often go "overbounds" into other pattern areas, like
;;	ED'S SOUND 17 for example.  This preset uses two defined patterns
;;	one right after another.  
;*
;*GWAVE FREQ PATTERN TABLE
;*
GFRTAB  EQU    	*
;;
;; PLAYER START PATTERN 		;;(Length = $04)($00 = STARTP-GFRTAB)
STARTP	FCB	$28,$01,$02
;;
;; UNUSED BLASTER ALARM 		;;(Length = $02)($03 = BLASTP-GFRTAB)
BLASTP	FCB	$26
;;
;; PIECE ADDED / GAME OVER 		;;(Length = $03)($04 = CLANGP-GFRTAB)
CLANGP	FCB	$03,$04,$24,$05,$06,$22,$07,$08
	FCB	$20,$09,$0A,$1E,$0B,$0C,$1C,$0D
	FCB	$0E,$1A,$0F,$10,$18,$11,$12,$16
	FCB	$13,$14 
;;
;; SINISTAR SPEECH ERROR		;;(Length = $1A)($1E = ERRORP-GFRTAB)
ERRORP	FCB	$40,$01,$3E,$03,$3C,$05,$3A,$07
	FCB	$38,$09,$35,$0C,$32,$0F,$2F,$12
	FCB	$2C,$15,$28,$19,$24,$1D,$20,$21
	FCB	$20,$21
;;
;*SWEEP PATTERN
SWPAT	EQU	*			;;(SWPAT-GFRTAB used by DPV1)
;*BIGBEN SOUNDS				;;(Length = $0A)($38 = BBSND-GFRTAB)	(Truncated BBSND pattern)
BBSND	FCB	$08,$40,$08,$40,$08,$40,$08,$40 
;;
;; PLAYER CRYSTAL PICKUP		;;(Length = $14)($40 = PCRYSP-GFRTAB)
PCRYSP	FCB	$08,$40	
;;
;; PLAYER/WARRIOR FIRE PATTERN		;;(Length = $03)($42 = FIRESND-GFRTAB)	(PLAYER)
FIRESND	FCB	$01,$02,$03,$04		;;(Length = $04)($42 = FIRESND-GFRTAB)	(WARRIOR)
;;
;; UNUSED ALTERNATE BOUNCE		;;(Length = $04)($46 = UBOUNCP-GFRTAB)
UBOUNCP	FCB	$20,$18,$20,$01
;;
;; BOUNCE PATTERN			;;(Length = $04)($4A = BOUNCEP-GFRTAB)
BOUNCEP	FCB	$01,$30,$28,$30                 
;;
;; WORKER CRYSTAL PICKUP		;;(Length = $16)($4E = ECRYSP-GFRTAB)
ECRYSP	FCB	$1E,$02,$1B,$04,$23,$07,$1D,$01
	FCB	$22,$03,$19,$09,$1F,$06,$1A,$05
	FCB	$1C,$0B,$21,$08,$20,$0A
;;
;*SPINNER SOUND "DRIP"			;;(Length = $04)($64 = SPNR-GFRTAB)	(ED'S SOUND 17)
SPNR    FCB    	$40
;*COOL DOWNER
COOLDN  FCB    	$10,8,1
;;
;; CRYSTAL FLASHING			;;(Length = $0E)($68 = CRYSFP-GFRTAB)
CRYSFP	FCB	$08,$80,$10,$78,$18,$70,$20,$60
	FCB	$28,$58,$30,$50,$40,$48
;*
;*PARAMETER TRANSFER
;*
TRANS	PSHA
TRANS1	LDAA	0,X
	STX	XPLAY
	LDX	XPTR
	STAA	0,X
	INX
	STX	XPTR
	LDX	XPLAY
	INX
	DECB
	BNE	TRANS1
	PULA
	RTS
;;---------------------------------------------------------------------
;;
;;   Unknown Lightning+Appear Routines (Unused - No call)
;;
;;	ENDLITE	EQU	$FAAE
;;	LITE	EQU	$FAB6
;;
;;	These are really interesting.  Both of these routines use the
;;	A register value so the sound ID itself acts as a seed for the
;;	random number generator.  
;;
;;      The LITE routine from Joust has been modified.  Instead of doing
;;	a downward pitch bend and then stopping, it goes upward and
;;	usually loops for a long time or sometimes forever, depending on
;;	the A register value.  
;;
;;	Calling ENDLITE produces a noise burst without looping.  Sometimes
;;	(depending on the A value) it sounds similar to the flapping
;;	sounds from Joust.  It stops LITE from looping so I labeled it
;;	as ENDLITE.
;;
;;	LITE sorta reminds me of Tempest's warp sound, with ENDLITE
;;	acting as a "switching to impulse engines" effect.
;;	It makes me wonder if these routines were originally going to
;;	be used for the warp that occurs after defeating the Sinistar.
;;
ENDLITE	ASLA 
	ASLA
	ASLA
	ASLA
	SUBA	#$03
	STAA	DFREQ
;*
;*LIGHTNING
;*
LITE	LDAB	#3			;;(this instruction has been flip-flopped)
	STAA	LFREQ			;;(originally used DFREQ)
	LDAA	#1			;;(this instruction has been flip-flopped)
;*
;*LIGHTNING+APPEAR NOISE ROUTINE
;*
LITEN	STAA	$1F			;;(not LFREQ?)
	LDAA	#$FF			;HIGHEST AMP
	;;
	SUBA 	DFREQ			;;(new instruction)
	;;
	STAA	SOUND
	STAB	CYCNT
LITE0	LDAB	CYCNT
LITE1	LDAA	LO			;GET RANDOM
	LSRA
	LSRA
	LSRA
	EORA	LO
	LSRA
	ROR	HI
	ROR	LO
	BCC	LITE2
	;;
	LDAA 	SOUND			;;
	COMA 				;;(original instruction was just: COM SOUND)
	STAA 	SOUND			;;
	;;
LITE2	LDAA	LFREQ			;COUNT FREQ
LITE3	DECA
	BNE	LITE3
	DECB				;COUNT CYCLES
	BNE	LITE1
	LDAA	LFREQ
	ADDA	DFREQ
	STAA	LFREQ
	BNE	LITE0
	RTS 
;*
;*HYPER
;*
;;
;;	HYPER	EQU	$FAF1
;;
HYPER	CLRA
	STAA	SOUND	
	STAA	TEMPA			;ZERO PHASE
HYPER1	CLRA				;ZERO TIME COUNTER
HYPER2	CMPA	TEMPA	
	BNE	HYPER3
	COM	SOUND			;PHASE EDGE?, COMPLEMENT SOUND
HYPER3	LDAB	#18			;DELAY
HYPER4	DECB
	BNE	HYPER4
	INCA				;ADVANCE TIME COUNTER
	BPL	HYPER2	
	COM	SOUND			;CYCLE DONE?, CYCLE EDGE
	INC	TEMPA			;NEXT PHASE
	BPL	HYPER1			;DONE?
	RTS

;;---------------------------------------------------------------------
;;
;;   CANNON Noise Routines
;;
;;	Three variations of this routine are used to make the explosion
;;	noises.  
;;
;;	The first one (CANNON) is identical to the routine found in
;;	VSNDRM1.  It is called by "QBANG" for enemy and planetoid
;;	explosions.  The routine enables DSFLAG and loads #1000 into
;;	X, giving us a medium-length distorted cannon blast.
;;
;;	The next one is called by the "IMPACT" sound trigger and
;;	plays whenever the player is hit before exploding.  I labled it
;;	as "GUNSHOT" because it has a much shorter duration and the
;;	distortion flag is turned off, creating a white noise burst,
;;	that sounds not unlike a gun.
;;
;;	The third one is "C4NNON" (the 1337 name is from WILL-I-ROMs).
;;	It's exactly the same as CANNON except it plays a longer
;;	duration by loading #4000 into X instead of #1000.
;;
;*
;*CANNON					
;*
CANNON  LDAA   	#1			;;(turn on distortion flag)
        STAA   	DSFLG			;;
        LDX   	#1000			;;(duration = 1000)
        LDAA   	#1			;;(FDFLG)(FREQUENCY DECREMENT FLAG)
        LDAB   	#$FF			;;(FMAX)(MAXIMUM_FREQUENCY)
        BRA    	FNOISE
;;
;;
GUNSHOT LDAA   	#0			;;(turn oFF distortion flag)
        STAA   	DSFLG			;;
        LDX   	#128			;;(duration = 128)
        LDAA   	#1			;;(FDFLG)
        LDAB   	#$C0			;;(FMAX)
        BRA    	FNOISE
;;
;;
C4NNON  LDAA   	#1			;;(turn on distortion flag)
        STAA   	DSFLG			;;
        LDX   	#4000			;;(duration = 4000)
        LDAA   	#1			;;(FDFLG)
        LDAB   	#$FF			;;(FMAX)
        BRA    	FNOISE
;*
;*FILTERED NOISE ROUTINE
;*X=SAMPLE COUNT, ACCB=INITIAL MAX FREQ
;*ACCA=FREQ DECAY FLAG ,DSFLG=DISTORTION FLAG
;*
FNOISE  STAA   	FDFLG
        STAB   	FMAX
        STX    	SAMPC
        CLR    	FLO
FNOIS0  LDX    	SAMPC
	LDAA	SOUND
FNOIS1  TAB                     	;NEXT RANDOM NUMBER
        LSRB 
        LSRB 
        LSRB 
        EORB   	LO
        LSRB 
        ROR   	HI
        ROR    	LO
        LDAB   	FMAX             	;SET FREQ
        TST    	DSFLG
        BEQ    	FNOIS2
        ANDB   	HI               	;DISTORT FREQUENCY
FNOIS2  STAB   	FHI
        LDAB   	FLO
        CMPA   	LO
        BHI    	FNOIS4
FNOIS3  DEX    	                 	;SLOPE UP
        BEQ    	FNOIS6
        STAA   	SOUND
        ADDB   	FLO
        ADCA   	FHI
        BCS    	FNOIS5
        CMPA   	LO
        BLS    	FNOIS3
        BRA    	FNOIS5
FNOIS4  DEX                     	;SLOPE DOWN
        BEQ    	FNOIS6
        STAA   	SOUND
        SUBB   	FLO
        SBCA   	FHI
        BCS    	FNOIS5
        CMPA   	LO
        BHI    	FNOIS4
FNOIS5  LDAA   	LO
        STAA   	SOUND
        BRA    	FNOIS1
FNOIS6  LDAB   	FDFLG
        BEQ    	FNOIS1
        LDAA   	FMAX             	;DECAY MAX FREQ
        LDAB   	FLO
        LSRA 
        RORB 
        LSRA 
        RORB 
        LSRA 
        RORB 
        COMA 
        NEGB 
        SBCA   	#-1
      	ADDB   	FLO
        ADCA   	FMAX
        STAB   	FLO
        STAA   	FMAX
        BNE    	FNOIS0
        CMPB   	#7
        BNE    	FNOIS0
        RTS  
;*
;*
;* SINGLE OSCILLATOR SOUND CALLS
;*
;;
;;	PERKSS	EQU	$FBAD
;;
PERKSS	LDAB	#$FF			;;(originally LDAA)
	;;(had to move AMP0 from $05 to $18)
	STAB	AMP0			;;(originally STAA)
	;;
ATARI	LDX	#VEC03X			;;(Original in VSNDRM4 was LDX #VEC06X)
	BSR	PERK1			;;(Original in VSNDRM4 was BRA PERK1)
	LDX	#VEC04X			;;(Original in VSNDRM4 was LDX #VEC02X)
	BSR	PERK1			;;(Original in VSNDRM4 was BRA PERK1)
SQRT2	DECB
	BNE	ATARI
	RTS
PERK1	JSR	MOVE
	JSR	SING
	RTS
VEC03X	FDB	$2003,$FF50,$FF00
VEC04X	FDB	$5003,$0120,$FF00
;*
;*	MOVE PARAMETERS
;*
MOVE	LDAA	0,X
	STAA	FREQS
	LDAA	1,X
	STAA	CSFRQ
	LDAA	2,X
	STAA	DSFRQ
	LDAA	3,X
	STAA	ESFRQ
	LDAA	4,X
	STAA	CSAMP
	LDAA	5,X
	STAA	DSAMP
	RTS
;*
;*	DELTA F, DELTA A ROUTINE
;*
	;;(had to move AMP0 from $05 to $18)
SING	LDAA	AMP0			;GET STARTING AMPLITUDE	
	;;
SINGS	PSHB				;SAVE B				;;Fixme was: SING$
	LDAB	CSAMP			;GET CYCLES AT AMPLITUDE
	STAB	CSAMPS			;SAVE AS COUNTER
	LDAB	CSFRQ			;GET CYCLES AT FREQUENCY
	STAB	CSFRQS			;SAVE AS COUNTER
SING1	COMA				;INVERT AMPLITUDE
	LDAB	FREQS			;GET FREQUENCY COUNTER
	STAA	SOUND			;OUTPUT TO D/A
SING2	DECB
	BNE	SING2
	COMA				;INVERT AMPLITUDE
	LDAB	FREQS			;GET FREQUENCY COUNTER
	BRA	*+2			;-I
	INX				;-I
	DEX				;-I--- SYNC, 20 CYCLES
	INX				;-I
	DEX 				;-I
	STAA	SOUND			;OUTPUT TO D/A
SING3	DECB
	BNE	SING3
	DEC	CSFRQS			;CHECK CYCLES AT FREQUENCY
	BEQ	SING4			;GO CHANGE FREQUENCY
	DEC	CSAMPS			;CHECK CYCLES AT AMPLITUDE
	BNE	SING1			;ALL OK, GO OUTPUT
	COMA				;INVERT AMPLITUDE
	LDAB	CSAMP			;GET CYCLES AT AMPLITUDE
	STAA	SOUND			;OUTPUT TO D/A
	STAB	CSAMPS			;SAVE AS COUNTER
	LDAB	FREQS			;GET FREQUENCY COUNT
	ADDA	DSAMP			;ADD AMPLITUDE DELTA
	BMI	SING6			;RETURN FROM SUBROUTINE
	NOP				;SYNC, 2 CYCLES
	BRA	SING5
SING4	INX				;-I
	DEX				;-I--- SYNC, 10 CYCLES
	NOP				;-I
	COMA				;INVERT AMPLITUDE
	LDAB	CSFRQ			;GET CYCLES AT FREQUENCY
	STAA	SOUND			;OUTPUT TO D/A
	STAB	CSFRQS			;SAVE AS COUNTER
	LDAB	FREQS			;GET FREQUENCY COUNT
	SUBB	DSFRQ			;SUBTRACT FREQUENCY DELTA
	CMPB	ESFRQ			;COMPARE TO END FREQUENCY
	CMPB	ESFRQ			;SYNC, 3 CYCLES
	BEQ	SING6			;RETURN FROM SUBROUTINE
SING5	STAB	FREQS			;SAVE FREQUENCY COUNT
	SUBB	#$05			;SYNC TO FREQUENCY COUNTDOWN
	BRA	SING2			;JUMP INTO COUNTDOWN LOOP
SING6	PULB				;RESTORE B
	RTS
;*
;*
;;
;;	In VSNDRM10, there are two duplicate instructions
;;	at the very end of the main program.
;;	This must be a mistake, but to match up with the
;;	original rom, these instructions are included.
;;


	IFDEF	STEREO
OOPS	PULB				
	RTS
	ENDIF
	

	ORG	TALKJMP
TALKADX	JMP	ADDX
;*
;* VECTORS HERE
;*
	ORG	VECTOR
IRQV	FDB	IRQ
SWIV	FDB	SETUP
NMIV	FDB	NMI
RESETV	FDB	SETUP
	END	;CKSUM