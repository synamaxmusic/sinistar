;       INCLVER RICH,table                      ;* ORG Macro

        PUSHORG ROMSAVE

        RADIX   10

;***
;*      Single warrior pilot attack plan #0.
;*      Track and follow squadron leader.
;*      Tuned for revised distance calculations.
;***
;       TABLE   stblW0
stblW0
        fdb     (4000),($0FFF),asrd2    ;* 3 1                  ;;Fixme was: fdb        (4000.),($0FFF),asrd2
        fdb     (0080),($0300),asrd3    ;* 4 1                  ;;Fixme was: fdb        (0080.),($0300),asrd3
        fdb     (0064),($02C0),asrd3    ;* 4 1                  ;;Fixme was: fdb        (0064.),($02C0),asrd3
        fdb     (0048),($0240),asrd2    ;* 3 1                  ;;Fixme was: fdb        (0048.),($0240),asrd2
        fdb     (0032),($0200),asrd2    ;* 3 1                  ;;Fixme was: fdb        (0032.),($0200),asrd2
        fdb     (0016),($0100),asrd1    ;* 2 0                  ;;Fixme was: fdb        (0016.),($0100),asrd1
        fdb     (0008),($0080),asrd1    ;* 2 0                  ;;Fixme was: fdb        (0008.),($0080),asrd1
        fdb     (0000),($0000),asrd0    ;* 1 0                  ;;Fixme was: fdb        (0000.),($0000),asrd0
;       PAD     (10.-((*-stblW0)/OSTBLZ))*OSTBLZ        ;* Pad entries
        RMB     (10-((*-stblW0)/OSTBLZ))*OSTBLZ
;       ENDTBL

        RADIX   16

        PULLORG ROMSAVE