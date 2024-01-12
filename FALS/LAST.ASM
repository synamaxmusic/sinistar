;	include [sam]start
;	Inclver SAM,SiniStar.equ

;	nlist
;	inclver	SAM,Sam.sym
;	inclver	RICH,Rich.sym
;	inclver	NOAH,Noah.sym
;	inclver	BOB,Bob.sym
;	list

;*			Cut down initials entry time by 1/2
	PushOrg	$88D1
	fdb	Maxetv/2
	PullOrg	
;*
;*			Change flashing rate
;*
	PushOrg	$7F7B
	fcb	$5A
	PullOrg
;*
;*
;*			Fix "Lost SiniBombs" bug by forcing end to game
;*		20 seconds after player dies.
;*
	PushOrg	PlxQue			;* patch in front of player explosion
	jmp	FLSTSB1
	PullOrg

	PushOrg	$FF90		;* take over f000 space

FLSTSB1	pshs	X									;;Fixme was: 1$ (FLSTSB1 = Fix LoST SiniBombs 1)
	New_Sleep	Task4,FLSTSB2,OMtLen+1
	clr	OMtLen,X
	puls	X
	jmp	Z_PlxQue		;* Jump to actual player explosion		;;Fixme was: jmp  ZPlxQue
;*
;*			Sleep task to insure death
;*
FLSTSB2	dec	OMtLen,Y		;* Decrement pass counter			;;Fixme was: 2$
	bne	FLSTSB3			;* If not a full count yet, keep going
;*
	clr	DeathFlag		;* Artificially make sure death occurs
;*
FLSTSB3	Sleep	LOOP									;;Fixme was: 3$
	PullOrg
;*
;*			Fix non-black screen on initialization
;*
	PushOrg	$F07F	;* Org over jsr clrscr before "initial tests indicate"
	jmp	$FFC0
	PullOrg

	PushOrg	$FFC0
	clr	$C000		;* Clear color 0
	clr	$CA01		;* Clear constant substit. byte
	jsr	ClrScr		;* Clear screen
	jmp	$F082		;* Go back to where we jumped from
	PullOrg
;*
;*
;*			Fix soundless sound line tests
;*
;	local
	PushOrg	$FEE4	;* org over incb, cmpb #7 in sound test
	jmp	$FFD0	;* jump to patch routine instead
	PullOrg
;*
	PushOrg	$FFD0
	incb
	cmpb	#3		;* see if we are at third line test
	bne	FIXSND1		;* if not, go on to other tests
	jmp	$FEE1		;* if so, skip third line, go to fourth
FIXSND1	cmpb	#6		;* See if we are done (do 5 lines only)			;;Fixme was: 1$
	jmp	$FEE7		;* Go back for branch on comparison
	PullOrg

;	local
;*			Fix to prevent player knocked offscreen
;*
	PushOrg	$4BCF
	fdb	ForceOn			;* Player off-screen routine vector
	PullOrg

	PushOrg	$FFB0
ForceOn	ldd	#$387A
	std	OBottom,Y		;* Stick player at mid-screen
	stb	OSPos,Y
	clr	OStatus,Y		;* Clear his clipping flags
	jmp	[OPDrwVe,Y]	;* Execute post-display routine, uses A,B,X,U

	PullOrg

;	END