;;===============================================================================
;;
;;   I think this patch is unused because LAST.ASM overwrites
;;   the patch at $4BCF with a jump to $FFB0 not $E1C7.  Does this mean
;;   $E1C7-$E1D3 is not used at all?
;;
;;   The FORCEON patch at $FFB0 is exactly the same...at first it was confusing to
;;   see that but I think there's a reason:
;;
;;   Since $FFB0 is part of the diagnostic ROM and the game can be built without it,
;;   perhaps the devs moved this patch over to prevent operators from running
;;   the game without the diagnostic/watchdog ROM.
;;
;;   To avoid double symbol errors, FORCEON has been renamed to ZFORCEON
;;
;;===============================================================================

;       INCLUDE START
;       INCLVER SAM,SINISTAR.EQU
FIXSMASH

;* patch offscreen routine to keep player on screen
        PUSHORG CPLAYER+OOFFSCR                                                 ;;($4BCF)
        FDB     ZFORCEON                                                        ;;Fixme was: FDB  FORCEON
        PULLORG

;* * *  PUSHORG ROMSAVE
        PUSHORG HISAV
;* keep player on screen
ZFORCEON LDD    #387A           ;stick the player at mid screen                 ;;Fixme was: FORCEON LDD  #387A  ;;($E1C7)
        STD     OBOTTOM,Y
        STB     OSPOS,Y
        CLR     OSTATUS,Y       ;clear his clipping flags
        JMP     [OPDRWVE,Y]     ;execute post-display routine, uses A,B,X,U

;* * *  PULLORG ROMSAVE
        PULLORG HISAV