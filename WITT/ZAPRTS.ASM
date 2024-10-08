        MESSAGE "                       DEFINING ZAPRTS"                ;;Fixme was: MESSG
;       NLIST
;*****
;*
;* ZAPRTS
;*      This macro is used in place of a normal RTS instruction.
;*      The result of which is that if the copyright for Williams
;*      is still intact, the RTS will occur normally.  Otherwise,
;*      the RTS does not occur.  Used strategically, the effect is
;*      that the system will SLOWLY begin to degrade.  Please do NOT
;*      use this macro where the system will come to a halt.  That is
;*      too easily traced and fixed.
;*
;*****
ZAPRTS  MACRO
;       BLIST
        tst     KenChk
        lbge    rts
;       MLIST
        ENDM

;       IFE     1               <<< Not used.  Not assembled. >>>
;*
;       LIST
;       MESSG   "                       DEFINING ZAPSTACK"
;       NLIST
;*****
;*
;* ZAPSTACK
;*      This macro will cause a word to be cleared off the stack when
;*      the Copyright is violated.  Thus, the routine will return to
;*      the wrong place.
;*
;*****
;ZAPSTACK MACRO                                                         ;;(Not refereneced anywhere else so this is unused)
;       ZAPRTS
;       leas    2,s
;       rts
;       ENDM
;
;       LIST
;       MESSG   "                       DEFINING ZAPD"
;       NLIST
;*****
;*
;* ZAPD
;*      This macro will cause the values in the A and B registers to
;*      be altered if the Copyright is violated.
;*
;*****
;ZAPD   MACRO                                                           ;;(Not refereneced anywhere else so this is unused)
;       BLIST
;       addb    KenChk
;       MLIST
;       ENDM
;*
;       ENDIF   1               <<< Not used.  Not assembled. >>>
;
;       LIST