;;===============================================================================
;
;   We're very lucky to have this source code because this routine and table were not
;   included in the final game (I'm assuming due to space constraints).  This is also the
;   only source code from Mike Metz known to have survived.  Kenneth F. Lantz was Noah
;   Falstein's boss, I believe he was director of software development.  He might
;   be who KenChk is named after.
;
;   Other examples of source code and comments written by Ken Lantz include routines
;   found in Joust so these weird funny comments below most likely belong to Mike Metz.
;
;;===============================================================================
;
;   This is a slightly different newer version of the MARQUEE routine, compared to
;   the one found in the AMOA prototype build.
;
;   The vertical position of the Sinistar AMOA marquee logo was raised slightly by
;   changing the Y position from $68 to $72.  In the original AMOA ROM, the $68 meant
;   that the graphic was placed in the center of the screen.  However, this new $72
;   value places the graphics slightly higher up to make room for the operator message,
;   which is normally displayed as two rows of "0"s on the title screen.
;
;   The vertical positions for the "TM" trademark and "COPYRIGHT 1982 WILLIAMS ELECTRONICS INC"
;   strings were also modified.  "TM" changed from $48 to $52 and the copyright string
;   moved up from $40 to $4A (which is the exact same position as seen in the final
;   title screen).
;
;;===============================================================================
;       INCLUDE [SAM]START
;       INCLVER SAM,SINISTAR.EQU



        PUSHORG ROMSAVE                                                         ;;Fixme was: PUSHORG    ROMSAV

        IFDEF   KENSMARQ  ;* Whole file is not included if KENSMARQ is undefined

;******************************************************************************
;*
;* Marquee Page
;*   By Ken Lantz and Mike Metz
;*
MARQUEE PSHS    Y               ;Now resave Y through the next trial

;*              TABLE CONCISTS OF COLUMN OFFSETS BYTES FOLLOWED BY
;*      LENGTH BYTE(S) <BYTES ENCODED WITH LENGTH (IN PIXELS), COLOR,
;*                      AND FLAG IF LAST LENGTH IN THIS COLUMN (IE:NEXT BYTE
;*                      IS AN OFFSET)>
;*      TABLE TERMINATES WITH ZERO LENGTH OFFSET
;*
;*

        LDA     #$7             ;Force Special Effects color E to go red
        STA     PCRAM+$E

        LDY     #MARKEY         ;Marquee table
        LDX     #$7225          ;COLUMN OFFSETS $26 THRU $D0                    ;;Originally #$6825 in AMOA prototype build

OWELL   TFR     X,D
        LDA     #$72                                                            ;;Originally #$68 in AMOA prototype build
        INCB
        CMPB    #$D0
        LBHI    FINSIT
        TFR     D,X

.11S    CLRB            ;ASSUME BLACK AT FIRST
        LDA     ,Y      ;LENGTH          CODE=  LCXX XXXX
        BITA    #$40    ;COLOR SELECTION          !!-!!!! SIX BIT LENGTH
        BEQ     .2S     ;                        !COLOR BIT 0=BLACK,1=RED
        LDB     #$EE    ;                       !LAST LENGTH IN COLUMN IF=1

.2S     ANDA    #$3F    ;STRIP OUT THE LENGTH

.22S    DECA            ;ODD PIXEL LENGTH TEST
        BEQ     .3S
        STB     ,X      ;AT LEST AN EVEN PIXEL LENGTH
        LEAX    -$100,X ;MOVING DOWN THE COLUMN
        DECA            ;AN EVEN BOUNDRY PERCHANCE
        BNE     .22S    ;NOPE, CHECK FOR AN ODD ONE (OR TWO (OR TOO( OR TO)))

.4S     TST     ,Y+     ;RECOGNIZE AND ADVANCE (OR VISIVERSE) COLUMN END?
        BMI     OWELL   ;NEW OFFSET TO BE CAD (HAD)       SAD...
        BRA     .11S    ;OWELL BACK FOR ANOTHER

.3S     EORB    #$E0    ;WWE GOT AN ODD ONE   DON'T WWE
        STB     ,X      ;END IT EVEN, LENGTH ALWAY START ON EVEN BOUNDRIES
        LEAX    -$100,X ;AND ADVANCE
        BRA     .4S     ;OF COURSE YOU GOTDA CHECK THIS ONE TOO.


FINSIT  TEXT    $52,$CD                                                         ;;Originally TEXT  $48,$CD in AMOA build
        PHRASE  RED,35,TM                                                       ;;(PHRASE POINTERS GET MISALIGNED HERE IF MARQUEE IS BUILT)
        TEXT    $4A,LEFEDG                                                      ;;Originally TEXT  $40,LEFEDG in AMOA build
        PHRASE  RED,35,COPYRIGHT,1982,WILLIAMS,ELECTRONICS,INC

        PULS    Y,PC


;******************************************************************************
;* THE MARKEY TABLE
;*   Everything you wanted to know about the Sinistar Marquee
;*   compacted into fewer bytes than ever known to man before
;*

MARKEY  FCB $2A,$C3
        FCB $2A,$C6
        FCB $0D,$48,$16,$C7
        FCB $0D,$4D,$12,$C8
        FCB $0D,$50,$10,$C8
        FCB $0E,$51,$0F,$C9
        FCB $06,$43,$05,$53,$0E,$CA
        FCB $06,$45,$04,$53,$0E,$CA
        FCB $05,$48,$02,$54,$0E,$CA
        FCB $05,$5F,$0D,$CB
        FCB $05,$60,$0D,$CB
        FCB $05,$61,$0C,$CB
        FCB $05,$61,$0D,$CB
        FCB $05,$60,$0E,$CB
        FCB $06,$5E,$0F,$CB
        FCB $06,$60,$0D,$CC
        FCB $06,$65,$08,$CC
        FCB $06,$F9
        FCB $06,$FA
        FCB $07,$4D,$02,$EA
        FCB $07,$4D,$04,$E8
        FCB $08,$4C,$06,$E7
        FCB $09,$4B,$07,$E6
        FCB $0A,$4A,$07,$E6
        FCB $0C,$48,$07,$E6
        FCB $0D,$48,$07,$E5
        FCB $0E,$47,$09,$E3
        FCB $10,$46,$0A,$E1
        FCB $11,$46,$0C,$DE
        FCB $13,$45,$0D,$DB
        FCB $15,$44,$0F,$D7
        FCB $2D,$CE
        FCB $9F
        FCB $13,$CC
        FCB $11,$D1
        FCB $10,$58,$0B,$CA
        FCB $0F,$EC
        FCB $0E,$EC
        FCB $0D,$ED
        FCB $0C,$EE
        FCB $0B,$46,$0D,$DC
        FCB $0B,$44,$12,$DA
        FCB $0B,$42,$17,$D7
        FCB $0B,$41,$07,$49,$0A,$D5
        FCB $11,$4E,$0A,$CA
        FCB $0F,$52,$0B,$C5
        FCB $0E,$56,$12,$C2
        FCB $0D,$5C,$0B,$C4
        FCB $0D,$EB
        FCB $0C,$EC
        FCB $0C,$46,$06,$E0
        FCB $0C,$42,$0C,$DF
        FCB $0C,$41,$0F,$49,$02,$D1
        FCB $1D,$49,$03,$CE
        FCB $1E,$49,$05,$C6
        FCB $1F,$C9
        FCB $14,$49,$03,$CA
        FCB $12,$DC
        FCB $11,$E0
        FCB $10,$E3
        FCB $0F,$E5
        FCB $0E,$E7
        FCB $0D,$45,$05,$DE
        FCB $18,$4C,$07,$CA
        FCB $2F,$C6
        FCB $B0
        FCB $14,$CA
        FCB $12,$D0
        FCB $11,$D3
        FCB $10,$57,$0A,$C3
        FCB $0F,$E5
        FCB $0F,$E5
        FCB $0E,$46,$04,$DC
        FCB $0E,$44,$0B,$D7
        FCB $0E,$43,$0E,$D5
        FCB $0E,$41,$12,$D2
        FCB $23,$CC
        FCB $25,$C8
        FCB $13,$48,$0C,$C5
        FCB $12,$CC
        FCB $13,$CE
        FCB $14,$CE
        FCB $0F,$43,$03,$4A,$08,$C3
        FCB $0E,$55,$05,$C4
        FCB $0E,$54,$06,$C5
        FCB $0E,$53,$08,$C5
        FCB $0E,$53,$08,$C6
        FCB $0E,$54,$07,$C7
        FCB $0E,$56,$05,$C8
        FCB $0F,$49,$02,$4D,$02,$C9
        FCB $0F,$49,$03,$D7
        FCB $10,$48,$04,$D7
        FCB $11,$47,$05,$D6
        FCB $12,$46,$05,$D6
        FCB $13,$45,$04,$D7
        FCB $14,$45,$03,$D8
        FCB $15,$44,$04,$D7
        FCB $17,$43,$05,$D5
        FCB $21,$D3
        FCB $26,$CD
        FCB $B0
        FCB $18,$C2
        FCB $12,$46,$01,$41,$19,$C1
        FCB $11,$49,$18,$C2
        FCB $10,$4A,$15,$C5
        FCB $10,$49,$13,$C8
        FCB $10,$49,$04,$D7
        FCB $10,$49,$01,$DA
        FCB $11,$67,$01,$C1
        FCB $11,$E2
        FCB $11,$E1
        FCB $11,$E0
        FCB $11,$E0
        FCB $10,$4E,$06,$CC
        FCB $10,$4A,$0D,$C8
        FCB $10,$C8
        FCB $0F,$C8
        FCB $0F,$C7
        FCB $0F,$47,$11,$CA
        FCB $0E,$48,$0B,$D4
        FCB $0E,$48,$08,$D9
        FCB $0D,$49,$05,$DC
        FCB $0E,$44,$08,$DA
        FCB $05,$41,$16,$D5
        FCB $05,$41,$17,$D3
        FCB $04,$42,$0F,$47,$02,$D2
        FCB $0C,$41,$07,$DB
        FCB $0C,$42,$05,$D3
        FCB $0B,$44,$02,$D3
        FCB $0B,$D8
        FCB $0B,$D8
        FCB $0B,$4B,$05,$C8
        FCB $0B,$4A,$05,$DB
        FCB $0B,$49,$06,$DD
        FCB $0C,$4B,$04,$DE
        FCB $0C,$EE
        FCB $0D,$EE
        FCB $0E,$EE
        FCB $0F,$ED
        FCB $10,$4E,$03,$51,$08,$C2
        FCB $08,$41,$09,$4A,$06,$CD
        FCB $08,$41,$1B,$C9
        FCB $08,$42,$2D,$C2
        FCB $08,$41,$01,$41,$2A,$C5
        FCB $08,$44,$25,$CA
        FCB $09,$44,$15,$DA
        FCB $09,$45,$13,$DC
        FCB $0A,$47,$05,$47,$03,$DE
        FCB $0A,$54,$01,$DE
        FCB $0B,$F2
        FCB $0B,$F1
        FCB $0C,$F0
        FCB $0C,$EF
        FCB $0C,$64,$01,$C1
        FCB $0D,$5C,$17,$C1
        FCB $0D,$48,$05,$4F,$16,$C2
        FCB $0D,$48,$05,$4F,$15,$C3
        FCB $0E,$47,$05,$50,$12,$C5
        FCB $0E,$48,$04,$51,$0F,$C6
        FCB $0E,$49,$03,$53,$0B,$C8
        FCB $0F,$49,$03,$E4
        FCB $0F,$4B,$01,$E3
        FCB $10,$52,$02,$D9
        FCB $11,$51,$03,$D8
        FCB $12,$50,$03,$D7
        FCB $14,$4F,$02,$D6
        FCB $16,$4D,$02,$D4
        FCB $18,$4B,$02,$D3
        FCB $1C,$46,$04,$D0
        FCB $27,$CC
        FCB $28,$C8
        FCB $00

        ENDIF           ;* Whole file is not included if KENSMARQ is undefined

        PULLORG ROMSAVE                                                         ;;Fixme was: PULLORG    ROMSAV