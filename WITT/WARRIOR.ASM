;;===============================================================================
; EQUs to remove later
BHSCROLL EQU    $0008
THSCROLL EQU    $006C
LHSCROLL EQU    $0010
RHSCROLL EQU    $00F0
;aimwarrior EQU $6836
;screenchk EQU  $68CC
;washodds EQU   $6A57
;shoot  EQU     $68DD
;BombsAway EQU  $6C5E
;aniwarrior EQU $684C
;;===============================================================================

;       SUBTTL  Warrior Intelligence - Mission Dispatcher
;*****
;*
;*      W   W   AAA   RRRR   RRRR   IIIII   OOO   RRRR
;*      W   W  A   A  R   R  R   R    I    O   O  R   R
;*      W   W  AAAAA  RRRR   RRRR     I    O   O  RRRR
;*      W W W  A   A  R  R   R  R     I    O   O  R  R
;*       W W   A   A  R   R  R   R  IIIII   OOO   R   R
;*
;*****
;       LOCAL
        PUSHORG ROMSAVE
;*****
;*
;* WARRIOR
;*      Warrior Intelligence Routine
;*
;* Needs:
;*      Y -> Task workspace for this warrior
;*
;* Returns:
;*      OSFLANG,Y =     The current flight angle of the squadron.  This
;*                      value is updated by the squadron leader and is
;*                      copied by the rest of the pack.
;*
;*      OSSQSIZ,Y =     The current size of the squadron.  This is updated
;*                      by the last craft in the pack for each member of the
;*                      squadron when one exists (i.e. a value > 0).  This
;*                      size may be set to zero (0) by some external process
;*                      thus signalling that the warrior has been called away
;*                      from the squadron on some other mission.
;*
;*      NOTHING - This task sleeps until it re-awakens.
;*
;*****
        ROUTINE warrior

        pshs    A,B,X,Y         ;* Save work registers
        ldy     [OWSCON,Y]      ;* Y -> scanner workspace

        jsr     upddtc          ;* Update Distance To Caller (for caller).
;***
;*      Check mission type
;*
;*      Mission assignments are made even and any odd mission value is
;*      treated as the even mission value below it.  However, mission
;*      values which are outside the range of 0 to OMWASave are dealt
;*      with as a SWI for testing purposes, or turned into a DRIFT mission
;*      in the final version (error reporting during game play is not useful).
;***
        ldb     OSMIS,Y         ;* Use the mission type as an offset into

        IFDEF   Development
        andb    #%11111110      ;*   the mission table (word offset only).
        blt     .1S             ;* Negative mission values are invalid.
        cmpb    #OMWASave       ;* Mission values must also be
        blt     .2S             ;*   less than this limit to be valid.
        swi
.1S     ldb     #OMWADRIFT      ;*   drift in space until orders are re-checked.
        ENDIF   ;Development

.2S     ldx     #warrmis        ;* X -> mission table
;***
;*      The shooting inhibitor is counted down until clear.
;***
        ldu     OSSCWSA,Y       ;* If the warrior is not on screen
        beq     .11S            ;*   then the inhibit counter is not affected.
        lda     OLPOS,U         ;* Check that the long screen
        cmpa    #BHSCROLL       ;*   position is within the
        bls     .11S            ;*   hard scrolling borders
        cmpa    #THSCROLL       ;*   at the top and bottom
        bhs     .11S            ;*   and exit if outside the range.
        lda     OSPOS,U         ;* Check that the short screen
        cmpa    #LHSCROLL       ;*   position is within the
        bls     .11S            ;*   hard scrolling borders
        cmpa    #RHSCROLL       ;*   at the left and right
        bhs     .11S            ;*   and exit if outside the range.
;*
        pshs    B               ;* Save work registers
        lda     OSPERS,Y        ;* The personality byte of the warrior reflects
        tfr     A,B             ;*   the shooting inhibitor status.
        andb    #PWaShInhibit   ;* If the inhibitor has already been cleared,
        beq     .10S            ;*   then it is not counted down any further.
        decb                    ;* Else, the inhibitor is counted down from its
        pshs    B               ;*   maximum value and stored back into the
        anda    #~(PWashIn)     ;*   personality (leaving the rest of the               ;;Fixme was: anda  #!N(PWashInhib)
        ora     ,S+             ;*   traits unaffected, of course) and saved
        sta     OSPERS,Y        ;*   for the next time the warrior awakens.
.10S    puls    B               ;* Restore work registers
.11S    jsr     [B,X]           ;* Start the mission.

        puls    A,B,X,Y         ;* Restore work registers
        SLEEP   LOOP            ;* That's All!  Reactivate later

;       SUBTTL  Warrior Intelligence - Mission Dispatch Table
        IFNDEF  WarrMis
WarrMis
        fdb     .110S           ;* Drift in space
        fdb     .120S           ;* Attack player
        fdb     .140S           ;* Mine planet
        fdb     .150S           ;* Tail object
        fdb     .160S           ;* Intercept object
        fdb     .170S           ;* Demo bombing run
;       PAD     OMWaLen-OMWaSave        ;* Pad for additional missions, if any.
        RMB     OMWaLen-OMWaSav
        ELSE
        PUSHORG WarrMis
        fdb     .110S           ;* Drift in space
        fdb     .120S           ;* Attack player
        fdb     .140S           ;* Mine planet
        fdb     .150S           ;* Tail object
        fdb     .160S           ;* Intercept object
        fdb     .170S           ;* Demo bombing run
        PULLORG
        ENDIF   ;WarrMis

;       SUBTTL  Warrior Intelligence - Drift Mission
;*****
;*
;* DRIFT (110$)
;*      Warrior drifts in space.  If a player happens to come by, the
;*      warrior will shoot at the player.
;*
;*      The animation is handled by the SHOOT routine.  The guns are aimed
;*      toward the player's craft.
;*
;* Needs:
;*      Y -> warrior scanner workspace
;*
;* Returns:
;*      Nothing
;*
;*****
.110S   pshs    A,B,X,Y,U       ;* Save work registers.
        ldx     [PlaIndex]      ;* X -> player (psuedo) scanner workspace
        jsr     .111S           ;* Animate for attack against moving player.
        jsr     think           ;* Continue with the DRIFT mission
        lbcc    .100S           ;*   if cleared to think.
        puls    A,B,X,Y,U       ;* Else, restore work registers and exit.
        rts

;*****
;*
;* Animate for attack against moving player (111$)
;*
;* Calls:
;*      aimwarrior
;*      aniwarrior
;*      updflang
;*
;* Needs:
;*      Y -> scanner workspace of (warrior) craft
;*      OSFLANG,Y - New animation angle.
;*      OSANANG,Y - Old animation angle.
;*
;* Returns:
;*      OSFLANG,Y   - New flight angle.
;*      OSANANG,Y   - New animation angle.
;*
;*****
.111S   pshs    A               ;* Save work registers
        lda     OSFLANG,Y       ;* Save the old flight angle
        pshs    A               ;*   for aiming the warrior.
        jsr     updflang        ;* Update the flight angle.
        puls    A               ;* Restore the aiming information.
        jsr     aimwarrior      ;* A = aim angle based on FLANG changes.
        jsr     aniwarrior      ;* Animate the warrior based on angle A.
        puls    A               ;* Restore work registers
        rts

;       SUBTTL  Warrior Intelligence - Attack Mission
;*****
;*
;* ATTACK (120$)
;*
;*      Warriors attack player.
;*      The animation is handled by the SHOOT routine.  The guns are aimed
;*      toward the player's craft.
;*
;* Needs:
;*      Y -> scanner workspace of warrior
;*
;* Returns:
;*      Nothing
;*
;*****
.120S   pshs    A,B,X,Y,U       ;* Save work registers
        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller
        jsr     .111S           ;* Animate for attack against moving player.
        jsr     think           ;* If the warrior can't think this time
        bcc     .121S           ;*   (it only does every other time)
        puls    A,B,X,Y,U       ;*   then restore the work registers and exit.
        ZAPrts
;***
        IF 0 = 0                                                        ;;Fixme was: IFE  0
;***
.121S   tfr     Y,X             ;* X -> this scanner workspace
        ldd     OSCSQI,X        ;* D -> leading squadron member index.
        cmpd    #GROUND         ;* If the list is not grounded at this point
        bne     .122S           ;*   then this is not the squadron leader.
;***
;*      The squadron leader will attack as a miner does a planet.
;***
        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller (player).
        jmp     .142S           ;* Attack!
;***
;*      It has now been determined that this warrior has joined a squadron
;*      but is not the squadron leader.
;***
.122S   lda     #IOrbit         ;* Around the Player, take an attack orbit.
        ldb     WarrOrbit       ;* Use the direction of orbit from the
;*      nop                     ;*   master orbit controller.

        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller (player).
        jsr     getlodist       ;* D = long orbital distance from the target
        ldx     #stblworker     ;* X -> speed table for this orbit.
        jsr     newvel          ;* D = velocity to achieve
        jsr     updlvel         ;* Update the long velocity

        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller (player).
        lda     #IOrbit         ;* Re-establish the attack orbit.
        ldb     WarrOrbit       ;* Use the direction of orbit from the
;*      nop                     ;*   master orbit controller.

        jsr     getsodist       ;* D = short orbital distance from the target
        ldx     #stblworker     ;* X -> speed table for this orbit.
        jsr     newvel          ;* D = velocity to achieve
        jsr     updsvel         ;* Update the short velocity
        jmp     .100S           ;* Attack player
;***
        ELSE    ;0
;***
;       NLIST
.121S   tfr     Y,X             ;* X -> this scanner workspace
        ldd     OSCSQI,X        ;* D -> leading squadron member index.
        cmpd    #GROUND         ;* If the list is grounded,
        lbeq    .130S           ;*   then this is the squadron leader!
;***
;*      It has now been determined that this warrior has joined a squadron
;*      but is not the squadron leader.
;***
        RADIX   10
        ldd     #OSEED2<<8+255  ;* On the average, for 5 warriors on this               ;;Fixme was:    ldd #OSEED2!<8+255.
        RADIX   16
        jsr     rand8r          ;*   tasklist (task16 effectively)
        tsta                    ;*   in 12 seconds
        bne     .122S           ;*   one will try to intercept the player
        ldb     #OMWaIntercept  ;*   by changing its mission
        stb     OSMIS,Y         ;*   for the next time it wakes up!
;*
.122S   clra                    ;* Clear a counter for squadron position.
.123S   ldx     [OSCSQI,X]      ;* X -> scanner workspace of leading craft
        inca                    ;* Count off the squadron position of this craft
        ldu     OSCSQI,X        ;* If the leading craft is not being lead,
        cmpu    #GROUND         ;*   then the leader has been located.
        bne     .123S           ;* Else, chain down the warrior list.
;***
;*      X -> scanner workspace of the leader
;***
        ldb     OSFLANG,X       ;* Get the flight angle from the leader's craft
        stb     OSFLANG,Y       ;*   and save it in case it's shot down.
        ldb     OSPERS,Y        ;* If and when this craft becomes
        andb    #!N(PWAIT)      ;*   the squadron leader, do not wait for
        stb     OSPERS,Y        ;*   distant warriors unless asked to do so.

        cmpa    OSSQSIZ,X       ;* If the squadron doesn't already know
        ble     .124S           ;*   that this craft has joined the group
        sta     OSSQSIZ,X       ;*   then tell them it's here.
.124S   ldb     OSSQSIZ,X       ;* B = squadron_size-1; A = squadron_position-1
        cmpa    #4
        lbgt    .161S           ;* Sorry, no more members.  Try a solo attack.
        cmpb    #4              ;* If the squadron size is less than five
        ble     .12S            ;*   members, fine.
        ldb     #4              ;* Else limit it (damnable elitist warriors).
.12S    decb                    ;* B = offset into formation table for squadron
        deca                    ;* A = the offset into the formation pattern
        sta     OSSQPOS,Y       ;*   which is saved for squadron size checking.
        ldu     #sqloffsets     ;* U -> squadron formation pattern table
        aslb                    ;* U -> the N'th
        leau    B,U             ;*   craft formation pattern index.
        ldu     0,U             ;* Y -> the N'th formation pattern.
        ldb     A,U             ;* Save the
        addb    OSFLANG,X       ;*   actual angle off of the
        pshs    B               ;*   squadron leader which shows flight position
;*
        jsr     Follow          ;* Target the squadron members on the leader.
        jsr     getldist        ;* Make D = the long distance from the leader
        pshs    D
        lda     2,S
        jsr     sincos          ;* A = sin(angle); B = cos(angle)
        sta     2,S             ;* Save the sine for the SHORT computation.
;***
;* The squadron long,short offset is based on the angle and position in the
;*      pack.  Warriors #1 and #2 are some factor away from the leader (#0).
;*      Warriors #3 and #4 are twice that distance factor away from the leader.
;*      This technique is closely tied to the patterns of the formation.
;***
        lda     OSSQPOS,Y       ;* Use the position of this warrior in the
        anda    #%00000010      ;*   to determine what factor multiplier to use
        beq     .125S           ;*   in computing the offset for this warrior
        lda     #OSqFactor      ;*   from the squadron leader.
.125S   adda    #OSqFactor      ;* Multiply the sine times this factor
        jsr     smul8           ;*   and reduced to get
        jsr     asrd4           ;*   a trailing distance to offset the leader.
        addd    ,S++            ;* Add this leader trail offset to target.
        pshs    X               ;* Save the squadron leader's scanner workspace.
        ldx     #stblW0         ;* X -> speed table for warriors
        jsr     newvel          ;* D = velocity to achieve
        jsr     updlvel         ;* Update the long velocity
        puls    X               ;* X -> squadron leader scanner workspace

        jsr     getsdist        ;* Make D = the short distance from the leader
        pshs    D
        ldb     2,S             ;* B = the sine for the SHORT distance calc.
        lda     OSSQPOS,Y       ;* Use the position of this warrior in the
        anda    #%00000010      ;*   to determine what factor multiplier to use
        beq     .126S           ;*   in computing the offset for this warrior
        lda     #OSqFactor      ;*   from the squadron leader.
.126S   adda    #OSqFactor      ;* Multiply the sine times this factor
        jsr     smul8           ;*   and reduced to get
        jsr     asrd4           ;*   a trailing distance to offset the leader.
        addd    ,S++            ;* Add this trail offset to the target distance.
        pshs    X               ;* Save the squadron leader's scanner workspace.
        ldx     #stblW0         ;* X -> speed table for warriors
        jsr     newvel          ;* D = velocity to achieve
        jsr     updsvel         ;* Update the short velocity
        puls    X               ;* X -> squadron leader scanner workspace

        leas    1,S             ;* Clear the stack.
        jsr     UnFollow        ;* Restore the real caller info for this warrior

        jsr     screenchk       ;* If the craft is not on the screen
        bcs     .98S            ;*   then don't bother to fire!
        ldx     [PlaIndex]      ;* X -> player (psuedo) scanner workspace
        jsr     washodds        ;* Fire at the player if the odd allow it
        bcs     .98S            ;*   else, exit.
        jsr     shoot           ;* Shoot at player.
.98S    puls    A,B,X,Y,U       ;* Restore work registers
        rts

;*****
;*
;* SQUACK (127$)
;*
;*      Each warrior that is supposed to be in a squadron has to check its
;*      position relative to the squadron leader.  If it is very far away,
;*      the leader is asked (PWAIT) to let it catch up to the formation when
;*      off screen.  If it has slipped out of formation but is very close,
;*      the leader is asked (PSLOW) not to accelerate away.
;*
;* Needs:
;*      D = the distance of the warrior to the squadron leader
;*      X -> scanner workspace of squadron leader
;*
;* Returns:
;*      OSPERS,X - updated to possibly reflect PWAIT status.
;*      CARRY CLEAR - Warrior well enough in formation.
;*      CARRY  SET  - Warrior in flying too slow!
;*
;*****
.127S   cmpd    #OSQUACK        ;* If this warrior is really far outside the
        bgt     .128S           ;*   squadron, update the personality.
        cmpd    #OSQUAD         ;*
        bgt     .129S
        andcc   #!N(CARRY)      ;* Mark the warrior doing fine.
        rts

.128S   pshs    B               ;* Ask the squadron leader to
        ldb     #PWAIT          ;*   wait up (he comes to a stop off screen).
        orb     OSPERS,X        ;* Mark the request in the squadron leader's
        stb     OSPERS,X        ;*   personality.
        puls    B               ;* Restore work register
.129S   orcc    #CARRY          ;* Mark the warrior in formation too slow.
        rts
;*****
;*
;* LEADATTACK (130$)
;*
;*****
.130S   ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller

        IFDEF   BargraphEnable                                                          ;;Fixme was: IFDEF      DIAGNOSE
        pshs    A               ;* Save work registers
        lda     OSFLANG,Y       ;* A = the Flight angle
        adda    #(CIRCLE/2)     ;* Range A from 0 to +256
        sta     GRAPH+GFLANG    ;* Plot the flight angle
        sta     GRAPH+GANANG    ;* Plot the flight angle
        puls    A               ;* Restore work registers
        ENDIF   ;DIAGNOSE

        jsr     screenchk       ;* If the squadron leader comes on screen
        bcc     .131S           ;*   then skip the off screen updates and checks
;***
;* The FLIGHT ANGLE is only updated off screen so as to keep the squadron aimed
;*              in the same direction while traveling across the screen.  This
;*              is acceptable since the squadron will move quickly relative to
;*              the player and get 'caught' without the intelligence to dodge
;*              a player tracking the squadron. Anyway, it is dangerous for
;*              the player to attempt to do so since the entire squadron
;*              would be firing while 'running away'.
;*              "He who fights and runs away ...."
;*
;* The PERSONALITY traits are checked offscreen to see if the squadron leader
;*              should be waiting for another warrior to join the squadron.
;***
        sta     OSFLANG,Y       ;* Update the formation angle.
        ldb     OSPERS,Y        ;* The squadron leader checks it's personality
        bitb    #PWAIT          ;*   traits to see if it should be waiting for
        beq     .131S           ;*   a remaining warrior to join the formation.
        andb    #!N(PWAIT)      ;* Clear the wait trait.  Warriors will signal
        stb     OSPERS,Y        ;*   again if they're still too far away.
        CLRD                    ;* Wait for the warrior by coasting to a stop.
        ldx     #stblL0         ;* X -> speed table for updlvel
        ldu     OSTBLA,X        ;* U -> acceleration routine for updlvel
        jsr     updlvel         ;* Update the LONG and
        jsr     updsvel         ;*   the SHORT velocities of the craft.
        bra     .98S            ;* No animation is neccessary, since off screen.
;*
.131S   suba    OSFLANG,Y       ;* In order to keep up the velocity while on
        bpl     .132S           ;*   screen, the leader must keep the same
        nega                    ;*   flight angle +/-32 degrees. Any other
.132S   anda    #%11000000      ;*   angle change would result in the loss of
        bne     .100S           ;*   speed as the target falls behind. Animate.
;*
;* * *  lda     #AORBIT         ;* A = the orbit factor for circling the player
        jsr     getldist        ;* Make D = the long distance from the target
        ldx     #stblL0         ;* X -> speed table for squadron leader
;* * *  ldx     #stblguard
        jsr     newvel          ;* D = velocity to achieve, U -> accel. routine
        jsr     updlvel         ;* Update the LONG velocity.
;*
        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller
;* * *  lda     #AORBIT         ;* A = the orbit factor for circling the player.
        jsr     getsdist        ;* Make D = the short distance from the target
        ldx     #stblL0         ;* X -> speed table for squadron leader
;* * *  ldx     #stblguard
        jsr     newvel          ;* D = velocity to achieve, U -> accel. routine
        jsr     updsvel         ;* Update the SHORT velocity.
;*
        LIST
        ENDIF   ;0
;***
.100S   jsr     screenchk       ;* If the craft is not on the screen
        bcs     .139S           ;*   then don't bother to fire!
        ldx     [PlaIndex]      ;* X -> player (psuedo) scanner workspace
        jsr     washodds        ;* Fire at the player if the odds allow it,
        bcs     .139S           ;*   else, exit.
        jsr     shoot           ;* Shoot at player.
.139S   puls    A,B,X,Y,U       ;* Restore work registers
        rts

;       SUBTTL  Warrior Intelligence - Mining Mission
;*****
;*
;* MINE (140$)
;*
;*      Warrior mines planetoids for crystals.  Shots are fired at the
;*      planetoid on a pseudo-random basis with odds of 1 in 2 wake-ups.
;*      Mining occurs only when the warrior has gotten within range.
;*
;*      The animation is handled by the SHOOT routine.  The guns are aimed
;*      toward the planetoid target.
;*
;* Bugs:
;*      Mining distances (based on STBLMINER entries) are hard-coded here.
;*
;* Needs:
;*      Y -> scanner workspace of warrior (this craft)
;*
;* Returns:
;*      Nothing
;*
;*****
.140S   pshs    A,B,X,Y,U       ;* Save work registers

        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller
        lda     OSFLANG,Y       ;* Save the old flight angle
        pshs    A               ;*   for aiming the warrior.
        jsr     updflang        ;* Update the flight angle.
        puls    A               ;* Restore the aiming information.
        jsr     aimwarrior      ;* A = aim angle based on FLANG changes.
        jsr     aniwarrior      ;* Create the animation.
        jsr     think           ;* Continue with the MINING mission
        bcc     .142S           ;*   if cleared to think.
        puls    A,B,X,Y,U       ;* Restore work registers
        ZAPrts

.142S   jsr     getldist        ;* Make D = the long distance from the target
        pshs    D               ;* Save this for the mining check.
        ldx     #stblminer      ;* X -> speed table for warrior miner
        jsr     newvel          ;* D = velocity to achieve
        jsr     updlvel         ;* Update the long velocity

        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller
        jsr     getsdist        ;* Make D = the short distance from the target
        pshs    D               ;* Save this for the mining check.
        ldx     #stblminer      ;* X -> speed table for warrior miner
        jsr     newvel          ;* D = velocity to achieve
        jsr     updsvel         ;* Update the short velocity
;***
;*      The warrior may mine the planetoid only when in range.  This means
;*      that a warrior cruising onto the screen should get close to the
;*      planetoid before begining to shoot.  Here, the mining distance is
;*      assumed <SORRY> to be 3 times the desired trailing distance.
;***
        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller (target).
        ldd     0,S             ;* First, check the long position
        bge     .143S           ;*   to see if the miner is within
        NEGD                    ;*   range of the target
.143S   cmpd    #(MineDist*2)   ;*   for mining.
        bgt     .148S           ;* If not, exit.
        ldd     2,S             ;* Second, check the short position
        bge     .144S           ;*   for the same thing.  When the
        NEGD                    ;*   miner is close enough to mine
.144S   cmpd    #(MineDist*2)   ;*   the target, only then may the shooting
        bgt     .148S           ;*   start (with a random firing pattern) ...
;*
        RADIX   10
        ldd     #OSEED2<<8+1+1  ;* Let A be some random number.                         ;;Fixme was: ldd  #OSEED2!<8+1+1.
        RADIX   16
        jsr     rand8r          ;* Mine the target with odds
        tsta                    ;*   of 1 in 2 (zero or one)
        bne     .148S           ;*   for a random shot pattern.
        lda     OSMIS,Y         ;* If the mission
        cmpa    #OMWaMine       ;*   is not to mine,
        beq     .146S           ;*   then shoot normally.
        leas    4,S             ;* Clear the stack
        jmp     .100S           ;*   and attack.
;*
.146S   jsr     shoot           ;* Else, rapid-fire mining.
.148S   leas    4,S             ;* Clear the stack of the mining distances.
        puls    A,B,X,Y,U       ;* Restore work registers
        rts

;       SUBTTL  Warrior Intelligence - Guarding Mission
;*****
;*
;* TAIL (150$)
;*      This will cause the craft to follow (guard) the target in an orbit.
;*
;*      Animation is performed to show the craft aimed in the direction of
;*      travel.  This animation only occurs when the intelligence "thinks"
;*      and is thus not as up-to-date (in animation) as the other warriors
;*      who animate twice as fast as they "think".
;*
;* Needs:
;*      Y -> warrior scanner workspace
;*
;* Returns:
;*      Nothing
;*
;*****
.150S   jsr     think           ;* Continue with the GUARDING mission
        bcc     .151S           ;*   only if cleared to think.
        rts
.151S   pshs    A,B,X,Y,U       ;* Save work registers
        ldx     [PlaIndex]      ;* X -> scanner workspace of Player (for attack)
        jsr     .111S           ;* Animate for attack on player

        lda     #OOrbit         ;* Around the Sinistar take an "outer" orbit.
        ldb     WarrOrbit       ;*   using the direction of orbit from the
;*      nop                     ;*   personality of the keystone warrior.
        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller (to orbit)
        pshs    A,B,X           ;* Save parameters for the SHORT computations.
        jsr     getlodist       ;* D = long orbital distance from the target
        ldx     #stblguard      ;* X -> speed table for warrior
        jsr     newvel          ;* D = velocity to achieve
        jsr     updlvel         ;* Update the long velocity
;*
        puls    A,B,X           ;* Restore parameters for SHORT computations.
        jsr     getsodist       ;* D = short orbital distance from the target
        ldx     #stblguard      ;* X -> speed table for warrior
        jsr     newvel          ;* D = velocity to achieve
        jsr     updsvel         ;* Update the short velocity
        jmp     .100S           ;* Attack player.

;       SUBTTL  Warrior Intelligence - Intercept Mission
;*****
;*
;* INTERCEPT (160$)
;*
;* Needs:
;*      Y -> warrior scanner workspace
;*
;* Returns:
;*      Registers unchanged
;*
;*****
.160S   pshs    A,B,X,Y,U       ;* Save work registers
        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of target
        jsr     .111S           ;* Animate for attacking moving player.
        jsr     think           ;* Continue with the GUARDING mission
        bcc     .161S           ;*   only if cleared to think.
.169S   puls    A,B,X,Y,U       ;* Restore work registers
        rts

.161S   jsr     getldist        ;* D = long distance from the target
        ldx     #stblW1         ;* X -> speed table for warrior
        jsr     newvel          ;* D = velocity to achieve
        jsr     updlvel         ;* Update the long velocity

        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of caller
        jsr     getsdist        ;* D = short distance from the target
        ldx     #stblW1         ;* X -> speed table for warrior
        jsr     newvel          ;* D = velocity to achieve
        jsr     updsvel         ;* Update the short velocity

        tst     AMDemo          ;* In attract mode, don't shoot,
        bne     .169S           ;*   crystals are being picked up.

        ldx     [OSCWCR,Y]      ;* X -> scanner workspace of target
        jmp     .100S           ;*   then it must be the player.  Attack!

;       SUBTTL  Pseudo Warrior Intelligence - Demo Bombing Mission
;*****
;*
;* BOMBING RUN (170$)
;*
;* Needs:
;*      Y -> psuedo warrior scanner workspace
;*
;* Returns:
;*      Registers unchanged
;*
;*****
.170S   pshs    A,B,X,Y,U       ;* Save work registers
        jsr     think           ;* Continue with the GUARDING mission
        bcs     .179S           ;*   only if cleared to think.
;* *    ldx     [PlaIndex]      ;* X -> scanner workspace of Player (for attack)
;* *    tst     AMDemo          ;* If not in attract mode,
;* *    beq     171$            ;*   then the caller is correct.
;***
;*      In attract mode, the player pretends to be this warrior and attacks
;*      the Sinistar as his psuedo caller.
;***
        ldx     [SinIndex]      ;* X -> scanner workspace of Sinistar to attack.
        jsr     ReTarget
        jsr     .111S           ;* Animate for attack on player

        lda     #IOrbit         ;* Around the Sinistar take an "outer" orbit.
        ldb     WarrOrbit       ;*   using the direction of orbit from the
;*      nop                     ;*   personality of the keystone warrior.
        tfr     Y,X             ;* Determine caller of warrior or pseudo-warrior
        jsr     LdyWCR          ;*   (as in attract demo) so that
        exg     X,Y             ;* X -> SW of caller and Y -> SW of callee.
;*
        pshs    A,B,X           ;* Save parameters for the SHORT computations.
        jsr     getlodist       ;* D = long orbital distance from the target
        ldx     #stblbomber     ;* X -> speed table for psuedo warrior
        jsr     newvel          ;* D = velocity to achieve
        jsr     updlvel         ;* Update the long velocity
;*
        puls    A,B,X           ;* Restore parameters for SHORT computations.
        jsr     getsodist       ;* D = short orbital distance from the target
        ldx     #stblbomber     ;* X -> speed table for psuedo warrior
        jsr     newvel          ;* D = velocity to achieve
        jsr     updsvel         ;* Update the short velocity
;*
;* *    tst     AMDemo          ;* If not in attract mode,
;* *    lbeq    100$            ;*   normal shooting attack occurs.
        ldx     [SinIndex]      ;* X -> scanner workspace of Sinistar to attack.
        jsr     UnTarget
;***
;*      In the attract mode demonstration release a bomb every couple seconds.
;***
        RANDOM  OSEED2,8,$FF    ;* Clear the carry bit only once in a while,
        bcs     .179S           ;*   for the most part not being able to bomb.
        lda     Bombs           ;* If there are no bombs available to launch
        beq     .179S           ;*   when the time is right, then just exit.
        jsr     screenchk       ;* If the sinistar is not on screen                     ;;This gets patched over by MICA/BOBFIXES.SRC ($682B)
        bcs     .179S           ;*   then the player should not waste bombs.
        jsr     BombsAway       ;* Otherwise, release a bomb.
.179S   puls    A,B,X,Y,U       ;* Restore work registers
        rts

        PULLORG ROMSAVE

        INCLUDE "../WITT/AIMWARR.ASM"           ;* Aiming to track moving target
        INCLUDE "../WITT/ANIWARR.ASM"           ;* Animation
;;      INCLVER RICH,distance           ;* Distance computations
        INCLUDE "../WITT/FOLLOW.ASM"            ;* Squadron leader targeting
        INCLUDE "../WITT/SCREENCH.ASM"          ;* On/Off screen check
        INCLUDE "../WITT/SHOOT.ASM"             ;* Warrior shooting routine
;;      INCLVER RICH,tables             ;* Distance/Velocity tables
        INCLUDE "../WITT/THINK.ASM"             ;* Animate/Intelligence check
;;      INCLVER RICH,upddtc             ;* Update Distance to Caller
;;      INCLVER RICH,updflang           ;* Update Flight Angle
;;      INCLVER RICH,velocity           ;* Velocity computations
        INCLUDE "../WITT/WARRON.ASM"            ;* On Screen routine
        INCLUDE "../WITT/WARROFF.ASM"           ;* Warrior off screen routine
        INCLUDE "../WITT/WASHODDS.ASM"          ;* Shooting odds computations
;;===============================================================================
;;
;;   There are three separate files that contain two different versions of the
;;   Warrior Shooting Odds Routine.  Rich initally wrote a slightly longer
;;   version of the routine (WITT/WASHODDS.SRC), which Sam copied and rewrote.
;;   Sam's optimized version can be found in SAM/WASHODDS.SRC.
;;
;;   Rich then copied Sam's refined code and pasted it into a new file named,
;;   "ZWASHODD.SRC" that checks first if the game's version is 17, then proceeds
;;   to patch over the old code with Sam's newer routine.  Because of this
;;   there are 6 garbage bytes Located at $6A6B-$6A70 that are the remains of
;;   the old routine.
;;
;;   Interestingly, the AMOA '82 build and the final version of the game (V17)
;;   both use Sam's WASHODDS so Witt's complete routine only exists in the
;;   source code.
;;
;;   At first, I wasn't sure how ZWASHODD was patched into the ROM.  I eventually
;;   found the answer in WITT/AOE.ASM, where an INCLVER for RICH.SRC is located.
;;   The only valid INCLVER in the file is for ZWASHODD; mystery solved.
;;
;;   Even though it's a patch, including it in RICH.SRC kinda makes things confusing
;;   so I'm including it here instead:
;;
        INCLUDE "../WITT/ZWASHODD.ASM"          ;* Shooting odds computations
;;
;;   Changing WASHODDS to the older version does not appear to reduce the
;;   frequency of the warriors shooting at the player.
;;
;;===============================================================================
;;      INCLVER RICH,zaprts             ;* Copyright check test.