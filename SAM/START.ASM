;       NLIST
;       NOGEN
;       IFNDEF  SSTART
;SSTART SET     *                               ;;(SymbolStart? Referenced in "WITT/EQUATES.TMP")
;
;INCMAC MACRO   I1,D1,F1                        ;;We don't need these two macros
;       IFNDEF  F1
;       MESSG   "INCLUDING [D1]F1"
;* I1F1
;       MLIST
;       INCLUDE [D1]F1
;       BLIST
;       ENDIF
;       ENDM

;INCLVER        MACRO   N1,F1
;       BLIST
;       IFIDN   <N1>,<NOAH>
;       INCMAC  N,LIBRARY.SINISTAR.FALS,F1
;       ELSE
;       IFIDN   <N1>,<RICH>
;       INCMAC  R,LIBRARY.SINISTAR.WITT,F1
;       ELSE
;       IFIDN   <N1>,<SAM>
;       INCMAC  S,LIBRARY.SINISTAR.SAM,F1
;       ELSE
;       IFIDN   <N1>,<BOB>
;       INCMAC  S,LIBRARY.SINISTAR.MICA,F1
;       ELSE
;       ERR     INCMAC  Z,N1,F1
;       ENDIF
;       ENDIF
;       ENDIF
;       ENDIF
;       MLIST
;       ENDM

        RADIX   16                              ;;(Messing around with this was causing too many issues.  Will have to manually use RADIX 10 for decimal)
;;
        ASSUME DPR:$98                          ;;Fixme was: SETDP  98 ({AS} doesn't support SETDP instruction)

;VERSION SET    17
;FINAL  SET     $7FFF
;.$PP   SET     0
;.$ORG0 SET     0
;.$ORG1 SET     0
;.$ORG2 SET     0
;.$ORG3 SET     0
;.$ORG4 SET     0
;.$ORG5 SET     0
;.$ORG6 SET     0

        INCLUDE "../SAM/MACROS.ASM"

;       ORG     -1                              ;;This was messing up the addresses for all the labels
        ORG     0
;       ENDIF

;       LOCAL
;       LIST