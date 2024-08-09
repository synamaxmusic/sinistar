;       INCLVER RICH,table              * Table definition org macro

        PUSHORG ROMSAVE

        RADIX   10                              ;;(decimal values ahead)

;***
;*      Warrior guarding in orbit. (TASKLIST 8/16)
;***
;       TABLE   stblimpulse
        PUSHORG stblimpulse                     ;;Adding PUSHORG here to replace stblimpulse ($5CF6)
        fdb     ($7FFF),($1FFF),asrd3
        fdb     (0250),($0100),asrd5            ;;Fixme was: fdb        (0250.),($0100),asrd5
        fdb     (0100),($0070),asrd2            ;;Fixme was: fdb        (0100.),($0070),asrd2
        fdb     (0064),($0070),asrd2            ;;Fixme was: fdb        (0064.),($0070),asrd2
        fdb     (0048),($0060),asrd2            ;;Fixme was: fdb        (0048.),($0060),asrd2
        fdb     (0032),($0040),asrd2            ;;Fixme was: fdb        (0032.),($0040),asrd2
        fdb     (0016),($0020),asrd1            ;;Fixme was: fdb        (0016.),($0020),asrd1
        fdb     (0000),($0000),asrd0            ;;Fixme was: fdb        (0000.),($0000),asrd0
;       ENDTBL
        PULLORG                                 ;;Adding PULLORG, per TABLE macro.

        RADIX   16                              ;;(returning to hex)

        PULLORG ROMSAVE