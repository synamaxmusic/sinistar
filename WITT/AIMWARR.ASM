        PUSHORG ROMSAVE
;*****
;*
;* AIMWARRIOR
;*
;*      The warrior turret is aimed at the player's craft "as well as possible"
;*      by measuring the average change in flight angles and attempting to
;*      angle the turret ahead of the player in order that the motion of the
;*      two crafts (player and warrior) will bring the player in the path of
;*      the warrior shots.
;*
;* Needs:
;*      A = previous flight angle
;*      Y -> warrior scanner workspace
;*      OSFLANG,Y = current flight angle
;*      OSFASTEP,Y = flight angle step 'average'
;*
;* Returns:
;*      A = animation angle
;*      OSFASTEP,Y = new flight angle step 'average'
;*
;*****
aimwarrior
        pshs    A               ;* Take the difference in the
        lda     OSFLANG,Y       ;*   current angle from the
        suba    ,S+             ;*   previous angle
        adda    OSFASTEP,Y      ;*   and average this with the running
        asra                    ;*   pseudo average change in angles.
        inca                    ;* Round up this change to make a more
        anda    #$FE            ;*   smooth and continuous run of
        sta     OSFASTEP,Y      ;*   average changes.
        asla                    ;* Aim well ahead of the player
        adda    OSFLANG,Y       ;*   to get in good hits.
        rts
        PULLORG ROMSAVE