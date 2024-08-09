;       INCLVER RICH,table                      ;* ORG Macro

        PUSHORG ROMSAVE

        RADIX   10

;***
;*      Psuedo Warrior bombing in orbit. (TASKLIST 8/16)
;***
;       TABLE   stblbomber
stblbomber
        fdb     ($7FFF),($1FFF),asrd3
        fdb     (0100),($0100),asrd1            ;;Fixme was: fdb        (0100.),($0100),asrd1
        fdb     (0064),($00C0),asrd1            ;;Fixme was: fdb        (0064.),($00C0),asrd1
        fdb     (0032),($00A0),asrd1            ;;Fixme was: fdb        (0032.),($00A0),asrd1
        fdb     (0016),($0080),asrd0            ;;Fixme was: fdb        (0016.),($0080),asrd0
        fdb     (0000),($0000),asrd0            ;;Fixme was: fdb        (0000.),($0000),asrd0
;       ENDTBL

        RADIX   16

        PULLORG ROMSAVE

;;===============================================================================
;;
;;  This table gets patched over with the tuned data found in ZSTBLBOM.ASM.
;;  For those who are interested in building the game with the older table,
;;  comment out the INCLUDE "../WITT/ZSTBLBOM.ASM" in the RICHFIXE.ASM file.
;;
;;===============================================================================