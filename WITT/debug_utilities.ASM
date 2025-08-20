;;===============================================================================
;;
;;   These are debug utilities from Rich's AOE.ASM file.  I have placed them here
;;   in this new file to make it easier to enable these debug functions.
;;
;;===============================================================================
;;
;;   Assembling up to Noah's module results in triggering the copyright protection.
;;   The scanner "fins" and score will be drawn on screen but the game won't start.
;;   Include this code to make the incomplete game playable.
;;
;;   This can also be useful for modding the game since KenChk is made to produce
;;   unwanted issues when checksums don't match up.
;;
;;   It probably goes without saying that you shouldn't include this code if you're
;;   trying to build the original ROM.
;;
;;===============================================================================

;SkipStatusPage  EQU     1
;RapidFireRate2x EQU     1
;WarriorBug      EQU     1
;WarriorBugv2    EQU     1
;SkipSiniExplode EQU     1
;SkipKaBoom      EQU     1
;AMOADeath       EQU     1
;SkipStars       EQU     1
;TrippyBG        EQU     1
;NoScanner       EQU     1
;NoHUD           EQU     1
;AMOATAIL        EQU     1
;DifficultyModV2  EQU     1
;EarlyHUD        EQU     1
;Player3Hits     EQU     1
;DrawPalette     EQU     1
;AttractTAIL     EQU     1

MODSAV  SET     $F4FB           ;; We're creating a new assembly counter called "MODSAV"
                                ;;  to keep track of all these mods.

;;==============================================================================

        CODEPAGE WILLIASCII             ;; This will make it easier to add more
        CHARSET '0',$00                 ;; phrase strings to the game
        CHARSET '1',$01
        CHARSET '2',$02
        CHARSET '3',$03
        CHARSET '4',$04
        CHARSET '5',$05
        CHARSET '6',$06
        CHARSET '7',$07
        CHARSET '8',$08
        CHARSET '9',$09
        CHARSET '\32',$0A       ;;Space
        CHARSET 'A',$0B
        CHARSET 'B',$0C
        CHARSET 'C',$0D
        CHARSET 'D',$0E
        CHARSET 'E',$0F
        CHARSET 'F',$10
        CHARSET 'G',$11
        CHARSET 'H',$12
        CHARSET 'I',$13
        CHARSET 'J',$14
        CHARSET 'K',$15
        CHARSET 'L',$16
        CHARSET 'M',$17
        CHARSET 'N',$18
        CHARSET 'O',$19
        CHARSET 'P',$1A
        CHARSET 'Q',$1B
        CHARSET 'R',$1C
        CHARSET 'S',$1D
        CHARSET 'T',$1E
        CHARSET 'U',$1F
        CHARSET 'V',$20
        CHARSET 'W',$21
        CHARSET 'X',$22
        CHARSET 'Y',$23
        CHARSET 'Z',$24
;       CHARSET 'CBARRW'        EQU     $25
;       CHARSET 'CEQU'  EQU     $26
        CHARSET '-',$27
;       CHARSET 'CQUE'  EQU     $28
        CHARSET '!',$29
        CHARSET '(',$2A
        CHARSET ')',$2B
        CHARSET '\H',$2C        ;;Apostrophe
        CHARSET ',',$2D
        CHARSET '.',$2E

;;==============================================================================





        IFDEF  T13MODDED
MODSAV  SET     NEWSAV                  ;; If we're using modded T13, change MODSAV so that it matches with NEWSAV ($F8CC)
        ENDIF


        IFDEF   DisableKenChk
;;      PUSHORG ROMSAVE
        PUSHORG $FFE0
        VECTOR  POWVECT
;       SYMVER  KENCHK,KENCHK
        clr     KENCHK
        rts
        VECTOR  IniVect
        clr     KenChk
        rts
;       PULLORG ROMSAVE
        PULLORG
;       SYMVER  ZAPSIN,ZAPSini
        PUSHORG ZAPSini         ;* In the PowVect routine, ignore the
        tst     $0              ;*   copyright violation test routine.
        PULLORG

;       PUSHORG $52D7
;       fcb     $7F             ;Just clear KenChk no matter what.
;       PULLORG

        ENDIF


;;===============================================================================
;*****
;*
;* WORK UTILITIES
;*
;*****
        IFDEF   BargraphEnable  ;*****************************************
;       IFE     VERSION-9                                               ;*
;       ENDIF   VERSION                                                 ;*
;       INCLUDE "../WITT/RICH.EQU"                                              ;;We need Rich's work EQUs

GrafxSAV SET    $F4FB                                                           ;;Let's overwrite the cross hatch test

        INCLUDE "../SAM/bargraph.ASM"           ;* <<< Bar Graphs >>>    *

;       PUSHORG $F09C
;       JMP     $49F9
;       PULLORG

;       PUSHORG $F07F                                                           ;;Disable Noah's patch in LAST.ASM
;       NOP
;       NOP
;       NOP
;       PULLORG

;       PUSHORG Palette                                                 ;*
;       fcb     @067,@377,@277,@256,@255,@244,@232,@067                 ;*
;       fcb     @377,@311,@120,@113,@005,@007,@007,@067                 ;*
;       PULLORG
;;*                                                                     ;*
;       PUSHORG RAMSAV                                                  ;*      ;;Fixme was: PUSHORG    RAMSAVE
;JUNKTIME       rmb     2                                               ;*
;       PULLORG RAMSAV                                                  ;*      ;;Fixme was: PULLORG    RAMSAVE
;;*                                                                     ;*
;       PUSHORG GRAFORG                                                         ;;Fixme was: PUSHORG    ROMSAVE  (We're going to overwrite the rug test instead)
;;      LOCAL                                                           ;*
;       VECTOR  IniVect                                                 ;*
;       clr     JUNKTIME                                                ;*
;       clr     JUNKTIME+1                                              ;*
;       New_Sleep       Task64,.JUNK1S                                  ;*      ;;Fixme was: New_Sleep  Task64,1$
;       rts                                                             ;*
;;**                                                                    ;*
;;*     Time clock                                                      ;*
;;**                                                                    ;*
;.JUNK1S        pshs    D,X,U                                                   ;*      ;;Fixme was: 1$ pshs    D,X,U
;       ldd     JUNKTIME                                                ;*
;       addd    #(1*4)          ;* Or (2*4) on the 128 list.            ;*
;       std     JUNKTIME                                                ;*
;       asla                                                            ;*
;       asla                                                            ;*
;       sta     Graph+GMinutes                                          ;*
;       stb     Graph+GSeconds                                          ;*
;       IF      1 = 1   ;***************** This is turned off! ***********      ;;Fixme was: IFE  1
;;**                                                                    *
;;*     Monitor Warrior Aggression                                      *
;;**                                                                    *
;       lda     WAgg                    ;* Monitor the high byte of     *
;       asla                            ;*   (shifted to scale)         *
;       sta     Graph+GAggression       ;*   the warrior aggression     *
;;**
;;*     Monitor Missions
;;**
;       ldx     #Temp
;       clr     TGMWaDrift,X
;       clr     TGMWaAttack,X
;       clr     TGMWaMine,X
;       clr     TGMWaTail,X
;       clr     TGMWaInt,X
;
;       ldu     #Ground
;       cmpu    KeyClee+2
;       beq     .4S
;       ldu     [KeyClee+2]
;.2S    lda     OSMIS,U
;       cmpa    #OMWaSav
;       bge     .3S
;       asra
;       ldb     A,X
;       addb    #(4*4)                                                          ;;Fixme was: addb  #(4.*4.)  (Is decimal really needed here?)
;       stb     A,X
;.3S    ldu     [OSCTYPT,U]
;       cmpu    #Ground
;       bne     .2S
;
;.4S    lda     TGMWaDrift,X
;       sta     Graph+GMWaDrift
;       lda     TGMWaAttack,X
;       sta     Graph+GMWaAttack
;       lda     TGMWaMine,X
;       sta     Graph+GMWaMine
;       lda     TGMWaTail,X
;       sta     Graph+GMWaTail
;       lda     TGMWaInt,X
;       sta     Graph+GMWaInt
;       ENDIF   ;1              ;******* Turned off for now. *************
;       puls    D,X,U                                                   ;*
;       SLEEP   LOOP                                                    ;*
;       PULLORG GRAFORG                                                         ;;Fixme was: PULLORG    ROMSAVE

;       IFNDEF  ROM
;       PUSHORG $FFF0                                                           ;; Let's restore the IRQ vectors in ROM 11 so that MAME can boot
;       FDB     RESTART,RESTART,RESTART,RESTART,IRQ,RESTART,RESTART,RESTART
;       PULLORG
;       ELSE
;       PUSHORG $FFF0
;       FDB     PWRUP,PWRUP,PWRUP,PWRUP,IRQ,PWRUP,PWRUP,PWRUP
;       PULLORG
;       ENDIF
                                ;*
        ENDIF   ;Diagnose       ;*****************************************

BCF     MACRO   A1,A2,A3
        IF      A1 <> 0                                                         ;;Fixme was: IFN        A1
        FCB     A1
        ELSE
        RMB     1
        ENDIF
        IF      A2 <> 0                                                         ;;Fixme was: IFN        A2
        FCB     A2
        ELSE
        RMB     1
        ENDIF
        IF      A3 <> 0                                                         ;;Fixme was: IFN        A3
        FCB     A3
        ELSE
        RMB     1
        ENDIF
        RMB     7
        ENDM
;;===============================================================================
;;
;;   Here's something I've never seen before.  Changing the IF to 1=1 here
;;   draws the letters "WITT" over the tiny Planetoid sprite in dark purple pixels.
;;
;;   To make it easier to enable, I added a new define called "WittRock" in MAKE.ASM
;;   that allows this to be included.
;;
;;===============================================================================
;       IF      1 = 0                                                           ;;Fixme was: IFE  1
        IFDEF   WITTROCK                                                        ;;Decided to comment out the original IF 1 = 0 for WittRock
        PUSHORG $E4E
        BCF     $5B,$BB,$BB
        BCF     $B5,$00,$00
        BCF     $5B,$B5,$00
        BCF     $B6,$00,$00
        BCF     $AB,$BB,$BB
        BCF     $00,$00,$00
        BCF     $AB,$BB,$BB
        BCF     $00,$00,$00
        BCF     $00,$00,$AB
        BCF     $AB,$BB,$BB
        BCF     $00,$00,$AB
        BCF     $00,$00,$00
        BCF     $00,$00,$AB
        BCF     $AB,$BB,$BB
        BCF     $00,$00,$AB
        PULLORG
        ENDIF

;       LIST
;       IFDEF   Debug           ;*****************************************
;       PUSHORG ROMSAVE                                                 ;*
;;*     Routine Witt1                                                   ;*
;;*     lda     #$FF                                                    ;*      ;; Here, Rich is enabling all the mask bits (including unused ones)
;;*     sta     PANMASK                                                 ;*      ;; for the control panel buttons.  This is to enable P2 button during gameplay
;;*     puls    Y                                                       ;*
;;*     jmp     DIE                                                     ;*
;;*                                                                     ;*
;;      LOCAL                                                           ;*
;       SWITCH  START2,CLOSE    ;* Fake out pickup                      ;*
;       LDA     BOMBS           ;get sinibomb count                     ;*
;       INCA                    ;add one                                ;*
;       cmpa    #MAXBOMBS       ;* If too many bombs are being held     ;*
;       ble     WITDBG1         ;*   then the crystal cannot be picked  ;*
;       DISPLAY                                                         ;*
;       PHRASE  BLUE,35,CAPTAIN,OUR                                     ;*
;       PHRASE  BLUE,35,BOMB,BAY,IS,FULL                                ;*
;       jsr     addpart                                                 ;*
;       DISPLAY                                                         ;*
;       PHRASE  WHITE,35,DEVELOPMENT                                    ;*
;       PHRASE  WHITE,35,PIECE,ADDED                                    ;*
;       rts                                                             ;*
;WITDBG1 STA    BOMBS           ;save new sinibomb count                 *      ;;Fixme was: 1$
;       LDB     #DWBL           ;get dma constant to write sbomb display *
;       JSR     UPBOMBS         ;update sinibomb display, save Y, uses A *
;       DISPLAY                                                         ;*
;       PHRASE  TANGREY,35,DEVELOPMENT                                  ;*
;       PHRASE  TANGREY,35,BOMBS,ADDED                                  ;*
;       rts                                                             ;*
;       PULLORG ROMSAVE                                                 ;*
;       ENDIF   ;Debug          ;*****************************************

        IFDEF   InfiniteShips   ;*****************************************      ;;Fixme was: IFDEF  Debug (duplicate symbol)
        PUSHORG ROMSAVE                                                 ;*
        VECTOR  IniVect                                                 ;*
        inc     Ships           ;Player won't run out of ships          ;*
        rts                                                             ;*
        PULLORG ROMSAVE                                                 ;*
        ENDIF   ;Debug          ;*****************************************

        IFDEF   WitPop  ;*************************************************
;       IFE     VERSION-9
;       ENDIF   VERSION
        PUSHORG InPop0                                                  ;*
        fcb     0,2,0                   ;* Workers                      ;*
        fcb     0,2,0                   ;* Warriors                     ;*
        fcb     0,1,0                   ;* Type 1 Planets               ;*
        fcb     0,1,0                   ;* Type 2 Planets               ;*
        fcb     0,1,0                   ;* Type 3 Planets               ;*
        fcb     0,1,0                   ;* Type 4 Planets               ;*
        fcb     0,1,0                   ;* Type 5 Planets               ;*
        PULLORG
;*                                                                      ;*
        PUSHORG Quota                                                   ;*
;*           Work,Warr                                                  ;*
        fcb     1,0                     ;* For testing, planet quota    ;*
        fcb     1,1                     ;* For testing, player quota    ;*
        fcb     1,0                     ;* For testing, sinistar quota  ;*
        fcb     9,9                     ;* For testing, sinibomb quota  ;*
        PULLORG
;*                                                                      ;*
        PUSHORG MisAss                  ;*<<< MESSED UP! >>>            ;*
;*               Workers,Warriors                       **  WARRIORS    ;*
        fcb     OMWoTail,OMWaDrift      ;* Planets      * 0 = Drift     ;*
        fcb     OMWoTail,OMWaDrift      ;* Player       * 2 = Attack    ;*
        fcb     OMWoTail,OMWaDrift      ;* Sinistar     * 4 = Mine      ;*
        fcb     OMWoIntercept,OMWaDrift       ;* Sinibombs    * 6 = Guard     ;*      ;;Fixme was: fcb     OMWoInt,OMWaDrift
        fcb     OMWoIntercept,OMWaInt         ;* Crystals     * 8 = Intercept ;*      ;;Fixme was: fcb     OMWoInt,OMWaInt
        PULLORG
;*
;       PUSHORG WarrMis                 ;*********************************      ;; This RTS breaks WarrMis
;       rts                             ;* Drift                         *
;*      rmb     2                       ;* Attack Player                 *
;*      rmb     2                       ;* Mine Planet                   *
;*      rmb     2                       ;* Guard Object                  *
;*      rmb     2                       ;* Intercept Object              *
;       PULLORG
;*
        PUSHORG RicPat
;       Local
        lda     #0
        ldu     #CWarrior
        sta     Temp
RICPAT1 dec     Temp                                                            ;;Fixme was: 1$
        bmi     RICPAT2
        jsr     [OInvec,U]
        jmp     RICPAT1
RICPAT2 rts                                                                     ;;Fixme was: 2$
        PULLORG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  During gameplay, there's a task for checking if the game is in attract mode.
;;  We need to disable it in order for this old debug code to Work.

        PUSHORG $7C5B   ;; (Assuming symbols haven't changed)
        RPT     8,NOP
        PULLORG
        
        PUSHORG $4D3B   ;; trying to make crystal visible in scanner
        FDB     VSCRON
        PULLORG

        PUSHORG $4D40
        FCB     OSWCLen
        FCB     6               ;scanner height
        FCB     6               ;scanner width
        FCB     $FF,$FF         ;bottom flavor scanner
        FCB     $0F,$F0         ;top flavor scanner
        FCB     $0F,$F0
        PULLORG
        
;        PUSHORG $6D4A   ;; makes warrior chase after sinibombs
;        ldx     #IRWarr
;        PULLORG

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ENDIF   ;WitPop ;*************************************************

        IFNDEF  Proms   ;*************************************************
        PUSHORG ROMSAVE                                                 ;*
;       LOCAL                                                           ;*
;*      VECTOR  PowVect                                                  *
;*      lda     #$1             For development, give lots of credits    *
;*      sta     Credits                                                  *
;*      rts                                                              *
        PULLORG ROMSAVE                                                 ;*
        ENDIF   ;Proms  ;*************************************************

        IFDEF   NoDeath                                                         ;;Fixme was: IFNDEF     Demo
        PUSHORG DEATH
        rts             ;************ TURN OFF PLAYER DEATHS *************
        PULLORG
        ENDIF   ;Demo
;*
        IFDEF   Witt    ;*************************************************
        PUSHORG ROMSAVE                                                 ;*
;       LOCAL                                                           ;*
        VECTOR  IniVect         ;****** BUILD THE SINISTAR ******       ;*
        RADIX   10                                                              ;;(decimal value ahead)
        lda     #20                                                     ;*      ;;Fixme was: lda        #20
        RADIX   16                                                              ;;(back to hex)
WITT1S  jsr     AddPiece                                                ;*      ;;Fixme was: 1$
        deca                                                            ;*
        bgt     WITT1S                                                  ;*
        rts                                                             ;*
        PULLORG ROMSAVE                                                 ;*
        PUSHORG SHOOT
        rts
        PULLORG
        ENDIF   ;Witt   ;*************************************************
;*
;       LIST
;* * *  INCLVER witt.dark,work0         * SYMVER checks
;* * *  INCLVER sam.sav,symtest         * For symbol table checking

;       ENDTEST
;       END

;;===========================================================================
;;
;;     SSSS  Y   Y  N   N   AAA   M   M   AAA   X   X
;;    S       Y Y   NN  N  A   A  MM MM  A   A   X X
;;     SSS     Y    N N N  AAAAA  M M M  AAAAA    X
;;        S    Y    N  NN  A   A  M   M  A   A   X X
;;    SSSS     Y    N   N  A   A  M   M  A   A  X   X
;;
;;  This is new code that I put in for fixes and mods to make the game easier.
;;
;;===========================================================================
;;
;;   If DIAG/T13 are not assembled, then force IRQ vectors in blank ROM 11 so
;;   that the game can still boot in MAME.
;;

        IFNDEF  IRQVectors
        PUSHORG $FFF0
        FDB     RESTART,RESTART,RESTART,RESTART,IRQ,RESTART,RESTART,RESTART
        PULLORG
        ENDIF

;;===========================================================================
;;
;;  Instead of nuking the Rug ROM/RAM tests, we are going to overwrite the
;;  cross hatch test, color bar tests and switch test instead.
;;
;;  EDIT:  This is now pretty much deprecated, thanks to the new modded version
;;  of the diagnostics source file.  It's still referenced in my older mods but
;;  doing it this way involved more debugging.  Just commenting out code in a 
;;  new copy of the diganostics source file turned out to be less confusing.
;;

        IFDEF   DisableTests

        PUSHORG $F470   ;; overwrite JSR instructions for SWTEST, AVWAIT, and CRTEST with NOPs
                        ;; so we can skip them and overwrite $F71C - $F928

        RPT     9,NOP

        PULLORG


        PUSHORG $F4ED   ;;replace "BSR  BARS" with NOPs so Auto cycle doesn't execute mod code

        NOP
        NOP

        PULLORG


        PUSHORG $F4F8   ;; make TSTPAT skip color bar and cross hatch tests and go straight to booking

        JMP     BOOK

        PULLORG

;;  $F4FB - $F928 are now clear (gives us $42C of space)

        ENDIF

;;===========================================================================
;;
;;                      <<< DEPRECATED!!! DON'T USE >>>
;;
;;   To avoid triggering KenChk, we force the program to skip the rug test
;;   on start up.  This is done by by overwriting the jump addresses that
;;   start the test with NOPs.
;;
        IFDEF   EnableMods

        PUSHORG $F063
        NOP
        NOP
        PULLORG

        PUSHORG $F069
        NOP
        NOP
        PULLORG

        PUSHORG $F06B
        NOP
        PULLORG

;;   We need this if the user wants to go into the operator service menu.
;;   A checksum test is done upon entering so let's reuse the debug code
;;   from T13.ASM that allows us to fake the ROM test.

        PUSHORG ROMTAB
        FCB     $00,$0  ;0000
        FCB     $10,$0  ;1000
        FCB     $20,$0  ;2000
        FCB     $30,$0  ;3000
        FCB     $40,$0  ;4000
        FCB     $50,$0  ;5000
        FCB     $60,$0  ;6000
        FCB     $70,$0  ;7000
        FCB     $80,$0  ;8000
        FCB     $90,$0  ;9000
        FCB     $A0,$0  ;A000
        FCB     $B0,$0  ;B000
        FCB     $C0,$0  ;C000
        FCB     $D0,$0  ;D000
        FCB     $E0,$0  ;E000
        FCB     $F0,$0  ;F000
        FCB     0
        FCB     $0      ;CHECK BYTE (FUDGER) FOR THIS PART ($F000)
        PULLORG

;;===========================================================================
;;
;;                      <<< DEPRECATED!!! DON'T USE >>>
;;
;;   Let's skip the ROM and RAM tests when we hit the service button.
;;   This has the side-effect of wiping away the screen graphics then waiting
;;   forever until the service/advance button (aka F2 in MAME) is pressed again.
;;   Continue hitting the service button to get to the Game Adjustments screen.

        IFDEF   DiagnosticTestFix
        PUSHORG $F003   ;;This restores access to the diagnostic menu!
        JMP     DIAG3   ;;Instead of JMP  ADVSWS, we're skiping the deleted RAM/ROM tests and going straight to CMOS test.
;       JMP     AUTO2   ;;(Do we need to replace Auto-cycle?)
        PULLORG
        ENDIF

        ENDIF

;;===========================================================================
;;
;;   The DEFALT table in SAM/TB13.ASM defines the default values for the
;;   game adjustments in the operator service menu. Here's a section of what
;;   it looks like:
;
;       DEFALT  FCB     $30     FIRST EXTRA SHIP AT
;               FCB     $30     ADDITIONAL POINTS PER EXTRA SHIP
;               FCB     $03     SHIPS PER GAME
;               FCB     $05     DIFFICULTY OF PLAY
;               FCB     $01     CONTINUOUS FIRE
;               ...
;;
;;   Note that these are hex numbers, but are treated as decimal values.
;;   The default for "ADDITIONAL POINTS PER EXTRA SHIP" is 30.  In the menu,
;;   it's displayed as "Additional Extra Ship Point Factor" and is at 30,000.
;;
;;   Extra ships are really difficult to score in Sinistar as opposed to other
;;   Williams titles. If you know what you're doing, you can easily rack up
;;   extra lives in Robotron or Joust, but with the exponential bonus scores
;;   in Sinistar (30k, 90k, 180k, etc), it's much harder to do so.
;;
;;   Lowering this value all the way to zero treats the bonus scores
;;   in a more linear fashion: (30k, 60k, 90k, 120k, etc...).
;;
;;   In an amazing stroke of luck, we have confirmation that this value was
;;   not the original one intended.  In SAM/DEFAULT.SRC, we have an earlier
;;   version of the DEFALT table that's unused.  Let's take a look and compare:
;;
;       * * *DEFALT
;               FCB     $30     FIRST EXTRA SHIP AT
;       * * *   FCB     $05     ADDITIONAL POINTS PER EXTRA SHIP
;       * * *   FCB     $03     SHIPS PER GAME
;       * * *   FCB     $05     DIFFICULTY OF PLAY
;       * * *   FCB     $01     CONTINUOUS FIRE
;               ...
;;
;;   As you can see, additional points per extra ship is the only value
;;   that has changed and it's set to a much lover number of $05.
;;   The following code restores this number so that extra ships are
;;   easier to get.
;;
        IFDEF   ExtraShipFix

        PUSHORG DEFALT+1        ;;($493B)
        FCB     $05     ;ADDITIONAL POINTS PER EXTRA SHIP
        PULLORG

        ENDIF

;;===========================================================================

        IFDEF   DisableSinistarCollision

        PUSHORG collision+$0A  ;;Skip to COLLIDE PLAYER,SINI
;;      COLLIDE PLAYER,SINI
        rts             ;;Make the player pass through the Sinistar
        PULLORG

        ENDIF

;;===========================================================================

        IFDEF   DifficultyMod

        PUSHORG CR_7

        NOP
        FCC     "POP. FIX MOD BY SYNAMAX 10/7/23 "
        RPT     8,NOP

        PULLORG

        PUSHORG $7ae4   ;;Reduce Warrior Increase rate for First Zone
        fcb     $04
        PULLORG

        PUSHORG $7b04   ;;Reduce Warrior Increase rate for Void Zone
        fcb     $04
        PULLORG

        PUSHORG $7b24   ;;Reduce Warrior Increase rate for Worker Zone
        fcb     $04
        PULLORG

        PUSHORG $7b44   ;;Reduce Warrior Increase rate for Warrior Zone
        fcb     $04
        PULLORG

        PUSHORG $7b64   ;;Reduce Warrior Increase rate for Planetoid Zone
        fcb     $04
        PULLORG

        PUSHORG $7b15   ;;Reduce Warrior Desired Population for Worker Zone
        fcb     $00
        PULLORG

        PUSHORG $7b35   ;;Reduce Warrior Desired Population for Warrior Zone
        fcb     $03
        PULLORG

        PUSHORG $7b55   ;;Reduce Warrior Desired Population for Planetoid Zone
        fcb     $05
        PULLORG

;; Void Zone Warrior Initial Population is unmodified.



        ORG     $F35E
        FCB     $94     ;7000

        ORG     $F36E
        FCB     $61     ;F000   ;;Fixme was: $57

        ORG     $FFDF
        FCB     $9F             ;;Fixme was: $DA (Fudger byte)


        ENDIF

;;===========================================================================

        IFDEF   QuickOperatorEntry

        PUSHORG $8B0F
        FCB     MAXBNC  ;;MAXBNC = 03 (original value was $0C, then patched in BOBFIXES.ASM to $12)
        PULLORG

        ENDIF

;;===========================================================================

        IFDEF   PauseMod
;;
;;  "Enable Pause" option added to Game Adjustment screen on April 4th, 2025
;;

;;
;;   First we insert a jump while the game is scanning the joystick.
;;   We do this instead of using SPANEL because the joystick is only enabled
;;   during gameplay, otherwise the player can pause the attract mode and
;;   the game will never actually start.
;;
        PUSHORG $361A           ;;(hijack joystick scanning routine)
        JMP     PauseScan
        PULLORG

        IFNDEF  T13MODDED

;;;
;;;   If the MarqueeFix mod is enabled, let's make room for it.
;;;   Doing this will overwrite ADVSWS but will still leave enough room to
;;;   leave the CMOS test alone.
;;;
;       IFDEF   MarqueeFix
;
;       PUSHORG $F370           ;; If MarqueeFix is enabled, let's add the pause mod after it.
;       ELSE
;       PUSHORG $F09F           ;; Otherwise, if the original title screen is used, just overwrite the rug tests.
;       ENDIF

;;
;;  Instead of nuking the Rug ROM/RAM tests, we are going to overwrite the
;;  cross hatch and color bar tests instead.
;;

        PUSHORG $F476  ;;overwrite "JSR CRTEST" with NOPs so we can skip it and overwrite $F71C - $F7B8

        NOP
        NOP
        NOP

        PULLORG


        PUSHORG $F4ED   ;;replace "BSR  BARS" with NOPs so Auto cycle doesn't execute mod code

        NOP
        NOP

        PULLORG

        PUSHORG $F4F8   ;;make TSTPAT skip color bar and cross hatch tests and go straight to booking

        JMP     BOOK

        PULLORG


;;  $F4FB - $F7B7 are now clear (gives us $2BC of space)
;;
;;  We can finally start the Pause Mod code

;       PUSHORG $F4FB

        IFNDEF  SAMTAIL         ;;If Sam's Tail code is not defined, then we save at $F4FB
        PUSHORG MODSAV
        ELSE                    ;;Otherwise, we'll run out of room so let's overwrtite the code that blinks the LED.

        ORG     $F300
        RPT     3,NOP           ;;remove JMP PULSE

        ORG     $F434
        RPT     3,NOP           ;;remove JMP PULSE

        PUSHORG $F211           ;;Overwrite PULSE routine
        ENDIF ;SAMTAIL

        ELSE

        PUSHORG MODSAV
        ENDIF ;T13MODDED

;;
;;  The PauseSTART and PauseCLR routines act very similar to how the "EMPTY" text is
;;  drawn in-game.  We have enough room in MESSAV that we can actually give the
;;  "PAUSED" string a new PhrNum and reference it just like all the other phrases!
;;

PauseSTART
        TEXT    WECO,$6C        ;; Reuse the William Electronics "court check" vertical position, horizontal position $6C is dead center for "PAUSED"
        lda     #SDLOFF         ;; Load WECO ($45) into A
        ldb     #SDSOFF         ;; Load $6C into B
        tfr     D,X             ;; We have to transfer both A/B registers to X because we need B for color
        WORD    YELLOW,68,PAUSED ;; Use 6x8 font and create "PAUSED" string for MESSAV
        rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers
        FDB     _PAUSED

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PauseCLR
        TEXT    WECO,$6C        ;; We clear the text by drawing it again
        lda     #SDLOFF         ;;   but this time we use black as the color
        ldb     #SDSOFF
        tfr     D,X
        WORD    BLACK,68,PAUSED
        rts

;;
;;  Here is the actual code that pauses the game.  This code was originally
;;  written in 2008 for Joust by Chris Brooks @ Coinoplove.com.  I have rewritten
;;  it to work with Sinistar and use the modified "EMPTY" text routines above to
;;  display the new string.
;;

PauseScan
        PSHS    D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        pshs    X
        ldx     #SPECFN+9       ;; Enable Pause Adjust
        jsr     RCmosA          ;* Read from CMOS
        puls    X

        TSTA                    ;; Check if Pause is enabled or not
        BEQ     PauseExit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        LDA     PIA3
        ANDA    #$10
        BEQ     PauseExit
        ORCC    #$10
        JSR     PauseDelay      ;;go to delay subroutine
.1S     JSR     .4S             ;;feed watchdog
        LDA     PIA3            ;;did player hit P1 button?
        ANDA    #$10
        BNE     .1S             ;;no? then go feed watchdog again
        JSR     PauseSTART      ;;yes? draw "PAUSED" text
.3S     JSR     .4S             ;;feed watchdog
        LDA     PIA3
        ANDA    #$10
        BEQ     .3S
        JSR     PauseDelay
.2S     JSR     .4S
        LDA     PIA3
        ANDA    #$10
        BNE     .2S
        JSR     PauseCLR        ;;player wants to resume play, let's go clear the "PAUSED" text
        JMP     PauseExit
.4S     LDB     #$39            ;;Watchdog food
        STB     WDOG            ;;Watchdog
        RTS

PauseDelay
        LDD     #$0200          ;;let's waste some CPU cycles so we give the player time to react
.1S     DECB
        BNE     .1S
        DECA
        BNE     .1S
        RTS                     ;;let's go feed the watchdog

PauseExit PULS    D             ;;grab D from stack
        ANDCC   #$EF
        LDA     PIA+4           ;read joystick pia (restore trashed instruction from $361A)
        JMP     $361D           ;;go back to Game Logic

        IFNDEF  T13MODDED

        IFNDEF  SAMTAIL
        PULLORG MODSAV          ;;Reuse MODSAV for more mods
        ELSE
        PULLORG                 ;;Otherwise, let's finish up overwriting PULSE routine.
        ENDIF

        ELSE
        PULLORG MODSAV
        ENDIF
;;
;;  Checksum fixes
;;


        ORG     $F356
        FCB     $3B     ;3000   ;;Fixme was: $33

        ORG     $F36C
        FCB     $70     ;E000   ;;Fixme was: $F8

        ORG     $F36E
        FCB     $0E     ;F000   ;;Fixme was: $57

        ORG     $FFDF
        FCB     $F3             ;;Fixme was: $DA (Fudger byte)


        ENDIF

;;===========================================================================

        IFDEF   SAMTAIL

;       INCLUDE START
;       INCLVER SAM,SINISTAR.EQU
;       INCLVER SAM,PLSUNIT

        PUSHORG SRAMSAV
TAILDAT RMB     $140            ;tail random data               ;;Fixme was: TAILDAT    RMB     140
        PULLORG SRAMSAV

        PUSHORG BASSAVE                                         ;;Fixme was: PUSHORG    BASSAV
TAILL   RMB     1       ;\      ;tail l screen position
TAILS   RMB     1       ;/      ;tail s screen position
TAILDMA RMB     1               ;tail flavor
PLDRWVE RMB     2               ;player erase-update-draw vector
        PULLORG BASSAVE                                         ;;Fixme was: PULLORG    BASSAV

        PUSHORG RAMSAV
TAILBUF RMB     3*5             ;tail data buffer
        PULLORG RAMSAV

        PUSHORG MODSAV                                          ;;Fixme was: PUSHORG    ROMSAVE (We want to overwrite cross hatch test)

;* erase tail on player ship
ETAIL   LDX     OIDESC,Y
        LDD     #$305!$404      ;* * * FOR DMA BUG              ;;Fixme was: LDD  #305!X404
        STD     DHIGH
        LDD     TAILL
        STD     DDEST
        LDD     #TAILBUF
        STD     DSOUR
        LDA     TAILDMA
        ORA     #DCNS
        STA     DCTRL
        JMP     [PLDRWVE]

;* change image of tail on player ship
CTAIL   LDD     #ETAIL
        STD     ODRWVEC,Y
        LDD     #DOBJECT
        STD     PLDRWVE
        LDD     #TAIL
        STD     OPDRWVE,Y

;* draw tail in player ship
TAIL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  To re-enable the TAIL effect in attract mode, we have to skip the 
;;  "LBEQ NOPOST" instruction...however this forces the TAIL effect to be on
;;  all the time during gameplay, which doesn't look as good.
;;
;;  To fix this, a new IFDEF has been added.
;;  We check if we're in attract mode and if so, we skip the branch to NOPOST.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        IFDEF   AttractTAIL

        tst     AMDemo          ;;If we're NOT in attract mode (AM = 0),
        bne     AMTAIL          ;;  then go to TAIL for attract mode
        
GAMETAIL
        LDB     PLACCEL         ;; get player acceleration
        LBEQ    NOPOST          ;; Turn off TAIL when there is no acceleration
        ASLB
        BRA     BRATAIL         ;; go back to the original code
        
AMTAIL
        LDB     PLACCEL
        ASLB

BRATAIL SET     *               ;; set up a marker for the OG code

        ELSE

        LDB     PLACCEL
        LBEQ    NOPOST
        ASLB
        
        ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        CLRA
        ADDD    #TAILDAT
        TFR     D,U
        FRANDOM OSEED1,BYTE
        ANDA    #$3F                                            ;;Fixme was: ANDA  #3F
        LEAU    A,U
        STU     DSOUR
        LDD     #TAILBUF
        STD     DDEST
        LDD     #$305!$404      ;* * * FOR DMA BUG              ;;Fixme was: LDD  #305!X404
        STD     DHIGH
        LDA     PMEMCTL
        PSHS    A
        ANDA    #~$4                                            ;;Fixme was: ANDA #!N4
        STA     PMEMCTL
        STA     MEMCTL
        CLR     DCTRL
        LDD     #IDSBOMB
        STD     DSOUR
        LDA     #DXWT+DXWB+DCNS+DZSP
        STA     DCTRL
;*<<< optimize this >>>
        PULS    A
        STA     PMEMCTL
        STA     MEMCTL
        LDD     #TAILBUF
        STD     DSOUR
        LDB     OIDESC+1,Y
        SUBB    #IPLAYER&$FF                                    ;;Fixme was: SUBB  #IPLAYER!.$FF
        LSRB
        LSRB
        LDX     #TAILTBL
        ABX
        LDA     1,X
        ADDA    OLEFT,Y
        STA     DDEST+1
        STA     TAILS
        LDA     X
        CLRB
        ASRA
        RORB
        ADDD    OLPOS,Y
        STA     DDEST
        STA     TAILL
        LDA     #DZSP+DSCY+DWBL
        BCS     .1S                                             ;;Fixme was: BCS  1$
        ORA     #DTFL
.1S     STA     DCTRL                                           ;;Fixme was: 1$
        STA     TAILDMA
        JMP     NOPOST

;       LOCAL
;* initialize random tail data
        VECTOR  SYSVECT
        LDX     #TAILDAT
        CLRA
        LDB     #$C0                                            ;;Fixme was: LDB        #0C0
        JSR     INITRAM
        JSR     INITRAM
        LDX     #PALETTE
        CLR     TEMP
TAIL1   LDA     X                                               ;;Fixme was: 1$
        BEQ     TAIL2
        BITA    #$C0                                            ;;Fixme was: BITA       #0C0
        BEQ     TAIL6
        BITA    #$30                                            ;;Fixme was: BITA       #30
        BNE     TAIL2
TAIL6   LDA     #$40                                            ;;Fixme was: 6$ LDA     #40
        STA     TEMP+1
TAIL5   RANDOM  OSEED1,BYTE                                     ;;Fixme was: 5$
        ANDA    #$3F                                            ;;Fixme was: ANDA  #3F
        JSR     SINCOS
        ;;;;;;;;;;;;;;;;;;;
        LDB     #$39                                            ;; We forgot to feed the watchdog!
        STB     WDOG                                            ;; Adding this here should fix it
        ;;;;;;;;;;;;;;;;;;;
        CLRB
        JSR     ASRD6
        PSHS    D
        RANDOM  OSEED2,BYTE
        TFR     A,B
        ANDB    #$7F                                            ;;Fixme was: ANDB       #7F
        CLRA
        ADDD    S++
        LSRA
        RORB
        LDU     #TAILDAT
        LEAU    D,U
        LDA     U
        BCS     TAIL3
        ANDA    #$0F                                            ;;Fixme was: ANDA       #0F
        STA     TEMP+2
        LDA     TEMP
        RPT     4,ASLA
        ORA     TEMP+2
        BRA     TAIL4
TAIL3   ANDA    #$F0                                            ;;Fixme was: 3$ ANDA    #0F0
        ORA     TEMP
TAIL4   STA     U                                               ;;Fixme was: 4$
        DEC     TEMP+1
        BNE     TAIL5
TAIL2   INC     TEMP                                            ;;Fixme was: 2$
        LEAX    1,X
        CMPX    #PALETTE+$10                                    ;;Fixme was: CMPX  #PALETTE+10
        BLO     TAIL1
        RTS

        VECTOR  INIVECT
        CLRD
        STD     TAILL           ;zero tail screen position
;*<<< add to player initialization >>>
        LDD     #DOBJECT        ;initialize player erase-update-draw vector
        STD     PLDRWVE
        LDD     #ETAIL          ;give player erase tail erase-update-draw vector
        STD     ODRWVEC+WPLAYER
        LDD     #TAIL           ;give player tail post-draw vector
        STD     OPDRWVE+WPLAYER
        RTS

;;
;;  We're very lucky to have the original addresses here
;;  match up with the earlier AMOA '82 build.  This helped
;;  me figure out where the instructions were located in
;;  the final build.  This patch was off by one byte, but
;;  the other patch was way off.
;;
;;  Old patch addresses:
;;      $3789
;;      $6F51
;;
;;  New patch addresses:
;;      $378A
;;      $736D
;;

;* patch to player image rotation
;       ERR     OLD ADDRESS
        PUSHORG $378A                                           ;;Fixme was: PUSHORG    $3789
        JSR     TA100S                                          ;;Fixme was: JSR        100$
        PULLORG
TA100S                                                          ;;Fixme was: 100$
;* * *
        STX     PLDRWVE
        LDD     #CTAIL          ;give player change tail post-draw vector
        STD     OPDRWVE,Y
;* * *
        RTS

;* tail offset table
TAILTBL FDB     $FC02,$FC02,$FD01,$FDFF,$FFFE,$FFFD,$00FD,$FFFD
        FDB     $02FB,$02FD,$05FD,$05FD,$07FE,$08FF,$0900,$0A01
        FDB     $0A03,$0A02,$0905,$0905,$0707,$0509,$040A,$020A
        FDB     $020A,$020A,$010A,$0009,$FF08,$FD05,$FD05,$FC02

;*<<< for Noah >>>
;       ERR     OLD ADDRESS
        PUSHORG $736D                                           ;;Fixme was: PUSHORG    $6F51
        JSR     TA101S                                          ;;Fixme was: JSR        101$
        PULLORG
TA101S                                                          ;;Fixme was: 101$
;* * *
        LDD     #NOPOST         ;turn off player's tail
        STD     OPDRWVE,X
;* * *
        ;;;;;;;;;;;;;;;;;;;                                     ;; New code so SAMTAIL can be
        IFNDEF  PLXQUE                                          ;; built without RJ's module
        RPT     3,NOP
        RTS
        ELSE
        ;;;;;;;;;;;;;;;;;;;
        JSR     PLXQUE                  ;* START UP PLAYER EXPLOSION
        RTS
        ;;;;;;;;;;;;;;;;;;;
        ENDIF
        ;;;;;;;;;;;;;;;;;;;

        PULLORG MODSAV                                          ;;Fixme was: PULLORG ROMSAVE

        ENDIF


        IFDEF   WittBombs

;;
;;  The following code was originally included with this:
;;
;        Routine Witt1
;        lda     #$FF
;        sta     PANMASK
;        puls    Y
;        jmp     DIE

;;
;;  This routine by Rich Witt enables all buttons
;;  (including P2 button and unused PANMASK bits) during gameplay.
;;
;;  However, this is bad as enabling Player 1 button will allow
;;  the player to unintentionally restart the game.
;;
;;  I made a patch to fix this but the best solution is to
;;  just change the PANMASK value to exclude P1 but allow P2.

        PUSHORG Witt1
        lda     #$2F
        PULLORG

;;  Patch to fix game restart <<< DEPRECATED >>>
;;
;;  Because Rich's code enables Player 1 during gameplay, it can restart
;;  the game if the player presses it during gameplay.  To fix this, we
;;  need to go into the Player 1 start button routine.

;        PUSHORG $2F17
;        JMP     FixP1Button
;        PULLORG

;        PUSHORG MODSAV
;FixP1Button
;        LDA     CREDIT          ;yes, get number of credits
;        BNE     .1S             ;not enough credits?
;        RTS                     ;yes, pay buddy!
;.1S     TST     AMDEMO          ;; check if we're actually in gameplay.
;        BNE     .2S
;        RTS                     ;; we are?!  get outta here!
;.2S     clr     AMDemo          ;* Turn off attract mode demo
;        JMP     StartDemo
;        PULLORG MODSAV


        IFNDEF  BargraphEnable
        PUSHORG MODSAV
        ELSE
        PUSHORG GrafxSAV
        ENDIF

;;==============================================================================

;;
;;  Now, let's define our words and store them here instead of MESSAV.
;;  We'll still need to use PHRSAV for now.
;;
;;  (3/15/25): I'm adding some IFNDEFs here for WittBombs.  The Star Trek
;;  easter egg messes up the numbering of PHRNUM so if WittBuild is defined,
;;  the code is not included.  This is fine since the message is immediately
;;  drawn over with "DEVELOPMENT PIECE ADDED".  This also gives us the added
;;  benefit of having some more space for MODSAV and PHRSAV.
;;
;;
        CODEPAGE WILLIASCII     ;Turn on Williams Character Set Table

        IFNDEF  WittBuild

_CAPTAIN FCC     "CAPTAIN"
        FCB     $8A

_OUR    FCC     "OUR"
        FCB     $8A

_BOMB   FCC     "BOMB"
        FCB     $8A

_BAY    FCC     "BAY"
        FCB     $8A

;;_IS is already defined!

_FULL   FCC     "FULL"
        FCB     $8A

        ENDIF

_DEVELOPMENT FCC "DEVELOPMENT"
        FCB     $8A

        IFDEF   WittBuild

_PIECE  FCC     "PIECE"
        FCB     $8A

_ADDED  FCC     "ADDED"         ;; The ordering of words must match how they were entered
        FCB     $8A

_BOMBS  FCC     "BOMBS"         ;; We need this extra BOMBS string! 
        FCB     $8A

        ELSE

_BOMBS  FCC     "BOMBS"
        FCB     $8A

_ADDED  FCC     "ADDED"         ;; The ordering of words must match how they were entered
        FCB     $8A


        ENDIF



        CHARSET                 ;Going back to regular ASCII

        IFNDEF  BargraphEnable
        PULLORG MODSAV
        ELSE
        PULLORG GrafxSAV
        ENDIF

;; Phrase pointers go here (thank goodness we have enough space for these in ROM 10)

        PUSHORG PHRSAV

        IFNDEF  WittBuild

        FDB     _CAPTAIN
        FDB     _OUR
        FDB     _BOMB
        FDB     _BAY
        FDB     _FULL

        ENDIF

        FDB     _DEVELOPMENT

        IFDEF   WittBuild

        FDB     _PIECE
        FDB     _ADDED
        FDB     _BOMBS

        ELSE

        FDB     _BOMBS
        FDB     _ADDED
        
        ENDIF

        PULLORG PHRSAV

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Now we can finally proceed with Rich's retargeted code.
;;

        IFNDEF  BargraphEnable
        PUSHORG MODSAV
        ELSE
        PUSHORG GrafxSAV
        ENDIF

        BSWITCH  START2,CLOSE    ;* Fake out pickup                     ;*      ;;Fixme was: SWITCH  START2,CLOSE
        LDA     BOMBS           ;get sinibomb count                     ;*
        INCA                    ;add one                                ;*
        cmpa    #MAXBOMBS       ;* If too many bombs are being held     ;*
        ble     WITDBG1         ;*   then the crystal cannot be picked  ;*

;;
;;  I'm actually really glad I put a new IFNDEF here, as I had unintentionally
;;  fixed a bug that was bothering me.
;;
;;  Originally, this easter egge message was preventing the "CLANG" sound from
;;  playing when WittBuild is enabled and I never really cared for that.  Had
;;  no idea isolating this block of code would fix the issue!
;;
;;  The message sound (QMesg) that overrides the intended sound effect doesn't
;;  sound great in this specific scenario.  You want to hear the clang if a
;;  Sinistar piece is being added, it's a pretty important audio cue.  The
;;  clang's duration and priority also line up with the button presses much
;;  better than the message jingle.  It feels more responsive as a result!
;;

        IFNDEF  WittBuild

        DISPLAY BLUE                                                    ;*      ;;Fixme was: DISPLAY
        PHRASE  BLUE,35,CAPTAIN,OUR                                     ;*
        PHRASE  BLUE,35,BOMB,BAY,IS,FULL                                ;*

        ENDIF

        IFDEF   WittBuild

        jsr     addpart                                                 ;*      ;; Add a Sinistar piece when bombs are full!
        DISPLAY WHITE                                                   ;*      ;;Fixme was: DISPLAY
        PHRASE  WHITE,35,DEVELOPMENT                                    ;*
        PHRASE  WHITE,35,PIECE,ADDED                                    ;*

        ENDIF

        rts                                                             ;*
WITDBG1 STA     BOMBS           ;save new sinibomb count                 *      ;;Fixme was: 1$
        LDB     #DWBL           ;get dma constant to write sbomb display *
        JSR     UPBOMBS         ;update sinibomb display, save Y, uses A *
        DISPLAY TANGREY                                                 ;*      ;;Fixme was: DISPLAY
        PHRASE  TANGREY,35,DEVELOPMENT                                  ;*
        PHRASE  TANGREY,35,BOMBS,ADDED                                  ;*
        rts                                                             ;*

        IFNDEF  BargraphEnable
        PULLORG MODSAV                                                  ;*      ;;Fixme was: PULLORG ROMSAVE
        ELSE
        PULLORG GrafxSAV
        ENDIF

        ENDIF   ;Debug          ;*****************************************

        IFDEF   WarriorBug

        PUSHORG $6D4A
        LDX     #CWARRIOR
        PULLORG
        
        PUSHORG $6D3A   ; don't decrease sinibomb count
        NOP
        NOP
        NOP
        PULLORG

        ENDIF




        IFDEF   RapidFireRate2x

        PUSHORG $6CC3
        FCB     $04
        PULLORG

        ENDIF

        IFDEF   SkipStatusPage

        PUSHORG STATPG
        JMP     STATPG+6
        PULLORG

        ENDIF


        IFDEF   WarriorBugv2

        PUSHORG PlShoot

        JMP     WarriorBug2

        PULLORG

        PUSHORG MODSAV

WarriorBug2
        
        pshs    A,B,X,Y         ;* Save work registers

.11S    TUNE    QFire          ;* Make the sound of a released sinibomb.
        LDA     SFREE           ;are there any screen workspaces available?
        BEQ     .1S
        ldd     #0700           ;* D = Scanner position for object.
        ldx     #CWarrior       ;* X -> Char. Desc. for sinibomb
        jsr     [OInVec,X]      ;* Create sinibomb, X -> scanner workspace

        lda     PlyrAng         ;* Determine the SHORT velocity based
        jsr     sincos          ;* A = the sine, B = the cosine of the angle.
        pshs    A,B             ;* Save them.
;*
        puls    B               ;* The SHORT velocity of
        sex                     ;*   the bomb is proportional
        RPT     3,aslb,rola   ;*   to the sine of the shot angle
        addd    OSVEL+WPlayer   ;*   and the player velocity.
        ldx     OSSCWSA,Y       ;* X -> sinibomb object workspace
        std     OSVEL,X         ;* Set the velocity.

        puls    B               ;* The LONG velocity of
        sex                     ;*   the bomb is proportional
        RPT     4,aslb,rola     ;*   to the cosine of the shot angle
        addd    OLVEL+WPlayer   ;*   and the player velocity.
        std     OLVEL,X         ;* Set the velocity.
        puls    A,B,X,Y         ;* Restore work registers
.1S     RTS
        
        PULLORG MODSAV

        ENDIF

;        PUSHORG $7DA1
;        
;        lda     #$0
;        JMP     $7DA7
;        
;        PULLORG
;        
;        PUSHORG $7DAD
;        
;        lda     #$0
;        JMP     $7DB3
;        
;        PULLORG

;; Skips Sinistar explosion from inside RJ's module

        IFDEF   SkipSiniExplode

        PUSHORG $7F5A
        JMP     $7F8A
        PULLORG

        ENDIF

;; Skips Sinistar explosion from inside Rich's module (MICA module not included)

        IFDEF   SkipKaBoom

        PUSHORG $58D7
        JSR     KRSini
        PULLORG

        ENDIF

;; Restores the original player death behavior from AMOA

        IFDEF   AMOADeath

        PUSHORG $5603
        LBEQ    DEATH
        PULLORG

        ENDIF

;; Skips drawing Starfield background

        IFDEF   SkipStars

        PUSHORG $E048
        JMP     $E0DD
        PULLORG

        ENDIF

        IFDEF   TrippyBG

        PUSHORG $E02D
        DEC     PCRAM           ;; update background with random color
        PULLORG

        ENDIF

;; Skips scanner scrolling so no objects are placed on-screen

        IFDEF   NoScanner

        PUSHORG SCROLSC
        rts
        PULLORG

        ENDIF

;; Skips drawing HUD items

        IFDEF   NoHUD

        PUSHORG PLAY1S
        JMP     $3117           ;; skip "Bonus At" string
        PULLORG

        PUSHORG UPBONUS
        rts                     ;; skip Bonus Points
        PULLORG

        PUSHORG UPSHIPS
        rts                     ;; skip flashing ship icons
        PULLORG

        PUSHORG UPSCORE
        rts                     ;; skip updating score
        PULLORG

        PUSHORG UPBOMBS         ;; skip updating bomb count
        rts
        PULLORG

        PUSHORG EMPTY           ;; skip "EMPTY" message
        rts
        PULLORG

;; Hide Scanner ("fins", frame surrounding the scanner and DrawScan routine)

        PUSHORG FIN
        rts
        PULLORG

        PUSHORG FRAME
        rts
        PULLORG

        PUSHORG DRWSCAN
        rts
        PULLORG

        ENDIF

;; In the AMOA build, TAIL is always on because PLACCEL is never cleared.
;; This was fixed in the final build, but doing this broke the TAIL effect in
;; attract mode.  To make TAIL behave as before, we skip the "LBEQ    NOPOST"
;; at the beginning of the routine.

        IFDEF   AMOATAIL

        IFDEF   TAIL            ;; Check if TAIL exists
        PUSHORG TAIL+2
        NOP
        NOP
        NOP
        NOP
        PULLORG
        ENDIF

        ENDIF


;;
;;  2/15/25 - New Mod that "slightly" reduces difficulty, in order to create
;;  a version of the game with an average playtime of 3 minutes.
;;

        IFDEF   DifficultyModV2
        
ExtraShipFix    EQU     1

        PUSHORG InPop0

;*              InPop0 - Initial population for first wave only

        RADIX   10                                                      ;;Need this for the decimal values

;InPop0
        fcb     0,6,0           ;* Workers
        fcb     0,0,0           ;* Warriors
        fcb     0,10,0          ;* Type 1 planets                       ;;Fixme was: fcb  0,10.,0
        fcb     0,2,0           ;* Type 2 planets
        fcb     0,2,0           ;* Type 3 planets
        fcb     0,2,0           ;* Type 4 planets
        fcb     0,2,0           ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0,0,0           ;* SiniBombs
        fcb     0,0,0           ;* Crystals
        fcb     0,1,0           ;* SiniStar
        fcb     0,1,0           ;* Player

;IP0End  rmb     0               ;* Marks end of table
;*
;*
;*              Difficulty increase figures for this population
;*
;InDif0
        fdb     DTime
        fcb     6
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     8                                                       ;;Fixme was: fcb  10
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     -8
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0

;ID0End  rmb     0               ;* Marks end of diff. table

;*              InPop1 - Void Zone

;InPop1
        fcb     6               ;* Workers
        fcb     8               ;* Warriors
        fcb     1               ;* Type 1 planets
        fcb     1               ;* Type 2 planets
        fcb     1               ;* Type 3 planets
        fcb     1               ;* Type 4 planets
        fcb     3               ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0               ;* SiniBombs
        fcb     0               ;* Crystals
        fcb     1               ;* SiniStar
        fcb     1               ;* Player
;*
;*
;*              Difficulty increase figures for this population
;*
        fdb     DTime
        fcb     6
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     -1
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     -1
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0

;ID1End  rmb     0               ;* Marks end of diff. table

;*              InPop2 - Worker Zone

;InPop2
        fcb     $10             ;* Workers                              ;;Fixme was: fcb  10
        fcb     1               ;* Warriors
        fcb     10              ;* Type 1 planets                       ;;Fixme was: fcb  10.
        fcb     2               ;* Type 2 planets
        fcb     2               ;* Type 3 planets
        fcb     2               ;* Type 4 planets
        fcb     2               ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0               ;* SiniBombs
        fcb     0               ;* Crystals
        fcb     1               ;* SiniStar
        fcb     1               ;* Player
;*
;*
;*              Difficulty increase figures for this population
;*
        fdb     DTime
        fcb     10                                                      ;;Fixme was: fcb  10.
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     8                                                       ;;Fixme was: fcb  10
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     -8
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0

;*              InPop3 - Warrior Zone

;InPop3
        fcb     4               ;* Workers
        fcb     5               ;* Warriors                             ;;Fixme was: fcb  10.
        fcb     10              ;* Type 1 planets                       ;;Fixme was: fcb  10.
        fcb     2               ;* Type 2 planets
        fcb     2               ;* Type 3 planets
        fcb     2               ;* Type 4 planets
        fcb     2               ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0               ;* SiniBombs
        fcb     0               ;* Crystals
        fcb     1               ;* SiniStar
        fcb     1               ;* Player
;*
;*
;*              Difficulty increase figures for this population
;*
        fdb     DTime
        fcb     4
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     8                                                       ;;Fixme was: fcb  10
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     -8
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0

;*              InPop4 - Planetoid Zone

;InPop4
        fcb     6               ;* Workers
        fcb     8               ;* Warriors
        fcb     $10             ;* Type 1 planets                       ;;Fixme was: fcb  10
        fcb     2               ;* Type 2 planets
        fcb     $10             ;* Type 3 planets                       ;;Fixme was: fcb  10
        fcb     2               ;* Type 4 planets
        fcb     5               ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0               ;* SiniBombs
        fcb     0               ;* Crystals
        fcb     1               ;* SiniStar
        fcb     1               ;* Player
;*
;*
;*              Difficulty increase figures for this population
;*
        fdb     DTime
        fcb     6
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     10                                                      ;;Fixme was: fcb  10.
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0



;*
;*              DEMO Population figures
;*

;InPopD
        fcb     0,2,0           ;* Workers
        fcb     0,0,0           ;* Warriors
        fcb     0,4,0           ;* Type 1 planets
        fcb     0,4,0           ;* Type 2 planets
        fcb     0,4,0           ;* Type 3 planets
        fcb     0,4,0           ;* Type 4 planets
        fcb     0,5,0           ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0,0,0           ;* SiniBombs
        fcb     0,0,0           ;* Crystals
        fcb     0,1,0           ;* SiniStar
        fcb     0,1,0           ;* Player
;*
;*
;*              Difficulty increase figures for this population
;*
        fdb     DTime
        fcb     6
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     1
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     1
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     1
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0

        RADIX   16                                                      ;;Switching back to hex

        ENDIF


        IFDEF   EarlySinistarChomp
        
;;
;;  This disables speech and forces the Sinistar to constantly chomp as seen in
;;  "The Innovators" AMOA '82 video, which contains the earliest footage known
;;  of Sinistar.
;;
;;  To do: add this to MODSAV
;;

;        PUSHORG $5350
;        JMP     $FFE0
;        PULLORG
        
        PUSHORG $FFE0           ;; This should be MODSAV
        LDD     #DZSP           ;setup for drawing without collision table
;***
;* The mouth draw was removed when the speech synchronization was added.
;*
        JSR     MODSINI         ;draw mouth
;***
        JMP     $5353
        PULLORG

        PUSHORG $53AA
        fdb     rts             ;* Dummy table entry
        fdb     rts             ;* SPEAK 1 - SC1
        fdb     rts             ;* SPEAK 2 - SC2
        fdb     rts             ;* SPEAK 3 - SC3
        fdb     rts             ;* SPEAK 4 - SC4
        fdb     rts             ;* SPEAK 5 - SC5
        fdb     rts             ;* SPEAK 6 - SC6
        fdb     rts             ;* SPEAK 7 - SC7
        fdb     rts             ;* SPEAK 8 - SC8 - Roar!
        fdb     rts             ;* SPEAK 9 - SC9 - Roar and leave mouth open!
        fdb     rts             ;* SPEAK DIESC - Shut up Sinistar.
        fdb     rts             ;* SPEAK 11 - Status page "Beware, I Live!"
        PULLORG

        ENDIF

        IFDEF   EarlyHUD

;;
;;  This is based off of the HUD seen in an early promotional photo.
;;  Score number has been repositioned lower and is BLUEGREY in color.
;;  Turns off all other HUD displays
;;

;        PUSHORG PLAY1S
;        JMP     $3117           ;; skip "Bonus At" string (DOESN'T WORK! MESSES UP SCORE DRAWING)
;        PULLORG

        PUSHORG $3108
        LDB     #BLACK          ;; Make "BONUS AT" text black (much better!)
        PULLORG

        PUSHORG UPBONUS
        rts                     ;; skip Bonus Points
        PULLORG

        PUSHORG UPSHIPS
        ;rts                     ;; skip flashing ship icons
        PULLORG
        
        PUSHORG $3C19
        LDA     #$77            ;; L axis for ship icons (originally #$7D)
        PULLORG

        PUSHORG UPBOMBS         ;; skip updating bomb count
        ;rts
        PULLORG

        PUSHORG $3C26
        LDB     #$82            ;; l axis for bombs (originally #$89)
        PULLORG

        PUSHORG EMPTY           ;; skip "EMPTY" message
        rts
        PULLORG

        PUSHORG NOTEMPTY        ;; skip drawing black "EMPTY" message
        rts
        PULLORG

        PUSHORG tdispe
        rts
        PULLORG

        PUSHORG dispe
        rts
        PULLORG

        PUSHORG $E20C           ;; Stop drawing text (Score and GAME OVER will still work)
        rts
        PULLORG

        PUSHORG $5E53           ;; Move first line of HUD's MESSAGE DISPLAY up to top (originally #$7A00)
        ldx     #$8F00
        PULLORG

        PUSHORG $5E6A
        ldx     #$8B00          ;; Move second line of HUD'S MESSAGE DISPLAY to the top (originally #$7600)
        PULLORG

        PUSHORG $3C83
        LDD     #$7C03          ;; Screen position for score (originally $8503)
        PULLORG

;        PUSHORG $2F27
;        fcb     $00             ;; OFFSET FOR ALL HUD ELEMENTS
;        PULLORG

        PUSHORG $3CD2
        fcb     $66             ;; change score font color to BLUEGREY
        PULLORG

	PUSHORG	VRLOAD+2
	nop			;* Eliminate overload flash
	nop			;*   by avoiding PCRAM store.
	PULLORG

        ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        IFDEF   ShieldMod

;;  Programming started on March 11th, 2025.
;;  HUD added on March 12th.
;;  Sounds on March 13/14th.
;;  Final strings on March 15th.
;;  Finished on March 20th.
;;
;;  Blitter bug fixed on April 20th by Sean Riddle.
;;
;;  Brad found a blitter issue with the graphics and Sean found what was
;;  causing it.  Turns out you can't clear the blitter constant immediately
;;  after a blit, so the code flow was changed slightly to let some
;;  instructions go first after blitting, then we clear DCONS.
;;
;;
;;
;; This allows the player to be hit two extra times before exploding.
;; Here's some interesting things I discovered after working on this mod.
;;
;; - $A1E1 to $A224 is free RAM space!
;;
;; - Palette color 8 is rarely used (This means we can add a new color!!)
;;
;; - DMA needs the address to the image data in order to properly draw.
;;   You can't just feed it the raw data.
;;
;; - I have a much better understanding of what the DMA inhibit code does.
;;   It's used so that sprites and the starfield aren't displayed in the HUD.
;;
;; - DCNS ("dma constant substitution") stores a color that the DMA uses
;;   for drawing over sprites (i.e. erasing).  It's normally zero so that
;;   it draws over everything with black.  So "DCNS+DWBL" means we're 
;;   enabling the constant color and writing it to the DMA.  Before we
;;   send the status byte over to DCTRL so the DMA can start drawing,
;;   we tell DCONS what color we want to substitute.  Remember to clear
;;   DCONS after the DMA is finished drawing so that it goes back to black.

;;
;;  To start off, let's add a patch to the Player/Warrior Shot collision.
;;

;* shoot player
;	COLLIDE	PLAYER,WASHOT	* Player death
;	tst	InWarp		* During the warp,
;	lbne	rts		*   player collisions are off!
;	leax	Y		* Kill off
;	jsr	killobj		*   warrior shot.
        PUSHORG $56FA           ;; Overwrite JSR DEATH
        JMP     ShipShield      ;; jump to MODSAV
        PULLORG

;;
;;  Now we add a patch to ADDBOMBS so that any extra crystals can
;;  regenerate SiniShield.
;;


        PUSHORG $568D       ;;($5680)
        JMP     ShipShield3     ;; Overwrite "TUNE  QFulCr"
        PULLORG

;;
;;  We're in MODSAV territory now
;;

        PUSHORG MODSAV


;;==============================================================================
;;
;;  Not sure why, but we need to copy this over here in order for new strings
;;  to convert correctly to Williams codepage.
;;

        CODEPAGE WILLIASCII             ;; This will make it easier to add more
        CHARSET '0',$00                 ;; phrase strings to the game
        CHARSET '1',$01
        CHARSET '2',$02
        CHARSET '3',$03
        CHARSET '4',$04
        CHARSET '5',$05
        CHARSET '6',$06
        CHARSET '7',$07
        CHARSET '8',$08
        CHARSET '9',$09
        CHARSET '\32',$0A       ;;Space
        CHARSET 'A',$0B
        CHARSET 'B',$0C
        CHARSET 'C',$0D
        CHARSET 'D',$0E
        CHARSET 'E',$0F
        CHARSET 'F',$10
        CHARSET 'G',$11
        CHARSET 'H',$12
        CHARSET 'I',$13
        CHARSET 'J',$14
        CHARSET 'K',$15
        CHARSET 'L',$16
        CHARSET 'M',$17
        CHARSET 'N',$18
        CHARSET 'O',$19
        CHARSET 'P',$1A
        CHARSET 'Q',$1B
        CHARSET 'R',$1C
        CHARSET 'S',$1D
        CHARSET 'T',$1E
        CHARSET 'U',$1F
        CHARSET 'V',$20
        CHARSET 'W',$21
        CHARSET 'X',$22
        CHARSET 'Y',$23
        CHARSET 'Z',$24
;       CHARSET 'CBARRW'        EQU     $25
;       CHARSET 'CEQU'  EQU     $26
        CHARSET '-',$27
;       CHARSET 'CQUE'  EQU     $28
        CHARSET '!',$29
        CHARSET '(',$2A
        CHARSET ')',$2B
        CHARSET '\H',$2C        ;;Apostrophe
        CHARSET ',',$2D
        CHARSET '.',$2E

;;==============================================================================

;;
;;  Now, let's define our words and store them here instead of MESSAV & PHRSAV.
;;
        CODEPAGE WILLIASCII     ;Turn on Williams Character Set Table

_SHIELD
        FCC     "SHIELD"
        FCB     $8A

;_BEEN   FCC     "BEEN"
;        FCB     $8A
;
;_ZAPPED FCC     "ZAPPED!"
;        FCB     $8A

_ANNIHILATED
        FCC     "ANNIHILATED"
        FCB     $8A

_WHOA   
        FCB     $0A             ;; Extra space for centering text
        FCB     $0A
        FCB     $0A
        FCC     "WOW!"
        FCB     $8A

_RESTORED
        FCC     "RESTORED"
        FCB     $8A

        CHARSET                 ;Going back to regular ASCII

        PULLORG MODSAV

;; Phrase pointers go here (thank goodness we have enough space for these in ROM 10)

        PUSHORG PHRSAV

        FDB     _SHIELD 
        FDB     _ANNIHILATED
        FDB     _WHOA
        FDB     _RESTORED

        PULLORG PHRSAV

;;
;;  Secret message check goes in DEATH
;;

;        PUSHORG DEATH
;        JMP     ScoreCheck
;        PULLORG
;
;;
;;  We're back in MODSAV again
;;

        PUSHORG MODSAV

;ScoreCheck
;        LDA     #$1F            ;; check if player scored 200,000 points yet
;        SUBA    PSCORE+1        ;;($9FFE)
;        bpl     .1S
;        STA     $A224           ;; update flag with large number (0 = no message)
;
;.1S     LDA     AMDEMO          ;in attract mode demo?
;        LBEQ    Mortal          ;; restore trashed instructions for DEATH
;        lbra    $5836           ;; back to normal routine


;;
;;  Now, this is really cool.  At first glance, it appears that palette color 8
;;  appears to be unused!  I verified this by modifying this same code to draw
;;  a color palette on screen during gameplay.
;;
;;  In previous experiments, I messed around with the bg color and was able to
;;  make this Defender-like trippy color cycle effect with just one instruction.
;;  We plug this into EXEVECT and decrement the value in color #8 on every
;;  frame.  We now have a new special effect color!
;;
;;  However, I noticed that after using this color, it started to affect the
;;  Sinistar explosion,  So this black color 8 is actually for the black pixels
;;  on the mangled Sinistar face.  Thankfully, the new color cycling effect
;;  doesn't ruin the explosion effect...in fact, I think it makes it look
;;  cooler!  The various selection of colors makes the explosion effect look
;;  slightly more unique each time it's triggered.
;;

        VECTOR  EXEVECT
;	LDA	OPEXCTR,Y	;Fetch the timer value for use as offset into
;	ASRA			;  Special Effects color table.  Divide by 2 to
;	LDU	#PLEXEE		;  use each entry twice.  Get the color from
;	LDA	A,U		;  the table and save it to the PCRAM location
;	STA	PCRAM+$8
        DEC     PCRAM+$8        ;; This looks way better!  It pulses like a heartbeat!
        RTS

;        VECTOR  IAMVECT
;        DEC     PCRAM+$8        ;; Do it for Attract Mode too (nevermind, it doesn't look as cool)
;        RTS

        VECTOR  POWVECT
        CLR     $A224           ;; clear "secret message unlocked" flag
        RTS

;;
;;  For every game start, initialize our new hit counter and show off the new HUD icons
;;

        VECTOR  GamVect

HITINIT lda     #$03            ;; get number of hits
        sta     $A223           ;; store in previously unused memory
        LDB     #DWBL+DZSP         ;; Originally this was #DWBL+DSCY+DZSP since RJ uses it in ZPNTSCRN, however DSCY (Slow Cycle) is for RAM stuff only.
NEXTHIT JSR     UPHITS          ;; do it again for the remaining hits
        DECA
        BNE     NEXTHIT

        RTS

;;
;;  Initialize again on every player turn
;;

        VECTOR	IniVect
        BRA     HITINIT
        RTS


ShipShield

        LDA     #$3F            ;; Flash the screen with yellow
        STA     PCRAM

        LDA     $A223           ;; load warrior shot count
        LDB     #DCNS+DWBL      ;get dma constant to erase sinibomb display
        JSR     UPHITS          ;; update hits display

        deca                    ;; decrease HIT COUNT
        bne     ShipShield2     ;; branch if positive number, otherwise...  (very intense, forces you to look at HUD)
;        bpl     ShipShield2     ;; branch if positive number, otherwise... (feels a little too easy)

        jsr     DEATH           ;; Three strikes and you're out!

        JMP     $56FD           ;; Return to RTS

ShipShield2
        sta     $A223           ;; save warrior shot count

        DISPLAY

;        PHRASE  BURGANDY,35,BATTLE,COMPUTER
;        PHRASE  BURGANDY,35,IS,DAMAGED

;        PHRASE  BURGANDY,35,SINISHIELD,HAS
;        PHRASE  BURGANDY,35,BEEN,ZAPPED

;        PHRASE  PURPLE,35,BATTLE,COMPUTER
;        PHRASE  PURPLE,35,IS
;        WORD    RED,35,DAMAGED

        PHRASE  BURGANDY,35,CRYSTAL,SHIELD
        PHRASE  BURGANDY,35,ANNIHILATED

        TUNE    QBLASTER        ;; play unused Blaster sound effect
        JMP     $56FD           ;; Return to RTS

ShipShield3
        LDA     $A223           ;; get number of Hits
        CMPA    #$02            ;; check if we are not full
        BLE     ADDHIT          ;; if less, then replenish player's shield
;;      bra     addhit               ;;DEBUG ONLY (replace the above line with this to keep seeing "WOW!")
;*
        TUNE    QFulCr          ;* Else, signal crystal pick up for warp engines
        LBRA    $5692           ;; Added back trashed "QFulCr" sound call and return to ADDBOMBS
;        DISPLAY GREY
;        PHRASE  GREY,35,CRYSTAL,SAVED
;        PHRASE  GREY,35,FOR,WARP,ENGINES
;        lbra     ADDB3S
;*
ADDHIT  INCA
        sta     $A223           ;; Add another shield
        ldb     #DWBL+DZSP
        jsr     UPHITS          ;; draw it on the HUD


        TUNE    QExtraCrystal   ;; Play new sequenced sound effect

;;
;;  Surprise "WOW" message goes here!
;;
;;  Now, because we're checking using BITA, this means that the "WOW" message
;;  reverts back to the "normal message" on each odd-numbered 100,000 points.
;;
;;    "WOW!"                       = 100,000
;;    "CRYSTAL SHIELD ANNIHILATED" = 200,000
;;    "WOW!"                       = 300,000
;;    "CRYSTAL SHIELD ANNIHILATED" = 400,000
;;    ...etc...
;;
;;  This was unintentional, however, this is better as it changes up the
;;  display more often so the WOW doesn't get boring.
;;  

;        LDA     SINIKILLS       ;; To make "WOW!" more of a surprise, let's check
;                                ;;   if the player has already killed two Sinistars.
;
;        CMPA    #$02            ;; Did player kill the Sinistar twice?
;        BLT     ShieldRestored  ;;   If not, then we show the normal message.

        LDA     #$10            ;; check if player scored 100,000 points yet
        BITA    PSCORE+1        ;;($9FFE)
        BEQ     ShieldRestored

        DISPLAY                 ;; if player has scored 100,000+
                                ;;   then we can celebrate like "Major Havoc"
        PHRASE  $88,68,WHOA     ;; "WOW!" in LARGE font with new color cycling!

        lbra     ADDB3S         ;; return to ADDBOMBS

ShieldRestored                  ;; "Normal" message to display

        DISPLAY
        PHRASE  $88,35,CRYSTAL,SHIELD
        PHRASE  $88,35,RESTORED

        lbra     ADDB3S


QBLASTER
        _IPrio	$38
;        _Sound	$1A
        FCB     $A5             ;; we already know the sound ID
        _Prio	$30
        _Time	$20
        _Stop



;; UPDATE HITS ON HUD

UPHITS
        PSHS    A,B             ;save dma constant  > uses none
        DECA                    ;too few or to many to display?
        CMPA    #2
        BHI     NOHITS

        LDB     #$11              ;compute s axis offset
        MUL
        ADDB    #$6C            ;add to s axis screen position
        LDA     #$8F            ;; screen position for pixel
        STD     DDEST           ;set dma destination
        LDD     #$407!$404      ;; draw a CROSS
        STD     DHIGH           ;; send the height and width to the DMA
        LDD     #ICROSS         ;; Get image data address
        STD     DSOUR           ;; send color bytes over

        LDA     PMEMCTL         ;* Turn off the
        PSHS    A               ;       save memory control byte
        ANDA    #~$4            ;*   DMA inhibit
        STA     PMEMCTL         ;*   to allow this routine
        STA     MEMCTL          ;*   to output it's message.

        LDB     #$AA            ;; grab DARK TEAL color and store DMA constant
        STB     DCONS           ;; so that we can erase icon on top of scanner

        LDA     2,S             ;; get DMA status byte from stack
        STA     $CA00           ;; store it in DCTRL to actually draw/erase

;;      CLR     DCONS           ;; TOO SOON!  This messes up the blitter.
                                ;; We must do it later!

        PULS    A               ;turn on dma inhibit
        STA     PMEMCTL
        STA     MEMCTL

        CLR     DCONS           ;; NOW we don't need the dark teal color anymore

NOHITS  PULS    D,PC

;;
;;  New SiniShield HUD Icons inspired by the artwork found on the control panel
;;

;ICROSS  FCB     $00,$08,$00
;        FCB     $00,$08,$00
;        FCB     $08,$88,$88
;        FCB     $00,$08,$00
;        FCB     $00,$08,$00
;        FCB     $00,$00,$00

        RADIX   16

;ICROSS  FCB     00,08,48,00
;        FCB     00,58,C8,40
;        FCB     08,88,D8,88
;        FCB     06,CD,DD,C4
;        FCB     08,88,D8,88
;        FCB     00,68,C8,50
;        FCB     00,08,58,00

ICROSS  FCB     00,08,58,00
        FCB     00,68,C8,50
        FCB     08,88,D8,88
        FCB     06,BC,DD,C5
        FCB     08,88,C8,88
        FCB     00,68,B8,60
        FCB     00,08,68,00

        PULLORG MODSAV

;;
;;  Let's overwrite Noah's sound line fix
;;  since that test doesn't exist in T13MODDED
;;
        PUSHORG $FFD0

QExtraCrystal
        _IPRIO  38
;        FCB     A9
;        _PRIO   39
;        _TIME   08
;        _SOUND  3       ;; short Extra Ship sound
;        _PRIO   39
;        _TIME   04
;;;        FCB     A9
;;;        _PRIO   39
;;;        _TIME   06
;        _SOUND  3       ;; short Extra Ship sound
;        _PRIO   39
;        _TIME   08
        _Sound  17      ;; full length full bombbay
        _PRIO   39
        _TIME   32
        _SOUND  3       ;; short Extra Ship sound
        _PRIO   39
        _TIME   08
        _SOUND  3       ;; short Extra Ship sound
        _PRIO   39
        _TIME   04
        _SOUND  3       ;; short Extra Ship sound
        _PRIO   39
        _TIME   08
;        _SOUND  19
;        _PRIO   39
;        _TIME   12

;QTEST   _IPRIO  38
;;        FCB     A9
;;        _PRIO   39
;;        _TIME   08
;;        _SOUND  3       ;; short Extra Ship sound
;;        _PRIO   39
;;        _TIME   04
;;;;        FCB     A9
;;;;        _PRIO   39
;;;;        _TIME   06
;;        _SOUND  3       ;; short Extra Ship sound
;;        _PRIO   39
;;        _TIME   08
;        _Sound  17      ;; full length full bombbay
;        _PRIO   39
;        _TIME   32
;;        _SOUND  19
;;        _PRIO   39
;;        _TIME   12

        _STOP

        PULLORG

;; Debug code for testing new sounds with insert coin sound call

;        PUSHORG $4B0B
;        TUNE    QTEST
;        PULLORG


        IFDEF   SynaMaxEgg

;;
;;  We're in MODSAV territory now
;;

        PUSHORG MODSAV


;;==============================================================================
;;
;;  Not sure why, but we need to copy this over here in order for new strings
;;  to convert correctly to Williams codepage.
;;

        CODEPAGE WILLIASCII             ;; This will make it easier to add more
        CHARSET '0',$00                 ;; phrase strings to the game
        CHARSET '1',$01
        CHARSET '2',$02
        CHARSET '3',$03
        CHARSET '4',$04
        CHARSET '5',$05
        CHARSET '6',$06
        CHARSET '7',$07
        CHARSET '8',$08
        CHARSET '9',$09
        CHARSET '\32',$0A       ;;Space
        CHARSET 'A',$0B
        CHARSET 'B',$0C
        CHARSET 'C',$0D
        CHARSET 'D',$0E
        CHARSET 'E',$0F
        CHARSET 'F',$10
        CHARSET 'G',$11
        CHARSET 'H',$12
        CHARSET 'I',$13
        CHARSET 'J',$14
        CHARSET 'K',$15
        CHARSET 'L',$16
        CHARSET 'M',$17
        CHARSET 'N',$18
        CHARSET 'O',$19
        CHARSET 'P',$1A
        CHARSET 'Q',$1B
        CHARSET 'R',$1C
        CHARSET 'S',$1D
        CHARSET 'T',$1E
        CHARSET 'U',$1F
        CHARSET 'V',$20
        CHARSET 'W',$21
        CHARSET 'X',$22
        CHARSET 'Y',$23
        CHARSET 'Z',$24
;       CHARSET 'CBARRW'        EQU     $25
;       CHARSET 'CEQU'  EQU     $26
        CHARSET '-',$27
;       CHARSET 'CQUE'  EQU     $28
        CHARSET '!',$29
        CHARSET '(',$2A
        CHARSET ')',$2B
        CHARSET '\H',$2C        ;;Apostrophe
        CHARSET ',',$2D
        CHARSET '.',$2E

;;==============================================================================

;;
;;  Now, let's define our words and store them here instead of MESSAV & PHRSAV.
;;
        CODEPAGE WILLIASCII     ;Turn on Williams Character Set Table

_SYNAMAX
        FCC     "SYNAMAX"
        FCB     $8A

_AND
        FCC     "AND"
        FCB     $8A

_SHOFFUR
        FCC     "SHOFFUR"
        FCB     $8A

_ARE
        FCC     "ARE"
        FCB     $8A

_PSYCHIC
        FCC     "PSYCHIC"
        FCB     $0A
        FCC     "RINK"
        FCB     $8A
        
        CHARSET                 ;Going back to regular ASCII

        PULLORG MODSAV

;; Phrase pointers go here (thank goodness we have enough space for these in ROM 10)

        PUSHORG PHRSAV

        FDB     _SYNAMAX
        FDB     _AND
        FDB     _SHOFFUR
        FDB     _ARE
        FDB     _PSYCHIC

        PULLORG PHRSAV

;;
;;  DON'T allow Player 1 but do allow Player 2 button during gameplay
;;
;;  Enabling the bit for player 1 means that the player can restart the game.
;;

        PUSHORG Witt1
        lda     #$2F
        PULLORG

;;
;;  We're back in MODSAV again
;;

        PUSHORG MODSAV

        BSWITCH  START2,CLOSE
        
        TST     $A224           ;; Test if flag is on
        BNE     MAXEGG          ;; Congrats on the good game, here's the secret message

;;
;;  Trying to implement the trigger for the secret took a while but this feels
;;  like the best solution.  I went through a few iterations before deciding
;;  to use a "cheat code" similar to the original easter egg.
;;
;;  Their easter egg requires no credits in the machine initially, and then
;;  3 credits to be inserted before displaying the names.  This egg will be a
;;  little bit easier to trigger.
;;
;;  I wanted to throw in some Sinibomb button presses but that made things too
;;  complex.  It also got in the way of triggering the original dev easter egg.
;;
;;  The player can choose to display this with or without the original secret.
;;  Once the player displays the original easter egg message, the player can
;;  start over with the asteroid bump and press fire 7 times and P2 8 times.
;;

;        LDA     #$1F            ;; check if player scored 200,000 points yet
;        SUBA    PSCORE+1        ;;($9FFE)
;        BMI     MAXEGG          ;; show them the secret message

        lda     #$8E            ;; One asteroid bump
        cmpa    WECheck         ;; 7 fire button presses,
        beq     MaxFlag         ;; 8 P2 button presses, to unlock the message

        RTS

        RADIX   10

MaxFlag STA     $A224           ;; update flag with large number (0 = no message)

MaxEgg  New_Sleep       Task4,MaxTask,OMTLen+1
        lda     #(15*16)        ;* Run the secondary display
        sta     OMTLen,X        ;*   for 15 seconds.

;        inc     $A224           ;; Secret message unlocked!

        ;inc     $A222           ;; Message is on

.1S     rts

        RADIX   16

MaxTask dec     OMTLen,Y        ;* Count down the life clock of this task
        bne     MaxEgg2         ;*   until it hits zero and should die.

        jsr     PClrScr         ;* Then clear the screen

        ;clr     $A222           ;; clear message flag

        jmp     Die             ;*   before dying.

MaxEgg2 pshs    A,B,X,Y         ;* Save work registers

;        TEXT    $20,$3f
;        PHRASE  $88,68,SYNAMAX
;
;        TEXT    $1E,$7a
;        PHRASE  $88,35,AND
;
;        TEXT    $20,$8f
;        PHRASE  $88,68,SHOFFUR
;
;        TEXT    $16,$50
;        PHRASE  $88,35,ARE
;
;        TEXT    $18,$63
;        PHRASE  $88,68,PSYCHIC

        TEXT    $50,$3f
        PHRASE  $88,68,SYNAMAX

        TEXT    $4E,$7a
        PHRASE  $88,35,AND

        TEXT    $50,$8f
        PHRASE  $88,68,SHOFFUR

        TEXT    $46,$50
        PHRASE  $88,35,ARE

        TEXT    $48,$63
        PHRASE  $88,68,PSYCHIC

        puls    A,B,X,Y
        Sleep   LOOP
        rts

        PULLORG MODSAV
        
        ENDIF ;SynaMaxEgg
;;;;;;;

        ENDIF ;ShieldMod

;;  This is a one-off revision for Shield Mod that restores the rarely used
;;  2 player mode.

        IFDEF V19855

;; Restore player 2 button functionality
        PUSHORG $2E2E
        FDB     $2ee3
        PULLORG

;; Restore Witt1's original PANMASK value
        PUSHORG $309E
        FCB     $0F
        PULLORG

;; Patch new code into SBOMBB,OPEN switch
        PUSHORG $6D7D
        JMP     $FEDE
        PULLORG

;; New code to check for easter egg goes in remaining space
        PUSHORG $FEDE

        ;TST     $A224           ;; Test if flag is on
        ;BNE     MAXEGG

        LDA     #$21            ;; Three-finger salute!
        cmpa    SCAN            ;; Hold down player 2, fire, bomb buttons...
        ;beq     MaxFlag
        lbeq     MaxEgg         ;; then let go of bomb button while still
                                ;; holding down the other two

;; Restore original instruction for SBOMBB, OPEN and jump back to main routine
        ldx     #Credits        ;* The trojan court check requires that
        JMP     $6D80
        PULLORG

        ENDIF ;V19855




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        IFDEF   DrawPalette

        PUSHORG MODSAV          ;; we're in MODSAV territory now

        VECTOR  GamVect
        LDB     #DWBL+DZSP         ;; Write Block of data AND Zero Suppression (make zeros transparent)
        JSR     UPPAL
        RTS


;; UPDATE HITS ON HUD

UPPAL
        PSHS    A,B             ;save dma constant  > uses none

        LDD     #$9163          ;; l axis = 91, s axis = 63 (on top of scanner)
        STD     DDEST           ;set dma destination
        LDD     #$023C!$404
        STD     DHIGH           ;; send the height and width to the DMA
        LDD     #IPAL         ;; Get image data address
        STD     DSOUR           ;; send color bytes over

        LDA     PMEMCTL         ;* Turn off the
        PSHS    A               ;       save memory control byte
        ANDA    #~$4            ;*   DMA inhibit
        STA     PMEMCTL         ;*   to allow this routine
        STA     MEMCTL          ;*   to output it's message.

        LDA     2,S             ;; get DMA status byte from stack
        STA     $CA00           ;; store it in DCTRL to actually draw/erase

        PULS    A               ;turn on dma inhibit
        STA     PMEMCTL
        STA     MEMCTL

NOHITS  PULS    D,PC

IPAL    FCB     $11,$11
        FCB     $11,$11
        FCB     $11,$11
        FCB     $11,$11
        FCB     $22,$22
        FCB     $22,$22
        FCB     $22,$22
        FCB     $22,$22
        FCB     $33,$33
        FCB     $33,$33
        FCB     $33,$33
        FCB     $33,$33
        FCB     $44,$44
        FCB     $44,$44
        FCB     $44,$44
        FCB     $44,$44
        FCB     $55,$55
        FCB     $55,$55
        FCB     $55,$55
        FCB     $55,$55
        FCB     $66,$66
        FCB     $66,$66
        FCB     $66,$66
        FCB     $66,$66
        FCB     $77,$77
        FCB     $77,$77
        FCB     $77,$77
        FCB     $77,$77
        FCB     $88,$88
        FCB     $88,$88
        FCB     $88,$88
        FCB     $88,$88
        FCB     $99,$99
        FCB     $99,$99
        FCB     $99,$99
        FCB     $99,$99
        FCB     $AA,$AA
        FCB     $AA,$AA
        FCB     $AA,$AA
        FCB     $AA,$AA
        FCB     $BB,$BB
        FCB     $BB,$BB
        FCB     $BB,$BB
        FCB     $BB,$BB
        FCB     $CC,$CC
        FCB     $CC,$CC
        FCB     $CC,$CC
        FCB     $CC,$CC
        FCB     $DD,$DD
        FCB     $DD,$DD
        FCB     $DD,$DD
        FCB     $DD,$DD
        FCB     $EE,$EE
        FCB     $EE,$EE
        FCB     $EE,$EE
        FCB     $EE,$EE
        FCB     $FF,$FF
        FCB     $FF,$FF
        FCB     $FF,$FF
        FCB     $FF,$FF

        PULLORG MODSAV

        ENDIF

;FastSinistarBuild EQU   1

        IFDEF   FastSinistarBuild

;        PUSHORG $7459
;        New_Sleep       TASK2,SinCon   ;* Start Sinistar Hector build and taunt ;; (Originally Task64)
;        PULLORG

        PUSHORG RicPat
        lda     #$14
        PULLORG

        ENDIF

;RJExplode       EQU     1

        IFDEF   RJExplode

;        PUSHORG MODSAV
;        VECTOR  EXEVECT
;        LDD	FINISH		Now test if the Sinistar is alive
;	CMPD	#ALIVE		  and skip the SPEAK call if not
;	BNE	DSFASD
;        LDU     #$D870          ;Get the Sinistar Image Pointer
;        LDX     #$312           ;Get the byte-count of the Sinistar image
;
;;* This loop modifies the RAM image of the Sinistar (X bytes long)
;RJ2S     LDB     ,U+             ;Get the next byte
;        BEQ     RJ3S             ;If both pixels are zero then skip
;
;        COMB                    ;Get complement
;        ADDB    OMTLEN,Y        ;Add in the explosion increment
;        STB     -1,U            ;Save back into Ram image
;RJ3S     LEAX    -1,X            ;Count down byte-count
;        BNE     RJ2S             ;  until it reaches zero
;DSFASD     rts
;        PULLORG MODSAV

        PUSHORG $7F92
        NOP                     ;; Disable KRSINI in ZSNXQUE
        NOP
        NOP
        PULLORG

;        PUSHORG SNXQUE
;        jsr     KaBoom          ;; Enable KRSINI in SUBPIECE
;        PULLORG

        PUSHORG $7F5A
        NEW_SLEEP TASK4,SNXTSK,OMTLEN+2  ;Awaken the Sinistar explosion task
        PULLORG

        PUSHORG SNXTSK
        JMP     BLAH1
        PULLORG

        PUSHORG MODSAV
BLAH1
        DEC     OMTLEN+1,Y      ;COUNTDOWN
        LBNE    $7FFB           ;* Still alive and mutating the RAM image.  Do it one more time
        JMP     $7FE3           ;  else SS is onscreen and dead dead dead

        PULLORG MODSAV

        PUSHORG $8025
        JMP     BLAH
        PULLORG

        PUSHORG MODSAV
BLAH
        jsr     KRSini
        JSR     PCLRSCR         ;Clear the lower screen
        DEC     DEATHFLAG
        JMP     $8028

        PULLORG MODSAV

        ENDIF

;       IFDEF   QuickBuild      ;*************************************************
;       PUSHORG ROMSAVE                                                 ;*
;;      LOCAL                                                           ;*
;       VECTOR  IniVect         ;****** BUILD THE SINISTAR ******       ;*
;       RADIX   10                                                              ;;(decimal value ahead)
;       lda     #10                                                     ;*      ;;Fixme was: lda        #20
;       RADIX   16                                                              ;;(back to hex)
;;WITT1S        jsr     AddPiece                                                ;*      ;;Fixme was: 1$
;WITT1S jsr     AddPart                                                         ;;(changing to AddPart seems to work a little bit better but player explosion lags and explosion sprite doesn't animate for some reason)
;       deca                                                            ;*
;       bgt     WITT1S                                                  ;*
;       rts                                                             ;*
;       PULLORG ROMSAVE                                                 ;*
;       ENDIF   ;Witt   ;*************************************************


;        PUSHORG $78EC
;        RTS
;        PULLORG