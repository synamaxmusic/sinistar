;;===============================================================================
;;
;;   These are debug utilities from Rich's AOE.ASM file.  I have placed them here
;;   in this new file to make it easier to enable these debug functions.
;;
;;===============================================================================
;;
;;   Assembling up to Noah's module results in triggering the copyright protection.
;;   The scanner "fins" and score will be drawn on screen but the game won't start.
;;   Include this code to make the incomplete game playable.
;;
;;   This can also be useful for modding the game since KenChk is made to produce
;;   unwanted issues when checksums don't match up.
;;
;;   It probably goes without saying that you shouldn't include this code if you're
;;   trying to build the original ROM.
;;
;;===============================================================================

	IFDEF	DisableKenChk
;;	PUSHORG	ROMSAVE
	PUSHORG	$FFE0
	VECTOR	POWVECT
;	SYMVER	KENCHK,KENCHK
	clr	KENCHK
	rts
	VECTOR	IniVect
	clr	KenChk
	rts
;	PULLORG	ROMSAVE
	PULLORG
;	SYMVER	ZAPSIN,ZAPSini
	PUSHORG	ZAPSini		;* In the PowVect routine, ignore the
	tst	$0		;*   copyright violation test routine.
	PULLORG
	
;	PUSHORG $52D7
;	fcb	$7F		;Just clear KenChk no matter what.
;	PULLORG
	
	ENDIF
	
	
;;===============================================================================	
;*****
;*
;* WORK UTILITIES
;*
;*****
	IFDEF	BargraphEnable	;*****************************************
;	IFE	VERSION-9						;*
;	ENDIF	VERSION							;*
;	INCLUDE "../WITT/RICH.EQU"						;;We need Rich's work EQUs
	
GrafxSAV SET	$F4FB								;;Let's overwrite the cross hatch test

	INCLUDE "../SAM/bargraph.ASM"		;* <<< Bar Graphs >>>	 *    

;	PUSHORG	$F09C
;	JMP	$49F9
;	PULLORG
	
;	PUSHORG	$F07F								;;Disable Noah's patch in LAST.ASM
;	NOP
;	NOP
;	NOP
;	PULLORG
	
;	PUSHORG	Palette							;*
;	fcb	@067,@377,@277,@256,@255,@244,@232,@067			;*
;	fcb	@377,@311,@120,@113,@005,@007,@007,@067			;*
;	PULLORG                                                         
;;*									;*
;	PUSHORG	RAMSAV							;*	;;Fixme was: PUSHORG	RAMSAVE	
;JUNKTIME	rmb	2						;*
;	PULLORG	RAMSAV							;*	;;Fixme was: PULLORG	RAMSAVE
;;*									;*
;	PUSHORG	GRAFORG     							;;Fixme was: PUSHORG	ROMSAVE  (We're going to overwrite the rug test instead)
;;	LOCAL								;*
;	VECTOR	IniVect							;*
;	clr	JUNKTIME						;*
;	clr	JUNKTIME+1						;*
;	New_Sleep	Task64,.JUNK1S					;*	;;Fixme was: New_Sleep	Task64,1$
;	rts								;*
;;**									;*
;;*	Time clock							;*
;;**									;*
;.JUNK1S	pshs	D,X,U							;*	;;Fixme was: 1$	pshs	D,X,U
;	ldd	JUNKTIME						;*
;	addd	#(1*4)		;* Or (2*4) on the 128 list.		;*
;	std	JUNKTIME						;*
;	asla								;*
;	asla								;*
;	sta	Graph+GMinutes						;*
;	stb	Graph+GSeconds						;*
;	IF	1 = 1	;***************** This is turned off! ***********	;;Fixme was: IFE  1
;;**									*
;;*	Monitor Warrior Aggression					*
;;**									*
;	lda	WAgg			;* Monitor the high byte of	*
;	asla				;*   (shifted to scale)		*
;	sta	Graph+GAggression	;*   the warrior aggression	*
;;**
;;*	Monitor Missions
;;**
;	ldx	#Temp
;	clr	TGMWaDrift,X
;	clr	TGMWaAttack,X
;	clr	TGMWaMine,X
;	clr	TGMWaTail,X
;	clr	TGMWaInt,X
;
;	ldu	#Ground
;	cmpu	KeyClee+2
;	beq	.4S
;	ldu	[KeyClee+2]
;.2S	lda	OSMIS,U
;	cmpa	#OMWaSav
;	bge	.3S
;	asra
;	ldb	A,X	
;	addb	#(4*4)								;;Fixme was: addb  #(4.*4.)  (Is decimal really needed here?)
;	stb	A,X	
;.3S	ldu	[OSCTYPT,U]
;	cmpu	#Ground
;	bne	.2S
;
;.4S	lda	TGMWaDrift,X
;	sta	Graph+GMWaDrift
;	lda	TGMWaAttack,X
;	sta	Graph+GMWaAttack
;	lda	TGMWaMine,X
;	sta	Graph+GMWaMine
;	lda	TGMWaTail,X
;	sta	Graph+GMWaTail
;	lda	TGMWaInt,X
;	sta	Graph+GMWaInt
;	ENDIF	;1		;******* Turned off for now. *************
;	puls	D,X,U							;*
;	SLEEP	LOOP							;*
;	PULLORG GRAFORG								;;Fixme was: PULLORG	ROMSAVE

;	IFNDEF	ROM
;	PUSHORG	$FFF0								;; Let's restore the IRQ vectors in ROM 11 so that MAME can boot
;	FDB	RESTART,RESTART,RESTART,RESTART,IRQ,RESTART,RESTART,RESTART
;	PULLORG
;	ELSE
;	PUSHORG	$FFF0
;	FDB	PWRUP,PWRUP,PWRUP,PWRUP,IRQ,PWRUP,PWRUP,PWRUP	
;	PULLORG
;	ENDIF
				;*
	ENDIF	;Diagnose	;*****************************************
	
BCF	MACRO	A1,A2,A3
	IF 	A1 <> 0								;;Fixme was: IFN	A1
	FCB	A1
	ELSE
	RMB	1
	ENDIF
	IF 	A2 <> 0								;;Fixme was: IFN	A2
	FCB	A2
	ELSE
	RMB	1
	ENDIF
	IF	A3 <> 0								;;Fixme was: IFN	A3
	FCB	A3
	ELSE
	RMB	1
	ENDIF
	RMB	7
	ENDM
;;===============================================================================
;;
;;   Here's something I've never seen before.  Changing the IF to 1=1 here
;;   draws the letters "WITT" over the tiny Planetoid sprite in dark purple pixels.
;;
;;   To make it easier to enable, I added a new define called "WittRock" in MAKE.ASM
;;   that allows this to be included.
;;
;;===============================================================================
;	IF	1 = 0								;;Fixme was: IFE  1
	IFDEF	WITTROCK							;;Decided to comment out the original IF 1 = 0 for WittRock
	PUSHORG	$E4E
	BCF	$5B,$BB,$BB
	BCF	$B5,$00,$00
	BCF	$5B,$B5,$00
	BCF	$B6,$00,$00
	BCF	$AB,$BB,$BB							
	BCF	$00,$00,$00
	BCF	$AB,$BB,$BB
	BCF	$00,$00,$00
	BCF	$00,$00,$AB
	BCF	$AB,$BB,$BB
	BCF	$00,$00,$AB
	BCF	$00,$00,$00
	BCF	$00,$00,$AB
	BCF	$AB,$BB,$BB
	BCF	$00,$00,$AB
	PULLORG
	ENDIF

;	LIST
;	IFDEF	Debug		;*****************************************
;	PUSHORG	ROMSAVE							;*
;;*	Routine	Witt1							;*
;;*	lda	#$FF							;*
;;*	sta	PANMASK							;*
;;*	puls	Y							;*
;;*	jmp	DIE							;*
;;*									;*
;;	LOCAL								;*
;	SWITCH	START2,CLOSE	;* Fake out pickup			;*
;	LDA	BOMBS		;get sinibomb count			;*
;	INCA			;add one				;*
;	cmpa	#MAXBOMBS	;* If too many bombs are being held	;*
;	ble	WITDBG1		;*   then the crystal cannot be picked	;*
;	DISPLAY								;*
;	PHRASE	BLUE,35,CAPTAIN,OUR					;*
;	PHRASE	BLUE,35,BOMB,BAY,IS,FULL				;*
;	jsr	addpart							;*
;	DISPLAY								;*
;	PHRASE	WHITE,35,DEVELOPMENT					;*
;	PHRASE	WHITE,35,PIECE,ADDED					;*
;	rts								;*
;WITDBG1 STA	BOMBS		;save new sinibomb count		 *	;;Fixme was: 1$
;	LDB	#DWBL		;get dma constant to write sbomb display *
;	JSR	UPBOMBS		;update sinibomb display, save Y, uses A *
;	DISPLAY								;*
;	PHRASE	TANGREY,35,DEVELOPMENT					;*
;	PHRASE	TANGREY,35,BOMBS,ADDED					;*
;	rts								;*
;	PULLORG	ROMSAVE							;*
;	ENDIF	;Debug		;*****************************************

	IFDEF	InfiniteShips	;*****************************************	;;Fixme was: IFDEF  Debug (duplicate symbol)
	PUSHORG	ROMSAVE							;*
	VECTOR	IniVect							;*
	inc	Ships		;Player won't run out of ships		;*
	rts								;*
	PULLORG	ROMSAVE							;*
	ENDIF	;Debug		;*****************************************

	IFDEF	WitPop	;*************************************************
;	IFE	VERSION-9
;	ENDIF	VERSION
	PUSHORG	InPop0							;*
	fcb	0,2,0			;* Workers			;*
	fcb	0,2,0			;* Warriors			;*
	fcb	0,1,0			;* Type 1 Planets		;*
	fcb	0,1,0			;* Type 2 Planets		;*
	fcb	0,1,0			;* Type 3 Planets		;*
	fcb	0,1,0			;* Type 4 Planets		;*
	fcb	0,1,0			;* Type 5 Planets		;*
	PULLORG
;*									;*
	PUSHORG	Quota							;*
;*	     Work,Warr							;*
	fcb	1,0			;* For testing, planet quota	;*
	fcb	1,1			;* For testing, player quota	;*
	fcb	1,0			;* For testing, sinistar quota	;*
	fcb	9,9			;* For testing, sinibomb quota	;*
	PULLORG
;*									;*
	PUSHORG	MisAss			;*<<< MESSED UP! >>>		;*
;*		 Workers,Warriors			**  WARRIORS    ;*
	fcb	OMWoTail,OMWaDrift	;* Planets	* 0 = Drift	;*
	fcb	OMWoTail,OMWaDrift	;* Player	* 2 = Attack	;*
	fcb	OMWoTail,OMWaDrift	;* Sinistar	* 4 = Mine	;*
	fcb	OMWoInt,OMWaDrift	;* Sinibombs	* 6 = Guard	;*
	fcb	OMWoInt,OMWaInt		;* Crystals	* 8 = Intercept	;*
	PULLORG
;*
	PUSHORG	WarrMis			;*********************************
	rts				;* Drift			 *
;*	rmb	2			;* Attack Player		 *
;*	rmb	2			;* Mine Planet			 *
;*	rmb	2			;* Guard Object			 *
;*	rmb	2			;* Intercept Object		 *
	PULLORG
;*
	PUSHORG	RicPat
;	Local
	lda	#0
	ldu	#CWarrior
	sta	Temp
RICPAT1	dec	Temp								;;Fixme was: 1$
	bmi	RICPAT2
	jsr	[OInvec,U]
	jmp	RICPAT1
RICPAT2	rts									;;Fixme was: 2$
	PULLORG

	ENDIF	;WitPop	;*************************************************

	IFNDEF	Proms	;*************************************************
	PUSHORG	ROMSAVE							;*
;	LOCAL								;*
;*	VECTOR	PowVect							 *
;*	lda	#$1		For development, give lots of credits	 *
;*	sta	Credits							 *
;*	rts								 *
	PULLORG	ROMSAVE							;*
	ENDIF	;Proms	;*************************************************

	IFDEF	NoDeath								;;Fixme was: IFNDEF	Demo
	PUSHORG	DEATH
	rts		;************ TURN OFF PLAYER DEATHS *************
	PULLORG
	ENDIF	;Demo
;*
	IFDEF	Witt	;*************************************************
	PUSHORG	ROMSAVE							;*
;	LOCAL								;*
	VECTOR	IniVect		;****** BUILD THE SINISTAR ******	;*
	RADIX	10								;;(decimal value ahead)
	lda	#20							;*	;;Fixme was: lda	#20
	RADIX	16								;;(back to hex)
WITT1S	jsr	AddPiece						;*	;;Fixme was: 1$	
	deca								;*
	bgt	WITT1S							;*
	rts								;*
	PULLORG	ROMSAVE							;*
	PUSHORG	SHOOT
	rts
	PULLORG
	ENDIF	;Witt	;*************************************************
;*
;	LIST
;* * *	INCLVER	witt.dark,work0		* SYMVER checks
;* * *	INCLVER	sam.sav,symtest		* For symbol table checking

;	ENDTEST
;	END

;;===========================================================================
;;
;;     SSSS  Y   Y  N   N   AAA   M   M   AAA   X   X
;;    S       Y Y   NN  N  A   A  MM MM  A   A   X X 
;;     SSS     Y    N N N  AAAAA  M M M  AAAAA    X
;;        S    Y    N  NN  A   A  M   M  A   A   X X 
;;    SSSS     Y    N   N  A   A  M   M  A   A  X   X
;;
;;  This is new code that I put in for fixes and mods to make the game easier.
;;
;;===========================================================================
;;
;;   If DIAG/T13 are not assembled, then force IRQ vectors in blank ROM 11 so
;;   that the game can still boot in MAME.
;;
	
	IFNDEF	IRQVectors
	PUSHORG	$FFF0
	FDB	RESTART,RESTART,RESTART,RESTART,IRQ,RESTART,RESTART,RESTART
	PULLORG
	ENDIF

;;===========================================================================
;;
;;  Instead of nuking the Rug ROM/RAM tests, we are going to overwrite the
;;  cross hatch test, color bar tests and switch test instead.
;;

	IFDEF	DisableTests

	PUSHORG $F470  	;; overwrite JSR instructions for SWTEST, AVWAIT, and CRTEST with NOPs
			;; so we can skip them and overwrite $F71C - $F928
	
	RPT	9,NOP

	PULLORG
	
	
	PUSHORG $F4ED	;;replace "BSR	BARS" with NOPs so Auto cycle doesn't execute mod code
	
	NOP
	NOP
	
	PULLORG
	
	
	PUSHORG $F4F8	;; make TSTPAT skip color bar and cross hatch tests and go straight to booking
	
	JMP	BOOK	
	
	PULLORG

;;  $F4FB - $F928 are now clear (gives us $42C of space)

	ENDIF

;;===========================================================================
;;
;;  			<<< DEPRECATED!!! DON'T USE >>>
;;
;;   To avoid triggering KenChk, we force the program to skip the rug test
;;   on start up.  This is done by by overwriting the jump addresses that
;;   start the test with NOPs. 
;;
	IFDEF	EnableMods
	
	PUSHORG	$F063
	NOP
	NOP
	PULLORG
	
	PUSHORG $F069
	NOP
	NOP
	PULLORG
	
	PUSHORG $F06B
	NOP
	PULLORG
	
;;   We need this if the user wants to go into the operator service menu.
;;   A checksum test is done upon entering so let's reuse the debug code
;;   from T13.ASM that allows us to fake the ROM test.
	
	PUSHORG ROMTAB
	FCB	$00,$0	;0000
	FCB	$10,$0	;1000
	FCB	$20,$0	;2000
	FCB	$30,$0	;3000
	FCB	$40,$0	;4000
	FCB	$50,$0	;5000
	FCB	$60,$0	;6000
	FCB	$70,$0	;7000
	FCB	$80,$0	;8000
	FCB	$90,$0	;9000
	FCB	$A0,$0	;A000
	FCB	$B0,$0	;B000
	FCB	$C0,$0	;C000
	FCB	$D0,$0	;D000
	FCB	$E0,$0	;E000
	FCB	$F0,$0	;F000
	FCB	0
	FCB	$0	;CHECK BYTE (FUDGER) FOR THIS PART ($F000)
	PULLORG
	
;;===========================================================================
;;
;;  			<<< DEPRECATED!!! DON'T USE >>>
;;	
;;   Let's skip the ROM and RAM tests when we hit the service button.
;;   This has the side-effect of wiping away the screen graphics then waiting
;;   forever until the service/advance button (aka F2 in MAME) is pressed again.
;;   Continue hitting the service button to get to the Game Adjustments screen.
	
	IFDEF 	DiagnosticTestFix
	PUSHORG	$F003	;;This restores access to the diagnostic menu!
	JMP	DIAG3	;;Instead of JMP  ADVSWS, we're skiping the deleted RAM/ROM tests and going straight to CMOS test.
;	JMP	AUTO2   ;;(Do we need to replace Auto-cycle?)
	PULLORG
	ENDIF
	
	ENDIF

;;===========================================================================
;;
;;   The DEFALT table in SAM/TB13.ASM defines the default values for the
;;   game adjustments in the operator service menu. Here's a section of what
;;   it looks like:
;
;	DEFALT	FCB	$30	FIRST EXTRA SHIP AT
;		FCB	$30	ADDITIONAL POINTS PER EXTRA SHIP
;		FCB	$03	SHIPS PER GAME
;		FCB	$05	DIFFICULTY OF PLAY
;		FCB	$01	CONTINUOUS FIRE
;		...
;;
;;   Note that these are hex numbers, but are treated as decimal values.
;;   The default for "ADDITIONAL POINTS PER EXTRA SHIP" is 30.  In the menu,
;;   it's displayed as "Additional Extra Ship Point Factor" and is at 30,000.
;;   
;;   Extra ships are really difficult to score in Sinistar as opposed to other
;;   Williams titles. If you know what you're doing, you can easily rack up 
;;   extra lives in Robotron or Joust, but with the exponential bonus scores 
;;   in Sinistar (30k, 90k, 180k, etc), it's much harder to do so. 
;;
;;   Lowering this value all the way to zero treats the bonus scores
;;   in a more linear fashion: (30k, 60k, 90k, 120k, etc...).
;;
;;   In an amazing stroke of luck, we have confirmation that this value was
;;   not the original one intended.  In SAM/DEFAULT.SRC, we have an earlier
;;   version of the DEFALT table that's unused.  Let's take a look and compare:
;;
;	* * *DEFALT	
;		FCB	$30	FIRST EXTRA SHIP AT
;	* * *	FCB	$05	ADDITIONAL POINTS PER EXTRA SHIP
;	* * *	FCB	$03	SHIPS PER GAME
;	* * *	FCB	$05	DIFFICULTY OF PLAY
;	* * *	FCB	$01	CONTINUOUS FIRE
;		...
;;
;;   As you can see, additional points per extra ship is the only value
;;   that has changed and it's set to a much lover number of $05.
;;   The following code restores this number so that extra ships are
;;   easier to get.
;;
	IFDEF	ExtraShipFix
	
	PUSHORG	DEFALT+1	;;($493B)
	FCB	$05	;ADDITIONAL POINTS PER EXTRA SHIP
	PULLORG
	
	ENDIF

;;===========================================================================
	
	IFDEF	DisableSinistarCollision
	
	PUSHORG collision+$0A  ;;Skip to COLLIDE PLAYER,SINI
;;	COLLIDE	PLAYER,SINI
	rts		;;Make the player pass through the Sinistar
	PULLORG
	
	ENDIF

;;===========================================================================

	IFDEF	DifficultyMod
	
	PUSHORG CR_7
	
	NOP
	FCC	"POP. FIX MOD BY SYNAMAX 10/7/23 "
	RPT	8,NOP
	
	PULLORG
	
	PUSHORG	$7ae4	;;Reduce Warrior Increase rate for First Zone
	fcb	$04
	PULLORG
	
	PUSHORG	$7b04	;;Reduce Warrior Increase rate for Void Zone
	fcb	$04
	PULLORG
	
	PUSHORG	$7b24	;;Reduce Warrior Increase rate for Worker Zone
	fcb	$04
	PULLORG
	
	PUSHORG	$7b44	;;Reduce Warrior Increase rate for Warrior Zone
	fcb	$04
	PULLORG
	
	PUSHORG	$7b64	;;Reduce Warrior Increase rate for Planetoid Zone
	fcb	$04
	PULLORG
	
	PUSHORG $7b15	;;Reduce Warrior Desired Population for Worker Zone
	fcb	$00
	PULLORG
	
	PUSHORG	$7b35	;;Reduce Warrior Desired Population for Warrior Zone
	fcb	$03
	PULLORG
	
	PUSHORG	$7b55	;;Reduce Warrior Desired Population for Planetoid Zone
	fcb	$05
	PULLORG
	
;; Void Zone Warrior Initial Population is unmodified.



	ORG	$F35E
	FCB	$94	;7000
	
	ORG	$F36E
	FCB	$61	;F000	;;Fixme was: $57
	
	ORG	$FFDF
	FCB	$9F		;;Fixme was: $DA (Fudger byte)

	
	ENDIF

;;===========================================================================	
	
	IFDEF	QuickOperatorEntry
	
	PUSHORG	$8B0F
	FCB	MAXBNC	;;MAXBNC = 03 (original value was $0C, then patched in BOBFIXES.ASM to $12)
	PULLORG
	
	ENDIF
	
;;===========================================================================
	
MODSAV	SET	$F4FB		;; We're creating a new assembly counter called "MODSAV"
				;;  to keep track of all these mods.
	
	IFDEF	PauseMod	
;;
;;   First we insert a jump while the game is scanning the joystick.
;;   We do this instead of using SPANEL because the joystick is only enabled
;;   during gameplay, otherwise the player can pause the attract mode and
;;   the game will never actually start.
;;	
	PUSHORG	$361A		;;(hijack joystick scanning routine)
	JMP	PauseScan
	PULLORG
	
;;;
;;;   If the MarqueeFix mod is enabled, let's make room for it.
;;;   Doing this will overwrite ADVSWS but will still leave enough room to
;;;   leave the CMOS test alone.
;;;	
;	IFDEF	MarqueeFix
;	
;	PUSHORG $F370		;; If MarqueeFix is enabled, let's add the pause mod after it.
;	ELSE
;	PUSHORG $F09F		;; Otherwise, if the original title screen is used, just overwrite the rug tests.
;	ENDIF

;;
;;  Instead of nuking the Rug ROM/RAM tests, we are going to overwrite the
;;  cross hatch and color bar tests instead.
;;

	PUSHORG $F476  ;;overwrite "JSR	CRTEST" with NOPs so we can skip it and overwrite $F71C - $F7B8
	
	NOP
	NOP
	NOP
	
	PULLORG
	
	
	PUSHORG $F4ED	;;replace "BSR	BARS" with NOPs so Auto cycle doesn't execute mod code
	
	NOP
	NOP
	
	PULLORG
	
	PUSHORG $F4F8	;;make TSTPAT skip color bar and cross hatch tests and go straight to booking
	
	JMP	BOOK	
	
	PULLORG
	
	
;;  $F4FB - $F7B7 are now clear (gives us $2BC of space)
;;
;;  We can finally start the Pause Mod code

;	PUSHORG $F4FB
	
	IFNDEF	SAMTAIL		;;If Sam's Tail code is not defined, then we save at $F4FB
	PUSHORG	MODSAV
	ELSE			;;Otherwise, we'll run out of room so let's overwrtite the code that blinks the LED.
	
	ORG	$F300
	RPT 3,NOP		;;remove JMP PULSE
	
	ORG	$F434
	RPT 3,NOP		;;remove JMP PULSE
	
	PUSHORG $F211		;;Overwrite PULSE routine
	ENDIF
	
;;
;;  The PauseSTART and PauseCLR routines act very similar to how the "EMPTY" text is
;;  drawn in-game.  We have enough room in MESSAV that we can actually give the
;;  "PAUSED" string a new PhrNum and reference it just like all the other phrases!
;;	
	
PauseSTART	
	TEXT	WECO,$6C	;; Reuse the William Electronics "court check" vertical position, horizontal position $6C is dead center for "PAUSED"
	lda	#SDLOFF		;; Load WECO ($45) into A
	ldb	#SDSOFF		;; Load $6C into B
	tfr	D,X		;; We have to transfer both A/B registers to X because we need B for color
	WORD	YELLOW,68,PAUSED ;; Use 6x8 font and create "PAUSED" string for MESSAV
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE	SET	*		;; Save the current address

	ORG	PHRSAV		;; Jump over to PHRSAV to save our pointers
	FDB	_PAUSED		

PHRSAV	SET	*		;; Mark the new address for PHRSAV to add
				;; more phrases later

	ORG	ROMSAVE		;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PauseCLR
	TEXT	WECO,$6C	;; We clear the text by drawing it again 
	lda	#SDLOFF		;;   but this time we use black as the color
	ldb	#SDSOFF		
	tfr	D,X		
	WORD	BLACK,68,PAUSED	
	rts
	
;;
;;  Here is the actual code that pauses the game.  This code was originally
;;  written in 2008 for Joust by Chris Brooks @ Coinoplove.com.  I have rewritten
;;  it to work with Sinistar and use the modified "EMPTY" text routines above to
;;  display the new string.
;;	
	
PauseScan
	PSHS    D 
	LDA     PIA3		
	ANDA    #$10
	BEQ     PauseExit
	ORCC    #$10
	JSR     PauseDelay	;;go to delay subroutine
.1S	JSR     .4S		;;feed watchdog
	LDA     PIA3		;;did player hit P1 button?
	ANDA    #$10
	BNE     .1S		;;no? then go feed watchdog again
	JSR     PauseSTART	;;yes? draw "PAUSED" text
.3S	JSR     .4S		;;feed watchdog
	LDA     PIA3		
	ANDA    #$10
	BEQ     .3S 
	JSR     PauseDelay
.2S	JSR     .4S
	LDA     PIA3		
	ANDA    #$10
	BNE     .2S
	JSR     PauseCLR	;;player wants to resume play, let's go clear the "PAUSED" text
	JMP     PauseExit
.4S	LDB     #$39		;;Watchdog food
	STB     WDOG		;;Watchdog
	RTS

PauseDelay
	LDD     #$0200		;;let's waste some CPU cycles so we give the player time to react
.1S	DECB    
	BNE     .1S 
	DECA    
	BNE     .1S 
        RTS			;;let's go feed the watchdog
	
PauseExit PULS    D		;;grab D from stack 
	ANDCC   #$EF
	LDA	PIA+4		;read joystick pia (restore trashed instruction from $361A)
	JMP     $361D		;;go back to Game Logic	
	
	IFNDEF	SAMTAIL
	PULLORG MODSAV		;;Reuse MODSAV for more mods
	ELSE
	PULLORG			;;Otherwise, let's finish up overwriting PULSE routine.
	ENDIF
	
;;
;;  Checksum fixes
;;


	ORG	$F356
	FCB	$3B	;3000	;;Fixme was: $33

	ORG	$F36C
	FCB	$70	;E000	;;Fixme was: $F8

	ORG	$F36E
	FCB	$0E	;F000	;;Fixme was: $57
	
	ORG	$FFDF
	FCB	$F3		;;Fixme was: $DA (Fudger byte)


	ENDIF
	
;;===========================================================================	
	
	IFDEF	SAMTAIL
	
;	INCLUDE	START
;	INCLVER	SAM,SINISTAR.EQU
;	INCLVER	SAM,PLSUNIT

	PUSHORG	SRAMSAV
TAILDAT	RMB	$140		;tail random data		;;Fixme was: TAILDAT	RMB	140
	PULLORG	SRAMSAV

	PUSHORG	BASSAVE						;;Fixme was: PUSHORG	BASSAV
TAILL	RMB	1	;\	;tail l screen position
TAILS	RMB	1	;/	;tail s screen position
TAILDMA	RMB	1		;tail flavor
PLDRWVE	RMB	2		;player erase-update-draw vector
	PULLORG	BASSAVE						;;Fixme was: PULLORG	BASSAV

	PUSHORG	RAMSAV
TAILBUF	RMB	3*5		;tail data buffer
	PULLORG	RAMSAV

	PUSHORG	MODSAV						;;Fixme was: PUSHORG	ROMSAVE (We want to overwrite cross hatch test)

;* erase tail on player ship
ETAIL	LDX	OIDESC,Y
	LDD	#$305!$404	;* * * FOR DMA BUG		;;Fixme was: LDD  #305!X404
	STD	DHIGH
	LDD	TAILL
	STD	DDEST
	LDD	#TAILBUF
	STD	DSOUR
	LDA	TAILDMA
	ORA	#DCNS
	STA	DCTRL
	JMP	[PLDRWVE]

;* change image of tail on player ship
CTAIL	LDD	#ETAIL
	STD	ODRWVEC,Y
	LDD	#DOBJECT
	STD	PLDRWVE
	LDD	#TAIL
	STD	OPDRWVE,Y
;* draw tail in player ship
TAIL	LDB	PLACCEL
	LBEQ	NOPOST
	ASLB
	CLRA
	ADDD	#TAILDAT
	TFR	D,U
	FRANDOM	OSEED1,BYTE
	ANDA	#$3F						;;Fixme was: ANDA  #3F
	LEAU	A,U
	STU	DSOUR
	LDD	#TAILBUF
	STD	DDEST
	LDD	#$305!$404	;* * * FOR DMA BUG		;;Fixme was: LDD  #305!X404
	STD	DHIGH
	LDA	PMEMCTL
	PSHS	A
	ANDA	#~$4						;;Fixme was: ANDA #!N4
	STA	PMEMCTL
	STA	MEMCTL
	CLR	DCTRL
	LDD	#IDSBOMB
	STD	DSOUR
	LDA	#DXWT+DXWB+DCNS+DZSP
	STA	DCTRL
;*<<< optimize this >>>
	PULS	A
	STA	PMEMCTL
	STA	MEMCTL
	LDD	#TAILBUF
	STD	DSOUR
	LDB	OIDESC+1,Y
	SUBB	#IPLAYER&$FF					;;Fixme was: SUBB  #IPLAYER!.$FF
	LSRB
	LSRB
	LDX	#TAILTBL
	ABX
	LDA	1,X
	ADDA	OLEFT,Y
	STA	DDEST+1
	STA	TAILS
	LDA	X
	CLRB
	ASRA
	RORB
	ADDD	OLPOS,Y
	STA	DDEST
	STA	TAILL
	LDA	#DZSP+DSCY+DWBL	
	BCS	.1S						;;Fixme was: BCS  1$
	ORA	#DTFL
.1S	STA	DCTRL						;;Fixme was: 1$
	STA	TAILDMA
	JMP	NOPOST

;	LOCAL
;* initialize random tail data
	VECTOR	SYSVECT
	LDX	#TAILDAT
	CLRA
	LDB	#$C0						;;Fixme was: LDB	#0C0
	JSR	INITRAM
	JSR	INITRAM
	LDX	#PALETTE
	CLR	TEMP
TAIL1	LDA	X						;;Fixme was: 1$
	BEQ	TAIL2
	BITA	#$C0						;;Fixme was: BITA	#0C0
	BEQ	TAIL6
	BITA	#$30						;;Fixme was: BITA	#30
	BNE	TAIL2
TAIL6	LDA	#$40						;;Fixme was: 6$ LDA	#40
	STA	TEMP+1
TAIL5	RANDOM	OSEED1,BYTE					;;Fixme was: 5$
	ANDA	#$3F						;;Fixme was: ANDA  #3F
	JSR	SINCOS
	CLRB
	JSR	ASRD6
	PSHS	D
	RANDOM	OSEED2,BYTE
	TFR	A,B
	ANDB	#$7F						;;Fixme was: ANDB	#7F
	CLRA
	ADDD	S++
	LSRA
	RORB
	LDU	#TAILDAT
	LEAU	D,U
	LDA	U
	BCS	TAIL3
	ANDA	#$0F						;;Fixme was: ANDA	#0F
	STA	TEMP+2
	LDA	TEMP
	RPT	4,ASLA
	ORA	TEMP+2	
	BRA	TAIL4
TAIL3	ANDA	#$F0						;;Fixme was: 3$ ANDA	#0F0
	ORA	TEMP
TAIL4	STA	U						;;Fixme was: 4$
	DEC	TEMP+1
	BNE	TAIL5
TAIL2	INC	TEMP						;;Fixme was: 2$
	LEAX	1,X
	CMPX	#PALETTE+$10					;;Fixme was: CMPX  #PALETTE+10
	BLO	TAIL1
	RTS

	VECTOR	INIVECT
	CLRD
	STD	TAILL		;zero tail screen position
;*<<< add to player initialization >>>
	LDD	#DOBJECT	;initialize player erase-update-draw vector
	STD	PLDRWVE
	LDD	#ETAIL		;give player erase tail erase-update-draw vector
	STD	ODRWVEC+WPLAYER
	LDD	#TAIL		;give player tail post-draw vector
	STD	OPDRWVE+WPLAYER
	RTS

;;  
;;  We're very lucky to have the original addresses here
;;  match up with the earlier AMOA '82 build.  This helped
;;  me figure out where the instructions were located in
;;  the final build.  This patch was off by one byte, but
;;  the other patch was way off.
;;
;;  Old patch addresses:
;;	$3789
;;	$6F51
;;
;;  New patch addresses:
;;	$378A
;;	$736D
;;

;* patch to player image rotation
;	ERR	OLD ADDRESS
	PUSHORG	$378A						;;Fixme was: PUSHORG	$3789
	JSR	TA100S						;;Fixme was: JSR	100$
	PULLORG
TA100S								;;Fixme was: 100$
;* * *
	STX	PLDRWVE
	LDD	#CTAIL		;give player change tail post-draw vector
	STD	OPDRWVE,Y
;* * *
	RTS

;* tail offset table
TAILTBL	FDB	$FC02,$FC02,$FD01,$FDFF,$FFFE,$FFFD,$00FD,$FFFD
	FDB	$02FB,$02FD,$05FD,$05FD,$07FE,$08FF,$0900,$0A01
	FDB	$0A03,$0A02,$0905,$0905,$0707,$0509,$040A,$020A
	FDB	$020A,$020A,$010A,$0009,$FF08,$FD05,$FD05,$FC02

;*<<< for Noah >>>
;	ERR	OLD ADDRESS
	PUSHORG $736D						;;Fixme was: PUSHORG	$6F51
	JSR	TA101S						;;Fixme was: JSR	101$
	PULLORG
TA101S								;;Fixme was: 101$
;* * *
	LDD	#NOPOST		;turn off player's tail
	STD	OPDRWVE,X
;* * *
  	JSR	PLXQUE			;* START UP PLAYER EXPLOSION
	RTS

	PULLORG MODSAV						;;Fixme was: PULLORG ROMSAVE
	
	ENDIF
	
	
	
	
	
	
	
	
;	IFDEF	QuickBuild	;************************************************* 
;	PUSHORG	ROMSAVE							;*
;;	LOCAL								;*
;	VECTOR	IniVect		;****** BUILD THE SINISTAR ******	;*
;	RADIX	10								;;(decimal value ahead)
;	lda	#10							;*	;;Fixme was: lda	#20
;	RADIX	16								;;(back to hex)
;;WITT1S	jsr	AddPiece						;*	;;Fixme was: 1$	
;WITT1S	jsr	AddPart								;;(changing to AddPart seems to work a little bit better but player explosion lags and explosion sprite doesn't animate for some reason)
;	deca								;*
;	bgt	WITT1S							;*
;	rts								;*
;	PULLORG	ROMSAVE							;*
;	ENDIF	;Witt	;*************************************************