;;===============================================================================
;
;   This is a hack that allows the original MARQUEE title screen.
;
;;===============================================================================
;       INCLUDE [SAM]START
;       INCLVER SAM,SINISTAR.EQU

        IFDEF   MarqueeFix

         IFNDEF  T13MODDED
;;
;;  Instead of nuking the Rug ROM/RAM tests, we are going to overwrite the
;;  cross hatch test, color bar tests and switch test instead.
;;

        PUSHORG $F470   ;; overwrite JSR instructions for SWTEST, AVWAIT, and CRTEST with NOPs
                        ;; so we can skip them and overwrite $F71C - $F928

        RPT     9,NOP

        PULLORG


        PUSHORG $F4ED   ;;replace "BSR  BARS" with NOPs so Auto cycle doesn't execute mod code

        NOP
        NOP

        PULLORG


        PUSHORG $F4F8   ;; make TSTPAT skip color bar and cross hatch tests and go straight to booking

        JMP     BOOK

        PULLORG


;;  $F4FB - $F928 are now clear (gives us $42C of space)


;       IFDEF   PauseMod
;
;       PUSHORG $F569           ;; If PauseMod is enabled, let's add the title screen after it.
;       ELSE
;       PUSHORG $F4FB           ;; Otherwise, let's place the title screen where the pause mod is normally stored
;       ENDIF

        IFNDEF  SAMTAIL         ;; If Sam's Tail code is not defined, then we proceed normally.
        PUSHORG MODSAV          ;;Fixme was: PUSHORG    ROMSAV

        ELSE

        ORG     $F455           ;;Otherwise, let's wipe out the sound test
;       RPT 20,NOP              ;;Wipe out references to sound test
        JMP     $F479

        PUSHORG $FE6C           ;;Overwrite sound test

        ENDIF ;SAMTAIL

        ELSE

        PUSHORG MODSAV

        ENDIF ;T13MODDED



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

        IFNDEF  T13MODDED
        IFDEF   SAMTAIL         ;; If SAMTAIL is defined...
        PULLORG                 ;;  then we finish overwriting the sound test...
        PUSHORG MODSAV          ;;  and go back to our allocated space for mods ($F4FB - $F928).
        ENDIF
        ENDIF

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

        PULLORG MODSAV                                                          ;;Fixme was: PULLORG    ROMSAV


        PUSHORG $811E
        JSR     MARQUEE ;; Insert jump to Marquee in game logic
        RADIX   10
        RPT     23,NOP  ;;    and then wipe out the old Sinistar typeface logo
        RADIX   16
        PULLORG


;;
;;  This section is no longer needed because we're preserving the Rug tests now.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       PUSHORG $802E                                                           ;;Overwrite copyright message
;;RAMEXITx LDB  #1      ;set to read rom                                        ;;Restore trashed instructions
;;      STB     PMEMCTL
;;      STB     MEMCTL
;;      LDS     #HSTK   ;set stack
;;      JSR     EXPFONT ;expand font into static ram
;;      JMP     Y       ;exit
;
;DELA1x LDX     #$5800                                                          ;;Restore trashed instructions
;DELA2x LEAX    -1,X                                                            ;;(Had to change labels to avoid double define errors)
;       LDB     #WDATA
;       STB     WDOG
;       CMPX    #0
;       BNE     DELA2x
;       DECA
;       BNE     DELA1x
;QUIKLDR        JMP     ,Y      ;RETURN                                                 ;;JMP $49F9 (CKCMOS) does the same thing
;
;       PULLORG
;
;
;       PUSHORG $F09C   ;;Make rug test jump to restored instructions so the game can boot
;       JMP     DELA1x  ;;Originally JMP DELA1x, but RAMEXITx is faster AND brings back "FACTORY SETTINGS RESTORED"!
;       PULLORG



;       PUSHORG $F003   ;;This restores access to the diagnostic menu!
;       JMP     DIAG3   ;;Instead of JMP  ADVSWS, we're skiping the deleted RAM/ROM tests and going straight to CMOS test.
;;      JMP     AUTO2   ;;(Do we need to replace Auto-cycle?)
;       PULLORG

;       PUSHORG $F4EF  ;;Related to autocycle (need to skip ROMTST/RAMTST jumps)
;       LDY     #AUTO2 ;;Change #AUTCYC to #AUTO2
;       PULLORG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;===============================================================================
;;
;;  Checksum fixes
;;

;;MarqueeFix ONLY
        ORG     $F360
        FCB     $C7     ;8000   ;;Fixme was: $2A

        ORG     $F36E
        FCB     $EF     ;F000   ;;Fixme was: $57

        ORG     $FFDF
        FCB     $11             ;;Fixme was: $DA (Fudger byte)

;;MarqueeFix AND PauseMod
         IFDEF  PauseMod

        ORG     $F360
        FCB     $37     ;8000   ;;Fixme was: $2A

        ORG     $F36E
        FCB     $F0     ;F000   ;;Fixme was: $57

        ORG     $FFDF
        FCB     $10             ;;Fixme was: $DA (Fudger byte)

;;MarqueeFix AND PauseMod AND DifficultyMod
          IFDEF DifficultyMod

        ORG     $F35E
        FCB     $94     ;7000

        ORG     $F360
        FCB     $38     ;8000   ;;Fixme was: $2A

        ORG     $F36E
        FCB     $2C     ;F000   ;;Fixme was: $57

        ORG     $FFDF
        FCB     $D4             ;;Fixme was: $DA (Fudger byte)

;;MarqueeFix AND PauseMod AND DifficultyMod AND SAMTAIL
           IFDEF SAMTAIL

        ORG     $F356
        FCB     $E1     ;3000   ;;Fixme was: $33

        ORG     $F35E
        FCB     $1C     ;7000

        ORG     $F360
        FCB     $D9     ;8000   ;;Fixme was: $2A

        ORG     $F36E
        FCB     $19     ;F000   ;;Fixme was: $57

        ORG     $FFDF
        FCB     $E7             ;;Fixme was: $DA (Fudger byte)

;;  Any further mods added on after these will require FakeChecksums enabled.

           ENDIF

          ENDIF

         ENDIF

;; AMOA Graphic / DifficultyMod only (No PauseMod)

        IFNDEF  PauseMod
         IFDEF  MarqueeFix
          IFDEF DifficultyMod

        ORG     $F35E
        FCB     $94     ;7000

        ORG     $F360
        FCB     $CA     ;8000   ;;Fixme was: $2A

        ORG     $F36E
        FCB     $2D     ;F000   ;;Fixme was: $57

        ORG     $FFDF
        FCB     $D3             ;;Fixme was: $DA (Fudger byte)

;; AMOA Graphic / DifficultyMod / SAMTAIL only (No PauseMod)
           IFDEF SAMTAIL

        ORG     $F356
        FCB     $C6     ;3000   ;;Fixme was: $33

        ORG     $F35E
        FCB     $1C     ;7000

        ORG     $F360
        FCB     $DA     ;8000   ;;Fixme was: $2A

        ORG     $F36E
        FCB     $CD     ;F000   ;;Fixme was: $57

        ORG     $FFDF
        FCB     $33             ;;Fixme was: $DA (Fudger byte)

           ENDIF
          ENDIF
         ENDIF
        ENDIF

;; AMOA Graphic / SAMTAIL / ExtraShipFix ("Perfect" ROM set)
        IFDEF   ExtraShipFix    ;; We're assuming that we're building V19645.
                                ;; Otherwise, we'll need fake checksums on
                                ;; overwrite these checksums for V19645
        ORG     $F356
        FCB     $C6     ;3000   ;;Fixme was: $33

        ORG     $F358
        FCB     $C4     ;4000

        ORG     $F35E
        FCB     $E1     ;7000

        ORG     $F360
        FCB     $DB     ;8000   ;;Fixme was: $2A

        ORG     $F36E
        FCB     $68     ;F000   ;;Fixme was: $57

        ORG     $FFDF
        FCB     $98             ;;Fixme was: $DA (Fudger byte)

        ENDIF

;;===============================================================================
;;
;;  As an easter egg, we're overwriting two inside-joke initial entries
;;

        PUSHORG $8C5F


        RADIX   10
        FCB     23,11,34        ;;MAX   (Overwrite "MOM" with SynaMax's name)
        FCB     12,23,28        ;;BMR   (Overwrite "FAC" with Braedel's initials)
        RADIX   16

        PULLORG

;;===============================================================================
;;
;;  To make it easier to identify which ROM set we're running on hardware, we'll
;;  borrow a trick from Eugene Jarvis and Larry DeMar in the Robotron Tie-Die ROMs
;;  and use the high score to denote a "version" number.
;;
;;  Normally, the first high score entry in the "Survivors Today" table is always
;;  set to 19045.
;;
;;  We'll change the zero here to ID the mod combo:
;;
;;    19145 = Pause Mod / AMOA Graphic
;;    19245 = Pause Mod / AMOA Graphic / DifficultyMod
;;    19300 = Pause Mod / AMOA Graphic / DifficultyMod / QuickOperatorEntry (Double zeros = FakeChecksums)
;;    19345 = AMOA Graphic / DifficultyMod
;;    19445 = Pause Mod / AMOA Graphic / DifficultyMod / SAMTAIL
;;    19545 = AMOA Graphic / DifficultyMod / SAMTAIL
;;    19645 = AMOA Graphic / SAMTAIL / ExtraShipFix (Closest to "Perfect" ROMs)
;;
;;  Note: enabling MarqueeFix only doesn't change the high score entries.

        IFDEF   MarqueeFix
         IFDEF PauseMod

        ORG     $8BA1
        FDB     $9145
          IFDEF DifficultyMod

        ORG     $8BA1
        FDB     $9245

           IFDEF SAMTAIL

        ORG     $8BA1
        FDB     $9445

           ENDIF
          ENDIF
         ENDIF
        ENDIF

        IFNDEF  PauseMod
         IFDEF  MarqueeFix
          IFDEF DifficultyMod   ;; AMOA Graphic / DifficultyMod only

        ORG     $8BA1
        FDB     $9345

           IFDEF SAMTAIL        ;; AMOA Graphic / DifficultyMod / SAMTAIL only

        ORG     $8BA1
        FDB     $9545

           ENDIF
          ENDIF
         ENDIF
        ENDIF

        IFDEF QuickOperatorEntry

        ORG     $8BA1
        FDB     $9300

        ENDIF

        IFDEF ExtraShipFix

        ORG     $8BA1
        FDB     $9645

        ENDIF

        ENDIF           ;* Whole file is not included if KENSMARQ is undefined

        IFDEF   V19845

FCKSUM  EQU     $F6
FUDGER  EQU     $100-FCKSUM
;FUDGER  EQU     $00

;; Change high score number to 19845
        PUSHORG $8BA1
        FDB     $9845
        PULLORG


        PUSHORG ROMTAB
        FCB     $00,$C6  ;0000
        FCB     $10,$62  ;1000
        FCB     $20,$A9  ;2000  ;;NEW
        FCB     $30,$79  ;3000  ;;NEW
        FCB     $40,$D2  ;4000  ;;NEW
        FCB     $50,$25  ;5000  ;;NEW
        FCB     $60,$42  ;6000  ;;NEW
        FCB     $70,$93  ;7000  ;;NEW
        FCB     $80,$A7  ;8000  ;;NEW
        FCB     $90,$0   ;9000
        FCB     $A0,$0   ;A000
        FCB     $B0,$0   ;B000
        FCB     $C0,$0   ;C000
        FCB     $D0,$0   ;D000
        FCB     $E0,$42  ;E000  ;;NEW
        FCB     $F0,FCKSUM  ;F000  ;;NEW
        FCB     0
        FCB     FUDGER      ;CHECK BYTE (FUDGER) FOR THIS PART ($F000)
        PULLORG

        ENDIF

        IFDEF   V19855

FCKSUM  EQU     $61
FUDGER  EQU     $100-FCKSUM
;FUDGER  EQU     $00

;; Change high score number to 19855
        PUSHORG $8BA1
        FDB     $9855
        PULLORG


        PUSHORG ROMTAB
        FCB     $00,$C6  ;0000
        FCB     $10,$62  ;1000
        FCB     $20,$24  ;2000  ;;NEW
        FCB     $30,$59  ;3000  ;;NEW
        FCB     $40,$D2  ;4000  ;;NEW
        FCB     $50,$25  ;5000  ;;NEW
        FCB     $60,$34  ;6000  ;;NEW
        FCB     $70,$93  ;7000  ;;NEW
        FCB     $80,$B7  ;8000  ;;NEW
        FCB     $90,$0   ;9000
        FCB     $A0,$0   ;A000
        FCB     $B0,$0   ;B000
        FCB     $C0,$0   ;C000
        FCB     $D0,$0   ;D000
        FCB     $E0,$42  ;E000  ;;NEW
        FCB     $F0,FCKSUM  ;F000  ;;NEW
        FCB     0
        FCB     FUDGER      ;CHECK BYTE (FUDGER) FOR THIS PART ($F000)
        PULLORG

        ENDIF

;;
;;   To make troubleshooting and debugging much easier, I'm adding this here since
;;   this is the last file to be assembled.
;;

        IFDEF   FakeChecksums

        PUSHORG ROMTAB
        FCB     $00,$0  ;0000
        FCB     $10,$0  ;1000
        FCB     $20,$0  ;2000
        FCB     $30,$0  ;3000
        FCB     $40,$0  ;4000
        FCB     $50,$0  ;5000
        FCB     $60,$0  ;6000
        FCB     $70,$0  ;7000
        FCB     $80,$0  ;8000
        FCB     $90,$0  ;9000
        FCB     $A0,$0  ;A000
        FCB     $B0,$0  ;B000
        FCB     $C0,$0  ;C000
        FCB     $D0,$0  ;D000
        FCB     $E0,$0  ;E000
        FCB     $F0,$0  ;F000
        FCB     0
        FCB     $0      ;CHECK BYTE (FUDGER) FOR THIS PART ($F000)
        PULLORG

        ENDIF