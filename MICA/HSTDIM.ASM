;       INCLUDE [SAM]START


;* On POWERUP, reset the RAM High Score Table
        PUSHORG ROMSAVE

        VECTOR  POWVECT

        LDX     #RAMHSC         ;Address of RAM table
        LDD     #$0001          ;Use 0001 for initialization base
        JMP     HSTDIM          ;Go set table (returns through HSTDIM)


;* On RESET HIGH SCORE Request
        ROUTINE RSHS

        LDX     #CMOSHSC        ;Address of CMOS High Score table
        LDD     #$0003          ;Use 30,000 as base value
        JSR     HSTDIM          ;Do it
        LDX     #RAMHSC         ;Address of RAM High Score table
        LDD     #$0001          ;Use 10,000 as base value
        JSR     HSTDIM          ;Do it

        CLR     $CA01           ;Clear the screen
        JSR     CLRSCR

        TEXT    $4F,$30
        PHRASE  WHITE,68,HIGH,SCORE,TABLE,RESET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers

        FDB     _TABLE
        FDB     _RESET

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        LDA     #$7F            ;Sleep for 7f
        JSR     NAPV

        RTS


;*******************************************************************************
;* HSTDIM
;*   Routine sets up HSENTCT values starting at X, uses D as base value

HSTDIM  PSHS    D,X,Y,U

        LDU     #$9045          ;Starting addition to base value

        LDX     #CMOSSD         ;Load saved random seed
        JSR     RCMOSA          ;  from CMOS
        INCA                    ;Bump to next
        ANDA    #3              ;Keep the value from 0 to 3
        LEAX    -2,X            ;Restore pointer to CMOSSD
        JSR     WCMOSA          ;Write the new value
        ASLA                    ;Turn into word index
        LDY     #HSISWE         ;Get address of starting addresses table
        LDY     A,Y             ;Get this starting address

        LDX     2,S             ;Restore starting location passed in X

        LDB     #HSENTCT        ;Number of entries
        PSHS    B

.1S     LDD     1,S             ;Restore base value
        JSR     WCMOSD          ;Stuff it at X

        TFR     U,D             ;Get addition
        JSR     WCMOSD          ;Stuff it at X
        EXG     A,B             ;Add the shuffle value
        ADDA    #$35            ;  to the low order digits
        DAA
        EXG     A,B
        ADDA    #$97            ;  and then decrease the two high digits
        DAA                     ;  by three
        TFR     D,U             ;Save the additive value

        LDB     #3              ;3 initials per pass

.4S     LDA     ,Y+             ;Get next initial
        JSR     WCMOSA          ;Stuff it at X
        DECB                    ;Another initial for this entry?
        BNE     .4S             ;  Branch if so

        CMPY    #HSISUS+(3*HSENTCT) ;Are we at the end of the table?
        BNE     .207S           ;Branch if not
        LDY     #HSISUS         ;  else start from beginning of table

.207S   DEC     ,S              ;Decrement the number of entries made
        BNE     .1S             ;  and loop until all have been done

        LEAS    1,S             ;Restore stack

        JSR     CLRHSLE         ;Clear High Score Last Entered pointers

        PULS    D,X,Y,U,PC      ;Bye for now


;*******************************************************************************
;* CLRHSLE
;*   Clear the High Score Last Entered pointers
CLRHSLE CLRD
        STD     HSLEN1
        STD     HSLEN2
        STD     HSRLN1
        STD     HSRLN2
        RTS


;* Pointers to initial initials
HSISWE  FDB     HSISSD,HSISNF,HSISBM,HSISRW


;* Table of initials, including everyone in the software department plus
;*   many other people who were key to the successful completion of Sinistar!
;* NB: This table must have at least as many entries as the maximum number
;*     of entries in either the RAM or CMOS tables (currently 30  18 March 1983)

        RADIX   10

HSISUS  FCB     17,25,14        ;GOD    Because He Is                           ;;Fixme was: FCB        17.,25.,14.
        FCB     21,11,35        ;KAY    Kay Anderson                            ;;Fixme was: FCB        21.,11.,35.
        FCB     18,15,13        ;HEC    Harry Cline                             ;;Fixme was: FCB        18.,15.,13.
HSISSD  FCB     29,11,23        ;SAM    Sam Dicker                              ;;Fixme was: FCB        29.,11.,23.
        FCB     21,32,14        ;KVD    Kristina Donofrio                       ;;Fixme was: FCB        21.,32.,14.
HSISNF  FCB     24,39,16        ;N-F    Noah Falstein                           ;;Fixme was: FCB        24.,39.,16.
        FCB     21,20,16        ;KJF    Ken Fedesna                             ;;Fixme was: FCB        21.,20.,16.
        FCB     21,11,17        ;KAG    Ken Graham                              ;;Fixme was: FCB        21.,11.,17.
        FCB     16,28,17        ;FRG    Rich Grande                             ;;Fixme was: FCB        16.,28.,17.
        FCB     35,11,21        ;YAK    Jack Haeger                             ;;Fixme was: FCB        35.,11.,21.
        FCB     20,20,21        ;JJK    John Kotlarik                           ;;Fixme was: FCB        20.,20.,21.
        FCB     21,16,22        ;KFL    Ken Lantz                               ;;Fixme was: FCB        21.,16.,22.
        FCB     26,20,23        ;PJM    Pierre Maloka                           ;;Fixme was: FCB        26.,20.,23.
        FCB     14,25,13        ;DOC    Keith McMillen                          ;;Fixme was: FCB        14.,25.,13.
        FCB     20,22,23        ;JLM    John Meissen                            ;;Fixme was: FCB        20.,22.,23.
        FCB     15,39,36        ;E-Z    Mike Metz                               ;;Fixme was: FCB        15.,39.,36.
HSISBM  FCB     38,23,38        ;=M=    Robert J. Mical                         ;;Fixme was: FCB        38.,23.,38.
        FCB     30,19,23        ;TIM    Tim Murphy                              ;;Fixme was: FCB        30.,19.,23.
        FCB     20,28,24        ;JRN    John Newcomer                           ;;Fixme was: FCB        20.,28.,24.
        FCB     30,25,23        ;TOM    Tom O'Meara                             ;;Fixme was: FCB        30.,25.,23.
        FCB     26,16,36        ;PFZ    Bill Pfutzengesundheit                  ;;Fixme was: FCB        26.,16.,36.
        FCB     28,30,26        ;RTP    Rudy Plemich                            ;;Fixme was: FCB        28.,30.,26.
        FCB     12,16,14        ;BFD    Dave Rzepka                             ;;Fixme was: FCB        12.,16.,14.
        FCB     23,12,29        ;MBS    Marc Stanis                             ;;Fixme was: FCB        23.,12.,29.
        FCB     23,28,29        ;MRS    Mike Stroll                             ;;Fixme was: FCB        23.,28.,29.
        FCB     15,20,29        ;EJS    Ed Suchocki                             ;;Fixme was: FCB        15.,20.,29.
        FCB     29,30,31        ;STU    Stewart West                            ;;Fixme was: FCB        29.,30.,31.
HSISRW  FCB     33,19,30        ;WIT    Rich Witt                               ;;Fixme was: FCB        33.,19.,30.
        FCB     23,25,23        ;MOM    Because She Is                          ;;Fixme was: FCB        23.,25.,23.
        FCB     16,11,13        ;FAC    Future Absurdity Commission             ;;Fixme was: FCB        16.,11.,13.

        FCC     'ROBERT J. MICAL'       ;Hey, who's that guy?

        RADIX   16

        PULLORG ROMSAVE





