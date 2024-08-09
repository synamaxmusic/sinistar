;;      INCLUDE "../SAM/START.ASM"
;;      INCLVER SAM,SINISTAR.EQU

;===============================================================================
; EQUs to remove later
;CFragme        EQU     $4D9B   ;SAMTABLE
;SMUL8  EQU     $47BE   ;FUNCTION
;===============================================================================

        PUSHORG ROMSAVE

;;      SUBTTL  FRAGMENT EXPLOSION

;* fragment explosion           pass screen workspace in X
        ROUTINE FRAGEXP
        PSHS    D,X,Y,U         ;> uses none
        LDU     OCHAR,X         ;get characteristic descriptor
        LDA     OPFRAG,U        ;get percentage for fragments
        LDB     SFREE           ;get number of free screen workspaces
        MUL
        TSTA
        LBEQ    .7S             ;do we make any?
        PSHS    D               ;yes, save number and initialize angle
        TFR     X,Y             ;transfer object workspace
        LDX     OIDESC,Y        ;get object image descriptor
        LDD     OLCENT,X        ;get center offset
        ADDD    OBOTTOM,Y       ;add to bottom-left
        PSHS    D               ;save object center
.1S     LDU     OCHAR,Y         ;get first fragment image descripter
        LDU     OFRAGIM,U
.2S     JSR     GETOBJ          ;get an object
        ldd     #CFragme        ;give it characteristics
        STD     OCHAR,X
        TFR     U,D
        JSR     IMGOBJ          ;give it an image
        RANDOM  OSEED1,55,55    ;add a random angle (60-120 deg)
        ADDA    3,S
        STA     3,S
        JSR     SINCOS          ;compute a unit vector
        PSHS    D               ;save it
        RANDOM  OSEED2,9,3      ;get a random radius (within a range)
        CMPY    #WPLAYER        ;is object player?
        BNE     .3S
        LSRA                    ;yes, divide radius by two
.3S     PULS    B               ;multiply radius by unit vector
        PSHS    A               ; and add to objects velocity for fragment vel
        JSR     SMUL8
        ADDD    OSVEL,Y
        STD     OSVEL,X
        PULS    D
        JSR     SMUL8
        ASRA                    ;divide long velocity by 2
        RORB
        ADDD    OLVEL,Y
        STD     OLVEL,X
        LDD     S               ;get object center
        SUBD    OLCENT,U        ;offset fragment
        CMPA    OBOTTOM,Y       ;don't allow fragment to be left or below object
        BHS     .4S
        LDA     OBOTTOM,Y
.4S     CMPB    OLEFT,Y
        BHS     .5S
        LDB     OLEFT,Y
.5S     STD     OBOTTOM,X       ;initialize fragment position
        STB     OSPOS,X
        ADDA    OHEIGHT,U
        STA     OTOP,X
        JSR     PUTOBJ          ;put it in object list
        DEC     2,S             ;more fragments?
        BEQ     .6S
        LEAU    OILEN,U         ;yes?, are we out of images
        LDA     U               ;yes?, start over
        BNE     .2S
        BRA     .1S
.6S     LEAS    4,S             ;balance stack
.7S     PULS    D,X,Y,U,PC      ;exit

        PULLORG ROMSAVE