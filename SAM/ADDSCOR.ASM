;;      INCLUDE "../SAM/START.ASM"

;===============================================================================
; EQUs to remove later
;QNEWSHI        EQU     $4DDF
;===============================================================================

        PUSHORG ROMSAVE

;;      SUBTTL  PLAYER SCORE AND SINIBOMB STATUS DISPLAY AND CHANGE

;* add bcd score to players score       pass score in D
        ROUTINE ADDSCOR
        PSHS    A,B,X,U         ;> uses none
        INC     SCOREFL         ;set score flag
        LDU     #NSCORE         ;get next ship score
        LDX     #PSCORE         ;get player score data address
        BSR     ADD6S           ;add new points to score,  save X, uses none                    ;; Fixme was: BSR ADDBCD
                                                                                                ;;(I have NO IDEA why renaming ADDBCD to ADD6S fixes the range overflow)
        BCC     .1S             ;wrap around?
        CLR     WRAPFLG         ;yes, set wrap flag and award extra ship
        BRA     .2S
.1S     LDX     #PSCORE         ;get player score data address
        BSR     CMPBCD          ;compare with players score,  save U, uses none
        BLO     .5S
        LDA     WRAPFLG         ;player's score higher?, test wrap flag
        BNE     .5S
.2S     LDX     #EXTRADD        ;get next ship level adder address
        LDD     EXTRINC         ;add next ship level adder increment
        BSR     ADD6S
        LDA     1,X             ;is sum over 999,900
        BEQ     .3S
        CLR     1,X             ;yes, clear over flow
        LDD     #-1             ;set to 999,900
        STD     2,X
.3S     LDD     EXTRADD+2       ;clear?, get next ship level adder
        LEAX    -1,U            ;add to next ship level (offset to mult by 100)
        BSR     ADD6S
        LDA     X               ;did it overflow? (9th digit)
        BEQ     .4S
        STA     WRAPFLG         ;yes, set wrap flag
        CLR     X               ;zero 9 digit
.4S     BSR     UPBONUS         ;display next bonus level, save none, uses none
        TUNE    QNEWSHI         ;play extra ship tune
        LDA     SHIPS           ;get ship count
        LDB     #DWBL           ;re-draw player up ship
        JSR     UPSHIPS         ;save none, uses none
        INCA
        BEQ     .1S             ;over 255?, don't add more!
        STA     SHIPS           ;save new ship count
        LDB     #5              ;add a free ship to the books
        JSR     AUD1S           ;save U, uses none
        LDB     #DWBL           ;draw another ship
        JSR     UPSHIPS         ;save none, uses none
        BRA     .1S             ;did he earn another ship?
.5S     PULS    A,B,X,U,PC

;* add bcd number in D to 8 dig numb pointed to by X, returns overflow in carry
ADDBCD  SET *                                                                           ;;Added this to restore label
ADD6S   PSHS    A,B,X   ;> uses none
        LDA     3,X
        ADDA    1,S
        DAA
        STA     3,X
        LDA     2,X
        ADCA    S
        DAA
        STA     2,X
        LDA     1,X
        ADCA    #0
        DAA
        STA     1,X
        LDA     X
        ADCA    #0
        DAA
        STA     X
        PULS    A,B,X,PC

;* compare 8 digit bcd number pointed to by X to number pointed to by U
CMPBCD  PSHS    A,B     ;> uses none
        LDD     X       ;compare top 4 digits
        CMPD    U
        BNE     .1S     ;if different, exit
        LDD     2,X     ;same?, compare bottom 4 digits
        CMPD    2,U
.1S     PULS    A,B,PC

;* update 'bonus at' score
UPBONUS PSHS    D,X,U
        LDA     PMEMCTL         ;dma inhibit off
        PSHS    A
        ANDA    #~$4                                                                    ;;Fixme was: ANDA #!N4
        STA     PMEMCTL
        STA     MEMCTL
        LDD     #(3<<8+8*4-1)!$404      ;erase score: set dma size * * *FOR DMA BUG     ;;Fixme was: LDD  #(3!<8+8*4-1)!X404
        STD     DHIGH
        LDA     #$81            ;set dma destination
        LDB     SCOREAD
        ADDB    #$22
        TFR     D,X
        STX     DDEST
        LDA     #DCNS+DWBL      ;erase it
        STA     DCTRL
        LDB     #BLUE           ;setup color
        LDU     #NSCORE         ;get address of bonus score
.1S     LDA     U+              ;find first non-zero byte
        BEQ     .1S
        BITA    #$F0            ;is upper nibble zero?
        BNE     .3S
        ORA     #$F0            ;yes, mask it
        BRA     .3S
.2S     LDA     U+              ;get next score byte
.3S     JSR     OUTB35          ;display score byte
        CMPU    #NSCORE+4
        BLO     .2S
        PULS    A               ;turn on dma inihibit
        STA     PMEMCTL
        STA     MEMCTL
        PULS    D,X,U,PC

;* update ship display          pass count in A, dma constant in B
        ROUTINE UPSHIPS
        PSHS    A,B             ;save dma constant  > uses none
        DECA                    ;too few or to many to display?
        CMPA    #9
        BHI     NOUPSTA
        LDB     #6              ;compute s axis offset
        MUL
        ADDB    SCOREAD         ;add to score s axis screen position
        LDA     #$7D            ;l axis screen position
        STD     DDEST           ;set dma destination
        LDD     #ISHIPS         ;set dma source
        BRA     UPSTATS         ;update status image, uses A,B

;* update sinibomb display      ;pass sinibomb count in A, dma constant in B
        ROUTINE UPBOMBS
        PSHS    D               ;save dma constant  > uses none
        DECA                    ;decrement count
        LDB     #$89            ;get l axis screen address for first row
        RADIX 10
        CMPA    #10             ;not in this row?                                       ;;Fixme was: CMPA #10.
        RADIX 16
        BLT     .1S
        RADIX 10
        SUBA    #10             ;yes, subtract number in this row                       ;;Fixme was: SUBA #10.
        RADIX 16
        ADDB    #3              ;add l axis spacing for one row
.1S     PSHS    B               ;save l axis address
        LDB     #6              ;compute s axis offset
        MUL                     ;(remainder * s axis spacing)
        ADDB    SCOREAD         ;add to score s address screen position
        PULS    A               ;get l axis offset
        STD     DDEST           ;set dma destination
        LDD     #ISBOMST        ;set image data
;* update status display        ;pass image address in D, dma ctrl byte in 2,S
UPSTATS STD     DSOUR                                                                   ;;Fixme was: UPSTAT (truncated label again)
        LDD     #$305!$404      ;set dma block size                                     ;;Fixme was: LDD #305!X404
        STD     DHIGH
        LDA     PMEMCTL         ;turn off dma inhibit
        PSHS    A
        ANDA    #~$4            ;Fixme was: ANDA        #!N4
        STA     PMEMCTL
        STA     MEMCTL
        LDA     2,S             ;get dma constant
        STA     DCTRL           ;draw it
        PULS    A               ;turn on dma inhibit
        STA     PMEMCTL
        STA     MEMCTL
NOUPSTA PULS    D,PC

;* score display task
        ROUTINE SCOREDI
        LDA     SCOREFL         ;did the player score?
        BEQ     .1S
        BSR     UPSCORE         ;update score
        CLR     SCOREFL         ;yes?, clear score flag
.1S     SLEEP   LOOP

;* update score routine
        ROUTINE UPSCORE
        PSHS    D,X,U           ;> uses none
        LDA     PMEMCTL         ;dma inhibit off
        PSHS    A
        ANDA    #~$4                                                                    ;;Fixme was: ANDA #!N4
        STA     PMEMCTL
        STA     MEMCTL
        LDD     #$8503          ;compute screen address of score
        ADDB    SCOREAD
        TFR     D,X
        LDU     #PSCORE         ;get address of score data
.1S     LDA     U               ;get byte of score
        CMPA    LSCORE-PSCORE,U ;compare with last displayed score
        BEQ     .2S
        LDA     #$0F            ;different?, set mask to mask off lower nibble
        BSR     .4S             ;erase and redraw upper nibble if different
        LDA     #$0F0           ;set mask to mask off upper nibble
        BSR     .4S             ;erase and redraw lower nibble if different
        LDA     U               ;get byte of score
        STA     LSCORE-PSCORE,U ;update byte of last displayed score
.2S     LEAX    $0E,X           ;advance screen address for next pair of digits
        LEAU    1,U             ;advance score data pointer
        CMPU    #PSCORE+4       ;done?
        BLO     .1S
        CLR     DCONS           ;yes?, zero dma constant
        PULS    A               ;turn on dma inihibit
        STA     PMEMCTL
        STA     MEMCTL
.3S     PULS    D,X,U,PC
;*
.4S     STA     TEMP            ;update digit: save nibble mask
        LDA     U               ;get byte of score
        ORA     TEMP            ;different?, mask off one nibble
        STA     TEMP+1          ;save it
        LDA     LSCORE-PSCORE,U ;get byte of last displayed score
        ORA     TEMP            ;mask off one nibble
        CMPA    TEMP+1          ;compare with nibb of score
        BEQ     .5S
        CLRB                    ;different?, zero color
        JSR     OUTBCD          ;erase old digit  save U, uses X
        LEAX    -$0E,X          ;restore screen position
        LDA     U               ;get byte of score
        ORA     TEMP            ;mask off on nibble
        LDB     #RED            ;get score color
        JSR     OUTBCD          ;draw new digit
        LEAX    -$0E,X          ;restore sceen position
.5S     RTS

        PULLORG ROMSAVE