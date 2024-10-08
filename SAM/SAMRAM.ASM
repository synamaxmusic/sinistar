;       INCLUDE "../SAM/START.ASM"
;       INCLVER SAM,SINISTAR

;       SUBTTL  RAM ALLOCATION

SAMRAM
;* direct page variables
        PUSHORG BASSAVE

D_P     SET     $98             ;Fixme was: D_P SET *!>8
        ;SETDP  D_P
        ASSUME DPR:D_P

TEMP    RMB     18              ;temps                                          ;$9800
IRQTEMP RMB     4               ;irq routine temporaries                        ;$9018
;*
SAVEOBJ RMB     2               ;saves current object during task execution     ;$981C
PCRAM   RMB     10              ;pseudo color ram
SEEDS   RMB     ORSPACE         ;random seeds
ESTATE  RMB     1               ;exec state: -1 for list drawn
;*                                            0 for normal behind beam drawing
;*                                            1 for catch up drawing
;*                                           >1 for overload
SCRKEY  RMB     OLEFT-OFLINK+1  ;screen list keystone dummy
RIGHT   RMB     1               ;current display object right
WSIKEY  RMB     2               ;free workspace index keystone
FOBJKEY RMB     2               ;free object list keystone
TCLOCK  RMB     1               ;task clock
TLEVEL  RMB     2               ;current task level
PRTASK  RMB     2               ;previous task pointer
SLVEL   RMB     2               ;screen l velocity
SSVEL   RMB     2               ;screen s velocity
SLPOS   RMB     3               ;screen l position
SSPOS   RMB     3               ;screen s position
STLPOS  RMB     1       ;\      star l position
STSPOS  RMB     1       ;/      star s position                                 ;$984F
PLYRANG RMB     1               ;player rotation angle                          ;$9850
PLSUNIT RMB     1       ;\      player ship direction unit vector s component
PLLUNIT RMB     1       ;/      player ship direction unit vector l component
PLACCEL RMB     1               ;player acceleration
TNTIME  RMB     1               ;tune timer
TNPC    RMB     2               ;tune program counter
TNPRIO  RMB     1               ;tune priority
SCAN    RMB     1               ;last B side control panel scan
DSCAN   RMB     1               ;last coin door scan
SLAMTIM RMB     1               ;slam timer/flag
PTIME   RMB     2               ;play timer
SAVEXOB RMB     2               ;saves X object during pixel collision check
SAVEYOB RMB     2               ;saves Y object during pixel collision check
SCLVEL  RMB     1       ;\      scanner l velocity
SCSVEL  RMB     1       ;/      scanner s velocity
SCTEDGE RMB     1       ;\      scanner top edge of screen
SCREDGE RMB     1       ;/      scanner bottom edge of screen
SCBEDGE RMB     1               ;scanner right edge of screen
SCLEDGE RMB     1               ;scanner left edge of screen
SBORD   RMB     2               ;address of screen border on scanner
PSBORD  RMB     2               ;previous address of screen border on scanner
HIGHBUB RMB     2               ;high bubble address
TRASBUB RMB     2               ;trash compactor bubble address
TRASEND RMB     2               ;trash compactor bubble end address
LDEAL   RMB     2               ;lowest de-allocated storage block address
FREE    RMB     2               ;size of available free space
SFREE   RMB     1               ;free screen object workspace counter
CRYANI  RMB     2               ;crystal animation routine address
SININDE RMB     2               ;address of sinistar scanner index
ANIMPTR RMB     2               ;pointer to current sinistar animation pieces
CRYCOLO RMB     1               ;random crystal color
SCANIVE RMB     2               ;scanner initialization velocity table pointer
EDGE    RMB     1               ;place on edge flag (<> 0 if true)
PANMASK RMB     1               ;bit mask for control panel (bit 2 used for joy)
SSLPOS  RMB     2               ;sinistar supersector l position
SSSPOS  RMB     2               ;sinistar supersector s position
FLASHTI RMB     1               ;flashing ship timer (bit 0 flags erase or draw)
RAPTIME RMB     1               ;rapid fire timer
RAPRATE RMB     1               ;rapid fire rate (interval in screens)
SAVSTK  RMB     2               ;save return ad from stack for storage overload
NPLAYER RMB     1               ;number of players in game
;*****
;*
;*              Sinistar Offset of the:
;*
;*                 Next    Present
;*                 Piece    Piece
;*              +--------+--------+
;*      Scanner | SiniLN | SiniLP |
;*              | SiniSN | SiniSP |
;*              +--------+--------+
;*      Screen  | SinLN  | SinLP  |
;*              | SinSN  | SinSP  |
;*              +--------+--------+
;*
;*****
SiniLP  rmb     1       ;* Present piece Long  scanner offset
SiniSP  rmb     1       ;* Present piece Short scanner offset
SiniLN  rmb     1       ;* Next    piece Long  scanner offset
SiniSN  rmb     1       ;* Next    piece Short scanner offset
SinLP   rmb     1       ;* Present piece Long  screen  offset
SinSP   rmb     1       ;* Present piece Short screen  offset
SinLN   rmb     1       ;* Next    piece Long  screen  offset
SinSN   rmb     1       ;* Next    piece Short screen  offset
;*
MesgTim rmb     1               ;* Time until current message is erased.
SINISEC rmb     1               ;* Sinistar out of sector flag
DeathFl RMB     1               ;* Death flag
AMDemo  rmb     1               ;* Attract Mode Demo vs Normal System Play

        PULLORG BASSAVE


;* extended ram
        PUSHORG RAMSAVE

;* arrays
WPLAYER RMB     0               ;player first workspace
WSOBJ   RMB     NOBJS*OLEN      ;object workspaces
STARRY  RMB     NSTARS*OSTLEN   ;star array
TNREPT  RMB     NTNREPT*OTNRLEN ;tune repeat counters
SINICLI RMB     SINIWID*2       ;sinistar collision table
DOTIMER RMB     0
DLCOIN  RMB     1       ;\      debounce timer left coin
SLCOIN  RMB     1       ;/      state of left coin
DCCOIN  RMB     1       ;\      debounce timer center coin
SCCOIN  RMB     1       ;/      state of center coin
DRCOIN  RMB     1       ;\      debounce timer right coin
SRCOIN  RMB     1       ;/      state of right coin
ENDTIME RMB     0

;* player specific ram
PLURAM  RMB     0               ;player up ram starting address
SHIPS   RMB     1               ;number of player ships remaining               ;$9FFC
PSCORE  RMB     4               ;player score (8 digit bcd)                     ;$9FFD
        RMB     1
NSCORE  RMB     4               ;next ship score (8 digit bcd)                  ;$A002
LSCORE  RMB     4               ;last displayed score (8 digit bcd)
SCOREAD RMB     1               ;screen address of left edge of score
SCOREFL RMB     1               ;new score flag
EXTRADD RMB     4               ;points required for extra ship (X100)
EXTRINC RMB     2               ;points required for extra ship increment (X100)
WRAPFLG RMB     1               ;score wraparound flag
BOMBS   RMB     1               ;the number of sinibombs (# of crystals)        ;$A013
PIECEPT RMB     2               ;pointer to next sinistar piece
FINISH  RMB     2               ;end of piece table for sinistar buildup
ZONECOL RMB     1               ;zone color

        ;PAD    PLAY,80
PLAYSAV SET     *
        RMB     80
PLAYLEN RMB     0

PLNURAM RMB     *-PLURAM        ;player not up ram starting address

;* extended variables
        RMB     2       ;\      index addr for fixed player scanner workspace
SPLAYER RMB     OSWWLen ;/      fixed player scanner workspace
TASK1   RMB     OTLEN   ;\      task 1 list data
TASK2   RMB     OTLEN   ; \     task 2 list data
TASK4   RMB     OTLEN   ;  \    task 4 list data
TASK8   RMB     OTLEN   ;   \   task 8 list data
TASK16  RMB     OTLEN   ;    \  task 16 list data
TASK32  RMB     OTLEN   ;     > task 32 list data
TASK64  RMB     OTLEN   ;    /  task 64 list data
TASK128 RMB     OTLEN   ;   /   task 128 list data
TASK256 RMB     OTLEN   ;  /    task 256 list data
TASK0   RMB     OTLEN   ; /     free task list data
TASKEND RMB     0       ;/

        ;PAD    RAM,80          ;allowance for noah and rich ram
RAMSAV  SET     *
        RMB     80
RAMLEN  RMB     0

;* dynamic storage
INDEXS  RMB     NINDEXS*2       ;dynamic storage block indexes          ;Fixme was: INDEXS      RMB     NINDEXES*2
                                                                        ;(I can't believe there's a typo in here)
DYNSTO  RMB     STACK-STACKAL-* ;dynamic storage space
DYNEND  RMB     0               ;end of dynamic storage
        RMB     STACKAL         ;stack space

        PULLORG

;* static ram
        PUSHORG SPTR            ;Fixme was: PUSHORG SRAMSAV (Not sure why this doesn't work)

SINIMAG RMB     SINIHIG*SINIWID ;sinistar image data
CRIMAGE RMB     4               ;image of crystal

        PULLORG SRAMSAV