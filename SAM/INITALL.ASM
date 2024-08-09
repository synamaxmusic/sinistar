;       INCLUDE "../SAM/START.ASM"

        PUSHORG ROMSAVE

;===============================================================================
; EQUs to remove later
;CRY1ANI EQU    $4566   ;DRAWOBJ
;SCIVELT        EQU     $5023   ;SAMTABLE
;RCMOSA EQU     $4A5F   ;TB13
;WCMOSA EQU     $4A78   ;TB13
;RCMOSB EQU     $4A70   ;TB13
;EXEC   EQU     $345E   ;EXEC
;CLRSCR EQU     $3245   ;INITALL
;PLAYINI        EQU     $30AC   ;INITALL
;SWPLAY EQU     $3345   ;INITALL
;FIN    EQU     $32FA   ;INITALL
;PCLRSCR        EQU     $320F   ;INITALL
;UPSHIPS        EQU     $3C0C   ;ADDSCOR
;UPSCORE        EQU     $3C74   ;ADDSCOR
;GAMOVER        EQU     $320C   ;INITALL
;ANPLAY EQU     $31D8   ;INITALL
;TIMER  EQU     $3419   ;INITALL
;INITURN        EQU     $2FF1   ;INITALL
;DCREDIT        EQU     $338E   ;INITALL
;IAMODE EQU     $2ED4   ;INITALL
;STARTBL        EQU     $4FA0   ;SAMTABLE
;SCOREDI        EQU     $3C65   ;ADDSCOR
;CPLAYER        EQU     $4BC3   ;SAMTABLE
;GETCOBJ        EQU     $4322   ;GETOBJ
;PUTOBJ EQU     $435E   ;GETOBJ
;SCANVEL        EQU     $3F74   ;SCANNER
;INISINI        EQU     $327E   ;INITALL
;FRAME  EQU     $33B4   ;INITALL
;DIE    EQU     $4755   ;SLEEP1
;ASRD4  EQU     $48EA   ;FUNCTION
;BCDHEX EQU     $4B89   ;TB13
;UPBONUS        EQU     $3BC0   ;ADDSCOR
;PIECEND        EQU     $5002   ;SAMTABLE
;PIECETB        EQU     $4FB2   ;SAMTABLE
;AUD1S  EQU     $4A8E   ;TB13           ;RENAMED FROM AUD1$
;PALETTE        EQU     $50CB   ;SAMTABLE
;LTWSI  EQU     $467B   ;SLEEP1
;LFTWSI EQU     $469E   ;SLEEP1
;INITRAM        EQU     $32F0   ;INITALL
;ALIVE  EQU     $4FE2   ;SAMTABLE
;ADDPIEC        EQU     $3D4E   ;ADDPIEC
;TARGET EQU     $3D7E   ;ADDPIEC

;QGAMEND EQU    $4DF2   ;SAMTABLE
;===========================================================

        ;SUBTTL INITIALIZATIONS

;* rts  (must be assembled before all messages)
RTS     RTS

;* restart
        ROUTINE INITALL
        LDS     #STACK          ;reset stack
        LDA     #D_P            ;set direct page
        TFR     A,DPR
        CLRD
        STA     SCRKEY+OLEFT    ;initialize screen keystone dummy left position
        STA     DCONS           ;zero dma constant for erase
        STA     TNTIME          ;no tune playing
        STA     TNPRIO          ;zero tune priority
        STA     CRIMAGE+1       ;zero pad bytes of crystal dma image
        STA     CRIMAGE+3
        STA     SLAMTIM         ;zero slam timer/flag
        STD     DLCOIN          ;zero coin debounce timers and clear valid flags
        STD     DCCOIN
        STD     DRCOIN
        STA     NPLAYER         ;zero number of players
        STA     CUNITS          ;zero coinage remainders
        STB     BUNITS                                                                  ;;This gets patched over in SAM/FIXOPENT.SRC with JMP $8E49
        LDX     #PIA            ;setup pias
        STA     5,X             ;select pia DDR's
        STA     7,X
        STA     $D,X
        STA     $F,X
        LDB     #$34            ;widget
        STB     5,X
        STB     7,X
        LDA     #$3F            ;sounds
        STD     $E,X
        LDD     #$8005
        STD     $C,X            ;coin-door
        STA     $C,X
        LDA     PIA+6           ;initialize control panel state                         ;;This gets patched over in SAM/FIXOPENT.SRC with RTS, leaving behind two junk bytes
        STA     SCAN
        LDA     PIA+$C          ;initialize coin door scan
        STA     DSCAN
        LDD     #CRY1ANI        ;initialize crystal animation vector
        STD     CRYANI
        LDD     #SCIVELT        ;initialize scanner init velocity table pointer
        STD     SCANIVE
        RADIX   10
        LDD     #-60*60         ;initialize play timer to time one minute               ;;Fixme was: LDD #-60.*60. (Decimal numbers originally used periods but {AS} uses that for floating numbers)
        RADIX   16
        STD     PTIME
        LDX     #CREDST         ;recover credit count from cmos
        JSR     RCMOSA
        CMPA    #$20            ;20 or more?
        BLS     .1S
        CLRA                    ;TOO BAD
.1S     STA     CREDIT          ;copy into ram                                          ;;Fixme was: STA CREDITS (another mismatch symbol!)
        LEAX    -2,X            ;reset X to store credits
        JSR     WCMOSA          ;save credits
        LDA     #-1             ;initialize random seeds
        LDX     #SLOT1+5*6+2    ;flight time in minutes is noise source
        JSR     RCMOSB
        STD     SEEDS+OSEED2
        JSR     RCMOSB
        STD     SEEDS+OSEED1
        LDA     #$30            ;enable only player 1 and 2 start buttons
        STA     PANMASK
        HOOK    POWVECT
        JSR     SYSTINI         ;initialize system
;* attract mode
        clr     AMDemo          ;* Turn off demonstration (if not already off)
        Routine IAMode
        JSR     SYSTINI         ;initialize system
        HOOK    IAMVECT



;* start system

STARTS  LDS     #STACK          ;set stack
        ANDCC   #$EF            ;enable irq
        JMP     EXEC            ;start system

;* 2 player start
        BSWITCH START2,CLOSE                                                    ;;Fixme was: SWITCH START2,CLOSE
        LDX     #COINSL         ;in pay play?
        JSR     RCMOSA
        CMPA    #$9
        BEQ     .1S
        LDA     CREDIT          ;yes, get number of credits
        CMPA    #2
        BHS     .1S             ;not enough credits?
        RTS                     ;yes, pay buddy!
.1S     clr     AMDemo          ;* Turn off attract mode demo
        JSR     CLRSCR          ;erase screen
        LDA     #2              ;set to 2 player
        STA     NPLAYER
        LDA     #$13            ;player s axis screen address of score
        JSR     PLAYINI         ;initialize player 1
        JSR     SWPLAY          ;switch players
        LDA     #$B4            ;player s axis screen address of score
        JSR     PLAYINI         ;initialize player 2
        BRA     GAMEINI

;* 1 player start
;       LOCAL
        SECTION PLAYER1START
        BSWITCH START1,CLOSE                                                    ;;Fixme was: SWITCH START1,CLOSE
        LDX     #COINSL         ;in pay play?
        JSR     RCMOSA
        CMPA    #9
        BEQ     .1S
        LDA     CREDIT          ;yes, get number of credits
        BNE     .1S             ;not enough credits?
        RTS                     ;yes, pay buddy!
.1S     clr     AMDemo          ;* Turn off attract mode demo
        ENDSECTION PLAYER1START
        ROUTINE StartDemo
        JSR     CLRSCR          ;erase screen
        LDA     #1              ;set to 1 player
        STA     NPLAYER
        LDA     #$13            ;player s axis screen address of score
        JSR     PLAYINI         ;initialize player 1

;* game initialization
        ROUTINE GAMEINI
        CLRD
        STA     PANMASK         ;disable switches
        LDD     #$FC7A          ;initialize scanner screen border position
        STD     PSBORD
        STD     SBORD
        LDA     #1              ;set read rom/write entire screen
        STA     PMEMCTL
        STA     MEMCTL
        LDA     #1!4            ;* * *FOR DMA BUG       draw fins:                      ;;Fixme was: LDA #1!X4
        STA     DHIGH           ;setup dma for horizontal lines
        LDA     #1              ;l axis offset for first fin in pixels
.1S     STA     TEMP            ;save in TEMP
        JSR     FIN             ;draw fin  save none, uses A,B
        LDA     TEMP            ;get fin l axis offset
        ADDA    #9              ;move up for next fin
        CMPA    #$35            ;done?
        BLO     .1S
        CLR     DCONS           ;zero dma constant for erase
        LDA     #5              ;set read rom/dma inihibit on
        STA     PMEMCTL
        STA     MEMCTL
        JSR     PCLRSCR         ;clear scanner
        HOOK    GAMVECT

;* turn initialization
        ROUTINE TURNINI
;===========================================================
;; (Local labels don't work when TEXT/PHRASE is
;; called so .2S, .3S, and .4S are now global labels
;; "TURN2S","TURN3S", and "TURN4S")
;===========================================================
        LDA     SHIPS           ;get ship count
        LDB     #DWBL           ;re-draw player up ship (extra precaution)
        JSR     UPSHIPS         ;save none, uses none
        JSR     UPSCORE         ;update score (extra precaution)
        JSR     SYSTINI         ;initialize game system
        NEW_SLEEP TASK1,.TURN1S,OTIMER ;setup timer
        JMP     STARTS
.TURN1S LDA     NPLAYER         ;two players?
        DECA
        BEQ     TURN3S
        LDA     SHIPS           ;yes?, is current player finished?
        IFDEF   SAMDEBUG                                                ;;Fixme was: IFDEF  DEBUG (duplicate symbol found)
        BRA     TURN2S
        ELSE
        BNE     TURN2S
        ENDIF
        JSR     GAMOVER
        LDA     PLNURAM-PLURAM+SHIPS    ;yes?, is other player still playing?
        BEQ     TURN4S
        JSR     ANPLAY          ;yes?, announce who died
        PSHS    Y
        TEXT    $4B,$60
        PHRASE  RED,68,GAME,OVER
        PULS    Y
        RADIX   10
        LDD     #180            ;delay 3 seconds                        ;;Fixme was: LDD #180.
        RADIX   16
        JSR     TIMER
TURN2S  LDA     PLNURAM-PLURAM+SHIPS    ;is other player still playing?
        BEQ     INITURN
        JSR     SWPLAY          ;yes?, switch players
        BRA     INITURN
TURN3S  LDA     SHIPS           ;one player, is player finished?
        IFDEF   SAMDEBUG                                                ;;Fixme was: IFDEF  DEBUG (duplicate symbol found)
        BRA     INITURN
        ELSE
        BNE     INITURN
        ENDIF
TURN4S  LDA     SCOREAD         ;is player two the last player
        BPL     .TURN5S
        JSR     SWPLAY          ;yes, switch players
.TURN5S PSHS    Y
        TUNE    QGAMEND         ;play game over tune

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *

        ORG     PHRSAV
        FDB     _GAME
        FDB     _OVER

PHRSAV  SET     *

        ORG     ROMSAVE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        TEXT    $4B,$60         ;display final game over message
        PHRASE  RED,68,GAME,OVER
        LDA     #$30            ;enable 1 and 2 player start buttons
        STA     PANMASK
HSTDENT CLR     NPLAYER         ;flag as attract mode                   ;;(This gets overwritten in HSTDTE.ASM by the ROUTINE macro, which places a JMP $8784 here)
        JSR     DCREDIT         ;display credits, if any
        PULS    Y
        RADIX   10
        LDD     #300            ;delay 5 seconds
        RADIX   16
        JSR     TIMER
        JMP     IAMODE
;*
INITURN PSHS    Y               ;save Y reg, remember this is a task
        JSR     PCLRSCR         ;clear player screen and scanner
        JSR     ANPLAY          ;announce who's up if two players
STATPG  NOP                     ;status page
        NOP
        NOP
        JSR     PCLRSCR         ;clear player screen and scanner
        CLRD                    ;initialize turn:
        STD     SLVEL           ;zero screen velocity
        STD     SSVEL
        STA     SLPOS           ;zero screen position
        STD     SLPOS+1
        STA     SSPOS
        STD     SSPOS+1
        STD     STLPOS          ;zero star position
        STA     SCLVEL          ;zero scanner velocity
        STD     OSLVEL+SPLAYER  ;zero player pseudo-scanner velocity
        STD     OSLPOS+SPLAYER  ;zero player pseudo-scanner position
        STA     EDGE            ;zero edge flag
        STA     DEATHFL         ;zero player death flag
        STA     FLASHTI         ;zero flashing player ship timer
        STA     RAPTIME         ;zero machine gun timer flag
;       LOCAL
        SECTION STARGEN
        LDX     #STARRY         ;generate star data
        LDU     #STARTBL
.1S     RANDOM  OSEED1,BYTE     ;random s position
        PSHS    A
        RANDOM  OSEED2,DINHIB   ;random l position
        PULS    B
        STD     X
        LDA     U+              ;get colors from table
        STA     OSCOLOR,X
        CLR     OSTMASK,X       ;zero pixel mask
        LEAX    OSTLEN,X
        CMPX    #STARRY+NSTARS*OSTLEN
        BLO     .1S
        ;LOCAL
        ENDSECTION STARGEN
        NEW_SLEEP TASK8,SCOREDI ;start score display task
        LDD     #CPLAYER        ;create player:
        STD     OSCHAR+SPLAYER  ;set characteristics in pseudo-scanner workspace
        JSR     GETCOBJ         ;save none, uses A,B,X
        STX     OSSCWSA+SPLAYER ;set screen wsa in pseudo-scanner workspace
        LDD     #$277A          ;mid screen
        STD     OBOTTOM,X
        STB     OSPOS,X
        CLRD                    ;zero velocity
        STD     OSVEL,X
        STD     OLVEL,X
        STA     PLYRANG         ;zero angle
        JSR     PUTOBJ          ;save none, uses none
        LDD     #SPLAYER        ;set scanner index to pseudo-scanner index
        STD     OSCAN,X
        STD     OINDEX+SPLAYER  ;use task link for pseudo-scanner index
        STD     SPLAYER
        NEW_SLEEP TASK8,SCANVEL,OSULEN ;create scanner position update task:
        LDD     SLPOS           ;initialize old l position
        SUBB    OLPOS+WPLAYER
        SBCA    #0
        RPT     1,ASRA,RORB
        STB     OSULPOS,X
        LDD     SSPOS           ;initialize old s position
        SUBB    OSPOS+WPLAYER
        SBCA    #0
        RPT     2,ASRA,RORB
        STB     OSUSPOS,X
        JSR     INISINI         ;initialize sinistar
        JSR     FRAME           ;draw frame for this level (extra precaution)
;       IFE     Level           ;* Level 0 of the version release
        HOOK    INIVECT         ;*   does a simple HOOK INIVECT
;       ELSE    Level not 0.    ;*   but updates to the release
;       IFE     Version-10.     ;*   are made at Level 1.
;*      Hook    IniVect (to first V11 routine)
;       jsr     $5587           ;* Updates cannot use the reSET value of INIVECT
;       ELSE    Version not 10. ;*   and the original value is version dependant
;       ERR     Hook to proper location.
;       ENDIF   Version
;       ENDIF   Level
        ROUTINE Witt1
        lda     #%00001111      ;* Turn on all but the player start buttons
        tst     AMDemo          ;*   during normal game play, but during
        beq     .1S             ;*   the attract mode demo, only the player
        lda     #%00111000      ;*   start buttons and scrolling should work.
.1S     sta     PanMask         ;* Set the controls.
        puls    Y
        jmp     Die

;* player initialization        ;pass s axis screen address of score in A
        ROUTINE PLAYINI         ;> uses A,B
        STA     SCOREAD         ;player s axis screen address of score
        CLRD
        STA     BOMBS           ;zero sinibomb count
        STD     PSCORE          ;zero player score
        STD     PSCORE+2
        STD     LSCORE          ;zero last displayed score
        STD     LSCORE+2
        STA     WRAPFLG         ;zero score wraparound flag
        STD     NSCORE-1        ;initialize next ship level
        STA     NSCORE+3
        STD     EXTRADD         ;zero extra ship adder overload flag
        LDX     #REPLAY         ;initialize extra ship adder
        JSR     RCMOSA
        CLRB
        JSR     ASRD4
        STD     EXTRADD+2
        STD     NSCORE+1        ;initialize next ship level
        JSR     RCMOSA          ;initialize extra ship adder increment
        CLRB
        JSR     ASRD4
        STD     EXTRINC
        JSR     RCMOSB          ;initialize ship count
        JSR     BCDHEX
        TFR     B,A
        STA     SHIPS
        LDB     #DWBL           ;display initial ships
PLAY1S  JSR     UPSHIPS         ;save A,B, uses none                            ;;(Had to change local labels)
        DECA
        BNE     PLAY1S
        LDA     #$FF            ;store junk in last display score ones and tens
        STA     LSCORE+3        ;and set score flag to display '00'
        JSR     UPSCORE         ;update score
        LDA     #$81            ;write 'bonus at' message for the player
        LDB     SCOREAD
        TFR     D,X
        WORD    BLUE,35,BONUS
        WORD    BLUE,35,AT
        JSR     UPBONUS         ;display first bonus level, save none, uses none
        LDD     #PIECEND        ;have to build up sinistar from scratch
        STD     FINISH
        LDD     #PIECETB        ;target to first piece
        STD     PIECEPT
        LDA     AMDEMO          ;in real game?
        BNE     PLAY2S
        LDX     #COINSL         ;yes, in pay play?
        JSR     RCMOSA
        CMPA    #9
        BEQ     PLAY2S
        LDA     CREDIT          ;yes, get number of credits
        ADDA    #$99            ;click off one credits
        DAA
        STA     CREDIT          ;save new credits
        LDX     #CREDST
        JSR     WCMOSA          ;back it up
        LDB     #8              ;add a game played to the books
        JSR     AUD1S                                                                           ;;Fixme was: JSR        AUD1$
PLAY2S  HOOK    PLAVECT
        RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *

        ORG     PHRSAV
        FDB     _BONUS
        FDB     _AT

PHRSAV  SET     *

        ORG     ROMSAVE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;* system initialization
        ROUTINE SYSTINI
        PSHS    CC
        ORCC    #$10            ;disable irq
        STA     TCLOCK          ;zero task clock
        LDX     #PCRAM          ;initialize colors
.SYS1S  LDD     (PALETTE-PCRAM),X
        STD     X++
        CMPX    #PCRAM+$10
        BLO     .SYS1S
        ;LOCAL
        SECTION SYSTINI
        LDX     #WSOBJ          ;create free object list
        STX     FOBJKEY
.1S     LEAX    OLEN,X
        STX     -OLEN,X
        CMPX    #WSOBJ+(NOBJS-1)*OLEN
        BNE     .1S
        CLRD
        STD     ,X
        ENDSECTION SYSTINI
        ;LOCAL
        LDX     #INDEXS         ;create free workspace index list
        STX     WSIKEY
.1S     LEAX    2,X
        STX     -2,X
        CMPX    #INDEXS+NINDEXS*2-2
        BLO     .1S
        CLRD
        STD     X
        STD     SCRKEY+OFLINK   ;initialize screen keystone dummy
        STD     SAVSTK          ;TEMPORARY zero stack save for trask kludge
        STA     ESTATE          ;initialize exec state
        LDD     #DYNSTO         ;initialize high bubble
        STD     HIGHBUB
        LDD     #DYNEND         ;turn off trash compactor
        STD     TRASBUB
        LDA     #-1             ;set lowest de-allocated block to high address
        STA     LDEAL
        LDA     #NOBJS          ;initialize free screen object workspace counter
        STA     SFREE
        LDD     #DYNEND-DYNSTO-SALLOW ;initialize free space
        STD     FREE
        LDX     #TASK1          ;initialize task lists:
        LDD     #LTWSI
.2S     STD     X               ;set keystones to dummy last workspace indexes
        STX     OTKEYI,X
        LEAU    OTKEYI,X        ;set pointers to indexes
        STU     OTPTR,X
        CLR     OTBACK,X        ;zero backlog counters
        LEAX    OTLEN,X
        CMPX    #TASK0
        BNE     .2S
        LDD     #LFTWSI         ;set free list keystone to dummy last wsi
        STD     X
        STX     OTKEYI,X
        LEAU    OTKEYI,X        ;set free list pointer to index
        STU     OTPTR,X
        LDA     #1              ;set free list backlog counter to 1
        STA     OTBACK,X
        LDD     #TASK0          ;set current task level to free list keystone
        STD     TLEVEL
        LDD     #TASK0+OTKEYI   ;set next task ptr to free list keystone index
        STD     PRTASK
        JSR     EXPFONT         ;expand font into static ram
        HOOK    SYSVECT
        PULS    CC,PC


;       SUBTTL  INITIALIZATION SUBROUTINES

;* announce player up
        ROUTINE ANPLAY
        PSHS    A,B,X,Y
        LDA     NPLAYER         ;two players?
        DECA
        BEQ     ANP2S                                   ;;Fixme was: BEQ .2S
        LDA     SCOREAD         ;yes, who up?
        BMI     ANP1S                                   ;;Fixme was: BMI .1S
        TEXT    $62,$66
        PHRASE  RED,68,PLAYER,1
        BRA     ANP2S                                   ;;Fixme was: BRA .2S
ANP1S   TEXT    $62,$66                                 ;;Fixme was: .1S
        PHRASE  RED,68,PLAYER,2
ANP2S   PULS    A,B,X,Y,PC                              ;;Fixme was: .2S
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *

        ORG     PHRSAV
        FDB     _PLAYER
        FDB     _1
        FDB     _2

PHRSAV  SET     *

        ORG     ROMSAVE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;* display game over in player window
        ROUTINE GAMOVER                                 ;;This gets patched over by MICA/ZGAMOVER.ASM
        NOP
        NOP
        RTS

;* partial screen clear - playing area and scanner
        ROUTINE PCLRSCR
        PSHS    D               ;> uses none
        LDA     PMEMCTL         ;turn off dma inhibit
        PSHS    A
        ANDA    #~$4                                                            ;;Fixme was: ANDA       #!N4
        STA     PMEMCTL
        STA     MEMCTL
        LDD     #$1831!$404     ;erase scanner region * * * FOR DMA ERROR       ;;Fixme was: LDD #1831!X404
        STD     DHIGH
        LDD     #((DINHIB+1)<<8)+$68                                            ;;Fixme was: LDD        #(DINHIB+1)!<8+68
        STD     DSOUR
        STD     DDEST
        LDB     #DWBL+DCNS
        STB     DCTRL
        LDA     #1!4            ;* * * FOR DMA BUG                              ;;Fixme was: LDA #1!X4
        STA     DHIGH
        LDA     #$8D
        STA     DDEST
        LDA     #DWBL+DCNS+DXWB
        STA     DCTRL
        LDA     #DINHIB-1       ;setup to erase play area
        BRA     CLRSC1          ;erase play area

;* clear screen
        ROUTINE CLRSCR
        PSHS    D               ;> uses none
        LDA     PMEMCTL         ;turn off dma inhibit
        PSHS    A
        ANDA    #~$4                                                            ;;Fixme was: ANDA #!N4
        STA     PMEMCTL
        STA     MEMCTL
        LDA     #$97            ;setup to erase entire screen
        ROUTINE CLRSC1
        LDB     #1!4            ;setup to erase one line * * * FOR DMA ERROR    ;;Fixme was: LDB #1!X4
        STB     DHIGH
        LDB     #$FF!4          ;* * * FOR DMA ERROR                            ;;Fixme was: LDB #0FF!X4
        STB     DWIDE
        CLR     DDEST+1
.1S     STA     DDEST           ;erase line loop
        LDB     #DWBL+DCNS
        STB     DCTRL
        LDB     #WDOGC          ;stroke watchdog
        STB     WDOG
        SUBA    #1
        BCC     .1S
        PULS    A               ;restore dma inhibit
        STA     PMEMCTL
        STA     MEMCTL
        PULS    D,PC

;* initialize sinistar
        ROUTINE INISINI         ;> uses none
        PSHS    D,X
        LDD     #SINIMAG        ;setup dma to zero sinistar ram image           ;;Fixme was: LDD #SINIMAGE
        STD     DSOUR
        STD     DDEST
        LDD     #(SINIHIG<<8)+SINIWID!$404                                      ;;Fixme was: LDD #SINIHIG!<8+SINIWID!X404 ;* * *FOR DMA BUG
        STD     DHIGH
        LDA     PMEMCTL         ;turn off dma inhibit
        PSHS    A
        ANDA    #~$4                                                            ;;Fixme was: ANDA #!N4
        STA     PMEMCTL
        STA     MEMCTL
        LDA     #DCNS           ;zero it
        STA     DCTRL
        PULS    A
        STA     PMEMCTL         ;turn on dma inhibit
        STA     MEMCTL
        LDX     #SINICLI        ;sinistar collision table
        LDA     #$7F-2*SINIHIG  ;initialize bottom edge
        LDB     #SINIWID
        JSR     INITRAM         ;save A,B, uses X
        NEGA                    ;initialize top edge
        JSR     INITRAM         ;save none, uses X
        LDD     PIECEPT         ;save sinistar builtup state
        PSHS    D
        LDD     FINISH          ;is it alive?
        CMPD    #ALIVE
        BNE     .2S
        STD     PIECEPT         ;yes?, build it up center
        LDX     #PIECEND        ;set finish to last center piece
        STX     FINISH
.1S     JSR     ADDPIEC         ;add pieces till center is finished
        CMPD    PIECEPT
        BLO     .1S
        STD     FINISH          ;set finish to alive
.2S     LDX     #PIECETB        ;retarget to first piece
        JSR     TARGET
.3S     CMPX    S               ;are more pieces needed?
        BEQ     .4S
        JSR     ADDPIEC         ;add pieces till pointer matches previous walue
        LDX     PIECEPT
        BRA     .3S
.4S     LEAS    2,S
        PULS    D,X,PC

;* initialize ram to a value
;*      pass start addr in X, value in A, # bytes in B, returns end addr+1 in X
        ROUTINE INITRAM
        ABX             ;> uses X
        PSHS    B,X
.1S     STA     -X
        DECB
        BNE     .1S
        PULS    B,X,PC

;* draw a fin           pass l axis offset in temp
FIN     LDD     #$1466          ;get width in A, color in B > uses A,B
        BSR     .1S             ;draw bottom color of fin
        LDA     TEMP            ;move l axis offset up 3 pixels
        ADDA    #3
        STA     TEMP
        LDD     #$11AA          ;get width in A, color in B, draw top color
.1S     STB     DCONS           ;set constant color in dma
.2S     BSR     .3S             ;draw line
        DECA                    ;next line
        BNE     .2S             ;done?
        RTS
;*
.3S     PSHS    A               ;save line
        CMPA    #$11            ;too wide?
        BLS     .4S
        LDA     #$11            ;yes, clip left and right edges
.4S     PSHS    A               ;save cliped line
        ASLA                    ;double it for length
        ADDA    #$35            ;add width of scanner
        EORA    #4              ;* * *FOR DMA BUG
        STA     DWIDE           ;setup dma width
        LDB     #$66            ;compute s axis starting position
        SUBB    S+
        LDA     S               ;compute l axis position
        ADDA    TEMP            ;add l axis offset
        RORA                    ;convert to pixels
        PSHS    CC              ;save flavor
        ADDA    #DINHIB         ;add l axis position
        CMPA    #$98            ;off top of screen?
        BLS     .5S
        CLRA                    ;yes, draw line on bottom of screen (invisible)
.5S     STD     DDEST           ;setup dma position
        LDA     #DXWB+DCNS+DWBL ;draw correct flavor
        PULS    CC
        BCC     .6S
        LDA     #DXWT+DCNS+DWBL
.6S     STA     DCTRL
        PULS    A,PC            ;restore line

;* switch players               uses sinistar image space
SWPLAY  PSHS    A,X,Y,U
        LDA     PMEMCTL         ;turn off dma inhibit
        PSHS    A
        ANDA    #~$4                                                            ;;Fixme was: ANDA       #!N4
        STA     PMEMCTL
        STA     MEMCTL
PLSIZE  SET     PLNURAM-PLURAM
;       IFGT    PLSIZE-0FF
;       MESSG   "TOO MUCH PLAYER RAM"
;PLSIZE SET     0FF
;       ENDIF
        LDX     #$100+PLSIZE!$404       ;* * *FOR DMA BUG  setup dma size               ;;Fixme was: LDX #100+PLSIZE!X404
        STX     DHIGH
        LDX     #PLNURAM        ;move other player ram into buffer
        STX     DSOUR
        LDY     #SINIMAG
        STY     DDEST
        LDA     #DSCY
        STA     DCTRL
        LDU     #PLURAM         ;move current player ram into other players ram
        STU     DSOUR
        STX     DDEST
        STA     DCTRL
        NOP
        STY     DSOUR           ;move buffer into current players ram
        STU     DDEST
        CLR     DCTRL
        PULS    A               ;restore dma inhibit
        STA     PMEMCTL
        STA     MEMCTL
        PULS    A,X,Y,U,PC

;* display number of credits
DCREDIT PSHS    D,X             ;> uses none
        LDA     NPLAYER         ;attract mode?
        BNE     DCRED3S                                 ;;Fixme was: BNE .3S
        TST     CREDIT          ;yes, any credits?
        BEQ     DCRED3S                                 ;;Fixme was: BEQ .3S
        TEXT    $10,$6D
        PHRASE  WHITE,35,CREDITS
        LDA     CREDIT          ;get number of credits
        BITA    #$F0            ;surpress leading zero
        BNE     DCRED2S                                 ;;Fixme was: BNE .2S
        ORA     #$F0
DCRED2S JSR     OUTB35          ;display value          ;;Fixme was: 2$
DCRED3S PULS    D,X,PC                                  ;;Fixme was: 3$
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *

        ORG     PHRSAV
        FDB     _CREDITS

PHRSAV  SET     *

        ORG     ROMSAVE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;* draw frame - color depends on zone color
FRAME   PSHS    A,B             ;> uses none
        LDA     PMEMCTL         ;turn off dma inhibit
        PSHS    A
        ANDA    #~$4                                                                    ;;Fixme was: ANDA #!N4
        STA     PMEMCTL
        STA     MEMCTL
        LDD     #$1FF!$404      ;* * * FOR DMA ERROR   draw scanner bottom frame        ;;Fixme was: LDD  #1FF!X404
        STD     DHIGH
        LDD     #DINHIB<<8                                                              ;;Fixme was: LDD  #DINHIB!<8
        STD     DDEST
        LDA     ZONECOL
        STA     DCONS
        LDB     #DWBL+DCNS
        STB     DCTRL
        LDB     #$35!4                                                                  ;;Fixme was: lDB  #35!X4
        STB     DWIDE           ;draw scanner top frame
        LDD     #$8E66
        STD     DDEST
        LDB     #DWBL+DCNS+DXWB
        STB     DCTRL
        LDA     #$8D
        STA     DDEST
        LDB     #DWBL+DCNS+DXWT
        STB     DCTRL
        LDD     #$1902!$404     ;* * * FOR DMA ERROR    draw scanner left frame         ;;Fixme was: LDD  #1902!X404
        STD     DHIGH
        LDA     #$75
        STA     DDEST
        LDB     #DWBL+DCNS
        STB     DCTRL
        LDA     #$99            ;draw scanner right frame
        STA     DDEST+1
        STB     DCTRL
        PULS    A               ;restore dma inhibit
        STA     PMEMCTL
        STA     MEMCTL
        CLR     DCONS
        PULS    A,B,PC

;* precision timer routine - uses ONLY in timer task (NEW_SLEEP TASK1,?,OTIMER)
;*     pass ticks in D, task wsa in Y, wakes after call
TIMER   STD     OTIME,Y         ;save sleep time
        PULS    D
        STD     OWAKE,Y         ;save return address
.1S     SLEEP   HERE
        LDD     OTIME,Y
        SUBD    #1
        STD     OTIME,Y
        BNE     .1S
        JMP     [OWAKE,Y]

        PULLORG ROMSAVE