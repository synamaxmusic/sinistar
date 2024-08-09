;       INCLVER RICH,table                      ;* ORG Macro

        PUSHORG ROMSAVE
;***
;*      Warrior as squadron leader attack plan.
;*      Fly squadron right past player.
;***

        RADIX   10

;       TABLE   stblL0
stblL0
        fdb     (1536),($0410),asrd3                    ;;Fixme was: fdb        (1536.),($0410),asrd3
        fdb     (0000),($0300),asrd4                    ;;Fixme was: fdb        (0000.),($0300),asrd4
;       PAD     (5-((*-STblL0)/OSTblZ))*OSTblZ  ;* Pad entries
        RMB     (5-((*-STblL0)/OSTblZ))*OSTblZ
;       ENDTBL

        RADIX   16

        PULLORG ROMSAVE