

        PUSHORG ROMSAVE

;******************************************************************************
;* AttModeSinistar Task
;*
;*   This task runs concurrently with Rich's Watchdog task.  Rich's Watchdog
;*     does nothing but wait for a certain amount of time, at which point it
;*     kills the Attract Demo.  Therefore, this task may wait with impugnity
;*     for events that might never happen (for example:  the player might never
;*     get the Sinistar onscreen long enough to launch off all bombs, while this
;*     task waits for this event), since the Watchdog task will shut down the
;*     Attract Demo sooner or later anyway.
;*
;*   This task does:
;*      Phase 1:
;*        Gives the player a certain amount of time to collect
;*        Sinibombs.  If enough bombs are collected, Phase 2 is
;*        started.  If not enough bombs are collected but Phase 1
;*        times out, Phase 2 is entered anyway.
;*      Phase 2 Setup:
;*        The player's mission is changed to OMWaBomb.  If the
;*        Sinistar is offsector, it is moved to sector's edge.
;*        The counter value is initialized to control the launching
;*        of crystal-laden workers.  The task is changed to list TASK8.
;*      Phase 2:
;*        Every 8th screen a crystal-laden worker is launched.  If the
;*        Sinibomb count drops to zero, Phase 3 is entered.  After the
;*        maximum number of workers have been launched, Phase 2 loops
;*        until there are no Sinimbombs.
;*      Phase 3:
;*        Sleep for 3 seconds, and then jump to Death

        ROUTINE AMSINI

;* Phase 1:
        LDD     OMTLEN,Y        ;Countdown
        SUBD    #1
        BEQ     .AM100S         ;When we've counted down start Phase 2
        STD     OMTLEN,Y        ;  else save countdown

        LDA     BOMBS           ;Have we collected enough Sinibombs yet?
        CMPA    #4                                                              ;;Patched over in BOBFIXES.ASM ($8C99) "8 Sinibombs to initiate Phase 2"
        BGE     .AM100S         ;If so then start Phase 2

        SLEEP   LOOP


;* Phase 2 Setup:
;* Here, we force the player's mission to Bomb the Sinistar!
.AM100S LDX     [PLAINDEX]      ;Player's workspace                             ;;Fixme was: 100$  LDX  [PLAINDEX]
        LDA     #OMWABOMB       ;Bomb mission
        STA     OSMIS,X
        LDD     SININDEX        ;Pointer to Sinistar's workspace
        STD     OSCWCR,X        ;This is the player's tail target
        LDA     #$FF            ;Force feed
        STA     OCALPRI,X       ;  the priority of this task

;* If the Sinistar isn't in sector, push it there
        TST     SINISECTOR      ;Is Sini onsector?
        BEQ     .105S           ;Branch if so
        CLRD                    ; else force to the edge
        STD     SSLPOS
        STD     SSSPOS

        RADIX   10                                                              ;;(decimal values ahead)

;* Set up to launch 16 workers
.105S   LDA     #16                                                             ;;Fixme was: LDA  #16. (This gets patched over in BOBFIXES.ASM but it's already the correct value!) ($8CBF)
        STA     OMTLEN,Y

;* Change the sleep to TASK8
        CHANGE_SLEEP    TASK8,HERE

;* Phase 2:
;* If the player has no Sinibombs, enter Phase 3
        TST     BOMBS                                                           ;;Patched over in BOBFIXES ($8CC8) "causes ZZAMSINI to constantly force-feed the bomb mission on the player"
        BEQ     .AM200S

;* Get the launch counter and launch a worker if another is wanted
        LDA     OMTLEN,Y        ;Is there another to do?
        BEQ     .110S           ;Branch to sleep if not

        DEC     OMTLEN,Y        ;Else bump the counter down
        ANDA    #3              ;Make A into an index to the start-pos table
        LDU     #AMSWTB         ;Get address of offset table
        LDD     B,U             ;Get next packed offset                         ;;Patched over in BOBFIXES ($8CD8) "FIX ZZAMSINI  --  Change LDD B,U to LDD A,U"
        JSR     IRWOCR          ;Create a crystallized worker there

.110S   SLEEP   LOOP            ;  and go back to sleep


;* Phase 3:
.AM200S LDD     #(3*60)/8       ;Sleep for approximately 3 seconds              ;;Fixmw was: 200$  LDD  #(3.*60.)/8  (Patched over in BOBFIXES ($8CE3), looks like time increased to 4 seconds)
        JSR     TIMER
        JMP     DEATH           ;  then go kill the attract demo


AMSWTB  FCB     $5F,$5F,$9F,$9F,$5F     ;Table of screen location pairs

        RADIX   16                                                              ;;(going back to hex)

        PULLORG ROMSAVE