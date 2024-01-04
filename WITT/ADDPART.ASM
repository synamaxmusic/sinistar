;	INCLVER	RICH,display		* Message display macros
;	INCLVER	RICH,speak		* Speech macro

	PUSHORG	ROMSAVE
;	SUBTTL	ADDPART
;*****
;*
;* ADDPART
;*	Build a part of the sinistar.  This routine also make the CLANG
;*	of the piece being added.  The sound occurs no matter where the
;*	Sinistar is within the universe.
;*
;* Calls:
;*	addpiece
;*
;* Needs:
;*	InWarp - NON-ZERO when the player is warping (the Sinistar should
;*		 not build up at that time).
;*
;* Returns:
;*	Nothing
;*
;*****
	ROUTINE	addpart
	pshs	D		;* Save work registers
	ldd	PiecePtr	;* If the Sinistar
	cmpd	Finish		;*   is built ...
	beq	.99S		;*   fully, then recover from a bad call.
	tst	InWarp		;* If the player is warping,
	bne	.99S		;*   the Sinistar shouldn't build up yet.

	jsr	addpiece	;* Build a part of the sinistar
	TUNE	QWorkSi		;* The sound of the sinistar building up!

	ldd	PiecePtr	;* If the Sinistar
	cmpd	Finish		;*   is built ...
	bne	.99S		;*   fully, then let him say so

	jsr	.100S		;* Say "Beware, I Live"

.99S	puls	D		;* Restore work registers
	rts

.100S	SPEAK	LiveSC		;* And then inhibit the Sinistar ...
	ROUTINE	Sinhibit
	pshs	A,Y		;* Save work registers
	ldy	[SinIndex]	;* Y -> Sinistar scanner workspace.
	RANDOM	OSEED1,BYTE	;* Randomize
	sta	SiniOrbit	;*   the Sinistar approach to the player.
	anda	#~(PSiniInhibit)						;;Fixme was: 	anda	#!N(PSiniInhibit)
	ora	#MaxSinOrbit	;* Establish a new personality
	sta	OSPers,Y	;*   with an initial maximum berth approach.
	puls	A,Y		;* Restore work registers
	rts

	PULLORG	ROMSAVE

;	INCLVER	RICH,anisini		* Sinistar animation routine and values