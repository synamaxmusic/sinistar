;	INCLUDE	[SAM]START

;	INCLVER	SAM,SINISTAR.EQU
BOBFIXES

;	INCLVER	SAM,SAM.SYM
;	INCLVER	RICH,RICH.SYM
;	INCLVER	NOAH,NOAH.SYM
;	INCLVER	BOB,BOB.SYM
	
;	INCLVER	BOB,ZBOBEQU
;	INCLVER	BOB,ZBOBOFF


;* Take the SINISECTOR <- -1 and INC DEATHFLAG out of Sinistar Explosion
	PUSHORG	$7F51
	RPT	6,NOP
	PULLORG


;* This causes ZZAMSINI to constantly force-feed the bomb mission on the player
;	LOCAL
	PUSHORG	$8CC8
	JSR	FIXZAM1
	PUSHORG	HISAV
FIXZAM1	LDX	[PLAINDEX]	;Player's workspace				;;Fixme was: 1$
	LDA	#OMWABOMB	;Bomb mission
	STA	OSMIS,X         
	LDD	SININDEX	;Pointer to Sinistar's workspace
	STD	OSCWCR,X	;This is the player's tail target
	LDA	#$FF		;Force feed
	STA	OCALPRI,X	;  the priority of this task
;*
	TST	BOMBS		;Restore trashed instruction
	RTS
	PULLORG	HISAV
	PULLORG


;* FIX ZZAMSINI  --  Change LDD	B,U to LDD A,U
	PUSHORG	$8CD8
	LDD	A,U
	PULLORG


;* This changes the location of FINIT in ZZATTRACT to include the copyright
	PUSHORG	$8183
	LBHS	$81A4
	PULLORG


;* THIS TINY LITTLE PATCH changes the Crystal Image from the yucky yellow
;*   to a beautiful white
;	LOCAL
	PUSHORG	$8E15
	FDB	FIXCRY1		;Address of crystal descriptor
	PUSHORG	HISAV
FIXCRY1	FDB	$0102,FIXCRY2	;Height/Width,Address of Image			;;Fixme was: 1$
FIXCRY2	FDB	$1111		;Image						;;Fixme was: 2$
	PULLORG	HISAV
	PULLORG


;* Change the bounce value after letter entry from MAXBNC*4 to 6
	PUSHORG	$8B0F
	FCB	MAXBNC*6
	PULLORG


;* This changes Rich's OMWaBomb routine to check for Sinistar onscreen
;*   before dropping bomb
;	LOCAL
	PUSHORG	$682B
	JSR	FXSOSB2
	BEQ	FXSOSB1		;If result of either test was zero, skip bombing
FXSOSB1	EQU	*+3									;;Fixme was: 1$  (FXSOSB1 = FiX Sinistar OnScreen Bomb 1)
	PUSHORG	HISAV
FXSOSB2	LDX	PIECEPTR	;Get the Sinistar Piece Pointer				;;Fixme was: 2$
	CMPX	#PIECETBL	;If it points to the bottom of the table
	BEQ	FXSOSB3		;  then there's nothing to shoot, so skip
	LDX	[SININDEX]	;Get Sinistar scanner WS				;;Fixme was: LDX  [SININD]
	LDX	OSSCWSA,X	;Get screen workspace address
FXSOSB3	RTS			;Go back with an equal or not-equal			;;Fixme was: 3$
	PULLORG	HISAV
	PULLORG

	
	RADIX	10									;;(decimal values ahead)
	
;* These are the Attract Demo adjusts
	PUSHORG	$525E
	FCB	5		;Number of bombs to start
	PULLORG
	PUSHORG	$5279
	FDB	(33*60)/2	;Timer for Phase 1					;;Fixme was: FDB  (33.*60.)/2
	PULLORG
	PUSHORG	$5287
	FDB	(60*60)		;Watchdog waits for 60. seconds				;;Fixme was: FDB  (60.*60.)
	PULLORG
	PUSHORG	$8C99
	FCB	8		;8 Sinibombs to initiate Phase 2			;;Fixme was: FCB  8.
	PULLORG
	PUSHORG	$8CBF
	FCB	16		;16. Crystal-Laden Workers				;;Fixme was: FCB  16.
	PULLORG
	PUSHORG	$8CE3
	FDB	(4*60)/8	;Time for Phase 3					;;Fixme was: FDB  (4*60.)/8
	PULLORG

	RADIX	16									;;(back to hex)

;* Change Sinistar Background Flasher from TASK4 to TASK1
	PUSHORG	$7F78
	FDB	TASK1
	PUSHORG	$7F7B
	FCB	$A8		;Adjust the timer value to about 2.75 seconds
	PULLORG
	PULLORG
;* This sucks.  Try task2 and put in variable wait before effecting next flash
;*   Also try different timer values to keep message from lasting to end of
;*   CONGRATS text.



;*	INCLVER	BOB,ZSTBLBOMB	New OMWaBomb Table



;*SinibombS and crystalS