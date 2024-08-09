        PUSHORG ROMSAVE
;*****
;*
;* ANIWARRIOR
;*      This routine animates the warrior based on the angle of flight
;*      and NITURRET animation images.  The animation aims the warrior's turret
;*      at the player's craft.  Because human beings are leary of computer
;*      controls, the warrior is inhibited from firing on a 'click' of the
;*      turret.  If the turret moved smoothly and continuously this would
;*      not be a problem, but it looks more 'natural' for the appearant
;*      machinery to 'lock' into position before being allowed to fire a shot.
;*
;* Needs:
;*      A = angle at which to animate craft
;*      Y -> scanner workspace of the craft
;*      OSANANG,Y = old animation angle.
;*      OSPERS,Y  = personality traits of warrior
;*
;* Returns:
;*      OSANANG,Y = new animation angle.
;*      OSPERS,Y  = PSHOOT clear if the turret has not just swung.
;*                  PSHOOT  set  if the turret has just swung.
;*
;*****
        ROUTINE aniwarrior
        pshs    A,B,X,Y         ;* Save work registers
        cmpy    #SPlayer        ;* If this is really the player in
        beq     .100S           ;*   warrior's clothing, animate the player.

        ldx     OSSCWSA,Y       ;* X -> object workspace of craft.
        beq     .99S            ;* If not on screen, don't animate.

        ldb     OSPERS,Y        ;* Clear the warrior to shoot if so desired
        andb    #$7F            ;*   assuming that the turret hasn't swung.             ;;Fixme was: andb  #!N(PSHOOT) (was getting range underflow errors with this)

        suba    OSANANG,Y       ;* In order to keep the turret from swinging
        bpl     .1S             ;*   back and forth too wildly,
        nega                    ;*   the angle change is made
.1S     cmpa    #(CIRCLE/NITURRET)      ;*   not to occur
        bgt     .2S             ;*   until well into the next
        lda     OSANANG,Y       ;*   animation arc.  So, a choice is made
        bra     .3S             ;*   between the old animation angle
.2S     lda     0,S             ;*   and the newly computed angle.

.3S     adda    #(CIRCLE/(NITURRET*2))  ;* Round off the animation angle.
;       IFN     (CIRCLE/NITURRET)-32.
;       messg   * Please correct the following object for the change in arc.
;       CLIST
;       ELSE
        anda    #%11100000      ;* Cut the angle to one of NITURRET choies.

        suba    OSANANG,Y       ;* Limit the amount that the
        cmpa    #(CIRCLE/NITURRET)      ;*   warrior turret may
        ble     .4S                     ;*   swing around in
        lda     #(CIRCLE/NITURRET)      ;*   either direction
        orb     #PSHOOT                 ;* (mark the swing of the turret)
.4S     cmpa    #-(CIRCLE/NITURRET)     ;*   by the amount of
        bge     .5S                     ;*   a single animation
        lda     #-(CIRCLE/NITURRET)     ;*   angle in the closest
        orb     #PSHOOT                 ;* (mark the swing of the turret)
.5S     adda    OSANANG,Y               ;*   direction of swing.
        stb     OSPERS,Y        ;* Mark whether or not the turret has swung.

        IFDEF   BargraphEnable                                                          ;;Fixme was: IFDEF      DIAGNOSE
        pshs    A               ;* Save work registers
        adda    #(CIRCLE/2)     ;* Range A from 0 to +256
        sta     GRAPH+GANANG    ;* Plot the flight angle
        puls    A               ;* Restore work registers
        ENDIF   ;DIAGNOSE

        sta     OSANANG,Y       ;* Save the angle for the next animation.
        RPT     5,asra          ;* There are 8 possible images
;       ENDIF   ;NITURRET       ;dependant code.
        adda    #(NITURRET/2)   ;*   from 0 through 7.
        ldb     #OILEN          ;* Multiply the image number times the length
        mul                     ;*   of an image descriptor
        addd    #ITURRET        ;* Now D -> the correct turret image.
        std     OEFFECT,X       ;* Save the new image descriptor.
        ldd     #pasteon        ;* Let the executive paste the turret
        std     OPDRWVE,X       ;*   on top of the warrior body.
                                ;
.99S    puls    A,B,X,Y         ;* Restore work registers
        rts
;*****
;*
;* 100$ - Animate the player in the attract mode demo.
;*
;*****
.100S   adda    #(CIRCLE/2)     ;* The exec loop will animate the
        sta     PlyrAngl        ;*   player angle.
        bra     .99S            ;* Exit.
        PULLORG ROMSAVE