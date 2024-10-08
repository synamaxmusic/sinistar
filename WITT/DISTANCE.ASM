;       INCLVER RICH,table              * ORG Macro

;       SUBTTL  DISTANCE ROUTINES

        PUSHORG ROMSAVE
        ROUTINE distance
;*****
;*
;* GETLDX - Get LONG  pixel distance of object X in 16-bits
;* GETSDX - Get SHORT pixel distance of object X in 16-bits
;*
;* Needs:
;*      X -> scanner workspace of the target
;*
;* Note:
;*      GETLDX operates a little differently from GETSDX since the
;*      executive maintains the screen distance differently between
;*      the long and the short values.
;*
;*      Scanner distances are computed differently from screen distances
;*      since scanner distances can be signed but screen distances are not
;*      in the executive's values.  The computed distance which these routines
;*      return is, of course, a signed 16-bit value in any case.  The executive
;*      maintains scanner distances relative to the player and screen distances
;*      relative to 0,0 (the corner of the display).
;*
;* Returns:
;*      D = the signed 16-bit pixel distance coordinate of the object
;*          relative to the player's ship.
;*
;*****
        ROUTINE GetLDX
        pshs    U,Y             ;* Save work registers
        ldu     OSSCWSA,X       ;* If the object is not on screen,
        beq     .100S           ;*   then scanner distances are good enough.
;***
;*      Screen distance computation
;***
        ldy     [PlaIndex]      ;* Y -> scanner workspace of (onscreen) player
        ldy     OSSCWSA,Y       ;* Y -> onscreen workspace of player

        clra
        ldb     OLPOS,Y         ;* Get the LONG screen distance of the
        aslb                    ;*   player in 2 pixel units
        adca    #0              ;*   scaled down to pixels.
        pshs    D               ;* Save it for a moment.
        clra
        ldb     OLPOS,U         ;* Get the LONG screen distance of the
        aslb                    ;*   object in 2 pixel units
        adca    #0              ;*   scaled down to pixels.

        subd    ,S++            ;* Make the object's distance relative to the
        bra     .99S            ;*   player by subtracting the player position.
;***
;*      Scanner distance computation
;***
.100S   ldb     OSLPOS,X        ;* Get the LONG scanner distance of the
        sex                     ;*   object in 4 pixel units
        RPT     2,aslb,rola     ;*   scaled down to pixels.
.99S    puls    U,Y             ;* Restore work registers
        rts
;***
;*
;***
        ROUTINE GetSDX
        pshs    U,Y             ;* Save work registers
        ldu     OSSCWSA,X       ;* If the object is not on screen,
        beq     .100S           ;*   then scanner distances are good enough.
;***
;*      Screen distance computation
;***
        ldy     [PlaIndex]      ;* Y -> scanner workspace of (onscreen) player
        ldy     OSSCWSA,Y       ;* Y -> onscreen workspace of player
        ldb     OSPOS,Y         ;* Get the SHORT screen distance of the
        clra                    ;*   player already in pixels.
        pshs    D               ;* Save it for a moment.
        ldb     OSPOS,U         ;* Get the SHORT screen distance of the
;*      clra                    ;*   object already in pixels.
        subd    ,S++            ;* Make the object's distance relative to the
        bra     .99S            ;*   player by subtracting the player position.
;***
;*      Scanner distance computation
;***
.100S   ldb     OSSPOS,X        ;* Get the SHORT scanner distance of the
        sex                     ;*   object in 4 pixel units
        RPT     2,aslb,rola     ;*   scaled down to pixels.
.99S    puls    U,Y             ;* Restore work registers
        rts

;*****
;*
;* GETDISTANCE
;*      Determine long (GETLDISTANCE) or short (GETSDISTANCE) distance
;*      of craft from target.
;*
;*      GETLDISTANCE -  Returns the 16-bit LONG distance in pixels.
;*      GETSDISTANCE -  Returns the 16-bit SHORT distance in pixels.
;*
;* Needs:
;*      X -> scanner workspace of the target
;*      Y -> scanner workspace of the craft
;*
;*      The computations are made from the screen distances of the target
;*      or craft when possible, otherwise using the scanner distances of
;*      these objects.  Both values must be converted to a 16-bit pixel dist.
;*
;* Returns:
;*      D = the signed 16-bit pixel distance from the target to the craft.
;*
;*****
        ROUTINE GetLDistance
        pshs    X               ;* Save work registers.
        jsr     GetLDX          ;* Get and save the LONG distance
        pshs    D               ;*   of the TARGET.
        leax    Y               ;* Get the LONG distance
        jsr     GetLDX          ;*   of the CRAFT.
        subd    S++             ;* Return (TARGET - CRAFT) distance in D.
        puls    X               ;* Restore work registers.
        rts

        ROUTINE GetSDistance
        pshs    X               ;* Save work registers.
        jsr     GetSDX          ;* Get and save the SHORT distance
        pshs    D               ;*   of the TARGET.
        leax    Y               ;* Get the SHORT distance
        jsr     GetSDX          ;*   of the CRAFT.
        subd    S++             ;* Return (TARGET - CRAFT) distance in D.
        puls    X               ;* Restore work registers.
        rts

        IF 1 = 0                ;* <<< Under construction >>>           ;;Fixme was: IFE  1
        ERROR   This code is not to be assembled                        ;;Fixme was: ERR
        ERROR   This code is/was under construction                     ;;Fixme was: ERR
;*****
;*
;* GET ELIPTIC DISTANCE
;*      Determine long (GETLEDISTANCE) or short (GETSEDISTANCE) eliptical
;*      distance of craft from target.
;*
;*      GETLEDISTANCE - Returns the 16-bit LONG eliptical distance in pixels.
;*      GETSEDISTANCE - Returns the 16-bit SHORT eliptical distance in pixels.
;*
;* Needs:
;*      X -> scanner workspace of the target
;*      Y -> scanner workspace of the craft
;*
;* Returns:
;*      D = the signed 16-bit distance from the target to the craft.
;*
;*****
        ROUTINE getledistance
        jsr     geteorbit       ;* Set the elipse.
        jmp     getoldistance   ;* Get the orbital distance.

        ROUTINE getsedistance
        jsr     geteorbit       ;* Set the elipse.
        jmp     getosdistance   ;* Get the orbital distance.

        ROUTINE getlodistance
        jsr     getcorbit       ;* Set the circle.
        jmp     getoldistance   ;* Get the orbital distance.

        ROUTINE getsodistance
        jsr     getcorbit       ;* Set the circle.
        jmp     getosdistance   ;* Get the orbital distance.
;*****
;*
;* GETCORBIT
;*      Get a circular orbit factor.
;*
;* Needs:
;*      A = absolute orbit factor
;*      X -> scanner workspace of orbit leading craft
;*      OSPERS,X contains personality bit POrbit which controls orbit direction
;*
;* Returns:
;*      A = a signed orbital factor
;*
;* GETEORBIT
;*      Get an eliptical orbit factor.
;*
;* Needs:
;*      X -> scanner workspace of orbit leading craft
;*      Y -> scanner workspace of orbiting craft
;*      OSFLANG,Y contains the flight angle of the orbiting craft
;*
;* Returns:
;*      A = a signed orbital factor
;*
;* Note:
;*      Both routines go through the common routine GETORBIT.
;*
;*****
;       TABLE   Eliptic
        fcb     IORBIT*2
        fcb     IORBIT*4
        fcb     IORBIT*8
        fcb     IORBIT
        fcb     IORBIT
        fcb     IORBIT
        fcb     IORBIT
        fcb     IORBIT
;       ENDTBL

        ROUTINE geteorbit
        pshs    U               ;* Save work registers
        ldu     #eliptic        ;* U -> orbital table
        lda     OSFLANG,Y       ;* A = angle of flight
        adda    #(CIRCLE/(8*2)) ;* Round off the flight angle.
        RPT     5,asra          ;* There are 8 possible images
        adda    #(8/2)          ;*   from 0 through 7.
        lda     A,U             ;* A = orbit to use
        bra     getorbit        ;* U -> orbital table

        ROUTINE getcorbit
        pshs    U               ;* Save work registers
;*      Needs A = orbital factor
;*                              ;* U -> orbital table
        ROUTINE getorbit
        ldb     WarrOrbit       ;* B = the leader's personality,
        andb    #1              ;*   from the timer established orbit,
        bne     1$              ;*   in a clockwise
        nega                    ;*   or a counterclockwise direction.
1$      puls    U               ;* Restore work registers
        rts

;*****
;*
;* GET ORBITAL DISTANCE
;*      Determine long (GETLODISTANCE) or short (GETSODISTANCE) orbital
;*      distance of craft from target.
;*
;*      GETLODISTANCE - Returns the 16-bit LONG orbital distance in pixels.
;*      GETSODISTANCE - Returns the 16-bit SHORT orbital distance in pixels.
;*
;* Needs:
;*      A = orbit factor (IORBIT or OORBIT)
;*      X -> scanner workspace of the target
;*      Y -> scanner workspace of the craft
;*
;* Returns:
;*      D = the signed 16-bit distance from the target to the craft.
;*
;*****
        ROUTINE getoldistance
        pshs    A,X,Y           ;* Save work registers
        jsr     GetLDX          ;* Get and save the LONG distance of the
        pshs    D               ;*   TARGET in pixels.
        jsr     aimflang        ;* A = flight angle for orbiting.
        jsr     sincos
        ldb     2,S             ;* Subtract
        negb
        jsr     smul8
        RPT     4,asra,rorb     ;* 12/15
        addd    0,S
        std     0,S
;* ***** *
        jsr     GetLVX          ;* Get the LONG velocity of TARGET in pix/frame

        IF 1 = 0                                                        ;;Fixme was: IFE  1
;* ** * This was pixels/frame but is now pixels in MSByte
;*      RPT     1,nop,nop
        RPT     3,aslb,rola     ;* In (tasklist) 8 times it will be
        ELSE
        RPT     8-3,asra,rorb   ;* (8 for pixels/frame) less (3 for task8 list)
        ENDIF   ;1

        addd    0,S             ;*   that many pixels further!
        std     0,S             ;* Save it for the subtract
        nop
;* ***** *
        leax    Y               ;* X -> scanner workspace of CRAFT.
        jsr     GetLDX          ;* Get the LONG distance of the CRAFT in pixels
        subd    ,S++            ;* Now subtract to determine the distance.
        leas    1,S             ;* Clear the stack
        puls    X,Y             ;* Restore work registers
        rts

        ROUTINE getosdistance
        pshs    A,X,Y           ;* Save work registers
        jsr     GetSDX          ;* Get and save the SHORT distance of the
        pshs    D               ;*   TARGET in pixels.
        jsr     aimflang        ;* A = flight angle for orbiting.
        jsr     sincos
        lda     2,S             ;* Add
        jsr     smul8
        RPT     4,asra,rorb     ;* 12/15
        addd    0,S
        std     0,S
;* ***** *
        jsr     GetSVX          ;* Get the SHORT velocity of TARGET in pix/frame

        IF 1 = 0                                                        ;;Fixme was: IFE  1
;* ** * This was pixels/frame but is now pixels in MSByte
;*      RPT     1,nop,nop
        RPT     3,aslb,rola     ;* In (tasklist) 8 times it will be
        ELSE
        RPT     8-3,asra,rorb   ;* (8 for pixels/frame) less (3 for task8 list)
        ENDIF   ;1

        addd    0,S             ;*   that many pixels further!
        std     0,S             ;* Save it for the subtract
        nop
;* ***** *
        leax    Y               ;* X -> scanner workspace of CRAFT.
        jsr     GetSDX          ;* Get the SHORT distance of the CRAFT in pixels
        subd    ,S++            ;* Now subtract to determine the distance.
        leas    1,S             ;* Clear the stack
        puls    X,Y             ;* Restore work registers
        rts

        ENDIF   ;1              ;* <<< Under construction >>>           ;;(Man, all this code from lines 131 to 312 is unused!)
;*****
;*
;* GET ORBITAL DISTANCE
;*      Determine long (GETLODISTANCE) or short (GETSODISTANCE) orbital
;*      distance of craft from target.
;*
;*      GETLODISTANCE - Returns the 16-bit LONG orbital distance in pixels.
;*      GETSODISTANCE - Returns the 16-bit SHORT orbital distance in pixels.
;*
;* Needs:
;*      A = orbit factor (IORBIT or OORBIT)
;*      X -> scanner workspace of the target
;*      Y -> scanner workspace of the craft
;*
;* Returns:
;*      D = the signed 16-bit distance from the target to the craft.
;*
;*****
        ROUTINE getlodistance
        pshs    A,X,Y           ;* Save work registers
        lda     OSLPOS,X        ;* Get the LONG scanner
        clrb                    ;*   distance of the target
        jsr     asrd2           ;*   scaled down to pixels.
        pshs    D
        jsr     AimFlAng        ;* A = the angle toward the target.
        jsr     sincos
        ldb     2,S             ;* Subtract
        negb
        jsr     smul8
        addd    0,S
        std     0,S
        ldb     OSLVEL,X        ;* Get the LONG scanner velocity
        sex                     ;*   in a 16-bit
        RPT     1,aslb,rola     ;*   pixel/second value
        RPT     6,aslb,rola     ;* In (tasklist) 16 times it will be
        addd    0,S             ;*   that many pixels further!
        std     0,S             ;* Save it for the subtract
        clrb                    ;* Get the LONG scanner
        lda     OSLPOS,Y        ;*   distance of the craft
        jsr     asrd2           ;*   scaled down to pixels.
        subd    ,S++            ;* Now subtract to determine the distance.
        leas    1,S             ;* Clear the stack
        puls    X,Y             ;* Restore work registers
        rts

        ROUTINE getsodistance
        pshs    A,X,Y           ;* Save work registers
        lda     OSSPOS,X        ;* Get the SHORT scanner
        clrb                    ;*   distance of the target
        jsr     asrd2           ;*   scaled down to pixels.
        pshs    D
        jsr     AimFlAng        ;* A = the angle toward the target.
        jsr     sincos
        lda     2,S             ;* Add
        jsr     smul8
        addd    0,S
        std     0,S
        ldb     OSLVEL,X        ;* Get the LONG scanner velocity
        sex                     ;*   in a 16-bit
        RPT     1,aslb,rola     ;*   pixel/second value
        RPT     6,aslb,rola     ;* In (tasklist) 16 times it will be
        addd    0,S             ;*   that many pixels further!
        std     0,S             ;* Save it for the subtract
        clrb                    ;* Get the SHORT scanner
        lda     OSSPOS,Y        ;*   distance of the craft
        jsr     asrd2           ;*   scaled down to pixels.
        subd    ,S++            ;* Now subtract to determine the distance.
        leas    1,S             ;* Clear the stack
        puls    X,Y             ;* Restore work registers
        rts

        PULLORG ROMSAVE

        INCLUDE "../WITT/GETLVX.ASM"            ;* Velocity module for orbits