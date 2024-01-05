;	include	start
;	INCLVER	SAM,Sinistar.equ
	PUSHORG	ROMSAVE

	PUSHORG	CWarrior+OOnScr
	fdb	WarrOn		;* Warrior on screen routine
	PULLORG

;*****
;*
;* WARRON
;*	Warrior On-Screen routine.  This routine is invoked when the warrior
;*	first comes on screen and is used to prepare the initial animation.
;*
;* Needs:
;*	X -> warrior object (screen) workspace
;*	Y -> warrior scanner workspace
;*	U -> warrior characteristics descriptor
;*
;* Returns:
;*	OSANANG,Y - The current animation angle set for onscreen animation.
;*
;*****
	ROUTINE	WarrOn
	pshs	A,B,X,Y		;* Save work registers
	ldb	OSMIS,Y		;* The warrior's mission
	andb	#%11111110	;*   (only even number missions allowed
	blt	.2S		;*    and neither may a mission go
	cmpb	#OMWaSav	;*    beyond the known mission id's			;;Fixme was: cmpb  #OMWaSave
	bge	.2S		;*    either is corrected in case of error.)
.1S	ldx	#.3S		;*   is used to determine how to aim the
	jmp	[B,X]		;*   warrior when first appearing on screen.

.2S	ldb	#OMWaDrift	;* Default in case of system error to drifting
	bra	.1S

.3S	fdb	.4S		;* Drift
	fdb	.5S		;* Attack
	fdb	.5S		;* Mine
	fdb	.5S		;* Guard
	fdb	.5S		;* Intercept

.4S	ldx	#SPLAYER	;* X -> psuedo object (screen) player workspace
	bra	.10S
.5S	ldx	[OSCWCR,Y]	;* X -> object (screen) workspace of caller
.10S	jsr	updflang	;* Set the angle of flight
	lda	OSFLANG,Y	;*   and use it
	sta	OSANANG,Y	;*   as the animation angle.
	puls	A,B,X,Y		;* Restore work registers
	jmp	VScrOn		;* Perform the remaining screen on jobs.

	PULLORG	ROMSAVE