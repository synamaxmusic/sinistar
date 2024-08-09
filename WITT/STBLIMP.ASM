;       INCLVER RICH,table              * Table definition org macro

        PUSHORG ROMSAVE
;***
;*      Warrior guarding in orbit. (TASKLIST 8/16)
;***
;       TABLE   stblimpulse
stblimpulse
        RADIX   10
        fdb     ($7FFF),($1FFF),asrd3
        fdb     (0200),($0100),asrd5                            ;;Fixme was: fdb (0200.),($0100),asrd5
        fdb     (0100),($0090),asrd3                            ;;Fixme was: fdb (0100.),($0090),asrd3
        fdb     (0064),($0090),asrd1                            ;;Fixme was: fdb (0064.),($0090),asrd1
        fdb     (0048),($0060),asrd2                            ;;Fixme was: fdb (0048.),($0060),asrd2
        fdb     (0032),($0040),asrd1                            ;;Fixme was: fdb (0032.),($0040),asrd1
        fdb     (0016),($0018),asrd1                            ;;Fixme was: fdb (0016.),($0018),asrd1
        fdb     (0000),($0000),asrd0                            ;;Fixme was: fdb (0000.),($0000),asrd0
        RADIX   16
;       ENDTBL

        PULLORG ROMSAVE

;;===============================================================================
;;
;;  This speed table is patched over with WITT/ZSTBLIMP.SRC
;;
;;===============================================================================