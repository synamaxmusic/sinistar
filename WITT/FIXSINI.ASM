;	IFE	Version-17.
fixsini
	PUSHORG	$6C2B		;* Remove 4 lines from SiStopChk
	RADIX	10							;;(decimal value ahead)
	RPT	10,nop							;;Fixme was: RPT  10.,nop
	RADIX	16							;;(back to hex)
	PULLORG
;***
;*	to be replaced by ...
;***
	PUSHORG	$6BC5
	jsr	FIXSIN1		;* Patch LONG vel.
	PULLORG
	PUSHORG	$6BD2
	jsr	FIXSIN1		;* Patch SHORT vel.
	PULLORG
;;===============================================================================
;;
;;   The devs were running out of space so this patch overwrites the first
;;   Copyright string that appears in the Sinistar ROM ($2DFB).
;;
;;===============================================================================
	PUSHORG	CR_2							;;Fixme was: PUSHORG	CR2SAVE
FIXSIN1	jsr	newvel		;* < Patched over >			;;Fixme was: 100$
	tst	SinGrave
	beq	FIXSIN2
	jsr	ScreenChk
	bcs	FIXSIN2
	CLRD
FIXSIN2	rts								;;Fixme was: 99$
	PULLORG	CR_2							;;Fixme was: PULLORG	CR2SAVE
;	IF CR_2SAVE-CR2LEN						;;Fixme was: IFGT	CR2SAVE-CR2LEN
;	ERROR	CR2 OVFL						;;Fixme was: ERR	CR2 OVFL
;	ENDIF	;CR2
;	ENDIF	Version-17.