;       IFE     Version-17.
fixkrsini
        PUSHORG $59C3
        jmp     FIXKRS1
        PULLORG
        PUSHORG ROMSAVE                                                         ;;($8E65)
FIXKRS1 tst     PlaGrave                                                        ;;Fixme was: 100$
        lbeq    $59C8
        New_SLEEP       Task1,FIXKRS2,OTimer    ;* Dead man's warp.
        jmp     FIXKR9
;**
;*      Dead player alternative to warp.
;**
FIXKRS2 lda     #-1             ;* Init impulse engines                         ;;Fixme was: 200$
        sta     InImpulse       ;*   on.
        RADIX   10                                                              ;;(decimal value ahead)
        ldd     #(60*9/4)       ;* Wait 2.25 seconds                            ;;Fixme was: ldd  #(60.*9/4)
        RADIX   16                                                              ;;(return to hex)
        jsr     Timer           ;*   and then ...
        clr     InImpulse       ;* Signal Sinistar to fall to pieces.
        clr     InWarp          ;* End warp (since player is dead).
;**
;*      ldd     #(60.*2)        ;* Wait another 2 seconds for explosion
;*      jsr     Timer           ;*   of Sinistar.
;*      lda     #-1             ;* Re-init the
;*      sta     InImpulse       ;*   impulse engines for the next time.
;**
FIXKR99 ldd     #CPlayer        ;* Enable player collisions                     ;;Fixme was: 99$
        std     OChar+WPLAYER   ;*   because SAM DESTROYED THEM !!!!
        jmp     Die             ;* That's all for this task!
        PULLORG ROMSAVE                                                         ;;($8E91) ... there are only 15 bytes of space left before hitting MESS2 ($8EA0)
;*
        PUSHORG $59D4
FIXKR9  rmb     0                                                               ;;Fixme was: 9$
        PULLORG
;***
;*
;***
        PUSHORG $5B03           ;* Patch KRSINI
        jmp     FIXKR99         ;*   to die with player enabled.
        PULLORG
;*****
;*
;* Sorry,
;*      But orbital distances weren't fixed as part of the distance
;*      corrections of earlier days.  These work funny with the player.
;*
;*****
        PUSHORG $5B2C
        jsr     getldist
        PULLORG
;*
        PUSHORG $5B43
        jsr     getsdist
        PULLORG
;*
;       ENDIF   Version-17.