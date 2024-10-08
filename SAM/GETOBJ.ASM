;;      INCLUDE "../SAM/START.ASM"
;;      INCLVER SAM,SINISTAR

;;===============================================================================
; EQUs to remove later
;DOBJECT        EQU     $4422   ;DRAWOBJ
;NOPOST EQU     $45EA   ;DRAWOBJ
;EKOBJ  EQU     $4393   ;DRAWOBJ
;CNULL  EQU     $4BB5   ;SAMTABLE
;;===============================================================================

        PUSHORG ROMSAVE
;;===============================================================================
;CR4SAVE        SET     *
;CR4    fcc     "COPYRIGHT 1983 WILLIAMS ELECTRONICS, INC."
;;===============================================================================

;;      SUBTTL  SCREEN LIST ROUTINES

;* get object add char and image          pass char addr in D, returns obj wsa in X
GETCOBJ PSHS    D               ;> uses A,B,X   save characteristics
        BSR     GETOBJ          ;get object  save none, uses A,B,X
        LDD     S               ;initialize characteristics
        STD     OCHAR,X
        ADDD    #OFIDESC
        STD     S
        LDD     [S++]
;* add image to object        pass image descriptor addr in D and obj wsa in X
IMGOBJ  PSHS    U,D             ;> uses none
        LDU     S
        STU     OIDESC,X
        LDD     OIMAGE,U        ;initialize image data
        STD     ODSOUR,X
        LDA     OWIDTH,U        ;initialize object width
        STA     ODWIDTH,X
        LDD     #DOBJECT        ;initialize display vector
        STD     ODRWVEC,X
        LDD     #NOPOST         ;initialize post-display vector
        STD     OPDRWVE,X
        PULS    U,D,PC

;* get object from free list            returns object wsa in X
        ROUTINE GETOBJ
        DEC     SFREE           ;one less free screen object  > uses A,B,X
        LDX     FOBJKEY         ;get first free object
        BNE     .1S             ;out of objects?
        SWI                     ;TEMPORARY TRAP
.1S     LDD     X               ;link-out
        STD     FOBJKEY
        CLR     OSTATUS,X       ;initialize status
        RTS

;* put object on screen list            pass object wsa in X
PUTOBJ  PSHS    U,Y,A           ;find position on list > uses none
        LDA     OLEFT,X
        LDU     #SCRKEY+OFLINK
.1S     LEAY    U
        LDU     OFLINK,U
        BEQ     .2S
        CMPA    OLEFT,U
        BHI     .1S
.2S     LDU     OFLINK,Y        ;link-in
        STU     OFLINK,X
        STX     OFLINK,Y
        STY     OBLINK,X
        STX     OBLINK,U
        LDA     OBOTTOM,X       ;initialize top edge
        LDU     OIDESC,X
        ADDA    OHEIGHT,U
        STA     OTOP,X
        PULS    U,Y,A,PC

;* kill object on screen list           pass object wsa in X
KILLOBJ LDD     #EKOBJ          ;> uses A,B
        STD     ODRWVEC,X
        LDD     #CNULL
        STD     OCHAR,X
        RTS

        PULLORG ROMSAVE