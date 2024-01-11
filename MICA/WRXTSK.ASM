
;	INCLUDE	[SAM]START
;	INCLVER	SAM,SINISTAR.EQU

	PUSHORG	ROMSAVE

;******************************************************************************
;*
;* WARRIOR EXPLOSION TASK
;*
;* Entry: Y points to task workspace

WRXTSK	LDA	OWXPCK,Y
	DECA
	ASLA			;Turn index into word index
	LDX	#WRXITB		;Get the address of the image addresses tables
	LDX	A,X		;X <- address of the image
	STX	DSOUR		;Save this to the DMA for the draw-loop below
	LDD	#WRXISZ		;Get the constant size of the image
	EORA	#4		;  and set it up for
	EORB	#4		;  the screwy DMA output
	STD	DHIGH		;  (Why did they do this to us?)

	INC	OWXALV,Y
	LDB	OWXALV,Y
	ASRB
	BCS	.10S
	DEC	OWXPCK,Y

.10S	LDA	#WRXPCT		;Get the piece-per-wave count
	PSHS	A		;  move and then save this number on the stack
				
	LEAX	OPXOTB,Y	;X <- address of the first entry in the
;*				     task object table
				
.30S	LDD	OWXPSP,X	;Get the screen position for this fragment
	BEQ	.50S		;If zero then this fragment is off-screen
	STD	DDEST		;Else write this destination to the DMA
	CLR	DCONS		;Clear the DMA Constant for a zero write
	LDA	#$12		;DMA
	STA	DCTRL		;  away!

	TST	OWXPCK,Y
	BEQ	.50S

	LDA	OWXPSP,X	;Restore the top half of the screen position
	ADDD	OWXPMM,X	;Mix in the momentum of this fragment
	CMPA	#SCRNLH-3	;Stir gently, abandon all hope if off-screen
	BHI	.40S
	CMPB	#SCRNSL
	BLO	.40S
	CMPB	#SCRNSH
	BHI	.40S

	STD	OWXPSP,X	;Now D has the new screen position.  Save it to
	STD	DDEST		;  both the task workspace and the DMA
	LDA	#$0E		;Now draw this next fragment
	STA	DCTRL           
	BRA	.50S		;Go do next
				
.40S	CLR	OWXPSP,X	;Mark this fragment as
	CLR	OWXPSP+1,X	;  off-screen
				
.50S	LEAX	OWXPSZ,X	;Advance X to point to next fragment entry
	DEC	,S		;Decrement the number of pieces we want to move
	BNE	.30S		;  and go do another if there's more to do
				
	LEAS	1,S		;Clean up stack
				
	TST	OWXPCK,Y	;Increment how many turns these fragments have
	LBEQ	DIE		;  been moving and while less than 128 continue
;*				   else go die now
				
.60S	SLEEP	LOOP		;Go back to sleep, wake again at top of routine


WRXITB	FDB	WRXIM3,WRXIM2,WRXIM1,WRXIM0,WRXIM0,WRXIM0

WRXIM0	FCB	$0A,$0A,$00
	FCB	$AA,$AA,$A0
	FCB	$0A,$FA,$00
	FCB	$AA,$AA,$A0
	FCB	$0A,$0A,$00

WRXIM1	FCB	$0A,$0A,$00
	FCB	$A1,$D1,$A0
	FCB	$0D,$DD,$00
	FCB	$A1,$D1,$A0
	FCB	$0A,$0A,$00

WRXIM2	FCB	$00,$00,$00
	FCB	$0C,$CC,$00
	FCB	$0C,$0C,$00
	FCB	$0C,$CC,$00
	FCB	$00,$00,$00

WRXIM3	FCB	$0D,$0D,$00
	FCB	$D0,$00,$D0
	FCB	$00,$00,$00
	FCB	$D0,$00,$D0
	FCB	$0D,$0D,$00


	PULLORG	ROMSAVE