;===============================================================================
; EQUs to remove later
;ADDPART EQU	$5D7B	;ADDPART
;===============================================================================
	PUSHORG	ROMSAVE
;*****
;*
;* LSWOCR
;*	Leaving Sector routine for a Worker with a Crystal.
;*	This automatically intercepts the sinistar and becomes another
;*	piece of it when the Sinistar is out of the sector too.
;*
;* Needs:
;*	Y -> scanner workspace of worker leaving the sector
;*	U -> characteristics descriptor of worker leaving the sector
;*	SiniSector	- non-zero when the sinistar is out of sector
;*		 zero when the sinistar is within the sector
;*
;* Returns:
;*	Nothing
;*
;*****
	PUSHORG	CWorkCr+OLSVec
	fdb	LSWoCr
	PULLORG

	ROUTINE	LSWoCr
	tst	SiniSector	;* If the sinistar is not out of the
	beq	.1S		;*   sector, the worker cannot transform.
	jsr	addpart		;* Become part of the sinistar
.1S	pshs	X		;* Save work registers
	leax	Y		;* Y -> worker scanner workspace
	jsr	[OKiVec,U]	;* Kill worker and crystal
	puls	X		;* Restore work registers
	rts

	PULLORG	ROMSAVE

	INCLUDE "../WITT/ADDPART.ASM"		;* Build up the sinistar