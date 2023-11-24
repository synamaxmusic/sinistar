	INCLUDE "../WITT/ZAPRTS.ASM"		;* Copyright checking RTS macro

;===============================================================================
; EQUs to remove later

;===============================================================================

	ORG	ROMSAV
;	SUBTTL	EMPTY - Conditionally displays EMPTY message in sinibomb area.
;*****
;*
;* EMPTY
;*	A test is made to determine if there are sinibombs in the bomb bay.
;*	If the bay is empty, the word "EMPTY" appears in the sinibomb display.
;*
;* Needs:
;*	Bombs	= The number of Sinibombs in the bomb bay.
;*	scoreaddr - SHORT position of player 1 or player 2 message area
;*
;* Returns:
;*	Condition code Z bit = 1 if there are bombs in bay.
;*		       Z bit = 0 if the bomb bay is empty.
;*
;*****
;	Routine	Empty
Empty	tst	Bombs		;* If there are bombs in the bomb bay,
	bne	EMPTY99		;*   no warning message is needed.			;;Fixme was: bne .99S (had to make global label)
	pshs	A,B,X,Y,CC	;* Save work registers
	TEXT	$8A,$00		;* Warn player of empty bomb bay.
	lda	#SDLOFF		;* <Normally the PHRASE macro is used here to		;;Fixme was: .$DLOFF
	ldb	ScoreAddr	;*  display the word, bu the TEXT MACRO is not
	tfr	D,X		;*  set up to handle two player switching yet.>
	WORD	YELLOW,68,EMPTY 
	puls	A,B,X,Y,CC	;* Restore work registers
EMPTY99	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAV	SET	*		;; Save the current address

	ORG	PHRSAV		;; Jump over to PHRSAV to save our pointers
	FDB	_EMPTY		

PHRSAV	SET	*		;; Mark the new address for PHRSAV to add
				;; more phrases later

	ORG	ROMSAV		;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	SUBTTL	NOTEMPTY - Erases EMPTY message from sinibomb display area.
;*****
;*
;* NOTEMPTY
;*	Erases the "EMPTY" message from the sinibomb display area.
;*
;* Needs:
;*	scoreaddr - SHORT position of player 1 or player 2 message area
;*
;* Returns:
;*	Nothing - but only if the copyright is still intact.
;*
;*****
;	Routine	NotEmpty
NOTEMPTY pshs	A,B,X,Y		;* Save work registers
	TEXT	$8A,$00		;* Clear the message regarding an empty bomb bay
	lda	#SDLOFF		;* <Normally the PHRASE macro is used here to		;;Fixme was: .$DLOFF
	ldb	ScoreAddr	;*  display the word, bu the TEXT MACRO is not
	tfr	D,X		;*  set up to handle two player switching yet.>
	WORD	BLACK,68,EMPTY  
	puls	A,B,X,Y		;* Restore work registers
	ZAPrts			;* RTS if copyrighted.

;	PULLORG	ROMSAVE
ROMSAV	SET	*