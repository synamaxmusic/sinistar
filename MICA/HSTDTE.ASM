;;===============================================================================
; EQUs to remove later
;CLRHSLE        EQU     $8BF4
;;===============================================================================

;       INCLUDE [SAM]START

;       INCLVER SAM,SINISTAR.EQU


        PUSHORG ROMSAVE


        ROUTINE HSTDENT
;*******************************************************************************
;* HSTDENT
;*   High Score To Date Entry routine
;*   Clears the system and takes complete control

        JSR     CLRHSLE         ;Clear High Score Last Entered pointers

        LDX     #PSCORE         ;Get address of current player's score
        LDY     #PSCORE-PLURAM+PLNURAM  ;Get addr of other player's score
        LDA     SCOREAD         ;Get current player value
        BPL     .HSTD2S         ;  and branch if PSCORE has player 1's score    ;;Fixme was: BPL  2$
        EXG     X,Y             ;  else swap registers so Y points to p.1 score
.HSTD2S PSHS    X,Y             ;Protect them through the tempest
        JSR     SYSTINI         ;Boom
        NEW_SLEEP       TASK1,HSTDMS,OHSMMR     ;Start up the master task
        PULS    Y,U             ;Restore Score pointers
        STY     OHSMP1,X        ;Save player one pointer
        STU     OHSMP2,X        ;  and Player two
        LDA     NPLAYER
        STA     OHSMNP,X
        CLR     NPLAYER
        JMP     STARTS          ;Go start up the task system

;*
;* High Score To Date Master Task
;*   This one runs until the others are die, and then restarts the system
;*
        RADIX   10                                                              ;;(decimal value ahead)
HSTDMS  LDD     #(60*1)                                                         ;;Fixme was: LDD  #(60.*1)
        RADIX   16                                                                      ;;(back to hex)
        JSR     TIMER

        LDX     #ALHSTD         ;Test if operator allows HSTD entry
        JSR     RCMOSA          ;  and if not
        BEQ     .10S            ;  then branch to exit timer

        TFR     Y,U

        LDA     #$13            ;Initialize for Player ONE
        STA     SCOREAD
        LDY     OHSMP1,U
        JSR     HSTEST          ;Go test/install player 1 score
        STA     OHSMFLG,U

        TFR     U,Y             ;Restore workspace pointer
        SLEEP   HERE
        TST     HSTDFLG
        BNE     .3S
        SLEEP   LOOP

.3S     TFR     Y,U
        LDA     OHSMNP,U        ;Test if this was a one or two player game
        DECA                    ;  and
        BEQ     .1S             ;  if one player then skip to page-display

        LDA     #7
        STA     PCRAM
        LDA     #$B4            ;Initialize for Player Two
        STA     SCOREAD
        LDY     OHSMP2,U
        JSR     HSTEST          ;Go test/install player 2 score
        ORA     OHSMFLG,U
        STA     OHSMFLG,U

        TFR     U,Y
        SLEEP   HERE
        TST     HSTDFLG
        BNE     .1S
        SLEEP   LOOP

.1S     TST     OHSMFLG,Y       ;Was the flag ever set?
        BNE     .2S             ;If so, then we've made High Score entry, skip

        RADIX   10                                                                      ;;(decimal value ahead)
.10S    LDD     #(60*4)         ;Sleep for 4 seconds to display GAME OVER               ;;Fixme was: LDD  #(60.*4)
        RADIX   16                                                                      ;;(back to hex)
        JSR     TIMER

.2S     JMP     IAMODE          ;Restart system


;*
;* Test For High Score to Date
;*   If a High Score is found, creates a task to get the initials and make
;*   the entry into the appropriate table
;*   On entry, Y points to the player's score
;*
;*   On exit, A is zero and HSTDFLG is non-zero if not high-score,
;*   opposite if high-score
;*

HSTEST  PSHS    B,X,Y,U

        CLR     HSTDFLG         ;Clear the HSTD Flag

        LDX     #CMOSLSC        ;Pointer to CMOS Lowest Score
        JSR     CMPSCR          ;Go see if this one is greater than CMOS lowest
        BCS     .1S             ;  and branch install if it is

        LDX     #RAMLSC         ;  else test this one with RAM lowest score
        JSR     CMPSCR          ;  and
        BCS     .1S             ;  branch install if it is

        CLRA                    ;  else return a sliver of sleep time
        COM     HSTDFLG
        PULS    B,X,Y,U,PC      ;  and return without High Score installation

;*
;* OK, this is a high score
;*   Set up to get player's initials
;*   On entry, Y points to player's score
;*            X points to low entry of table where score is to be installed

.1S     PSHS    X,Y             ;Save our pointers

        JSR     PCLRSCR         ;Clear the bottom of the screen
        JSR     ANPLAY          ;  and announce the current player

        TEXT    $4F,$4F
        PHRASE  BLUE,68,CONGRATULATIONS
        TEXT    $50,$4E
        PHRASE  YELLOW,68,CONGRATULATIONS
        TEXT    $48,$49
        PHRASE  WHITE,68,YOUR,SCORE,RANKS
        TEXT    $40,$49
        PHRASE  WHITE,68,AMONG,THE,TOP,30
        TEXT    $38,$53
        PHRASE  CREAM,68,GIVE,3,INITIALS
        JSR     JFTEXT          ;Joystick/Fire Buttons Message subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers

        FDB     _YOUR
;       FDB     _SCORE
        FDB     _RANKS
        FDB     _AMONG
;       FDB     _THE
        FDB     _TOP
        FDB     _30

        FDB     _GIVE
        FDB     _3
        FDB     _INITIALS

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        NEW_SLEEP       TASK2,CENTRY,OHSTDMR  ;Make the task to get the entry
        PULS    Y,U             ;Restore our pointers

        STY     OHSTPTR,X       ;Table pointer
        STU     OHSPSCR,X       ;Player's score

        LDA     #3              ;Size of this entry request (3 initials)
        STA     OHSESZ,X
        LDD     #HSTDINS        ;Post-Processing address
        STD     OHSPPR,X
        LDD     #$1E77          ;Screen Base address
        STD     OHSBADR,X
        LDA     #CBLANK+1       ;Initialize current letter
        STA     OHSCLT,X
        LDD     #MAXETV         ;Maximum time to enter initials
        STD     OHSETM,X
        COMA                    ;Mark A register to designate task queued
        PULS    B,X,Y,U,PC      ;  and return it to calling routine


;* The CENTRY task returns here for post-processing
;* Install this very entry
HSTDINS LDX     OHSTPTR,U       ;Get pointer to correct table
        CMPX    #CMOSLSC        ;Is this table CMOS?
        BNE     .5S             ;Nope, so go do RAM only

        JSR     HSTDTL          ;Yes, CMOS.  Get table pointer into Y

        LDX     HSLEN1          ;Is first CMOS entry used?
        BNE     .1S             ;Yes, so branch to special test
        STY     HSLEN1          ;  else No, so make this one the first entry
        BRA     .2S             ;  and skip to RAM test

.1S     STY     HSLEN2          ;Save this as second entry
        CMPY    HSLEN1          ;Is this one below (higher) in table?
        BHI     .2S             ;If not above (lower) or same, skip
        LEAX    SCRSIZ,X        ;  else bump other one
        STX     HSLEN1          ;  down one entry

.2S     JSR     HSTDDT          ;Go move this entry in

        LDX     #RAMLSC         ;Now install into RAM table

.5S     JSR     HSTDTL          ;Go get pointer into RAM table

        LDX     HSRLN1          ;Is first RAM entry already dirty?
        BNE     .3S             ;Yes, so branch to do extra stuff
        STY     HSRLN1          ;  else No, so
        BRA     .4S             ;  store pointer here and split

.3S     STY     HSRLN2          ;Save this pointer
        CMPY    HSRLN1          ;See above for below (higher)/above (lower)
        BHI     .4S             ;  decsription of what's being done here
        LEAX    SCRSIZ,X
        STX     HSRLN1

.4S     JSR     HSTDDT          ;Go install this entry into RAM

        COM     HSTDFLG         ;Flip flag to designate task done
        TFR     U,Y             ;Restore Y register and
        JMP     DIE             ;  go die




;******************************************************************************
;* CMPSCR
;*   Compares player score at Y with CMOS/RAM score at X,
;*   returns with carry set if Y-score >= X-score

CMPSCR  PSHS    D,X,Y

        LDB     #4

.1S     JSR     RCMOSA
        CMPA    ,Y+
        BLO     .2S
        BHI     .3S
        DECB
        BNE     .1S

.2S     ORCC    #1
        PULS    D,X,Y,PC

.3S     ANDCC   #$FE
        PULS    D,X,Y,PC

;******************************************************************************
;* BLKMOV
;*   MOVE A BYTES FROM [X] TO [Y]
;*   All registers are restored on exit

BLKMOV  PSHS    D,X,Y

.1S     LDB     ,X+
        STB     ,Y+
        DECA
        BNE     .1S

        PULS    D,X,Y,PC


;******************************************************************************
;* HSTDTL
;*   High Score To Date Table Lookup
HSTDTL  PSHS    X

        LDY     OHSPSCR,U

        LDA     #HSENTCT        ;Get number of entries per table
        PSHS    A

.100S   DEC     ,S              ;Decrement entry count
        BEQ     .101S           ;  and if 0, then this score is the table-topper

        LEAX    -SCRSIZ,X       ;Get next higher entry in table
        JSR     CMPSCR          ;Test this score against player's
        BCS     .100S           ;Loop while player score is >= score at X
        LEAX    SCRSIZ,X

.101S   PSHS    X
        LDX     3,S             ;Restore table bottom pointer
        TFR     X,Y             ;Get copy of it in Y
        LDA     #SCRSIZ         ;Get entry size

.102S   LEAX    -SCRSIZ,X       ;Bump X up [down] table
        CMPX    ,S
        BLO     .103S
        JSR     BLKMOV          ;  else move this block from X to Y
        LEAY    -SCRSIZ,Y       ;  and bump up [down] Y too
        BRA     .102S           ;  and do it again

.103S   LEAS    5,S
        RTS


;******************************************************************************
;* HSTDDT
HSTDDT  TFR     Y,X
        LDY     OHSPSCR,U       ;Restore pointer to player's score

        LDB     #4              ;CMOS-move 4 bytes

.104S   LDA     ,Y+             ;Go
        JSR     WCMOSA          ;  do
        DECB                    ;  it
        BNE     .104S           ;  to it

        JSR     CENINS

        RTS



        ROUTINE OPENT
;******************************************************************************
;* OPENT
;*   This routine gets the Operator Message and saves it to CMOS
;*

        LDD     ,S              ;Get return address
        STD     OPENRTN         ;  and save for later

        CLR     PANMASK         ;Turn off all switch-control

        JSR     SYSTINI         ;Wipe clean thy slate, oh master
        NEW_SLEEP       TASK2,OPENMS,OHSTDMR    ;Start up the master task
        JMP     STARTS          ;Start up the system

;*
;* This is a pseudo-entry point for the CENTRY task ... whereas the HSTD Entry
;*   queues CENTRY directly, operator entry does the pre-processing
;*   within head of the task itself.  Once the CENTRY variables are set,
;*   a jump into the CENTRY routine is taken

OPENMS  CLR     $CA01           ;Clear the DMA constant
        JSR     CLRSCR          ;Clear the screen

        TEXT    $50,$36
        PHRASE  WHITE,68,OPERATOR,MESSAGE,ENTRY
        JSR     JFTEXT          ;Joystick/fire text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers

        FDB     _OPERATOR
        FDB     _MESSAGE
        FDB     _ENTRY

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        LDA     #CBLANK         ;Save a blank for this current letter
        LDB     #OPENLEN*2
        LDX     #CMOSOPE
.1S     JSR     WCMOSA
        DECB
        BNE     .1S

        STA     OHSCLT,Y
        LDA     #OPENLEN        ;Operator message entry length
        STA     OHSESZ,Y
        LDD     #OPENINS        ;Post-processing address after input is complete
        STD     OHSPPR,Y
        LDD     #OPENMTM        ;Maximum time for Operator message entry
        STD     OHSETM,Y

        LDD     #$3818          ;Force second screen base address
        STD     OHSBADR,Y       ;  into task workspace
        JSR     ALLCURS         ;  and then go draw the second line of cursors

        LDD     #$4018          ;Set up the first screen base address
        STD     OHSBADR,Y

        JMP     CENTRY          ;Go continue with the Character Entry task


;* OPENINS
;*   The CENTRY routine returns here for post-processing of the Operator Message
;*   first line

OPENINS LDX     #CMOSOPE        ;Get address for first line of operator message

        JSR     CENINS          ;Go install the operator input into CMOS

        LDD     #OPENI2         ;Get the post-processing address for the second
        STD     OHSPPR,Y        ;  line of operator message entry
        LDD     #$3818          ;Get the secpond screen base address
        STD     OHSBADR,Y
        JMP     CENTRY          ;Go continue the task

;*  The CENTRY task returns here for post-processing of the Operator's second
;*    line of text

OPENI2  LDX     #CMOSO2         ;Get CMOS address for second line of operator
        JSR     CENINS          ;  text.  Go install this input

        JSR     SYSTINI         ;Bomb out the system
        LDS     #HSTK           ;Restore the stack pointer
        JMP     [OPENRTN]       ;  and go back from whence we came


;******************************************************************************
;* CENINS
;*   Character Entry Install subroutine
;*   Installs OHSESZ characters starting at OHSINIT into the CMOS locations
;*   pointed to by X
;* ENTRY:
;*      X has address in CMOS for move
;*      U has task workspace address

CENINS  PSHS    D,Y

        LEAY    OHSINIT,U       ;Get literal address of characters

        LDB     OHSESZ,U        ;Get character count

.10S    LDA     ,Y+             ;Get next character
        JSR     WCMOSA          ;Write it to CMOS
        DECB                    ;Countdown
        BNE     .10S            ;  and loop until done

        PULS    D,Y,PC


;******************************************************************************
;* WRCURS
;*   Write cursor of color B at the current offset
;*

WRCURS  PSHS    D,X

        JSR     MAKSCX
        LEAX    -$200,X         ;Adjust for cursor being below letters
        LDA     #CCURS
        JSR     OUTCHR

        PULS    D,X,PC

;******************************************************************************
;* WRCLT
;*   Write the current letter at the current offset

WRCLT   PSHS    D,X,Y,U

        JSR     MAKSCX
        LDA     OHSCLT,U
        LDB     #YELLOW
        JSR     OUTCHR

        PULS    D,X,Y,U,PC

;******************************************************************************
;* ERCLT
;*   Erases the letter at the current offset

ERCLT   PSHS    D,X

        JSR     MAKSCX
        STX     DDEST
        LDX     #$0608!$404                                                             ;;Fixme was: LDX  #$0608!X$404
        STX     DHIGH
        CLR     DCONS
        LDA     #$12
        STA     DCTRL

        PULS    D,X,PC


;******************************************************************************
;* MAKSCX
;*   Makes a screen address in X based on the base address in OHSBADR,U and
;*   the current offset in OHSCPS,U (times 8)

MAKSCX  PSHS    D

        LDA     OHSCPS,U
        LDB     #8
        MUL
        ADDD    OHSBADR,U
        TFR     D,X

        PULS    D,PC



;******************************************************************************
;* ALLCURS

ALLCURS PSHS    D,U

        TFR     Y,U

        LDB     OHSESZ,Y
        STB     OHSCPS,Y
        LDB     #BLUE

.10S    DEC     OHSCPS,Y
        BMI     .20S
        JSR     WRCURS
        BRA     .10S

.20S    INC     OHSCPS,Y

        PULS    D,U,PC


;******************************************************************************
;* JFTEXT
;*   Write the Joystick/Fire Button Message to the screen

JFTEXT  PSHS    D,X,Y

        TEXT    $30,$50
        PHRASE  CREAM,68,USE,JOYSTICK,TO
        TEXT    $28,$46
        PHRASE  CREAM,68,MAKE,LETTER,ENTRY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers

        FDB     _USE
        FDB     _JOYSTICK
;       FDB     _TO
;       FDB     _MAKE
        FDB     _LETTER
;       FDB     _ENTRY

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        PULS    D,X,Y,PC

;******************************************************************************
;* CENTRY
;*   Character entry routine
;*   Gets entry from Joystick/Buttons, enters into current task workspace
;*
;* This is a segment of a task.  Either the player's initials or the operator
;*   entry can be made through here.  The return address from this task segment
;*   is specified in OHSBADR.  When the return is finally taken, the
;*   results of the character input remain in the task workspace
;*
;* WANTS:
;*      OHSCLT (1) current letter set (initials set to "A", op-entry to " ")
;*      OHSETM (2) maximum time to make entry
;*      OHSESZ (1) entry size (Initials set to 3, operator entry to 20.)
;*      OHSPPR (2) Return address when this portion of the task is completed
;*      OHSBADR (2) Base address for character input
;*
;* RETURNS:
;*   Returns to the address specified in OHSPPR for post-processing of
;*   characters.
;*      OHSINIT (20.) characters entered through this routine
;*                    if this is the player's initials, only the first 3 count
;*       U Register has address of task workspace

CENTRY  CLR     OHSCPS,Y        ;Cursor positioned initialized

        LDA     #CBLANK         ;Get a blank character
        LDB     OHSESZ,Y
        LEAU    OHSINIT-1,Y     ;Get the address for the characters
.10S    STA     B,U             ;Store a blank here
        DECB                    ;  and
        BNE     .10S            ;  repeat

        LDA     #MAXBNC
        STA     OHSBNC,Y

        JSR     ALLCURS

        SLEEP   HERE            ;Now go to sleep for a bit

        TFR     Y,U             ;Save Y register in U
        LDX     OHSETM,U        ;Get our time-out counter and
        LEAX    -1,X            ;  decrement and
        BNE     .20S
        JMP     [OHSPPR,U]      ;  when time's up, install what we've got
.20S    STX     OHSETM,U        ;  else save decremented value


        LDB     #WHITE          ;Write the cursor at this location
        JSR     WRCURS

        JSR     WRCLT

        TST     OHSBNC,U        ;Test if the bounce counter has counted down
        BEQ     .30S            ;  and if so then go feel for another input
        DEC     OHSBNC,U        ;  else bounce down
        BRA     .100S           ;  and go back to sleep

.30S    JSR     APIA2           ;Go feel for input
        ANDA    #FORWARD+REVERSE+JYLEFT+JYRIGHT  ;Is it one of the ones we like?
        BEQ     .100S           ;Nah, so get outta here

        LDB     #MAXBNC
        STB     OHSBNC,U
        LDB     OHSCLT,U

        CMPA    #FORWARD
        BEQ     .50S
        CMPA    #REVERSE
        BEQ     .60S

        PSHS    A
        LDB     #MAXBNC*4                                                               ;;Patched over in BOBFIXES ($8B0F) "Change the bounce value after letter entry from MAXBNC*4 to 6"
        STB     OHSBNC,U
        LDB     #BLUE           ;The current letter has been entered.  First, go
        JSR     WRCURS          ;  erase the cursor
        LDB     OHSCLT,U
        LDA     OHSCPS,U
        ADDA    #OHSINIT
        STB     A,U
        PULS    A

        CMPA    #JYLEFT
        BEQ     .40S

;* Entry is "Joystick Right" bit for Next Letter
        LDA     OHSCPS,U        ;Increment the cursor displacement
        INCA                    ;  until
        CMPA    OHSESZ,U        ;  it reaches 3, at which point all initials
        BNE     .45S
        JMP     [OHSPPR,U]

;* Entry is Joystick Left for Move to Previous Letter
.40S    LDA     OHSCPS,U        ;Yes.  Is cursor displacement at left edge?
        BEQ     .100S
        DECA

.45S    STA     OHSCPS,U
        ADDA    #OHSINIT
        LDB     A,U
        STB     OHSCLT,U
        BRA     .100S           ;  and restart project


;* Entry is Joystick Up for Increase Current Letter
.50S    INCB                    ;Go forward
        CMPB    #MAXLET         ;Does this take us beyond the last letter?
        BLS     .65S            ;  no
        CLRB                    ;  yes, so wrap-around to first character
        BRA     .65S

;* Entry is Joystick Down for Decrease Current Letter
.60S    DECB                    ;Go backward
        BPL     .65S
        LDB     #MAXLET         ;  yes, so wrap-around to last character

.65S    STB     OHSCLT,U        ;Save this character as the current one
        JSR     ERCLT

.100S   TFR     U,Y             ;Restore the Y register
        SLEEP   LOOP            ;  and go sleepy-bye

        PULLORG ROMSAVE