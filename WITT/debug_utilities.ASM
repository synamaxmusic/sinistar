;;===============================================================================
;;
;;   These are debug utilities from Rich's AOE.ASM file.  I have placed them here
;;   in this new file to make it easier to enable these debug functions.
;;
;;===============================================================================
;*****
;*
;* WORK UTILITIES
;*
;*****
	IFDEF	BargraphEnable	;*****************************************
;	IFE	VERSION-9						;*
;	ENDIF	VERSION							;*
	INCLUDE "../WITT/RICH.EQU"						;;We need Rich's work EQUs
	
	
	
GRAFORG	SET	$F09F								;;Let's overwrite the ROM/RAM test 

	INCLUDE "../SAM/bargraph.ASM"		;* <<< Bar Graphs >>>	 *       
	PUSHORG	Palette							;*
	fcb	@067,@377,@277,@256,@255,@244,@232,@067			;*
	fcb	@377,@311,@120,@113,@005,@007,@007,@067			;*
	PULLORG                                                         
;*									;*
	PUSHORG	RAMSAV							;*	;;Fixme was: PUSHORG	RAMSAVE	
JUNKTIME	rmb	2						;*
	PULLORG	RAMSAV							;*	;;Fixme was: PULLORG	RAMSAVE
;*									;*
	PUSHORG	GRAFORG     							;;Fixme was: PUSHORG	ROMSAVE  (We're going to overwrite the rug test instead)
;	LOCAL								;*
	VECTOR	IniVect							;*
	clr	JUNKTIME						;*
	clr	JUNKTIME+1						;*
	New_Sleep	Task64,.JUNK1S					;*	;;Fixme was: New_Sleep	Task64,1$
	rts								;*
;**									;*
;*	Time clock							;*
;**									;*
.JUNK1S	pshs	D,X,U							;*	;;Fixme was: 1$	pshs	D,X,U
	ldd	JUNKTIME						;*
	addd	#(1*4)		;* Or (2*4) on the 128 list.		;*
	std	JUNKTIME						;*
	asla								;*
	asla								;*
	sta	Graph+GMinutes						;*
	stb	Graph+GSeconds						;*
	IF	1 = 1	;***************** This is turned off! ***********	;;Fixme was: IFE  1
;**									*
;*	Monitor Warrior Aggression					*
;**									*
	lda	WAgg			;* Monitor the high byte of	*
	asla				;*   (shifted to scale)		*
	sta	Graph+GAggression	;*   the warrior aggression	*
;**
;*	Monitor Missions
;**
	ldx	#Temp
	clr	TGMWaDrift,X
	clr	TGMWaAttack,X
	clr	TGMWaMine,X
	clr	TGMWaTail,X
	clr	TGMWaInt,X

	ldu	#Ground
	cmpu	KeyClee+2
	beq	.4S
	ldu	[KeyClee+2]
.2S	lda	OSMIS,U
	cmpa	#OMWaSav
	bge	.3S
	asra
	ldb	A,X	
	addb	#(4*4)								;;Fixme was: addb  #(4.*4.)  (Is decimal really needed here?)
	stb	A,X	
.3S	ldu	[OSCTYPT,U]
	cmpu	#Ground
	bne	.2S

.4S	lda	TGMWaDrift,X
	sta	Graph+GMWaDrift
	lda	TGMWaAttack,X
	sta	Graph+GMWaAttack
	lda	TGMWaMine,X
	sta	Graph+GMWaMine
	lda	TGMWaTail,X
	sta	Graph+GMWaTail
	lda	TGMWaInt,X
	sta	Graph+GMWaInt
	ENDIF	;1		;******* Turned off for now. *************
	puls	D,X,U							;*
	SLEEP	LOOP							;*
	PULLORG GRAFORG								;;Fixme was: PULLORG	ROMSAVE

	IFNDEF	ROM
	PUSHORG	$FFF0								;; Let's restore the IRQ vectors in ROM 11 so that MAME can boot
	FDB	RESTART,RESTART,RESTART,RESTART,IRQ,RESTART,RESTART,RESTART
	PULLORG
	ELSE
	PUSHORG	$FFF0
	FDB	PWRUP,PWRUP,PWRUP,PWRUP,IRQ,PWRUP,PWRUP,PWRUP	
	PULLORG
	ENDIF
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

	IFDEF	InfiniteShips		;*****************************************	;;Fixme was: IFDEF  Debug (duplicate symbol)
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
	
;;   Let's skip the ROM and RAM tests when we hit the service button.
;;   This has the side-effect of wiping away the screen graphics as the
;;   CMOS test runs.  Continue hitting the service button to get to the 
;;   Game Adjustments screen.
	
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
	
	ENDIF