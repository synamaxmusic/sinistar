;===========================================================
; EQUs to remove later

;NEW_SLEEP EQUs
;SLEEP1 EQU     $46BB   ;SLEEP1
;SLEEP2 EQU     $46DB   ;SLEEP1

;NEWTUNE EQU    $3891   ;NEWTUNE

;RAND8 EQU      $4808   ;FUNCTION
;RAND8B EQU     $4802   ;FUNCTION
;RAND8R EQU     $47FA   ;FUNCTION

;GETSCN EQU     $3FB1   ;SCANNER

;===========================================================
;*******************
;* SINISTAR MACROS *
;*******************

;* assembler extensions:

;* repeat
RPT     MACRO   COUNT,P1,P2,P3,P4,P5,P6,P7,P8,P9,{NOEXPAND}     ;;Fixme was: RPT MACRO  COUNT,P1,P2,P3,P4,P5,P6,P7,P8,P9
;       NLIST                                                   ;;(using {NOEXPAND} to not make this show up in the listing)
        REPT    COUNT
        IRP     INST, P1,P2,P3,P4,P5,P6,P7,P8,P9                ;;Fixme was: IRP INST,<<P1>,<P2>,<P3>,<P4>,<P5>,<P6>,<P7>,<P8>,<P9>>
        INST
        ENDM                                                    ;;Fixme was: ENDR
        ENDM                                                    ;;Fixme was: ENDR
;       LIST
        ENDM

;* hook for a vector patch
HOOK    MACRO   N1,{NOEXPAND}
;       NLIST
N1      SET     *
        RPT     3,NOP
;       LIST
        ENDM

;* vector patch
VECTOR  MACRO   N1
;       BLIST
;       LOCAL                                           ;; Making this section local prevented the macro from working properly
SS      SET     *                                       ;; .$$ was previously defined in MESSEQU.SRC (Had to rename to "SS")
        ORG     N1
        JSR     SS
        ORG     SS
        HOOK    N1
;       MLIST
        ENDM

;* ROUTINE
;* first occurance      - creates symbol
;* second occurance     - types 'REPLACING' message
;* first occurance      - types 'DUP REPLACE' error message
ROUTINE MACRO   N1,{GLOBAL}
;       BLIST
        IFNDEF  N1
N1      SET     *
        MESSAGE "                       CREATING N1"                                    ;; Instead of MESSG and ERR, Macroassembler AS uses MESSAGE and ERROR
        ELSE
        IFNDEF  Z_N1
Z_N1    SET     *                                                                       ;; Macroassembler AS also needs an "_" to attach macro arguments to labels
        MESSAGE "                                               REPLACING N1"
        ELSE
;       LOCAL
        MESSAGE "DUP                                            REPLACE N1"
        ENDIF
SS      SET     *
        ORG     N1
        JMP     SS
        ORG     SS
        ENDIF
;       MLIST
        ENDM

;;
;; In the original code, PUSHORG and PULLORG were already defined in MESSAGE.SRC, but the PUSHORG macro in there
;; is different as it's missing the ROMTEST sub-macro found here.  To avoid "macro double defined" errors, I decided to
;; rename the MESSAGE macros as PUSMORG and PULMORG.
;;

;;* push current address on org stack (8 levels) and optionally re-org
PUSHORG MACRO   ADR                                                                     ;,{NOEXPAND}
;       NLIST
PP      SET     PP+1            ;;Fixme was: .$PP   SET .$PP+1
ORG7    SET     ORG6            ;;Fixme was: .$ORG7 SET .$ORG6
ORG6    SET     ORG5            ;;Fixme was: .$ORG6 SET .$ORG5
ORG5    SET     ORG4            ;;Fixme was: .$ORG5 SET .$ORG4
ORG4    SET     ORG3            ;;Fixme was: .$ORG4 SET .$ORG3
ORG3    SET     ORG2            ;;Fixme was: .$ORG3 SET .$ORG2
ORG2    SET     ORG1            ;;Fixme was: .$ORG2 SET .$ORG1
ORG1    SET     ORG0            ;;Fixme was: .$ORG1 SET .$ORG0
ORG0    SET     *               ;;Fixme was: .$ORG0 SET .$*
TSTPTR  SET     *
        IFNB    <ADR>
        ORG     ADR
        IF ROMSAVE-* = 0                ;;Fixme was:    IFE     ROMSAV-*
        RADIX 10                ;; (decimal 12)
        ROMTEST (ROMSAVE>>12)   ;;Fixme was:    ROMTEST (*!>12.)
        RADIX 16
        ENDIF
        ENDIF
;       LIST
        ENDM
;;===============================================================================
;;
;;  Because PULLORG was already defined in MESSAGE.ASM, we get "double macro defined" errors in AS.
;;  As a result, this macro is commented out to fix this.
;;
;;===============================================================================
;* pull current address off of org stack and optionally reset symbol address
;PULLORG        MACRO   ADR
;;      NLIST
;       IFNB    <ADR>
;ADR    SET     *
;       ENDIF
;       ORG     ORG0            ;;Fixme was:    ORG     .$ORG0
;PP     SET     PP-1            ;;Fixme was: .$PP       SET     .$PP-1
;ORG0   SET     ORG1            ;;Fixme was: .$ORG0     SET     .$ORG1
;ORG1   SET     ORG2            ;;Fixme was: .$ORG1     SET     .$ORG2
;ORG2   SET     ORG3            ;;Fixme was: .$ORG2     SET     .$ORG3
;ORG3   SET     ORG4            ;;Fixme was: .$ORG3     SET     .$ORG4
;ORG4   SET     ORG5            ;;Fixme was: .$ORG4     SET     .$ORG5
;ORG5   SET     ORG6            ;;Fixme was: .$ORG5     SET     .$ORG6
;ORG6   SET     ORG7            ;;Fixme was: .$ORG6     SET     .$ORG7
;;      LIST
;       ENDM

;* equate a symbol to a value if not already defined
SYMVER  MACRO   N1,A1,{NOEXPAND}
;       NLIST
        IFNDEF  N1
N1      EQU     A1
        ELSE
        IF N1-A1 <> 0
        ERROR   "N1,A1 conflict"
        ENDIF
        ENDIF
;       LIST
        ENDM

;*****
;*
;* PAD  [label,] bytes
;*
;*      "PAD bytes" will pad an RMB "bytes" long.
;*      "PAD label,bytes" will create labelSAV followed by the RMB "bytes"
;*                        long and follow that with labelLEN.
;*
;*****
PAD     MACRO   a1,a2
;       BLIST
        IFNB    <a2>
a1_SAV  SET     *                               ;;Fixme was: a1SAV
        RMB     a2
a1_LEN  RMB     0                               ;;Fixme was: a1LEN
        ELSE
        RMB     a1
        ENDIF
;       MLIST
        ENDM    PAD

;* End tests
ENDTEST MACRO
;       BLIST
        IF BASSAV-((D_P+1)<<8) >= 0             ;;Fixme was: IFGE BASSAV-(D_P+1)!<8
        MESSAGE "DP OVFL"
        ENDIF
        IF PP <> 0                              ;;Fixme was: IFN .$PP
        ERROR   "PUL/PUS MM"
        ENDIF
;       IF 1+* <> 0                             ;;Fixme was: IFN 1+*
;       ERROR   "ORG"
;       ENDIF
        IF MESS2-ROMSAV < 0                     ;;Fixme was: IFLT MESS2-ROMSAV
        ERROR   "ROM OVFL"
        ENDIF
;       IF MESLEN-MESSAV < 0                    ;;Fixme was: IFLT MESLEN-MESSAV
;       ERROR   "MESROM OVFL"
;       ENDIF
;       IF INDEXS-RAMSAV < 0                    ;;Fixme was: IFLT INDEXS-RAMSAV
;       ERROR   "RAM OVFL"
;       ENDIF
;       IF OUTCHR-HISAV < 0                     ;;Fixme was: IFLT OUTCHR-HISAV
;       ERROR   "HIROM OVFL"
;       ENDIF
;       MLIST
        ENDM

;*********************

;* pseudo op-codes:

;* negate D
NEGD    MACRO
;       BLIST
        COMA
        NEGB
        SBCA    #-1
;       MLIST
        ENDM

;* clear D
CLRD    MACRO
;       BLIST
        CLRA
        CLRB
;       MLIST
        ENDM

;* D = Absolute Value of D
ABSD    MACRO
;       BLIST
        tsta
        bge     *+6
        NEGD
;       MLIST
        ENDM    ;ABSD

;*********************

;* game macros:

;* random number generator
RANDOM  MACRO   SEED,RNG,OFS
;       BLIST
        IF ("RNG"="WORD")                       ;Fixme was: IFIDN <RNG>,<WORD>
        LDA     #SEED
        JSR     RAND8
        ELSEIF ("RNG"="BYTE")                   ;Fixme was: ELSE
                                                ;           IFIDN <RNG>,<BYTE>
        LDA     #SEED
        JSR     RAND8B
        ELSEIF  RNG=FALSE                       ;Fixme was: ELSE
                                                ;           IFB   <RNG>
        LDA     #SEED
        ELSEIF                                  ;Fixme was: ELSE
        LDD     #(SEED<<8)+RNG                  ;           LDD #SEED!<8+RNG
;       ENDIF
        JSR     RAND8R
        ENDIF
        IFNB    OFS                             ;Fixme was: IFNB  <OFS>
        ADDA    #OFS
        ENDIF
;       ENDIF
;       MLIST
        ENDM

;* fast random number generator
FRANDOM MACRO   SOFF,RNG,OFS
;       BLIST
        IF ("RNG"="WORD")
        LDD     SOFF+SEEDS
        ELSE
        LDA     SOFF+SEEDS
        IF ("RNG"<>"BYTE")
        IFNB    <RNG>
        LDB     #RNG
        ENDIF
        MUL
        IFNB    OFS
        ADDA    #OFS
        ENDIF
        ENDIF
        ENDIF
;       MLIST
        ENDM

;* play a tune
TUNE    MACRO   NUM
;       BLIST
        JSR     NEWTUNE
        FDB     NUM
;       MLIST
        ENDM

;* handle a switch
BSWITCH MACRO   N1,S1           ; Renamed SWITCH to BSWITCH since AS has an
                                ; instruction with the same name.
;       BLIST
SS      SET     *
        IF ("S1"="OPEN")
        ORG     N1
        ELSEIF ("S1"="CLOSE")
        ORG     N1+2
        ENDIF
        FDB     SS
        ORG     SS
;       MLIST
        ENDM

;* make a new scanner object   pass scanner position in D, returns scanwsa in X
;*      NEW_SCAN        [characteristic descriptor address]
NEW_SCAN MACRO  CHR
;       BLIST
        JSR     GETSCN
        FDB     CHR
;       MLIST
        ENDM

;*********************

;* multitasking macros:

;* make a new sleep task
;*  forms:
;*      NEW_SLEEP       [sleep list],[wake up address]
;*              returns task workspace address in X
;*      NEW_SLEEP       [sleep list],[wake up address],[size of workspace]
;*              returns task workspace address in X
NEW_SLEEP MACRO SL,WU,NUMB
;       BLIST
        IFB     NUMB
        JSR     SLEEP1
        FDB     WU,SL
        ELSE
;       IFLE    NUMB-OMTLEN
;       ERR     BYTE COUNT ?
;       ENDIF
        JSR     SLEEP2
        FDB     WU
        FCB     NUMB
        FDB     SL
        ENDIF
;       MLIST
        ENDM

;* sleep
;*  forms:
;*      SLEEP   HERE
;*              wakes up after call, reqrs current task workspace address in Y
;*      SLEEP   LOOP
;*              wakes up at last wake up address, reqrs task wsa in Y
;*      SLEEP   [wake up address]
;*              requires current task workspace address in Y
SLEEP   MACRO   WU
;       BLIST
        IF ("WU"="HERE")
        RADIX 10
        WAKE_AT *+10                            ;;Fixme was: WAKE_AT *+10.
        RADIX 16
        ELSEIF ("WU"<>"LOOP")
        WAKE_AT WU
        ENDIF
        LDD     OINDEX,Y
        STD     PRTASK
        RTS
;       MLIST
        ENDM

;* change sleep list
;*  forms:
;*      CHANGE_SLEEP    [sleep list],HERE
;*              wakes up after call, reqrs current task workspace address in Y
;*      CHANGE_SLEEP    [sleep list],LOOP
;*              wakes up at last wake up address, reqrs task wsa in Y
;*      CHANGE_SLEEP    [sleep list],[wake up address]
;*              requires current task workspace address in Y
CHANGE_SLEEP MACRO SL,WU
;       BLIST
        LDX     #SL
        IF ("WU"="HERE")                        ;;Fixme was: IFIDN <WU>,<HERE>
        JSR     C1SLEEP
        ELSEIF ("WU"="LOOP")                    ;;Fixme was: ELSE
;       IFIDN   <WU>,<LOOP>
        JMP     C3SLEEP
        ELSE
        LDD     #WU
        JMP     C2SLEEP
        ENDIF
;       ENDIF                                   ;; This is not needed.
;       MLIST
        ENDM

;* change wake up address to here, requires current task workspace address in Y
WAKE_HERE MACRO
        WAKE_AT *+5
        ENDM

;* change wake up address, requires current task workspace address in Y
;*      WAKE_AT [wake up address]
WAKE_AT MACRO   WU
        LDD     #WU
        STD     OEXEC,Y
        ENDM

;*********************

;* tune interpreter instructions:

;* interuption tune priority
_IPRIO  MACRO   NUM                             ;Fixme was: .IPRIO
;       BLIST
        IF _STMODE<>0                           ;IFN    _STMODE
        MESSAGE "NO END"
        ELSE
_STMODE SET     TRUE                            ;Fixme was: .$TMODE
        ENDIF
        FCB     NUM
_SSOUND SET     -1                              ;Fixme was: .$SOUND
_SPRIO  SET     -1                              ;Fixme was: .$PRIO
        ENDM

;* set tune priority
_PRIO   MACRO   NUM                             ;Fixme was: .PRIO
        TUNECK
        SOUNDCK
        PRIOCK
_SPRIO  SET     NUM
        ENDM

;* play a sound
_SOUND  MACRO   NUM                             ;Fixme was: .SOUND
        TUNECK
        SOUNDCK
_SSOUND SET     NUM!3F                          ;Fixme was: .$SOUND SET NUM!X3F
        ENDM

;* time delay
_TIME   MACRO   NUM                             ;Fixme was: .TIME
        TUNECK
        IF _SPRIO>=0                            ;Fixme was: IFGE _SPRIO
        SOUNDCK
        FCB     _SPRIO+40,NUM
        ELSEIF _SSOUND>=0                       ;Fixme was: IFGE _SSOUND
        FCB     _SSOUND+$C0,NUM                 ;Fixme was: FCB _SSOUND!+$C0,NUM
        ELSE
        MESSAGE "NO SOUND OR PRIO"
;       ENDIF
        ENDIF
_SSOUND SET     -1
_SPRIO  SET     -1
        ENDM

;* repeat tune
_REPEAT MACRO   NUM,ADR                         ;Fixme was: .REPEAT
        TUNECK
        SOUNDCK
        PRIOCK
        FCB     NUM,ADR-*
_STMODE SET     FALSE
        ENDM

;* stop tune
_STOP   MACRO                                   ;Fixme was: .STOP
        TUNECK
        SOUNDCK
        PRIOCK
        FCB     0
_STMODE SET     FALSE
;       MLIST
        ENDM

;*********************

;* sub-macros:

SOUNDCK MACRO
        IF _SSOUND>=0                           ;Fixme was: IFGE _SSOUND
        FCB     _SSOUND+80
_SSOUND SET     -1
        ENDIF
        ENDM

PRIOCK  MACRO
        IF _SPRIO>=0                            ;Fixme was: IFGE _SPRIO
        MESSAGE "EXTRA PRIO"
_SPRIO  SET     -1
        ENDIF
        ENDM

TUNECK  MACRO
        IF _STMODE=0                            ;Fixme was: IFE _STMODE
        MESSAGE "NO IPRIO"
        _IPRIO  1
        ENDIF
        ENDM

ROMTEST MACRO   ADR
        IF ADR-1 = 0                    ;;Fixme was: IFE ADR-1
        CPYCHK  1
        ENDIF
        IF ADR-2 = 0                    ;;Fixme was: IFE ADR-2
        CPYCHK  2
        ENDIF
        IF ADR-3 = 0                    ;;Fixme was: IFE ADR-3
        CPYCHK  3
        ENDIF
        IF ADR-4 = 0                    ;;Fixme was: IFE ADR-4
        CPYCHK  4
        ENDIF
        IF ADR-5 = 0                    ;;Fixme was: IFE ADR-5
        CPYCHK  5
        ENDIF
        IF ADR-6 = 0                    ;;Fixme was: IFE ADR-6
        CPYCHK  6
        ENDIF
        IF ADR-7 = 0                    ;;Fixme was: IFE ADR-7
        CPYCHK  7
        ENDIF
        IF ADR-8 = 0                    ;;Fixme was: IFE ADR-8
        CPYCHK  8
        ENDIF
        IF ADR-$E = 0                   ;;Fixme was: IFE ADR-E
        CPYCHK  E
        ENDIF
        IF ADR-$F = 0                   ;;Fixme was: IFE ADR-F
        CPYCHK  F
        ENDIF
        ENDM

CPYCHK  MACRO   ROM
        IFNDEF  CR_ROM                  ;;Fixme was: IFNDEF     CRROM
;       LIST
CR_ROM  SET     *                       ;;Fixme was: CRROM      SET     *
        fcc     "COPYRIGHT 1983 WILLIAMS ELECTRONICS, INC."
;       NLIST
        ENDIF
        ENDM

;*      This inclver appears here so that DISPLAY may use the macros!

        INCLUDE "../WITT/DISPLAY.ASM"