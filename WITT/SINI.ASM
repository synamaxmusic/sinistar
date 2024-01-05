	PUSHORG	ROMSAVE
;*****
;*
;* SINI
;*	Intelligence routine for the Sinistar
;*
;* Needs:
;*	SinIndex -> Scanner workspace for the Sinistar
;*
;* Returns:
;*	NEVER - This task sleeps and wakes up again at the top.
;*
;*****
	ROUTINE	Sini
	pshs	A,B,X,Y,U	;* Save work registers

	ldd	Finish		;* If the Sinistar is
	cmpd	#Alive		;*   not yet built up
	lbne	.99S		;*   then it has no intelligence.

	ldy	[SinIndex]	;* Y -> scanner workspace
	jsr	Think		;* Effectively, thinking occurs
	lbcs	.99S		;*   on the Task16 list.

	jsr	upddtp		;* Update distance to player (for explosion)
	jsr	anisinistar	;* Else, it goes "chomp, chomp, chomp ..."
;***
;*	The orbital approach is reduced from a large orbit to a small orbit,
;*	eventually reaching no orbit at all.
;***
	ldb	OSPERS,Y	;* The personality byte of the Sinistar reflects
.10S	lda	OSPERS,Y	;*   the shooting inhibitor status.
	andb	#PSiniInhibit	;* If the inhibitor has already been cleared,
	beq	.12S		;*   then it is not counted down any further.
;***
;* Orbital radius:
;*	0 1 2 3 4 5 ... MaxSinOrbit*3/4 ... MaxSinOrbit
;*			      +-------------------+ Reduced at any time.
;*	+---------------------+ Reduced only on screen.
;***
	cmpb	#(MaxSinOrbit*3/4)	;* If the inhibitor is still within
	bgt	.11S		;*   the inner orbit (less than MaxSinOrbit*3/4)
	jsr	ScreenChk	;*   then wait until the Sinistar is on screen
	bcs	.12S		;*   before reducing it any further.
.11S	decb			;* Else, the inhibitor is counted down from its
.12S	pshs	B		;*   maximum value and stored back into the
	anda	#$F0		;*   personality (leaving the rest of the		;;Fixme was: anda  #!N(PSiniInhib) (More range underflow errors)
	ora	,S+		;*   traits unaffected, of course) and saved
	sta	OSPERS,Y	;*   for the next time the warrior awakens.
;*
.13S	tst	InStun		;* If the Sinistar stun timer
	beq	.20S		;*   is turned on then it must
	dec	InStun		;*   be counted down.
;***
;*	Chase the player!  (Ooooh!  It's scary boys and girls!)
;***
.20S	jsr	SiStopChk	;* If the Sinistar is under the kind of
	bcs	.99S		;*   duress that means it should stay still.
;*	Go ...
	ldx	[SinIndex]	;* Temporaily
	LDD	SINLP		;get sinistar last piece offsets
	PSHS	D		;save them
	LDD	#412		;offset for mouth
	STD	SINLP
	jsr	ReTarget	;*   retarget the Sinistar
	ldx	[PlaIndex]	;* X -> pseudo scanner workspace of PLAYER
	jsr	.100S		;* D = the LONG distance to player
	jsr	newvel		;* D = velocity to achieve
	jsr	updlvel		;* Update the long velocity
;*                              
	ldx	[PlaIndex]	;* X -> pseudo scanner workspace of PLAYER
	jsr	.200S		;* D = the SHORT distance to player
	jsr	newvel		;* D = velocity to achieve
	jsr	updsvel		;* Update the short velocity
	ldx	[SinIndex]	;* Untarget the Sinistar to
	jsr	UnTarget	;*   restore it's correct coordinates.
	PULS	D		;restore sinistar last piece offsets
	STD	SINLP

.99S	puls	A,B,X,Y,U	;* Restore work registers
	SLEEP	LOOP
;*
.100S	lda	OSPERS,Y
	anda	#PSiniInhibit
	beq	.102S
	ldb	SiniOrbit		;* Set orbital directon.
	cmpa	#MaxSinOrbit
	ble	.101S
	lda	#MaxSinOrbit
.101S	jsr	getlodistance
	ldx	#StblOSini
	rts
.102S	jsr	getldistance
	ldx	#STblSinistar								;;Fixme was: ldx  #STblSini
	rts
;*
.200S	lda	OSPERS,Y
	anda	#PSiniInhibit
	beq	.202S
	ldb	SiniOrbit		;* Set orbital directon.
	cmpa	#MaxSinOrbit
	ble	.201S
	lda	#MaxSinOrbit
.201S	jsr	getsodistance
	ldx	#StblOSini
	rts
.202S	jsr	getsdistance
	ldx	#STblSinistar								;;Fixme was: ldx  #STblSini
	rts
;*****
;*
;* SISTOPCHK
;*	Check if the Sinistar should stop.
;*
;* Needs:
;*	Y -> Sinistar scanner workspace
;*	InStun - (SET) When the Sinistar is stunned.
;*	AMDemo - (SET) The Sinistar does not chase when in demo mode.
;*	SinGrave - (SET) The Sinistar stops when dying (if on screen).
;*
;* Returns:
;*	CARRY CLEAR if it may KEEP GOING.
;*	CARRY  SET  if it SHOULD STOP.
;*
;*****
	ROUTINE	SiStopChk
	pshs	Y		;* Save work registers
;***
;*	A stun should stop the Sinistar
;***
	tst	InStun		;* If stunned,
	bne	.77S		;*   then zero the velocity.
;***
;*	A dying Sinistar should stop on screen.
;***
	tst	SinGrave	;* If the Sinistar is NOT dying,
	beq	.1S		;*   then it should chase the player.
	jsr	ScreenChk	;* If the Sinistar IS dying,
	bcc	.77S		;*   and on screen, then it should stop.
;***
;*	An attract mode demonstration Sinistar should stop on screen.
;***
.1S	tst	AMDemo		;* If the Sinistar is NOT in a demo
	beq	.2S		;*   then it can chase the player.
	jsr	ScreenChk	;* If the Sinistar IS in a demo,
	bcc	.77S		;*   and on screen, then it should stop.
;*
.2S	andcc	#~(CARRY)	;* GO.  Return with the carry bit clear.		;;Fixme was: andcc  #!N(CARRY)
	bra	.99S
;*
.77S	clr	OSLVEL,Y	;* Clear the scanner
	clr	OSSVEL,Y	;*   velocities.
	ldy	OSSCWSA,Y	;* If the Sinistar
	beq	.98S		;*   is on screen,
	CLRD			;*   then clear
	std	OLVEL,Y		;*   the screen
	std	OSVEL,Y		;*   velocities.
.98S	orcc	#CARRY		;* STOP.  Return with the carry bit set.
.99S	puls	Y		;* Restore work registers
	rts

	PULLORG	ROMSAVE

;	INCLVER	RICH,anisini		;* Sinistar animation
;	INCLVER	RICH,upddtc		;* Update distance package