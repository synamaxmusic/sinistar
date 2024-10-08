;;===============================================================================
; EQUs to remove later
;think  EQU     $69DA
;upddtc EQU     $6496
;updflang EQU   $64D2
;aniworker EQU  $62C8
;getldist EQU   $6338
;getsdist EQU   $6349
;Nexttarget EQU $63F7
;KRWorker EQU   $6C73
;;===============================================================================

        PUSHORG ROMSAVE
;***
;*
;* Rich's changes to Version 6:
;*  Workers with crystals become part of the sinistar faster via
;*      farther distance allowed during off screen checking.
;*
;***
;       SUBTTL  Worker intelligence - Mission Dispatcher
;*****
;*
;*      W   W   OOO   RRRR   K   K  EEEEE  RRRR
;*      W   W  O   O  R   R  K  K   E      R   R
;*      W   W  O   O  RRRR   KKK    EEEE   RRRR
;*      W W W  O   O  R  R   K  K   E      R  R
;*       W W    OOO   R   R  K   K  EEEEE  R   R
;*
;*****
;;      LOCAL
;*****
;*
;* WORKER
;*      This routine controls the WORKER intelligence.
;*
;* Needs:
;*      Y -> task workspace for this worker
;*
;* Returns:
;*      nothing - all registers preserved (not condition codes)
;*
;*****
        ROUTINE worker
        pshs    A,B,X,Y         ;* Save work registers
        ldy     [OWSCON,Y]      ;* Y -> scanner workspace
;***
;*      Check mission type
;*
;*      Mission assignments are made even and any odd mission value is
;*      treated as the even mission value below it.  However, mission
;*      values which are outside the range of 0 to OMWOSIZE are dealt
;*      with as a SWI for testing purposes, or turned into a DRIFT mission
;*      in the final version (error reporting during game play is not useful).
;***
        clra                    ;* Use the mission type
        ldb     OSMIS,Y         ;*   as an offset into

        IFDEF   Development
        andb    #%11111110      ;*   the mission table (word offset only).
        blt     .1S             ;* Negative mission values are invalid.
        cmpb    #OMWoSav        ;* Mission values must also be          ;;Fixme was: cmpb #OMWoSave
        blt     .2S             ;*   less than this limit to be valid.
        swi                     ;*   trap incorrect missions
.1S     ldb     #OMWODRIFT      ;*   drift in space until orders are re-checked.
        ENDIF   ;;Development

.2S     ldx     #workmis        ;* Call the routine
;*
        jsr     [B,X]           ;*   for that mission.
        puls    A,B,X,Y         ;* Restore work registers
        SLEEP   LOOP            ;* That's All!  Reactivate later

        IFNDEF  WORKMIS
workmis
        fdb     .110S           ;* Drift in space
        fdb     .120S           ;* Tail target
        fdb     .130S           ;* Intercept target
        fdb     .140S           ;* Deliver crystal to Sinistar
        fdb     .150S           ;* Evade from current course
;;      PAD     (6*2)-OMWoSave  ;* Pad to 6 entries
        RMB     (6*2)-OMWoSav                                           ;;Fixme was: PAD (6*2)-OMWoSave
        ELSE
        PUSHORG workmis
        fdb     .110S           ;* Drift in space
        fdb     .120S           ;* Tail target
        fdb     .130S           ;* Intercept target
        fdb     .140S           ;* Deliver crystal to Sinistar
        fdb     .150S           ;* Evade from current course
;;      PAD     (6*2)-OMWoSave  ;* Pad to 6 entries
        RMB     (6*2)-OMWoSav                                           ;;Fixme was: PAD (6*2)-OMWoSave
        PULLORG
        ENDIF   ;;WorkMis
;*****
;*
;* DRIFT (110$)
;*      Worker drifts in space.
;*
;* Bugs:
;*      Funny animation
;*
;* Needs:
;*      Nothing
;*
;* Returns:
;*      Nothing
;*
;*****
.110S   pshs    A,B,X,Y,U       ;* Save work registers
        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller

        lda     OSFLANG,Y       ;* Bump up the flight
        adda    #(CIRCLE/NIWORKER)      ;*   angle of the drifting worker
        sta     OSFLANG,Y       ;*   to create the motion of traveling
        lda     #DORBIT         ;*   in a tight circle.
        jsr     think           ;* Effectively, thinking occurs
        lbcc    .122S           ;*   on the Task16 list.
        puls    A,B,X,Y,U       ;* Restore work registers
        rts

;*****
;*
;* TAIL (120$)
;*
;*      Worker tails (orbits) target.  Animation is performed to aim the
;*      worker craft in the direction of travel (tangent to the caller
;*      target being orbited).
;*
;* Needs:
;*      Y -> worker scanner workspace
;*
;* Returns:
;*      Nothing
;*
;*****
.120S   pshs    A,B,X,Y,U       ;* Save work registers
        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller
        jsr     think           ;* Effectively, thinking occurs
        lbcs    .129S           ;*   on the Task16 list.
        jsr     upddtc          ;* Update the Distance To Caller (for caller).
.121S   lda     #OORBIT         ;* Workers orbit on the outside.
.122S   pshs    X               ;* Save scanner workspace of target
        jsr     updflang        ;* Update flight angle for orbiting.
;***
;*      Update the velocity (to ORBIT the target)
;***
        ldb     WorkOrbit       ;* B = Personality of a worker orbit.
        pshs    A               ;* Save the orbit factor
        pshs    B               ;* Save the orbit trait
        jsr     getlodist       ;* D = long orbital distance from the target
        pshs    D               ;* Save it for the animation.
        ldx     #stblworker     ;* X -> speed table for workers
        jsr     newvel          ;* D = velocity to achieve
        jsr     updlvel         ;* Update the long velocity

        ldx     2+1+1,S         ;* X -> scanner workspace of target
        lda     2+1,S           ;* A = the orbit factor.
        ldb     2+0,S           ;* B = the orbit personality.
        jsr     getsodist       ;* D = short orbital distance from the target
        pshs    D               ;* Save it for the animation.
        ldx     #stblworker     ;* X -> speed table for workers
        jsr     newvel          ;* D = velocity to achieve
        jsr     updsvel         ;* Update the short velocity

        puls    D               ;* Restore the short orbital distance
        RPT     2,aslb,rola     ;*   and scale it back up to scanner
        pshs    A               ;*   distances (for RECTANG).
        ldd     1,S             ;* Restore the long orbital distance
        RPT     2,aslb,rola     ;*   and scale it back up to scanner
        puls    B               ;*   distances (for RECTANG).
        jsr     rectang         ;* Animate the craft based
        jsr     aniworker       ;*   on the angle of the craft's heading.

        leas    2+1+1+2,S       ;* Clear the stack.
.129S   puls    A,B,X,Y,U       ;* Restore work registers
        rts

;*****
;*
;* INTERCEPT (130$)
;*
;*      Worker intercepts target (to pick up crystal or ram player).
;*
;* Needs:
;*      Y -> worker scanner workspace
;*
;* Returns:
;*      Nothing
;*
;*****
.130S   pshs    A,B,X,Y,U       ;* Save work registers
        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller
        jsr     updflang        ;* Update flight angle for animation.
        lda     OSFLANG,Y       ;* Animate based on
        jsr     aniworker       ;*   the angle of the craft's heading.
        jsr     think           ;* Effectively, thinking occurs
        lbcs    .139S           ;*   on the task16 list.

        jsr     upddtc          ;* Update the Distance To Caller (for caller).
        pshs    X               ;* Save for the SHORT calculations.
;***
;*      Update the velocity (to INTERCEPT the target)
;***
        jsr     getldist        ;* D = long distance from the target
        ldx     #stblintercept  ;* X -> speed table for workers
        jsr     newvel          ;* D = velocity to achieve
        jsr     updlvel         ;* Update the long velocity

        puls    X               ;* X -> scanner workspace of target
        jsr     getsdist        ;* D = short distance from the target
        ldx     #stblintercept  ;* X -> speed table for workers
        jsr     newvel          ;* D = velocity to achieve
        jsr     updsvel         ;* Update the short velocity

.139S   puls    A,B,X,Y,U       ;* Restore work registers
        rts

;*****
;*
;* SINICEPT (140$)
;*
;*      Worker intercepts Sinistar to deliver crystal.
;*      The worker determines that it has reached the Sinistar by checking
;*      the updated Distance To Caller.  When this value is zero, the worker
;*      builds a piece of the Sinsitar.
;*
;* Needs:
;*      A = Default condition for worker existance (0 = life, 1 = death)
;*      Y -> worker scanner workspace
;*
;* Returns:
;*      A = 0 for life or 1 for death
;*      Nothing
;*
;*****
.140S   pshs    A,B,X,Y,U       ;* Save work registers
;***
;*      ldx     SinIndex        ;* Force a "Sinicepting" worker
;*      stx     OSCWCR,Y        ;*   to be called by the Sinistar.
;***
        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller (Sinistar)
;***
;*      IFN     Version-Final   ;* Until the final release,
;*      cmpx    [SinIndex]      ;*   check that the caller is always
;*      beq     141$            ;*   the Sinistar.
;*      swi                     ;* If the caller is not the Sinistar, then TRAP!
;*141$  nop
;*      ENDIF   Version-Final
;***
        jsr     think           ;* Effectively, thinking occurs
        lbcs    .149S           ;*   on the task16 list.

        jsr     Nexttarget      ;* Retarget the Sinistar to its next offset.
;*      The old Sinistar position information is stored in TEMP for UNTARGET.
        jsr     upddtc          ;* Update the Distance To Caller (for caller).

        tst     SinGrave        ;* Workers should not attempt to approach
        bne     .144S           ;*   a dying Sinistar.
;***
;*      The buildup of the first Sinistar is different from all the rest.
;*      The first Sinistar does not rebuild when damaged.  It can only be hurt.
;*      All other Sinistars will rebuild (from workers with crystals) as damage
;*      occurs.
;***
        ldd     PiecePtr        ;* If the Sinistar
        cmpd    Finish          ;*   is fully built
        beq     .144S           ;*   then orbit it.
        tst     SiniKills       ;* If not fully built and this is not the first
        bne     .146S           ;*   Sinistar, then build or rebuild it.
        ldd     Finish          ;* The first Sinistar only builds up until
        cmpd    #Alive          ;*   it comes alive.  If not alive, it builds up
        bne     .146S           ;*   but, alive, the 1st one doesn't rebuild.

.144S   jsr     .145S           ;* Else, orbit the Sinistar
        bra     .148S           ;*   and end intelligence.
.145S   pshs    A,B,X,Y,U       ;* Save work registers
        lda     #SORBIT         ;* A = Sinistar orbiting factor
        jmp     .122S           ;* Tail the Sinistar.
;*
.146S   jsr     updflang        ;* Update flight angle for animation.
;***
;*      Update the velocity (to INTERCEPT the target)
;***
        jsr     getldist        ;* D = long distance from the target
        ldx     #stblheavy      ;* X -> speed table for workers w/crystals
        jsr     newvel          ;* D = velocity to achieve
        jsr     updlvel         ;* Update the long velocity

        ldx     [SinIndex]      ;* X -> scanner workspace of Sinistar
        jsr     getsdist        ;* D = short distance from the target
        ldx     #stblheavy      ;* X -> speed table for workers w/crystals
        jsr     newvel          ;* D = velocity to achieve
        jsr     updsvel         ;* Update the short velocity

        lda     OSFLANG,Y       ;* Animate based on
        jsr     aniworker       ;*   the angle of the craft's heading.

        lda     OSCLDC,Y        ;* If the target has been hit, as indicated by
        ora     OSCSDC,Y        ;*   both LONG and SHORT positions being zero,
        bita    #Transform      ;*   within a tolerance of 8*4 pixels,
        bne     .148S           ;*   then then it's time to
        jsr     addpart         ;*   add a piece to the Sinistar.
;***
;*      Normally a worker with a crystal might be killed
;*      with a sequence such as:
;*
;*      leax    Y               ;* Point X to scanner WS of object to kill
;*      ldu     OSChar,X        ;* Load register with charac. descr.
;*      jsr     [OKiVec,U]      ;* Kill it
;*
;*      but that would leave a crystal behind, so a special call is made
;*      instead:
;***
        ldd     OINDEX,Y        ;* It was the worker with the crystal
        std     OSCWCR,Y        ;*   that became the piece that was
        tfr     Y,X             ;*   just added, so that is now
        jsr     KRWorker        ;*   killed off.

.148S   ldx     [SinIndex]      ;* X -> scanner workspace of Sinistar
        jsr     UnTarget        ;* Restore the Sinistar's position information.

.149S   puls    A,B,X,Y,U       ;* Restore work registers
        rts

;*****
;*
;* EVADE (150$)
;*
;*      Worker changes from current course.
;*
;* Needs:
;*      Y -> worker scanner workspace
;*
;* Returns:
;*      Nothing
;*
;*****
.150S   pshs    A,B,X,Y,U       ;* Save work registers
        jsr     think           ;* Effectively, thinking occurs
        bcs     .159S           ;*   on the Task16 list.
;***
;*      Do NOT update distance to caller.
;*      This is so that this worker can be called away.
;***
        ldx     [PlaIndex]      ;* Go and bother the player for lack
        jmp     .121S           ;*   of something better to do.

.159S   puls    A,B,X,Y,U       ;* Restore work registers
        rts

        PULLORG ROMSAVE

;       INCLVER RICH,addpart            ;* Build up the sinistar
        INCLUDE "../WITT/ANIWORK.ASM"           ;* Animate
        INCLUDE "../WITT/DISTANCE.ASM"          ;* Distance Computations
;       INCLVER RICH,lswocr             ;* Leaving sector routine
;       INCLVER RICH,tables             ;* Distance/Velocity tables
        INCLUDE "../WITT/RETARGET.ASM"          ;* Reposition Sinistar to center offset
        INCLUDE "../WITT/UPDDTC.ASM"            ;* Update Distance to Caller
        INCLUDE "../WITT/UPDFLANG.ASM"          ;* Update Flight Angle
        INCLUDE "../WITT/VELOCITY.ASM"          ;* Velocity computations