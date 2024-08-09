;;      INCLUDE "../SAM/START.ASM"

;===============================================================================
; EQUs to remove later
;MODSINI        EQU     $3DC1   ;ADDPIEC
;CPIECE EQU     $4D6E   ;SAMTABLE
;ANIMTBL        EQU     $5002   ;SAMTABLE
;===============================================================================

        PUSHORG ROMSAVE

;;      SUBTTL  ADD AND SUBTRACT SINISTAR PIECES

;* subtract a sinistar piece
        ROUTINE SUBPIEC
        PSHS    D,X,U           ;save regs > uses none
        LDX     PIECEPT         ;is sinistar gone?
        CMPX    #PIECETB
        BNE     .1S
        LDX     FINISH          ;yes?, was it alive?
        CMPX    #ALIVE
        BNE     .5S
        BSR     SNXQUE          ;Bob's sinistar explosion queuer
        BRA     .5S
.1S     LEAX    -OSPLEN,X       ;backup piece pointer to previous piece
        LDD     #$FF00+DZSP+DCNS ;setup for erasing
        JSR     MODSINI         ;save X, uses none
        JSR     TARGET          ;retarget workers with crystals
        LDU     [SININDE]       ;erase piece: is sinistar on screen?
        LDU     OSSCWSA,U
        BEQ     .2S
        LDD     OSPLOFF,X       ;yes? compute screen position of piece
        LSRA
        ADDA    OLPOS,U
        ADDB    OSPOS,U
        STD     DDEST           ;setup dma destination
        LDD     [OSPDESC,X]     ;compute piece size
        INCA                    ;allow for flavoring
        EORA    #4              ;* * *FOR DMA BUG
        EORB    #4              ;* * *FOR DMA BUG
        STD     DHIGH
        LDA     #DCNS+DWBL      ;erase block
        STA     DCTRL
.2S     LDX     [SININDE]       ;get sinistar scanner workspace address in X
        LDD     OSLPOS,X        ;yes?,get scanner position of sinistar
        TST     OSSCWSA,X       ;is sinistar on screen?
        BEQ     .3S
        ADDA    SINILN          ;yes, add offset of dead piece
        ADDB    SINISN
.3S     NEW_SCAN CPIECE         ;create piece object
        LDU     PIECEPT         ;piece pointer
        LDU     OSSCWSA,X       ;get piece object workspace, on screen?
        BEQ     .4S
        LDA     SINILN          ;yes, compute piece screen velocity from offset
        CLRB
        RPT     2,ASRA,RORB
        STD     OLVEL,U
        LDA     SINISN
        CLRB
        RPT     1,ASRA,RORB
        STD     OSVEL,U
.4S     LDD     SINILN          ;compute piece scanner velocity from offset
        STD     OSLVEL,X
.5S     PULS    D,X,U,PC

;* Bob's 'queuer' sinistar explosion
        ROUTINE SNXQUE
        NOP
        NOP
        RTS

;* add a sinistar piece
        ROUTINE ADDPIEC
        PSHS    D,X             ;save regs > uses none
        LDX     PIECEPT         ;is sinistar still being built?
        CMPX    FINISH
        BEQ     .1S
        LDD     #$FF00+DZSP     ;setup for drawing
        BSR     MODSINI         ;save X, uses none
        LEAX    OSPLEN,X        ;advance piece pointer to next piece
        CMPX    FINISH          ;is sinistar finished now?
        BNE     .1S
        CMPX    #PIECEND        ;yes?, completely?
        BNE     .1S
        LDX     #ALIVE          ;yes?
        STX     PIECEPT         ;set next piece to border end
        STX     FINISH          ;set finish point to border end
        LDD     #ANIMTBL        ;initialize animation pointer
        STD     ANIMPTR
        BRA     .2S
.1S     JSR     TARGET          ;retarget workers with crystals
.2S     PULS    D,X,PC

;*****
;*
;* TARGET
;*      Retarget workers with crystals
;*
;* Needs:
;*      X -> target piece
;*
;* Returns:
;*      SiniLP - Current Sinistar piece LONG  offset (scanner) in 8 bits
;*      SiniSP - Current Sinistar piece SHORT offset (scanner) in 8 bits
;*      SiniLN - Next Sinistar piece LONG  offset (scanner) in 8 bits
;*      SiniSN - Next Sinistar piece SHORT offset (scanner) in 8 bits
;*
;*      SinLP - Current Sinistar piece LONG  offset (screen) in 8 bits
;*      SinSP - Current Sinistar piece SHORT offset (screen) in 8 bits
;*      SinLN - Next Sinistar piece LONG  offset (screen) in 8 bits
;*      SinSN - Next Sinistar piece SHORT offset (screen) in 8 bits
;*
;*****
        ROUTINE TARGET
        PSHS    A,B,X,U         ;save regs  > uses none
        STX     PIECEPT         ;save target piece pointer
        LDD     OSPLOFF,X       ;get target piece offsets
        ASRA                    ;convert to screen coordinates
        STA     SINLN           ;save l screen target piece offset
        ROLA                    ;convert back to bytes
        LDU     OSPDESC,X       ;get target image descriptor
        ADDD    OLCENT,U        ;add piece offsets to center
        SUBA    #SiniLCE-2      ;compute l scanner offset from coordinate
        RPT     2,ASRA          ;  (with roundoff)
        STA     SINILN          ;save scanner target piece offset
        STB     SINSN           ;save s screen target piece offset
        SUBB    #SiniSCE-2      ;compute s scanner offset from coordinate
        RPT     2,ASRB          ;  (with roundoff)
        STB     SINISN          ;save scanner target piece offset
;*
        LDD     FINISH          ;is it alive?
        CMPD    #ALIVE
        BNE     .1S
        LDX     #PIECEND        ;target last piece to nose
.1S     LDD     OSPLOFF-OSPLEN,X;       get target piece offsets
        LDU     OSPDESC-OSPLEN,X;       get target image descriptor
        ADDD    OLCENT,U        ;add piece offsets to center
        ASRA                    ;convert to screen coordinates
        STA     SinLP           ;save l screen target piece offset
        ROLA                    ;convert back to bytes
        SUBA    #SiniLCE-2      ;compute l scanner offset from coordinate
        RPT     2,ASRA          ;  (with roundoff)
        STA     SiniLP          ;save scanner target piece offset
        STB     SinSP           ;save s screen target piece offset
        SUBB    #SiniSCE-2      ;compute s scanner offset from coordinate
        RPT     2,ASRB          ;  (with roundoff)
        STB     SiniSP          ;save scanner target piece offset
        PULS    A,B,X,U,PC

;* modify sinistar
;*      pass piece descriptor in X, change collis flag in A, dma ctrl byte in B
        ROUTINE MODSINI
        PSHS    D,X,Y,U         ;save regs
        LEAS    -(MHPIECE+8),S  ;get temporary space
        LDA     OSPSOFF,X       ;get s position offset
        STA     2,S             ;save for collision table adjustment
        LDB     #SINIHIG        ;multiply by sinistar height
        MUL                     ;
        LDY     #SINIMAG        ;Y points to sinistar image                             ;;Fixme was: LDY        #SINIMAGE
        LEAY    D,Y             ;add s sequential offset
        LDB     OSPLOFF,X       ;get l position offset
        STB     3,S             ;save for collision table adjustment
        LSRB                    ;convert to bytes
        LDA     1+(MHPIECE+8),S ;compute dma control constant
        BCC     .1S
        ORA     #DTFL
.1S     STA     S               ;save it
        LEAY    B,Y             ;add l byte offset
        LDU     OSPDESC,X       ;get piece image descriptor
        LDA     #1!4            ;* * *TEMPORARY FOR DMA BUG                             ;;Fixme was: LDA        #1!X4
        STA     DWIDE           ;initialize dma for width of 1
        LDA     OWIDTH,U        ;get piece width
        STA     1,S             ;save it
        STA     6,S             ;save for collision table adjustment
        LDB     OHEIGHT,U       ;get piece height
        EORB    #4              ;* * *TEMPORARY FOR DMA BUG
        STB     DHIGH           ;initialize dma for piece height
        EORB    #4              ;* * *TEMPORARY FOR DMA BUG
        LDA     #SINIWID/2+1    ;get center of sinistar offset
        SUBA    2,S             ;compute number of lines till center
        CMPA    #3              ;start past center?
        BGT     .17S
        CLRA                    ;yes, don't check for past center
        NEGB                    ;reverse direction of source
.17S    CMPX    #PIECEND        ;is this a buildup piece?
        BHS     .19S
        CLRA                    ;yes, don't check for end
.19S    STA     7,S             ;save number of lines till center
        LDX     OCOLTBL,U       ;get piece collision table
        STX     4,S             ;save for collision table adjustment
        LDX     OIMAGE,U        ;get start of piece image
        LEAU    8,S             ;get start of ram buffer
        LDA     PMEMCTL         ;write inhibit off
        PSHS    A
        ANDA    #~$4                                                                    ;;Fixme was: ANDA       #!N4
        STA     PMEMCTL
        STA     MEMCTL
.2S     STY     DSOUR           ;set source to sinistar image
        STU     DDEST           ;set destination to ram buffer
        CLR     DCTRL           ;copy line of sinistar image to ram buffer
        LDA     0+1,S           ;get dma control byte / wait for dma
        STX     DSOUR           ;set source to piece
        STA     DCTRL           ;write one line of piece
        LDA     #DSCY           ;get slow cycle dma constant / wait for dma
        STU     DSOUR           ;set source to ram buffer
        STY     DDEST           ;set destination to sinistar image
        STA     DCTRL           ;copy ram buffer to sinistar image
        LEAY    SINIHIG,Y       ;advance destination sinistar height
        DEC     1+7,S           ;count down one line till center
        BNE     .18S
        NEGB                    ;at center, reverse direction of source
.18S    LEAX    B,X             ;advance source piece height
        DEC     1+1,S           ;count down one line
        BNE     .2S             ;done?
        PULS    A               ;write inhibit on
        STA     PMEMCTL
        STA     MEMCTL
        LDA     (MHPIECE+8),S   ;does collsion table need to be adjusted?
        LBEQ    .3S
        SEX                     ;yes, set left or mirrored right flag (1 or -1)
        ORA     #1
        STA     1,S
        LDX     #SINICLI        ;adjust collision table: get collision tbl in X
        LDB     2,S             ;offset for piece s offset
        ABX
        LDA     S               ;check if adding piece or subtracting
        BITA    #DCNS
        BNE     .9S
        LDU     4,S             ;adding, get piece collision table address
        LDA     6,S             ;get piece width
        LEAY    A,U             ;offset for piece top edge collision table
.6S     LDB     U               ;adding loop: get piece bottom edge
        ADDB    3,S             ;offset into sinistar
        CMPB    X               ;is it the bottom edge of the sinistar?
        BGE     .7S
        STB     X               ;yes, adjust sinistar bottom edge table
.7S     LDB     Y               ;get piece top edge
        ADDB    3,S             ;offset into sinistar
        CMPB    SINIWID,X       ;is it the top edge of the sinistar?
        BLE     .8S
        STB     SINIWID,X       ;yes, adjust sinistar top edge table
.8S     LDB     1,S             ;get left or mirrored right flag
        LEAU    B,U             ;advance to next line
        LEAY    B,Y
        LEAX    1,X
        DECA                    ;done?
        BNE     .6S
        BRA     .3S
.9S     LDA     #SINIHIG        ;subtracting loop:
        MUL                     ;compute position of first line in image
        ADDD    #SINIMAG
        TFR     D,U             ;get position in U
.16S    LDA     SINIWID,X       ;get top collision offset
        LSRA                    ;convert to bytes
        PSHS    A               ;save it
        LDB     X               ;get bottom collision offset
        LSRB                    ;convert to bytes
.10S    LDA     B,U             ;bottom adjust - read image
        BNE     .11S            ;something there?
        INCB                    ;no?, try one byte up
        CMPB    S               ;is that top collision boundry?
        BLS     .10S
        LEAS    1,S             ;yes, pull stack
        LDB     #$7F-2*SINIHIG  ;turn off collisions for this line
        STB     X
        NEGB
        BRA     .15S
.11S    ASLB                    ;convert new bottom collision offset to pixels
        BITA    #$F0            ;check flavor
        BNE     .13S
        INCB
.13S    STB     X               ;save new bottom collison offset
        PULS    B               ;get top collision offset
.12S    LDA     B,U             ;read image
        BNE     .14S            ;something there?
        DECB                    ;no?, try one down
        BRA     .12S
.14S    INCB                    ;convert new top collision offset to pixels
        ASLB
        BITA    #$0F            ;check flavor
        BNE     .15S
        DECB
.15S    STB     SINIWID,X       ;save new top collison offset
        LEAU    SINIHIG,U       ;advance image for next line
        LEAX    1,X             ;advance collision table pointer
        DEC     6,S             ;count off one line
        BNE     .16S
.3S     LEAS    (MHPIECE+8),S   ;release temporary space
        PULS    D,X,Y,U,PC      ;restore regs

        PULLORG ROMSAVE