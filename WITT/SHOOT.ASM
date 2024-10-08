;       include start
;       INCLVER SAM,sinistar.equ

        PUSHORG ROMSAVE
;       SUBTTL  SHOOT
;*****
;*
;* SHOOT
;*      Fire a shot at the player or planet or whatever target.
;*
;* Needs:
;*      X -> target scanner workspace
;*      Y -> warrior scanner workspace
;*      OSANANG,Y = (opposite) angle at which to shoot
;*
;* Returns:
;*      NOTHING - registers are preserved.
;*
;*****
        ROUTINE shoot
        pshs    A,B,X,Y,U       ;* Save work restisters
SAVEDY  SET     4               ;* Position of Y value on stack.

        ldu     OSSCWSA,X       ;* If target is not on screen,
        lbeq    .99S            ;*   then exit.

        ldu     OSSCWSA,Y       ;* If warrior is not on screen,
        lbeq    .99S            ;*   then exit.

        lda     SFree           ;* If there are no more free screen object
        lbeq    .99S            ;*   workspaces, then a shot can't be fired.
;***
;*      Shooting only occurs when the warrior is within scrolling borders.
;***
        lda     OLPOS,U         ;* Check that the long screen
        cmpa    #BHSCROLL       ;*   position is within the
        lbls    .99S            ;*   hard scrolling borders
        cmpa    #THSCROLL       ;*   at the top and bottom
        lbhs    .99S            ;*   and exit if outside the range.
        lda     OSPOS,U         ;* Check that the short screen
        cmpa    #LHSCROLL       ;*   position is within the
        lbls    .99S            ;*   hard scrolling borders
        cmpa    #RHSCROLL       ;*   at the left and right
        lbhs    .99S            ;*   and exit if outside the range.
;***
;*      Shooting only occurs when the warrior uninhibited.
;***
        lda     OSMIS,Y         ;* If the warrior is
        cmpa    #OMWaMine       ;*   on a mining mission
        beq     .1S             ;*   then it's ok to shoot.
        lda     OSPERS,Y        ;* If the inhibitor has not been counted
        anda    #PWaShInhibit   ;*   down to zero, then the warrior
        lbne    .99S            ;*   cannot yet shoot.
.1S     cmpy    #SPlayer        ;* If this is the player, it must be an
        lbeq    .100S           ;*   attract mode demo, just shoot.
;***
;*
;***
        jsr     aimflang
        pshs    A

        lda     OSANANG,Y       ;* A = angle of the target
        adda    #(CIRCLE/2)     ;*   from the craft (opposite of animation).
        adda    #(CIRCLE/(NITURRET*2))
        anda    #%11100000      ;*   one of 8 warrior angles out of 32 images.

        tfr     A,B             ;* If the warrior's turret is aligned
        subb    ,S+             ;*   with the player,
        bge     .2S             ;*   then don't check if the
        negb                    ;*   turret is locked in yet.
.2S     cmpb    #(CIRCLE/(NITURRET*2))
        ble     .3S

.3S     ldb     OSPERS,Y        ;* If the turret hasn't locked into position
        bitb    #PSHOOT         ;*   then a shot can't be fired,
        lbne    .99S            ;*   so exit if not clear to shoot.
;*
        pshs    A               ;* Save shot angle.
SAVEDY  SET     SAVEDY+1

        TUNE    Qwfire          ;* Make the sound for a warrior shot.
        jsr     getobj          ;* X -> shot object workspace
        ldy     #CWARSHOT       ;* Save the warrior's shot
        sty     OCHAR,X         ;*   image characteristics.

        ldb     0,S             ;* Round off the angle to
        andb    #%01100000      ;*   one of 8 warrior angles out of 32 images.
        RPT     5,asrb
        lda     #OILEN          ;* Multiply the image number times the length
        mul                     ;*   of an image descriptor
        addd    #IWARRSHOT      ;* Now D -> the correct animation image.
        tfr     D,U             ;* Establish
        jsr     imgobj          ;*   the image.
;***
;*      X -> scanner workspace of shot
;*      U -> shot image descriptor
;*
;*      Establish SHORT Velocity
;***
        lda     0,S             ;* A = the shot angle
        jsr     SinCos          ;* The SHORT velocity of the shot is based
        exg     A,B             ;*   on the sine of the craft's flight angle.
        pshs    A               ;*   (save the cosine for LONG velocity)
SAVEDY  SET     SAVEDY+1
;*
        sex
        RPT     2+1,ASLB,ROLA
;*
        ldy     SAVEDY,S        ;* Y -> warrior scanner workspace
        ldy     OSSCWSA,Y       ;* Y -> warrior object workspace
        addd    OSVEL,Y         ;* Add the warrior speed
        std     OSVEL,X         ;*   to the speed of the shot.
;***
;*      Establish LONG velocity
;***
        puls    B               ;* The LONG velocity is cosine of flight angle.
SAVEDY  SET     SAVEDY-1
        sex
        RPT     2+0,ASLB,ROLA

        ldy     SAVEDY,S        ;* Y -> warrior scanner workspace
        ldy     OSSCWSA,Y       ;* Y -> warrior object workspace
        addd    OLVEL,Y         ;* Adjust the speed of the shot
        std     OLVEL,X         ;*   by adding the speed of the warrior.
;***
;*      Establish LONG and SHORT position
;***
        ldy     SAVEDY,S        ;* Y -> warrior scanner workspace
        puls    A               ;* A = the shot angle.
SAVEDY  SET     SAVEDY-1

        ldy     OSSCWSA,Y       ;* Y -> warrior object workspace
        pshs    Y               ;* Save it.
        ldy     OIDESC,Y        ;* Y -> image descriptor of warrior

        lda     OLCENT,Y
        suba    OLCENT,U
        clrb
        jsr     asrd1
        pshs    D
        lda     OSCENT,Y
        suba    OSCENT,U
        clrb

        ldy     2,S             ;* Y -> warrior object workspace
        addb    OSPOSF,Y
        adca    OSPOS,Y         ;* Add the warrior position
        sta     OSPOS,X         ;* Store the shot's
        stb     OSPOSF,X        ;*   new short position.

        sta     OLEFT,X         ;* And assume that is the left edge too.

        puls    D
        puls    Y               ;* Y -> warrior object workspace
        addb    OLPOSF,Y        ;* Add the LONG position
        adca    OLPOS,Y         ;*   of the warrior craft.
        sta     OLPOS,X         ;* Save the LONG postion
        stb     OLPOSF,X        ;*   coordinate.

        clr     OSTATUS,X       ;* Update the display status
        jsr     putobj          ;*   to display the shot.

.99S    puls    A,B,X,Y,U       ;* Restore work resgisters
        rts

.100S   jsr     PlShoot         ;* The player shoots his own shot.
        bra     .99S            ;* Exit.

        PULLORG ROMSAVE