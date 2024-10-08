;;===============================================================================
; EQUs to remove later
;PLXTSK EQU     $7CD8
;PLEXTRA        EQU     $7D85
;;===============================================================================

;       INCLUDE [SAM]START
;       INCLVER SAM,SINISTAR

        PUSHORG ROMSAVE

;*******************************************************************************
;*
;* PLAYER EXPLOSION TASK QUEUER
;*
;* Entry: X points to the player ship image descriptor
        ROUTINE PLXQUE

        PSHS    D,X,Y,U

        LDA     #7              ;Turn palette zero into bright-red
        STA     PCRAM

        LDD     FREE            ;Test for enough free memory for the task
        CMPD    #2*(OPXRRQ+ODYNOVH)     ;and
        BLT     PLXXIT                  ;exit without creating the task if not

        TFR     X,U             ;U <- pointer to Image Descriptor
        NEW_SLEEP TASK2,PLXTSK,OPXRRQ   ;Create the player explosion task

        CLR     OPXALV,X        ;Clear the PlayerX turns-alive counter

        LEAY    OPXOTB,X        ;Y <- address of the fragments table

        LDD     OBOTTOM,U       ;D <- screen position of the player ship
        PSHS    D               ;Save on stack

        LDA     #PXPPCT*PXPWVS  ;Get the total number of fragments to create
        PSHS    A               ;  and save this on the stack

;* This loop picks at random the velocity vector and starting position
;*   displacement for each fragment
        RADIX   10
PLXPLP  RANDOM  OSEED2,15,-7    ;Random SHORT velocity of -7 to 7               ;;Fixme was: RANDOM     OSEED2,15.,-7
        RADIX   16
        PSHS    A
        RANDOM  OSEED1,7,-3     ;Random LONG velocity of -3 to 3
        PULS    B               ;Restore SHORT velocity
        STD     OPXPMM,Y        ;Save it into this table entry
        BEQ     PLXPLP          ;If momentum is zero, try again

        RANDOM  OSEED1,4        ;Now, get a SHORT position offset
        ASLA                    ;Multiply by 2
        PSHS    A
        RANDOM  OSEED2,4        ;Get the LONG offset
        PULS    B               ;Restore short
        ADDD    1,S             ;Add the screen position
        STD     OPXPSP,Y        ;Save this fragment's screen position

        LEAY    OPXPSZ,Y        ;Advance Y to the next entry

        DEC     ,S              ;Decrement the fragment count
        BNE     PLXPLP          ;While not zero set up another fragment

        LEAS    3,S             ;Else reset stack

        LDD     FREE            ;Test if there's enough memory left
        CMPD    #2*(OPEXTSZ+ODYNOVH)    ;for this task
        BLT     PLXXIT          ;  and skip it if not

        NEW_SLEEP       TASK2,PLEXTRA,OPEXTSZ   ;else queue up the task


PLXXIT  PULS    D,X,Y,U,PC         ;and split



        PULLORG ROMSAVE

