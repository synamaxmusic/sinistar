	PUSHORG	ROMSAVE
;*****
;*
;* SCREENCHK
;*	Check to see if the object is on-screen
;*
;* Needs:
;*	Y -> scanner workspace of object
;*
;* Returns:
;*	CARRY CLEAR if ON SCREEN
;*	CARRY SET   if OFF SCREEN
;*
;*	This follows the CARRY SET on ERROR convention.
;*
;*****
screenchk
	pshs	D		;* Save work registers
	CLRD			;* Check if the object is on the screen, as
	cmpd	OSSCWSA,Y	;*   indicated by the workspace pointer.
	puls	D		;* Restore work registers
	beq	.1S		;* If on screen,
	andcc	#~(CARRY)	;*   return with the carry bit clear.			;;Fixme was: andcc  #!N(CARRY)
	rts                     
.1S	orcc	#CARRY		;* Else, mark it off screen with the carry set.
	rts

	PULLORG	ROMSAVE