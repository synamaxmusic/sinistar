	ORG	ROMSAV
;*****
;*
;* DISPE   - Erases the message display area.
;* TDISPE  - Plays a tune and Erases the message display area.
;*
;* Needs:
;*	ScoreAddr = the address of the left edge of the message area.
;*	A = message tune priority
;*
;* Returns:
;*	MesgTime = -1 for no messages and a clear display.
;*
;*****
;	ROUTINE	tdispe
tdispe	CMPA	TNPRIO		;do we have priority?
	BLS	DISPE
	CLR	TNPRIO		;yes, zero old priority
	TUNE	QMesg		;* Display message tune.
	STA	TNPRIO		;set new message tune priority
;	ROUTINE	dispe
dispe	pshs	A,B,X		;* Save work registers
	lda	#-1		;* Reset the message flag
	sta	MesgTim		;*   to keep the Erase process sleeping.	;Fixme was: sta	MesgTime
	lda	PMEMCTL
	pshs	A
	ANDA	#-$5		;Fixme was: anda #!N(4)
	sta	PMEMCTL
	sta	MEMCTL
	ldd	#$0741!$0404	;* 404 is for DMA bug				;Fixme was: ldd #$0741!X$0404
	std	DHigh
	ldb	ScoreAd								;Fixme was: ldb	ScoreAdr
	lda	#$76
	std	DSour 
	std	DDest
	lda	#DCNS+DWBL	;* Draw constant, Write block
	sta	DCTRL
	puls	A
	sta	Pmemctl	
	sta	MemCtl
	puls	A,B,X		;* Restore work registers
	rts

;	PULLORG	ROMSAVE
ROMSAV	SET	*

;	INCLUDE "../WITT/DISP.ASM"	;* Message to player positioning
	INCLUDE "../WITT/ERASE.ASM"		;* Message erasing intelligence