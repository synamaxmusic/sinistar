
;       INCLUDE [SAM]START
;       INCLVER SAM,SINISTAR

        PUSHORG ROMSAVE

;*****************************************************************************
;*
;* SINISTAR EXPLOSION TASK
;*
;* ENTRY: Y points to the task workspace
SNXTSK  TST     INIMPULSE       ;If we're still in impulse drive phase -1
        BNE     .1S             ;  then go mutate the face

        LDD     #PIECEND        ;  else SS is onscreen and dead dead dead
        STD     FINISH          ;  so make marks as such
        STD     PIECEPTR

        NEW_SLEEP       TASK1,SNXBRX,OMTLEN+1  ;Task to blow the pieces
        RADIX   10
        LDA     #14             ;Set to blow 13 pieces                          ;;Fixme was: LDA  #14.
        RADIX   16
        STA     OMTLEN,X
        JMP     DIE             ;       Die

;* Still alive and mutating the RAM image.  Do it one more time
.1S     LDU     #$D870          ;Get the Sinistar Image Pointer
        LDX     #$312           ;Get the byte-count of the Sinistar image

;* This loop modifies the RAM image of the Sinistar (X bytes long)
.2S     LDB     ,U+             ;Get the next byte
        BEQ     .3S             ;If both pixels are zero then skip

        COMB                    ;Get complement
        ADDB    OMTLEN,Y        ;Add in the explosion increment
        STB     -1,U            ;Save back into Ram image
.3S     LEAX    -1,X            ;Count down byte-count
        BNE     .2S             ;  until it reaches zero

        SLEEP   LOOP            ;Nighty-night

;******************************************************************************
;* SNXBRX
;* This task blows off the pieces, then resets the piece pointers & calls KRSINI
SNXBRX  DEC     OMTLEN,Y                ;Another to do?
        BEQ     .2S                     ;Nope, so go die
        JSR     SUBPIECE                ;  else let loose another piece
        SLEEP   LOOP                    ;  and rest

.2S     LDD     #PIECETBL               ;Reset the Sinistar piece pointers
        STD     PIECEPTR

        JSR     PCLRSCR         ;Clear the lower screen
        JSR     INISINI         ;* To clean out the SiniStar image
        JMP     DIE             ;When we hit zero we're through


        PULLORG ROMSAVE