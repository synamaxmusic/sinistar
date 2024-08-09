;* Collision macros:

;* initialize collision for an object type
MAKECOL MACRO   N1
;       BLIST
L_N1    set     CLCOUNT
M_N1    SET     0
CLCOUNT SET     CLCOUNT+1
        IF CLCOUNT-NCOLLIS>0                    ;;Fixme was: IFGT CLCOUNT-NCOLLIS
        MESSAGE "CLCOUNT OVFL"                  ;;Fixme was: MESSG
        ENDIF
;       MLIST
        ENDM

;* handle a collision
COLLIDE MACRO   N1,N2
;       BLIST
        IF $4000>>L_N2&M_N1 <> 0                ;;Fixme was: IFN 4000!>LN2!.MN1
        MESSAGE "DUP COL N1,N2"
        ENDIF
M_N1    SET     4000>>L_N2|M_N1         ;;Fixme was: 4000!>LN2!+MN1 (!+ is Logical Or according to BSO but it's actually BINARY OR!)
M_N2    SET     4000>>L_N1|M_N2         ;;Fixme was: 4000!>LN1!+MN2

SS      SET     *                               ;;Fixme was: .$$
        IF      L_N1-L_N2<=0                    ;;Fixme was: IFLE LN1-LN2
        ORG     CLTABLE+L_N2*(L_N2+1)+2*L_N1    ;;Fixme was: ORG  CLTABLE+LN2*(LN2+1)+2*LN1
        FDB     SS
        ORG     SS
        ELSE
        ERROR   "SWAP N1,N2"
        ENDIF
;       MLIST
        ENDM