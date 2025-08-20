;VERSION        SET     17              ;Fixme was: VERSION EQU 17
;FINAL  EQU     32767
;***
;* For each entry that MAXMES allows, 2 bytes are used to provide a phrase
;* number entry and AVGLEN bytes are used to provide message storage.
;* So, the allocated area is MAXMES*(AVGLEN+2).  This area is only provided
;* when VERSION is not equal to FINAL.
;*
;* PHRSAV -> +----------------------------------------------------------+
;*          | MAXMES number of 2 byte entries for new phrase addresses |
;*          +----------------------------------------------------------+
;* PHRLEN ->
;*
;* MESSAV -> +----------------------------------------------------------+
;*          | MAXMES number of AVGLEN byte entries for the new phrases |
;*          +----------------------------------------------------------+
;* MESLEN ->
;*
;***
MAXMES  EQU     $F0             ;* Maximum phrases.
AVGLEN  EQU     5               ;* The average phrase length.

;* Color nibbles
BLUE    EQU     $99             ;* Intense Blue
RED     EQU     $DD             ;* Red

        ;NLIST
;*****
;*
;* LINE <TEXT>
;*
;*****
;LINE   MACRO   TEXT
;       NLIST
;*      BLIST
;       IRPC    CHAR,<TEXT>
;       IFIDN   <CHAR>,< >
;       PFCB    CSPC
;       ELSE
;       IFIDN   <CHAR>,<'>
;       PFCB    CSQOT
;       ELSE
;       IFIDN   <CHAR>,<!>
;       PFCB    CEXC
;       ELSE
;       IFIDN   <CHAR>,<(>
;       PFCB    CBRKL
;       ELSE
;       IFIDN   <CHAR>,<)>
;       PFCB    CBRKR
;       ELSE
;       IFIDN   <CHAR>,<->
;       PFCB    CDSH                    ;;This should be CDASH so MICA/ZZATTRAC.ASM can use it
;       ELSE
;       IFIDN   <CHAR>,<.>
;       PFCB    CPER
;       ELSE
;       IFIDN   <CHAR>,<,>
;       PFCB    CCMMA
;       ELSE
;       PFCB    CCHAR
;       ENDIF
;       ENDIF
;       ENDIF
;       ENDIF
;       ENDIF
;       ENDIF
;       ENDIF
;       ENDIF
;       ENDR
;       ORG     *-1
;       fcb     .$CHR+END
;       LIST
;       ENDM    LINE

;PFCB   MACRO   C1
;.$CHR  SET     C1
;       FCB     C1
;       ENDM

;*****
;*
;* PAD  [label,] bytes
;*
;*      "PAD bytes" will pad an RMB "bytes" long.
;*      "PAD label,bytes" will create labelSAV followed by the RMB "bytes"
;*                        long and follow that with labelLEN.
;*
;*****
MPAD    MACRO   arg1,arg2                                                       ;; (PAD macro already exists in MACROS.ASM, ultimately, this one is not needed.  I renamed it to MPAD to avoid errors.)
;* * *  IFN     VERSION-FINAL   * Version is not final.
        IFNB    arg2
arg1_SAV        SET     *                                                       ;;Fixme was: arg1SAV SET *
        RMB     arg2
arg1_LEN        RMB     0                                                       ;;Fixme was: arg1LEN RMB 0
        ELSE
        RMB     arg1
        ENDIF
;* * *  ELSE                    * Version is Final
;* * *  IFNB    <arg2>
;* * *arg1LEN   RMB0
;* * *  ENDIF
;* * *  ENDIF
        ENDM    PAD

;       LIST
        PUSHMORG MESS1MID
;*
;**** PHRASE CHARACTER LISTS ****
;*
;;=========================================================================
;;
;;  I went with Macro Assembler AS's CODEPAGE and CHARSET instructions
;;  to achieve the same effect that the LINE macro did.
;;
;;  Using RORG, we go back by 1 byte and overwrite the last character
;;  by adding the last chacter with CEND to terminate the string.
;;
;;=========================================================================
        CODEPAGE WILLIASCII     ;Turn on Williams Character Set Table
INDIC   FCC     "INITIAL TESTS INDICATE"
        RORG -1
        FCB CE+CEND
ALLGO   FCC     "ALL SYSTEMS GO"
        RORG -1
        FCB CO+CEND
RMERR   FCC     "RAM ERROR "
        RORG -1
        FCB CSPC+CEND
ROMER   FCC     "ROM ERROR "
        RORG -1
        FCB CSPC+CEND
ROMK    FCC     "ALL ROMS OK"
        RORG -1
        FCB CK+CEND
RAMF    FCC     "RAM TEST FOLLOWS"
        RORG -1
        FCB CS+CEND
EXIT    FCC     "PRESS ADVANCE TO EXIT"
        RORG -1
        FCB CT+CEND
ERDECT  FCC     " RAM ERRORS DETECTED"
        RORG -1
        FCB CD+CEND
NO      FCC     "NO"
        RORG -1
        FCB CO+CEND
CMS     FCC     "NO CMOS"
        RORG -1
        FCB CS+CEND
CMSER   FCC     "CMOS RAM ERROR"
        RORG -1
        FCB CR+CEND
CMSDR   FCC     "FRONT DOOR MUST BE OPEN"
        RORG -1
        FCB CN+CEND
CMSTBL  FCC     "OR TABLE TOP RAISED FOR TEST"
        RORG -1
        FCB CT+CEND
WRTPRT  FCC     "OR WRITE PROTECT FAILURE"
        RORG -1
        FCB CE+CEND
CRAMT   FCC     "COLOR RAM TEST"
        RORG -1
        FCB CT+CEND
VERBAR  FCC     "HORIZONTAL BARS INDICATE ERROR"
        RORG -1
        FCB CR+CEND
SWITCH  FCC     "SWITCH TEST"
        RORG -1
        FCB CT+CEND
AUT     FCC     "AUTO UP"
        RORG -1
        FCB CP+CEND
ADV     FCC     "ADVANCE"
        RORG -1
        FCB CE+CEND
RIG     FCC     "RIGHT COIN"
        RORG -1
        FCB CN+CEND
MHIGH   FCC     "HIGH SCORE RESET"
        RORG -1
        FCB CT+CEND
LEFT    FCC     "LEFT COIN"
        RORG -1
        FCB CN+CEND
CENT    FCC     "CENTER COIN"
        RORG -1
        FCB CN+CEND
SLAMS   FCC     "SLAM SWITCH"                           ;;Fixme was: SLAM  (Duplicate symbol in IRQ.ASM)
        RORG -1
        FCB CH+CEND
PLY1    FCC     "ONE PLAYER START"
        RORG -1
        FCB CT+CEND
PLY2    FCC     "TWO PLAYER START"
        RORG -1
        FCB CT+CEND
UDSWA   FCC     "UP-DOWN SWITCH A"
        RORG -1
        FCB CA+CEND
UDSWB   FCC     "UP-DOWN SWITCH B"
        RORG -1
        FCB CB+CEND
UDSWC   FCC     "UP-DOWN SWITCH C"
        RORG -1
        FCB CC+CEND
UDDRC   FCC     "UP-DOWN DIRECTION"
        RORG -1
        FCB CN+CEND
LRSWA   FCC     "LEFT-RIGHT SWITCH A"
        RORG -1
        FCB CA+CEND
LRSWB   FCC     "LEFT-RIGHT SWITCH B"
        RORG -1
        FCB CB+CEND
LRSWC   FCC     "LEFT-RIGHT SWITCH C"
        RORG -1
        FCB CC+CEND
LRDRC   FCC     "LEFT-RIGHT DIRECTION"
        RORG -1
        FCB CN+CEND
FIRE    FCC     "FIRE"
        RORG -1
        FCB CE+CEND
BOMB    FCC     "BOMB"
        RORG -1
        FCB CB+CEND
MSOUND  FCC     "SOUND LINE"
        RORG -1
        FCB CE+CEND
MSBOK   FCC     "BOOKKEEPING TOTALS"
        RORG -1
        FCB CS+CEND
MSLEFT  FCC     "LEFT SLOT COINS"
        RORG -1
        FCB CS+CEND
MSCENT  FCC     "CENTER SLOT COINS"
        RORG -1
        FCB CS+CEND
MSRIGT  FCC     "RIGHT SLOT COINS"
        RORG -1
        FCB CS+CEND
MSPAD   FCC     "PAID CREDITS"
        RORG -1
        FCB CS+CEND
MSFRE   FCC     "FREE SHIPS"
        RORG -1
        FCB CS+CEND
MSTPT   FCC     "TOTAL TIME IN MINUTES"
        RORG -1
        FCB CS+CEND
MSTM    FCC     "TOTAL SHIPS PLAYED"
        RORG -1
        FCB CD+CEND
MSTP    FCC     "TOTAL CREDITS PLAYED"
        RORG -1
        FCB CD+CEND
MSAVTM  FCC     "AVERAGE TIME PER CREDIT"
        RORG -1
        FCB CT+CEND
MSDJ    FCC     "GAME ADJUSTMENTS"
        RORG -1
        FCB CS+CEND
MSXTR   FCC     "FIRST EXTRA SHIP AT"
        RORG -1
        FCB CT+CEND
MSNCR   FCC     "ADDITIONAL EXTRA SHIP POINT FACTOR"
        RORG -1
        FCB CR+CEND
MS1CR   FCC     "SHIPS PER GAME"
        RORG -1
        FCB CE+CEND
MSDFF   FCC     "DIFFICULTY OF PLAY"
        RORG -1
        FCB CY+CEND
MSCFI   FCC     "CONTINUOUS FIRE"
        RORG -1
        FCB CE+CEND
MS2CR   FCC     "HIGH SCORE TO DATE ALLOWED"
        RORG -1
        FCB CD+CEND
MSPRC   FCC     "PRICING SELECTION"
        RORG -1
        FCB CN+CEND
MSLSL   FCC     "    LEFT SLOT UNITS"
        RORG -1
        FCB CS+CEND
MSCSL   FCC     "    CENTER SLOT UNITS"
        RORG -1
        FCB CS+CEND
MSRSL   FCC     "    RIGHT SLOT UNITS"
        RORG -1
        FCB CS+CEND
MSURC   FCC     "    UNITS REQUIRED FOR CREDIT"
        RORG -1
        FCB CT+CEND
MSURB   FCC     "    UNITS REQUIRED FOR BONUS CREDIT"
        RORG -1
        FCB CT+CEND
MSMN    FCC     "    MINIMUM UNITS FOR ANY CREDIT"
        RORG -1
        FCB CT+CEND
MSRST   FCC     "RESTORE FACTORY SETTINGS"
        RORG -1
        FCB CS+CEND
MSCLR   FCC     "CLEAR BOOKEEPING TOTALS"
        RORG -1
        FCB CS+CEND
MSHGH   FCC     "HIGH SCORE TABLE RESET"
        RORG -1
        FCB CT+CEND
MSAT    FCC     "AUTO CYCLE"
        RORG -1
        FCB CE+CEND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        IFDEF   PauseAdjust

MPAUS   FCC     "PAUSE"
        RORG -1
        FCB CE+CEND

        ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MSSTA   FCC     "SET ATTRACT MODE MESSAGE"
        RORG -1
        FCB CE+CEND
MSSDJ   FCC     "USE 'MOVE' TO SELECT "
        RORG -1
        FCB CSPC+CEND
MSCDJ   FCC     "USE 'FIRE-SINIBOMB' BUTTONS TO CHANGE THE VALUE"
        RORG -1
        FCB CE+CEND
YES     FCC     "YES"
        RORG -1
        FCB CS+CEND
ADJMS   FCC     "ADJUSTMENT"
        RORG -1
        FCB CT+CEND
LETTR   FCC     "LETTER"
        RORG -1
        FCB CR+CEND
FAIL    FCC     " FAILURE"
        RORG -1
        FCB CE+CEND
RESFAC  FCC     "FACTORY SETTINGS RESTORED"
        RORG -1
        FCB CD+CEND
OPENS   FCC     "BY OPENING FRONT DOOR OR TABLE TOP"    ;;Fixme was: OPEN (Duplicate symbol in WITT/ANISINI.ASM)
        RORG -1
        FCB CP+CEND
ONOFF   FCC     "AND TURNING GAME ON AND OFF"
        RORG -1
        FCB CF+CEND
CLER    FCC     " CLEARED"
        RORG -1
        FCB CD+CEND
FRPLAY  FCC     "  FREE PLAY"
        RORG -1
        FCB CY+CEND
        CHARSET         ;Going back to regular ASCII
;;=========================================================================
;*
;*      START OF PHRASE VECTORS
;*
PHRASE  FDB     INDIC   ;'INITIAL TESTS INDICATE'
        FDB     ALLGO   ;'ALL SYSTEMS GO'
        FDB     RMERR   ;'RAM ERROR '
        FDB     ROMER   ;'ROM ERROR '
        FDB     ROMK    ;'ALL ROMS OK'
        FDB     RAMF    ;'RAM TEST FOLLOWS'
        FDB     EXIT    ;'PRESS ADVANCE TO EXIT'
        FDB     ERDECT  ;' RAM ERRORS DETECTED'
        FDB     NO      ;'NO'
        FDB     CMS     ;'NO CMOS'
        FDB     CMSER   ;'CMOS RAM ERROR'
        FDB     CMSDR   ;'FRONT DOOR MUST BE OPEN'
        FDB     CMSTBL  ;'OR TABLE TOP RAISED FOR TEST'
        FDB     WRTPRT  ;'WRITE PROTECT FALIURE'
        FDB     CRAMT   ;'COLOR RAM TEST'
        FDB     VERBAR  ;'HORIZONTAL BARS INDICATE ERROR'
        FDB     SWITCH  ;'SWITCH TEST'
        FDB     AUT     ;'AUTO UP'
        FDB     ADV     ;'ADVANCE'
        FDB     RIG     ;'RIGHT COIN SWITCH'
        FDB     MHIGH   ;'HIGH SCORE RESET'
        FDB     LEFT    ;'LEFT COIN SWITCH'
        FDB     CENT    ;'CENTER COIN SWITCH'
        FDB     SLAMS   ;'SLAM SWITCH'                  ;;Fixme was: SLAM  (Duplicate symbol in IRQ.ASM)
        FDB     PLY1    ;'ONE PLAYER START'
        FDB     PLY2    ;'TWO PLAYER START'
        FDB     UDSWA   ;'UP-DOWN SWITCH A'
        FDB     UDSWB   ;'UP-DOWN SWITCH B'
        FDB     UDSWC   ;'UP-DOWN SWITCH C'
        FDB     UDDRC   ;'UP-DOWN DIRECTION'
        FDB     LRSWA   ;'LEFT-RIGHT SWITCH A'
        FDB     LRSWB   ;'LEFT-RIGHT SWITCH B'
        FDB     LRSWC   ;'LEFT-RIGHT SWITCH C'
        FDB     LRDRC   ;'LEFT-RIGHT DIRECTION'
        FDB     FIRE    ;'FIRE'
        FDB     BOMB    ;'BOMB'
        FDB     MSOUND  ;'SOUND LINE'
        FDB     MSBOK   ;'BOOKKEEPING TOTALS'
        FDB     MSLEFT  ;'LEFT SLOT COINS'
        FDB     MSCENT  ;'CENTER SLOT COINS'
        FDB     MSRIGT  ;'RIGHT SLOT COINS'
        FDB     MSPAD   ;'PAID CREDITS'
        FDB     MSFRE   ;'FREE SHIPS'
        FDB     MSTPT   ;'TOTAL TIME IN MINUTES'
        FDB     MSTM    ;'TOTAL SHIPS PLAYED'
        FDB     MSTP    ;'TOTAL CREDITS PLAYED'
        FDB     MSAVTM  ;'AVERAGE TIME PER CREDIT'
        FDB     MSDJ    ;'GAME ADJUSTMENTS'
        FDB     MSXTR   ;'FIRST EXTRA SHIP AT'
        FDB     MSNCR   ;'ADDITIONAL EXTRA SHIP POINT FACTOR'
        FDB     MS1CR   ;'SHIPS PER GAME'
        FDB     MSDFF   ;'DIFFICULTY OF PLAY'
        FDB     MSCFI   ;'CONTINUOUS FIRE'
        FDB     MS2CR   ;'HIGH SCORE TO DATE ALLOWED'
        FDB     MSPRC   ;'PRICING SELECTION'
        FDB     MSLSL   ;'    LEFT SLOT UNITS'
        FDB     MSCSL   ;'    CENTER SLOT UNITS'
        FDB     MSRSL   ;'    RIGHT SLOT UNITS'
        FDB     MSURC   ;'    UNITS REQUIRED FOR CREDIT'
        FDB     MSURB   ;'    UNITS REQUIRED FOR BONUS CREDIT'
        FDB     MSMN    ;'    MINIMUM CREDITS FOR ANY CREDIT'
        FDB     MSRST   ;'RESTORE FACTORY SETTINGS'
        FDB     MSCLR   ;'CLEAR BOOKKEEPING TOTALS'
        FDB     MSHGH   ;'HIGH SCORE TABLE RESET'
        FDB     MSAT    ;'AUTO CYCLE'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        IFDEF   PauseAdjust

        FDB     MPAUS   ;; ENABLE PAUSE

        ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        FDB     MSSTA   ;'SET ATTRACT MODE MESSAGE'
        FDB     MSSDJ   ;'USE 'MOVE' TO SELECT '
        FDB     MSCDJ   ;'USE 'FIRE-SINIBOMB' BUTTONS TO CHANGE THE VALUE'
        FDB     YES     ;'YES'
        FDB     ADJMS   ;'ADJUSTMENT'
        FDB     LETTR   ;'LETTER'
        FDB     FAIL    ;' FAILURE'
        FDB     RESFAC  ;'FACTORY SETTINGS RESTORED'
        FDB     OPENS   ;'BY OPENING FRONT DOOR OR TABLE TOP'   ;;Fixme was: OPEN (Duplicate symbol in WITT/ANISINI.ASM)
        FDB     ONOFF   ;'AND TURNING GAME ON AND OFF'
        FDB     CLER    ;' CLEARED'
        FDB     FRPLAY  ;'  FREE PLAY'
PhrNum  SET     (*-Phrase)/2
;       PAD     PHR,2*(MaxMes-PhrNum)   ;* Padding for additional phrases
;;=========================================================================
;;
;;  Because of how {AS} needs to use an underscore for adding macro arguments to labels,
;;  the commonly used label "PHRSAV" is replaced with "PHR_SAV" if we use the PAD (or MPAD) macro.
;;  Instead, it's just easier to recreate what PAD did with just three new lines of code so that
;;  we can still use "PHRSAV".
;;
PHRSAV  SET     *
        RMB     2*(MaxMes-PhrNum)
PHRLEN  RMB     0
;;=========================================================================
;*
;*      GAME STRINGS
;*
        ;PAD    MES,AVGLEN*(MaxMes-PhrNum)      ;* New phrase storage.
MESSAV  SET     *
        RMB     AVGLEN*(MaxMes-PhrNum)
MESLEN  RMB     0
;*
;*      START OF TEXT VECTORS
;*
TXT     FDB     ROMOK
        FDB     RAMOK
        FDB     CMOSOK
        FDB     CMOSER
        FDB     CMOSDR
        FDB     COLOR
        FDB     SWITC
        FDB     BOOKTXT                                                         ;;Fixme was: FDB  BOOK (Duplicate symbol in T13, renaming to BOOKTXT)
        FDB     AJUST
        FDB     BADJ
        FDB     IMES
        FDB     REST
        FDB     BKRES


ROMOK   FDB     $6855   ;CURSOR
        FCB     $99     ;COLOR
        FCB     MSRMK   ;`MESSAGE ALL ROMS OK'
        FDB     $4243
        FCB     $33
        FCB     MSRAMF  ;`RAM TEST TO FOLLOW'
        FDB     $3934
        FCB     $33
        FCB     MSEXIT+CEND ;`PRESS ADVANCE TO EXIT'

RAMOK   FDB     $4C2F
        FCB     $99
        FCB     MSNO    ;`NO'
        FDB     $0
        FCB     $99
        FCB     MSERDT+CEND ;` RAM ERRORS DETECTED'

CMOSOK  FDB     $4C1D
        FCB     $99
        FCB     MSCMS   ;`NO CMOS'
        FDB     $0
        FCB     $99
        FCB     MSERDT+CEND ;` RAM ERRORS DETECTED'

CMOSER  FDB     $4C4A
        FCB     $22
        FCB     MSCMER+CEND ;`CMOS RAM ERROR'

CMOSDR  FDB     $4C4A
        FCB     $22
        FCB     MSCMER  ;`CMOS RAM ERROR'
        FDB     $422B
        FCB     $22
        FCB     MSWRT   ;`WRITE PROTECT FAILURE'
        FDB     $392B
        FCB     $99
        FCB     MSCMDR  ;`FRONT DOOR MUST BE OPEN'
        FDB     $341C
        FCB     $99
        FCB     MSCMTL+CEND ;`OR TABLE TOP RAISED FOR TEST'

COLOR   FDB     $4C4B
        FCB     $33
        FCB     MSCRMT  ;`COLOR RAM TEST'
        FDB     $2F1F
        FCB     $33
        FCB     MSVRBR+CEND ;`VERTICAL BARS INDICATE ERROR'

SWITC   FDB     $8557           ;DIAGNOSTICS, SWITCH TEST
        FCB     $88
        FCB     MSSWIT+CEND ;`SWITCH TEST'

BOOKTXT FDB     $853F           ;BOOKKEEPING HEADER                             ;;Fixme was: BOOK  (Duplicate symbol in T13, renaming to BOOKTXT)
        FCB     $99
        FCB     MSBOOK+CEND

AJUST   FDB     $8543           ;GAME ADJUST HEADER
        FCB     $99
        FCB     MSADJ+CEND

        PULLORG MESS1END
                                ;*********
;*********************************      *********************************
;*                         ROM RE-ORGANIZATION                          *
;*********************************      *********************************
        PUSHMORG MESS2          ;*********

BADJ    FDB     $183E           ;GAME ADJUST TRAILER
        FCB     $BB
        FCB     MSSADJ
        FDB     $0
        FCB     $BB
        FCB     MSAJM
        FDB     $131D
        FCB     $44
        FCB     MSCADJ
        FDB     $0E52
        FCB     $11
        FCB     MSEXIT+CEND

IMES    FDB     $4C3E           ;POWER-UP PROTECTED CMOS CHECKSUM FAILURE
        FCB     $22
        FCB     MSAJM
        FDB     $0
        FCB     $22
        FCB     MSFAIL
        FDB     $392A
        FCB     $22
        FCB     MSREST
        FDB     $2F07
        FCB     $22
        FCB     MSOPEN
        FDB     $261F
        FCB     $22
        FCB     MSONOF+CEND

REST    FDB     $4C26           ;FACTORY SETTINGS RESTORE DIAGNOSTIC MESSAGE
        FCB     $99
        FCB     MSRFAC+CEND

BKRES   FDB     $5F23           ;BOOKS RESET STATUS MESSAGE
        FCB     $33
        FCB     MSBOOK
        FDB     $0
        FCB     $33
        FCB     MSCLRD+CEND

        PULLORG MESS2MID