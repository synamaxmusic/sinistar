;	NLIST
;*****
;*
;* Speak	{1,2,3,4,5,6,7,8,9,10.,11.}
;*
;*****
SPEAK	MACRO	ARG
	IF ARG < 0			;;Fixme was: IFLT	ARG
	ERROR	SPEAK VAL               ;;Fixme was: ERR	SPEAK VAL
	ENDIF                           ;;Fixme was: ENDIF
	IF ARG-$0B > 0                  ;;Fixme was: IFGT	ARG-11.
	ERROR	SPEAK VAL               ;;Fixme was: ERR	SPEAK VAL
	ENDIF                           ;;Fixme was: ENDIF
	jsr	AniSCS
	fcb	ARG
	ENDM

;	LIST