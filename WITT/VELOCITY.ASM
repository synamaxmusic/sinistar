;;===============================================================================
; EQUs to remove later
;LdyWCR EQU     $65EE
;CHASE  EQU     $65B9
;;===============================================================================

velocity
        PUSHORG ROMSAVE
;*****
;*
;* NEWVELOCITY
;*      A desirable velocity is established based on the distance from
;*      the target to the craft.  A positive distance requires a negative
;*      velocity to bring the craft back and visa-versa.
;*
;* Needs:
;*      D = the distance between the target and the craft
;*      X -> velocity table
;*
;* Returns:
;*      D = the signed desired velocity for the craft
;*      U -> acceleration routine
;*
;*****
newvelocity
        pshs    A,X             ;* Save work registers and mark stack
        clr     0,S             ;*   assuming a negative velocity
        dec     0,S             ;*   for a positive distance.
        tsta                    ;* If the distance in question
        bge     .1S             ;*   is negative
        neg     0,S             ;* Then mark the velocity positive
        NEGD                    ;*   and make it so.
;***
;* Ready to range distance and establish a velocity objective.
;***
.1S     cmpd    OSTBLD,X        ;* Range the current distance (in D) with
        bge     .2S             ;*   a distance entry in the table.
        leax    OSTBLZ,X        ;* If the current entry didn't match, one
        bra     .1S             ;*   of the succeeding entries must match.

.2S     ldd     OSTBLS,X        ;* D = the velocity objective for this range.
        tst     ,S+             ;* If the velocity should be negated,
        bge     .3S             ;*   as indicated by the flag from the start,
        NEGD                    ;* Then negate it.
.3S     puls    X               ;* Restore work registers
        tfr     X,U
        pshs    D
        tsta
        bge     .4S
        NEGD
.4S     cmpd    OSTBLS,U
        bge     .5S
        leau    OSTBLZ,U        ;* U -> next entry in table
        bra     .4S             ;* Try again to match.
.5S     ldu     OSTBLA,U        ;* U -> acceleration routine to use.
        puls    D               ;* Restore velocity
        rts

;*****
;*
;* UPDATE OBJECT VELOCITY
;*
;*      UPDLVELOCITY    - Update the Long direction Scanner/Screen Velocity
;*      UPDSVELOCITY    - Update the Short direction Scanner/Screen Velocity
;*
;*      Velocity changes are made in small increments in order to imitate
;*      acceleration.  The amount of the increment is controlled by the
;*      caller via providing U pointing to a routine which will return a
;*      fraction of the velocity change.
;*
;*      The velocity intended for the SHORT direction is made twice as fast
;*      as that in the long, in order to compensate the shape of the physical
;*      universe.
;*
;* Calls:
;*      chase
;*
;* Needs:
;*      X -> top of speed table (for maximum velocity of CHASE)
;*      Y -> scanner workspace of the craft
;*      U -> acceleration routine
;*      D =  the desired velocity of the craft
;*
;* Returns:
;*      NOTHING - Registers remain unchanged (CC may be affected).
;*
;*****
updlvelocity
        pshs    D,Y             ;* Save work registers
STACKY  SET     2               ;* This is the offset of Y onto the stack
;***
;*      Add the velocity of the target to the desired velocity
;***
        jsr     LdyWCR          ;* Y -> scanner workspace of caller
        pshs    D
        ldb     OSLVEL,Y        ;* Y -> the LONG speed of the target
        clra
        jsr     asrd1
        subd    SLVEL           ;* <<< Rick test w/workers! >>>
        tfr     D,Y
        puls    D
        jsr     chase           ;* Update speed of craft to persue target.
        ldy     STACKY,S        ;* Restore the scanner workspace pointer
        ldy     OSSCWSA,Y       ;* Y -> object workspace of craft.
        bne     .10S            ;* If craft is on screen, update screen speed.
;***
;*      Update the scanner velocity (long)
;***
        ldy     STACKY,S        ;* Y -> scanner workspace
        leay    OSLVEL,Y        ;* Y -> long scanner velocity
        bra     updscanner
;***
;*      Update the screen velocity (long)
;***
.10S    leay    OLVEL,Y         ;* Y -> long object velocity
        bra     updscreen
;***
;*
;* UPDSVELOCITY
;*
;***
updsvelocity
        pshs    D,Y             ;* Save work registers
STACKY  SET     2               ;* This is the offset of Y onto the stack
        RPT     1,aslb,rola     ;* Double the short velocity for the system.
;***
;*      Add the velocity of the target to the desired velocity
;***
        jsr     ldyWCR          ;* Y -> scanner workspace of caller
        pshs    D
        ldb     OSSVEL,Y        ;* Y -> the SHORT speed of the target
        clra
        jsr     asrd1
        subd    SSVEL           ;* <<< Rick, test! >>>
        tfr     D,Y
        puls    D
        jsr     chase           ;* Update speed of craft to persue target.
        ldy     STACKY,S        ;* Restore the scanner workspace pointer
        ldy     OSSCWSA,Y       ;* If the WORKER is on screen
        bne     updss           ;*   then update the screen speed
;***
;*      Update the scanner velocity (short)
;***
        ldy     STACKY,S        ;* Y -> scanner workspace
        leay    OSSVEL,Y        ;* Y -> short scanner velocity

updscanner
        jsr     asrd6           ;* Scale Down the Scanner Velocity
        subb    0,Y             ;* If the desired velocity has already been
        beq     .4S             ;*   attained, then no change occurs.
        sex                     ;* Otherwise,
        jsr     0,U             ;*   Cut the velocity difference
        tstb                    ;* Only round up if B is positive
        bmi     .2S             ;*   else, round down.
        orb     #1              ;* < Patched over >
        bra     .3S
.2S     andb    #-2             ;* Round down when B is negative.
.3S     addb    0,Y             ;* < Patched over >
        stb     0,Y             ;*   gradual.
.4S     bra     updexit         ;* Done!
;***
;*      Update the screen velocity (short)
;***
updss   leay    OSVEL,Y         ;* Y -> short object velocity
;       IFN     VERSION-FINAL
        NOP                     ;FOR REPLACING
;       ENDIF
updscreen
        subd    0,Y             ;* If the desired velocity has already been

        beq     updexit         ;*   attained, then no change occurs.
        jsr     0,U             ;* Cut the velocity difference
        orb     #1              ;*   (and round up)
        addd    0,Y             ;*   to make the change in velocity
        std     0,Y             ;*   gradual.

updexit
        puls    D,Y             ;* Restore work registers
        rts

        PULLORG ROMSAVE

        INCLUDE "../WITT/CHASE.ASM"
        INCLUDE "../WITT/LDYWCR.ASM"