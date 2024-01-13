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

	
	PUSHORG	$FFF0								;; Let's restore the IRQ vectors in ROM 11 so that MAME can boot
	FDB	RESTART,RESTART,RESTART,RESTART,IRQ,RESTART,RESTART,RESTART
	PULLORG
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

	IFNDEF	Demo
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