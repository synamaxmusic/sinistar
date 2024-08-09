;       include start
;       INCLUDE "../WITT/RICH.EQU"                                              ;;Rich's work EQUs
;       INCLVER RICH,Table              * Macro
;PROMS  EQU     1               ;* Define before burning proms                  ;;(Moving this to MAKE.ASM since it's important)
richfixes
;***
;*      Define DEMO when assembling this module for a ROM version work file.
;*      This eliminates the overload flash.
;***
        IFDEF   Proms
;       SYMVER  VRLOAD,VRLOAD
        PUSHORG VRLOAD+2                                                        ;;($37F2)
        nop                     ;* Eliminate overload flash
        nop                     ;*   by avoiding PCRAM store.
        PULLORG
        ENDIF   ;Proms
;***
;*      This overrides the japzap during development.
;***
        IFNDEF  Proms
        PUSHORG ROMSAVE
        VECTOR  POWVECT
;       SYMVER  KENCHK,KENCHK
        clr     KENCHK
        rts
        VECTOR  IniVect
        clr     KenChk
        rts
        PULLORG ROMSAVE
;       SYMVER  ZAPSIN,ZAPSini
        PUSHORG ZAPSini         ;* In the PowVect routine, ignore the
        tst     $0              ;*   copyright violation test routine.
        PULLORG
        ENDIF   ;Proms
;*****
;*
;*      <<<<< V17 BUG FIXES >>>>>
;*
;* Notes:
;*      Workers with crystals should check PlaGrave as well as SinGrave
;*      to keep from building the Sinistar when the player is dead.  This
;*      is a current bone.
;*
;*****
;;      IFE     Version-17.
;***
;*      New Jap Zapping Table.
;***
;       SYMVER  KENTBL,KENTBL
        PUSHORG KenTbl                                                          ;;Adding PUSHORG here to replace KenTbl ($52E3)
;       TABLE   KenTbl          ;* This one is
        fdb     $6A00           ;*   as of 3/23 at 8:02 PM
        fdb     $0000           ;*   ... Rich.
        fdb     $0C4A
        fdb     $1591
        fdb     $4543
        fdb     $0150
        fdb     $3502
;       ENDTBL
        PULLORG                                                                 ;;Adding PULLORG, per TABLE macro.

        INCLUDE "../WITT/FIXBUTTO.ASM"  ;* FIREB version editing correction
        INCLUDE "../WITT/FIXINIRI.ASM"  ;* SINIB demo error and timing correction
        INCLUDE "../WITT/FIXKRSIN.ASM"  ;* Dead man's warp correction
        INCLUDE "../WITT/FIXRISBO.ASM"  ;* Value error correction
;       INCLVER RICH,fixsini    ;* Sinistar death motion correction             ;;(Already included in AOE.ASM)
        INCLUDE "../WITT/ZSTBLIMP.ASM"  ;* Impulse engine speed table tuned
        INCLUDE "../WITT/ZSTBLBOM.ASM"  ;* Demo bombing run speed table tuned

;       ENDIF   Version-17.