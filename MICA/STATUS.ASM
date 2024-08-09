;       INCLUDE [SAM]START

;       INCLVER RICH,SPEAK


        PUSHORG ROMSAVE

        VECTOR  PLAVECT         ;On player initialization
        CLR     PLUWPF          ;Clear the player up warp flag
        RTS


;*******************************************************************************
;*
;* STATUS PAGE
;*   DISPLAYED AT START OF PLAYER TURN

        ROUTINE STATPG
        TST     AMDEMO          ;Test the mysterious AMDEMO flag
        BNE     .200S           ;  and exit immediately if non-zero

        BSR     .201S           ;  with the Status Page call
;* 201$ returns with D set to the appropriate TIMER value
        PULS    Y

        JSR     TIMER           ;Replace STATPG wiped out TIMER call
        TST     PLUWPF          ;Did the player kill Baldy after dying?
        BEQ     .255S           ;If zero, then nope
        NEW_SLEEP       TASK1,.10S,OTIMER+2     ;else yes, so make messages
        CLR     PLUWPF                          ;and turn flag off
        JSR     RSTPOP                          ;and reset the population

.255S   PSHS    Y

.200S   JMP     STATPG+3

        RADIX   10                                                              ;;(decimal values ahead)

;* This queues up the zone message task
.10S    NEW_SLEEP       TASK4,ZNMTSK    ;This is the zone message task
        LDX     OINDEX,X        ;Save Display Task Index
        STX     OTIMER,Y
        LDD     #(60*2)         ;Sleep 2 seconds                                ;;Fixme was: LDD  #(60.*2)
        JSR     TIMER
        LDX     [OTIMER,Y]      ;Get display task workspace into X
        LDD     #DIE            ;  and force it to
        STD     OEXEC,X         ;  commit suicide
        JSR     PCLRSCR         ;Clear screen
        JMP     DIE             ;Die


;* This is the main status page subroutine
.201S   PSHS    X,Y,U

        TUNE    QPLSTR          ;Play the player start song
        SPEAK   10              ;Silence the Sinifart!                          ;;Fixme was: SPEAK  10.

        JSR     INISINI         ;Go initialize the Sinistar

        LDA     NPLAYER         ;Test if two-player
        DECA                    ;  and
        BNE     .STAT1S         ;  branch if so
        JSR     PCLRSCR         ;  else clear the screen

.STAT1S JSR     FRAME           ;Draw the current frame

        TST     PLUWPF          ;If player should have warped
        BEQ     STAT5S          ;  but was dead instead then take branch        ;;(local label 5$ is now global to make PHRASE macro work again)

        RADIX   16                                                              ;;(back to hex)

        TEXT    $50,$4E         ;Write CONGRATS
        PHRASE  WHITE,68,CONGRATULATIONS
        TEXT    $42,$2B
        PHRASE  WHITE,68,YOU,DEFEATED,THE,SINISTAR
        JMP     STAT25S         ;Jump over bombs/pieces text                    ;;(local label 25$ is now global to make PHRASE macro work again)

STAT5S  TEXT    $58,$53
        PHRASE  BLUE,35,YOU,HAVE

        PSHS    D
        LDA     BOMBS           ;Go write the number of bombs to the screen
        JSR     FAOBCD          ;  in RED
        PULS    D

        LEAX    4,X             ;Advance cursor 4 pixels

        WORD    BLUE,35,SINIBOMBS

        TEXT    $52,$52
        PHRASE  BLUE,35,SINISTAR,HAS

        PSHS    D

        LDD     PIECEPT         ;Get SINISTAR recent-piece pointer and subtract
        SUBD    #PIECETB        ;  the end-of-table pointer, yielding a
        ASRA                    ;  displacement which, when divided by 4 for
        RORB                    ;  the 4 bytes of each table entry, gives the
        ASRA                    ;  number of Sinipieces.  If FINISH is set
        RORB                    ;  equal to ALIVE then the SS is alive and the
        PSHS    B               ;  piece count must be incremented by one to
        LDD     FINISH          ;  account for the skull
        CMPD    #ALIVE
        BNE     .15S
        INC     ,S
.15S    LDA     ,S              ;Fetch the piece count for output in RED
        JSR     FAOBCD

        LDD     1,S             ;Restore D

        LEAX    4,X             ;Advance cursor 4 pixels

        WORD    BLUE,35,PIECES

        PULS    A               ;Restore Sinipiece-count, and if less than
        CMPA    BOMBS           ;  or equal to number of Sbombs then skip
        BLE     STAT20S         ;  MINE CRYSTALS message                        ;;(local label 20$ is now global to make PHRASE macro work again)

        TEXT    $48,$3C         ;  else remind the dummy of his/her primary task
        PHRASE  RED,35,MINE,CRYSTALS,TO,MAKE,SINIBOMBS

STAT20S LEAS    2,S             ;Restore the stack from previous PSHS D

STAT25S JSR     STTDRS          ;Draw the Sinistar image

        LDA     SINIKILLS       ;Test for player Sinikills                      ;;Fixme was: LDA  SINIKIL
        BEQ     STAT30S         ;  and if none then skip extra message

        TEXT    $20,$44         ;  else let him/her know the score
        PHRASE  SILVER,35,YOU,HAVE,SMASHED

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers
        FDB     _HAVE
        FDB     _HAS
        FDB     _PIECES
        FDB     _SMASHED

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        LDA     SINIKILLS       ;Write the number of kills                      ;;Fixme was: LDA  SINIKIL
        JSR     FAOBCD

        LEAX    4,X             ;  and put another word
        LDB     #SILVER         ;  with the color silver
        WORD    SILVER,35,SINISTAR

        LDA     SINIKILLS       ;  and if #kills = 1 then branch out            ;;Fixme was: LDA  SINIKIL
        DECA
        BEQ     STAT30S                                                         ;;(local label 30$ is now global to make PHRASE macro work again)

        LEAX    -4,X            ;  else write an S for proper grammar
        WORD    SILVER,35,S

STAT30S LDA     SINIKILLS       ;Get kill count                                 ;;Fixme was: LDA  SINIKILL
        BEQ     .31S            ;If none then nozone
        ANDA    #3              ;Strip to zone
        PSHS    A               ;Save for second use
        LDX     #$1B51          ;Text location
        LDU     #ZNOTBL         ;Address of offset table
        LDB     A,U             ;Get offset for this text
        LEAX    B,X             ;  and adjust screen location with it
        LDD     #(P_ENTERING*$100)+SILVER                                       ;;Fixme was: LDD  #(.ENTER*$100)+SILVER
        TST     PLUWPF
        BNE     .35S
        LEAX    3,X
        LDA     #P_NOW                                                          ;;Fixme was: LDA  #.NOW
        JSR     OUTP35
        LDA     #P_IN                                                           ;;Fixme was: LDA  #.IN
.35S    JSR     OUTP35

        PULS    A               ;Restore zone value
        LDU     #ZNTTBL         ;Get word values table
        LDA     A,U             ;Get word value
        LDB     #RED            ;Get color for this word
        JSR     OUTP35          ;Go print it
        LDD     #(P_ZONE*$100)+SILVER   ;Set up for word ZONE in color SILVER   ;;Fixme was: LDD  #(.ZONE*$100)+SILVER
        JSR     OUTP35          ;Go print it

.31S    TST     PLUWPF          ;Should player have warped?
        BNE     .80S            ;If so, then do special function

        LDD     FINISH          ;Now test if the Sinistar is alive
        CMPD    #ALIVE          ;  and skip the SPEAK call if not
        BNE     .83S

        RADIX   10                                                              ;;(decimal values ahead)

;* Say "Beware, I Live"
        SPEAK   11                                                              ;;Fixme was: SPEAK  11.

;* Now, create a task to animate the Sinistar while he speaks
        NEW_SLEEP       TASK1,STTSPK,OMTLEN+1
        LDA     #60*3           ;Set up to animate for 3 seconds                ;;Fixme was: LDA  #60.*3
        STA     OMTLEN,X

        LDD     #60*4           ;Set up to run TIMER for 4 seconds              ;;Fixme was: LDD  #60.*4
        BRA     .86S

.80S    LDD     #(60*4)                                                         ;;Fixme was: LDD  #(60.*4)
        BRA     .89S

.83S    LDD     #60*3           ;Set up to run TIMER for 3 secondS              ;;Fixme was: LDD  #60.*3

.86S    PSHS    D
        NEW_SLEEP       TASK1,STTBCL,OMTLEN+2
        PULS    D
        STD     OMTLEN,X


.89S    PULS    X,Y,U,PC        ;Now it's time to say goodbye


ZNOTBL  FCB     10,6,4,0                                ;Offsets for zone text  ;;Fixme was: ZNOTBL  FCB  10.,6,4,0
ZNTTBL  FCB     P_VOID,P_WORKER,P_WARRIOR,P_PLANETOIDS  ;Word values for zone   ;;Fixme was: ZNTTBL  FCB  .VOID,.WORKER,.WARRIOR,.PLANETOID (maybe there's room in PHRSAV for "Planetoid"?)


;******************************************************************************
;* FAOBAD
;*  fix and output BCD in color red
;*  returns through OUTB35

FAOBCD  JSR     HEXBCD          ;Translate register A from HEX to BCD
        BITA    #$F0
        BNE     .1S
        ORA     #$F0
.1S     LDB     #RED            ;Get color RED for output
        JMP     OUTB35          ;Go write the digit(s)



;******************************************************************************
;* STTSPK
;*  Task to animate the Sinistar while he speaks
;*  Expects pointer to task workspace in Y

STTSPK  DEC     OMTLEN,Y        ;Count down
        LBEQ    DIE             ;  and go die when done

        JSR     STTDRS          ;Else, draw the Sinistar image one more time
        SLEEP   LOOP            ;  and then back to sleepy-by



;******************************************************************************
;* STTDRS
;*   Draw the Sinistar image

STTDRS  PSHS    D

        LDA     #SINIHIG        ;Sinistar Height & Width                        ;;Fixme was: LDA  #SINIHI
        LDB     #SINIWID                                                        ;;Fixme was: LDB  #SINIWI
        EORA    #$4
        EORB    #$4
        STD     DHIGH

        LDD     #$2A66          ;Screen location
        STD     DDEST

        LDD     #SINIMAG        ;Image Address
        STD     DSOUR

        LDA     #$0E            ;DO RAM to RAM draw
        STA     DCTRL

        PULS    D,PC            ;Return



;******************************************************************************
;* STTBCL
;*   Status Page Background Color Task
;*   If Sinistar is not built yet, turn screen blue
;*      else turn screen RED

STTBCL  LDD     OMTLEN,Y        ;Count down task and split when done
        SUBD    #1
        STD     OMTLEN,Y
        LBEQ    DIE

        LDA     #$40            ;Get background color of blue
        LDU     FINISH          ;Test if Sinistar is alive yet
        CMPU    #ALIVE          ;If FINISH and ALIVE are not equal
        BNE     .1S             ;  then SS is not built so use BLUE
        LDA     #$02            ;  else SS LIVES!  Use scary RED
.1S     STA     PCRAM
        SLEEP   LOOP



;* That's all, folks!
        PULLORG ROMSAVE