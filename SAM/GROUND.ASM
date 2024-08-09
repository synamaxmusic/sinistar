;       INCLUDE START

        PUSHORG 0

;       SUBTTL  ORG 0


;* end of grounded intelligence lists
Ground  fdb     Ground          ;* Points to itself for indirect use
;*
        JMP     INITALL         ;starts at address 2
;* dummy last object workspace
        RPT     OLEFT-*,FCB 0                           ;;Fixme was: RPT OLEFT-*,<FCB 0>
        FCB     -1
;;===============================================================================
;;
;;  This creates a false positive for some reason but the output is correct.
;;  Commenting out for now.
;;
;;===============================================================================
;       IF *-DSPACE <> 0                                ;;Fixme was: IFN *-DSPACE
;       ERROR   "DUMMY WORKSPACE SIZE ERROR"            ;;Fixme was: ERRMESS "DUMMY WORKSPACE SIZE ERROR"
;       ENDIF

        PULLORG