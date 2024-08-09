;       INCLUDE "../SAM/START.ASM"
;SDLOFF SET     0
;SDSOFF SET     0
;SCOLR  SET     0
;SDISP  SET     0
;       MESSG   "                       DEFINING TEXT"
;       NLIST
;*****
;*
;* TEXT
;*      This macro positions to any place on the screen.  Note that it
;*      1) Does not automatically get messages erased (like DISPLAY does)
;*      2) Does not depend on the player number (like DISPLAY does)
;*
;*****
TEXT    MACRO   LONGPOS,SHORTPOS,{NOEXPAND}     ;;Fixme was: TEXT MACRO L1,S1
;       NLIST
SDLOFF  SET     LONGPOS                         ;;Fixme was: .$DLOFF
SDSOFF  SET     SHORTPOS                        ;;Fixme was: .$DSOFF
SCOLR   SET     $100                            ;;Fixme was: .$COLR
SDISP   SET     rts                             ;;Fixme was: .$DISP
;       LIST
;       NMLIST
        ENDM

        ;LIST
        ;MESSG  "                       DEFINING PHRASE"
        ;NLIST
;*****
;*
;* PHRASE       COLOR,SIZE,<LIST,OF,WORDS>
;* WORD         COLOR,SIZE,SINGLEWORD
;*
;*      COLOR   may be BLACK, BLUE, RED or YELLOW
;*      SIZE    may be 35 for 3x5
;*                  or 68 for 6x8
;*
;* Example:
;*      LINE    RED,35,<hello,mike>
;*
;* Bugs:
;*      No error is reported if you forget to DISPLAY before the PHRASE.
;*      No error is reported if you forget to PHRASE before the WORD.
;*      The WORD macro does not actually use the equates CA, CB, etc. but
;*              instead generates the correct values.  This works only for
;*              alphanumerics (0-9, A-Z and ' ').
;*
;*****
PHRASE  MACRO   C1,S1,W1,W2,W3,W4,W5,W6,W7,W8
;       NLIST
        IF S1<>35                       ;Fixme was: IFNIDN      <S1>,<35>
SDLOFF  SET     SDLOFF-2                ;Fixme was: .$DLOFF SET .$DLOFF-2
        ENDIF
;       LIST
        ldx     #(SDLOFF<<8)+SDSOFF     ;Fixme was: ldx #.$DLOFF!<8+.$DSOFF
        jsr     SDISP                   ;Fixme was: jsr .$DISP
;       NMLIST
        IFNB    W1
        WORD    C1,S1,W1
        ENDIF
        IFNB    W2
        WORD    C1,S1,W2
        ENDIF
        IFNB    W3
        WORD    C1,S1,W3
        ENDIF
        IFNB    W4
        WORD    C1,S1,W4
        ENDIF
        IFNB    W5
        WORD    C1,S1,W5
        ENDIF
        IFNB    W6
        WORD    C1,S1,W6
        ENDIF
        IFNB    W7
        WORD    C1,S1,W7
        ENDIF
        IFNB    W8
        WORD    C1,S1,W8
        ENDIF
SDLOFF  SET     SDLOFF-4                ;Fixme was: .$DLOFF SET .$DLOFF-4
        IF S1<>35                       ;Fixme was: IFNIDN      <S1>,<35>
SDLOFF  SET     SDLOFF-2                ;Fixme was: .$DLOFF SET .$DLOFF-2
        ENDIF
;       BLIST
        ENDM


;       LIST
;       MESSG   "                       DEFINING WORD"
;       NLIST
WORD    MACRO   COLOR,SIZ,TXT           ;Fixme was: WORD MACRO  COLOR,SIZ,TXT
        IF      COLOR<>SCOLR
        LDB     #COLOR
SCOLR   SET     COLOR
        ENDIF
SS      SET     *
        IFNDEF  _TXT
        ORG     MESSAV
_TXT    SET     *
        IRPC    CHAR,"TXT"
        IF ("CHAR"="\32")
        FCB     CSPC
        ELSEIF ("CHAR"="\H")
        FCB     CSQOT
        ELSEIF ("CHAR"="0")
        FCB     $00
        ELSEIF ("CHAR"="1")
        FCB     $01
        ELSEIF ("CHAR"="2")
        FCB     $02
        ELSEIF ("CHAR"="3")
        FCB     $03
        ELSEIF ("CHAR"="4")
        FCB     $04
        ELSEIF ("CHAR"="5")
        FCB     $05
        ELSEIF ("CHAR"="6")
        FCB     $06
        ELSEIF ("CHAR"="7")
        FCB     $07
        ELSEIF ("CHAR"="8")
        FCB     $08
        ELSEIF ("CHAR"="9")
        FCB     $09
        ELSEIF ("CHAR"="A")
        FCB     $0B
        ELSEIF ("CHAR"="B")
        FCB     $0C
        ELSEIF ("CHAR"="C")
        FCB     $0D
        ELSEIF ("CHAR"="D")
        FCB     $0E
        ELSEIF ("CHAR"="E")
        FCB     $0F
        ELSEIF ("CHAR"="F")
        FCB     $10
        ELSEIF ("CHAR"="G")
        FCB     $11
        ELSEIF ("CHAR"="H")
        FCB     $12
        ELSEIF ("CHAR"="I")
        FCB     $13
        ELSEIF ("CHAR"="J")
        FCB     $14
        ELSEIF ("CHAR"="K")
        FCB     $15
        ELSEIF ("CHAR"="L")
        FCB     $16
        ELSEIF ("CHAR"="M")
        FCB     $17
        ELSEIF ("CHAR"="N")
        FCB     $18
        ELSEIF ("CHAR"="O")
        FCB     $19
        ELSEIF ("CHAR"="P")
        FCB     $1A
        ELSEIF ("CHAR"="Q")
        FCB     $1B
        ELSEIF ("CHAR"="R")
        FCB     $1C
        ELSEIF ("CHAR"="S")
        FCB     $1D
        ELSEIF ("CHAR"="T")
        FCB     $1E
        ELSEIF ("CHAR"="U")
        FCB     $1F
        ELSEIF ("CHAR"="V")
        FCB     $20
        ELSEIF ("CHAR"="W")
        FCB     $21
        ELSEIF ("CHAR"="X")
        FCB     $22
        ELSEIF ("CHAR"="Y")
        FCB     $23
        ELSEIF ("CHAR"="Z")
        FCB     $24
        ELSEIF ("CHAR"="!")
        FCB     CEXC
        ELSEIF ("CHAR"="(")
        FCB     CBRKL
        ELSEIF ("CHAR"=")")
        FCB     CBRKR
        ELSEIF ("CHAR"="-")
        FCB     CDSH
        ELSEIF ("CHAR"=".")
        FCB     CPER
        ;ELSEIF ("CHAR"=",")
        ;FCB    CCMMA
        ENDIF
        ENDM
        fcb     $8A
;       PULLORG MESSAV
MESSAV  SET     *
        ENDIF
        IFNDEF  P_TXT
P_TXT   SET     PHRNUM
PHRNUM  SET     PHRNUM+1
        ENDIF
        ORG     SS
        lda     #P_TXT
        IF SIZ=35
        jsr     outp35
        ELSEIF SIZ=68
        jsr     outp68
        ENDIF
;       IFNDEF  P_TXT
;       ORG     PHRSAV
;       fdb     _TXT
;P_TXT  SET     PHRNUM
        ;IFGE   PHRNUM-$FF
        ;BLIST
        ;ERR    * N OVFL
        ;ENDIF
;       ENDIF
;       PULLORG PHRSAV
;PHRSAV SET     *
        ENDM

;__LABEL__ LABEL        TXT
;       IFNB    TXT
;;      BLIST
;       ELSEIF COLOR<>(COLOR-SCOLR)     ;Fixme was: IFN COLOR-.$COLR
;       ldb     #COLOR
;SCOLR  SET     COLOR                   ;Fixme was: .$COLR SET  COLOR
;       ENDIF
;;      NMLIST
;       IFNDEF  ___LABEL__
;       ORG     MESSAV
;___LABEL__     SET     *
;;      SECTION ASCII2TXT
;;      CODEPAGE WILLIASCII
;;      IRPC    CC,"TXT"                ;Fixme was: IRPC        CC,<TXT>
;;      IF      "CC"<=9                 ;Fixme was: IFLE        'CC-'9
;;      fcb     CC
;;      ELSEIF  "CC"="-"                ;Fixme was: ELSE
;;      IFE     'CC-'-
;;      fcb     $27
;;      ELSEIF  "CC">="a"               ;Fixme was: ELSE
;;      IFGE    'CC-'a
;;      RADIX   10
;;      fcb     'CC-'a+11               ;Fixme was: fcb 'CC-'a+11.
;;      ELSE
;;      fcb     'CC-'A+11               ;Fixme was: fcb 'CC-'A+11.
;;      RADIX   16
;;      ENDIF
;;      ENDIF
;;      ENDIF
;;      ENDM                            ;Fixme was: ENDR
;;===============================================================================
;       IRPC    CHAR,TEXT
;       IF ("CHAR"="\32")
;       FCB     CSPC
;       ELSEIF ("CHAR"="\H")
;       FCB     CSQOT
;       ELSEIF ("CHAR"="A")
;       FCB     CA
;       ELSEIF ("CHAR"="B")
;       FCB     CB
;       ELSEIF ("CHAR"="C")
;       FCB     CC
;       ELSEIF ("CHAR"="D")
;       FCB     CD
;       ELSEIF ("CHAR"="E")
;       FCB     CE
;       ELSEIF ("CHAR"="F")
;       FCB     CF
;       ELSEIF ("CHAR"="G")
;       FCB     CG
;       ELSEIF ("CHAR"="H")
;       FCB     CH
;       ELSEIF ("CHAR"="I")
;       FCB     CI
;       ELSEIF ("CHAR"="J")
;       FCB     CJ
;       ELSEIF ("CHAR"="K")
;       FCB     CK
;       ELSEIF ("CHAR"="L")
;       FCB     CL
;       ELSEIF ("CHAR"="M")
;       FCB     CM
;       ELSEIF ("CHAR"="N")
;       FCB     CN
;       ELSEIF ("CHAR"="O")
;       FCB     CO
;       ELSEIF ("CHAR"="P")
;       FCB     CP
;       ELSEIF ("CHAR"="Q")
;       FCB     CQ
;       ELSEIF ("CHAR"="R")
;       FCB     CR
;       ELSEIF ("CHAR"="S")
;       FCB     CS
;       ELSEIF ("CHAR"="T")
;       FCB     CT
;       ELSEIF ("CHAR"="U")
;       FCB     CU
;       ELSEIF ("CHAR"="V")
;       FCB     CV
;       ELSEIF ("CHAR"="W")
;       FCB     CW
;       ELSEIF ("CHAR"="X")
;       FCB     CX
;       ELSEIF ("CHAR"="Y")
;       FCB     CY
;       ELSEIF ("CHAR"="Z")
;       FCB     CZ
;       ELSEIF ("CHAR"="!")
;       FCB     CEXC
;       ELSEIF ("CHAR"="(")
;       FCB     CZ
;       FCB     CBRKL
;       ELSEIF ("CHAR"=")")
;       FCB     CBRKR
;       ELSEIF ("CHAR"="-")
;       FCB     CDSH
;       ELSEIF ("CHAR"=".")
;       FCB     CPER
;       ;ELSEIF ("CHAR"=",")
;       ;FCB    CCMMA
;       ENDIF
;       ENDM
;;===============================================================================
;       fcb     $8A
;;      PULLORG MESSAV
;MESSAV SET     *
;       IF MESSAV>=(MESSAV-MESLEN)              ;Fixme was: IFGT MESSAV-MESLEN
;;      BLIST
;;      ERR     * C OVFL
;       ENDIF
;       ENDIF
;;      BLIST
;       lda     #PTXT                   ;Fixme was: lda #.TXT
;       IF SIZ=35
;       jsr     outp35
;       ELSEIF SIZ=68
;       jsr     outp68
;       ENDIF
;;      NMLIST
;       IFNDEF  PTXT                    ;Fixme was: IFNDEF .TXT
;       ORG     PHRSAV
;       fdb     _TXT
;PTXT   SET     PHRNUM                  ;Fixme was: .TXT SET PHRNUM
;       IF PTXT>=(PHRNUM-$FF)           ;Fixme was: IFGE PHRNUM-$FF
;;      BLIST
;;      ERR     * N OVFL
;       ENDIF
;PHRNUM SET     PHRNUM+1
;       ORG     PHRSAV
;       IF PHRNUM>=(PHRSAV-PHRLEN)              ;Fixme was: IFGT PHRSAV-PHRLEN
;;      BLIST
;;      ERR     * P OVFL
;       ENDIF
;       ENDIF
;;      BLIST
;       ENDM

;       LIST
