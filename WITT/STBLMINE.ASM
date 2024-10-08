;       INCLVER RICH,table                      ;* ORG Macro

        PUSHORG ROMSAVE
;***
;*      Warrior mining flight plan.
;***
;       TABLE   stblminer
stblminer
;       SYMVER  MineDist,40.            ;* Maximum distance at which to mine.
        RADIX   10
MineDist EQU    40

        fdb     ((000000001024)),$0FFF,asrd4            ;;Fixme was: fdb        ((000000001024.)),$0FFF,asrd4
        fdb     ((MineDist+256)),$0300,asrd4            ;;Fixme was: fdb        ((MineDist+256.)),$0300,asrd4
        fdb     ((MineDist+096)),$0200,asrd4            ;;Fixme was: fdb        ((MineDist+096.)),$0200,asrd4
        fdb     ((MIneDist+024)),$0100,asrd3            ;;Fixme was: fdb        ((MIneDist+024.)),$0100,asrd3
        fdb     ((MineDist+000)),$0080,asrd3            ;;Fixme was: fdb        ((MineDist+000.)),$0080,asrd3
        fdb     ((MineDist-016)),$0000,asrd2            ;;Fixme was: fdb        ((MineDist-016.)),$0000,asrd2
        fdb     ((MineDist-032)),$0000,asrd1            ;;Fixme was: fdb        ((MineDist-032.)),$0000,asrd1
        fdb     ((000000000000)),$FFF0,asrd4            ;;Fixme was: fdb        ((000000000000.)),$FFF0,asrd4
;       ENDTBL

        RADIX   16

        PULLORG ROMSAVE