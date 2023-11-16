newvel equ $6503
SinGrave equ $A1BB
ScreenChk equ $68CC
;===============================================================================
;	IFE	Version-17.
fixsini
	ORG	$6C2B		;* Remove 4 lines from SiStopChk
	RPT	$A,nop			;Fixme was: RPT 10,nop (we're using RADIX 16)
;	PULLORG
;***
;*	to be replaced by ...
;***
	ORG	$6BC5
	jsr	fixsini.100		;* Patch LONG vel.
;	PULLORG
	ORG	$6BD2
	jsr	fixsini.100		;* Patch SHORT vel.

	ORG	CR2SAVE
fixsini.100	jsr	newvel		;* < Patched over >
	tst	SinGrave
	beq	fixsini.99
	jsr	ScreenChk
	bcs	fixsini.99
	CLRA
	CLRB
fixsini.99	rts
;	PULLORG	CR2SAVE
CR2SAVE SET	*
	;IFGT	CR2SAVE-CR2LEN
	;ERR	CR2 OVFL
	;ENDIF	CR2
	;ENDIF	Version-17.

