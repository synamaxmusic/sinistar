;;	INCLUDE "../SAM/START.ASM"
	
	PUSHORG ROMSAVE

;;===============================================================================	
;CR5SAVE	SET	*	
;CR5	fcc	"COPYRIGHT 1983 WILLIAMS ELECTRONICS, INC."
;ROMSAV	SET	*
;;===============================================================================
	
	PUSHORG	HISAV

;;	SUBTTL	INTERRUPT ROUTINES

;* restart
RESTART	LDA	#1		;set read rom/write entire screen
	STA	PMEMCTL
	STA	MEMCTL
	JMP	INITALL

;* irq		NOTE: no dma operations are permitted in interrupt routine    
	ROUTINE	IRQ
	LDA	SCNLIN		;update colors
	CMPA	#4
	BHS	.1S
	LDU	#CRAM+$10
	LDD	PCRAM+$0A
	LDX	PCRAM+$0C
	LDY	PCRAM+$0E
	PSHU	D,X,Y
	LDD	PCRAM+4
	LDX	PCRAM+6
	LDY	PCRAM+8
	PSHU	D,X,Y
	LDD	PCRAM
	LDX	PCRAM+2
	PSHU	D,X
	CLR	PCRAM		;yes, black background
.1S	EQU	*
;	LOCAL
	SECTION IRQ
	LDA	PMEMCTL		;save ctl byte, set to read rom
	PSHS	A
	ORA	#1
	STA	PMEMCTL
	STA	MEMCTL
	LDA	PIA+$0C		;clear interupt
	LDA	#WDOGC		;stroke watch dog
	STA	WDOG
	LDA	PANMASK		;in scrolling enabled?
	BITA	#8
	LBEQ	.13S
;*
	LDD	SSPOS+1		;stars: compute change in screen s position
	SUBA	STSPOS
	ADDD	#$80
	STA	IRQTEMP+1	;save in temporary
	ADDA	STSPOS
	STA	STSPOS
	LDD	SLPOS+1		;compute change in screen l position
	SUBA	STLPOS
	ADDD	#$80
	STA	IRQTEMP		;save in temporary
	ADDA	STLPOS
	STA	STLPOS
	LDA	SLPOS+2		;find current star flavor
	BPL	.1S
	LDA	#$F0
	BRA	.2S
.1S	LDA	#$0F
.2S	STA	IRQTEMP+2	;save in temporary
	LDX	#STARRY		;update star positions:
	LDY	#0		;clear random star wrap flag (one per screen)
	CLRA			;set to read screen
	STA	PMEMCTL
	STA	MEMCTL
.3S	LDU	X		;star loop: get star old screen address
	LDA	OSTMASK,X	;get old pixel mask
	COMA			;erase pixel
	ANDA	U
	STA	U
.4S	LDD	IRQTEMP		;get change in position
	ADDA	X		;add to l coordinate
	CMPA	#DINHIB		;off screen?
	BLO	.7S
	LEAY	Y		;yes, test random wrap flag
	BNE	.5S		;first wrap?
	LEAY	1,Y		;yes, set flag
	FRANDOM	OSEED1,BYTE	;get a random s coordinate
	TFR	A,B
.5S	LDA	IRQTEMP		;wrap around l coordinate
	BPL	.6S
	LDA	#DINHIB-1
	BRA	.10S
.6S	CLRA
	BRA	.10S
.7S	TSTB			;add change to s coordinate
	BPL	.8S		;and check for wrap
	ADDB	1,X
	BCS	.10S
	BRA	.9S
.8S	ADDB	1,X
	BCC	.10S
.9S	LEAY	Y		;wrapped?, test random wrap flag
	BNE	.10S		;first wrap?
	LEAY	1,Y		;yes, set flag
	STB	IRQTEMP+3	;get random l coordinate
	FRANDOM	OSEED2,DINHIB
	LDB	IRQTEMP+3
.10S	STD	X		;save new coordinate
	LDU	X		;get in U
	LDB	U		;read screen
	BEQ	.11S		;anything there?
	CLR	OSTMASK,X	;yes, zero pixel mask to inhibit erase
	BRA	.12S		;don't write star
.11S	LDA	IRQTEMP+2	;get star flavor
	STA	OSTMASK,X	;save in mask
	ANDA	OSCOLOR,X	;mask color
	STA	U		;write star to screen
.12S	LEAX	OSTLEN,X	;next star
	CMPX	#STARRY+NSTARS*OSTLEN ;done?
	BNE	.3S
	LDA	#5		;switch back memory control
	STA	PMEMCTL
	STA	MEMCTL
.13S	INC	ESTATE		;tick display
;	LOCAL
	ENDSECTION IRQ
	SECTION	COINDOOR
	LDX	#DOTIMER	;handle coin door timers: get address of timers
.1S	LDB	X++		;is timer on?
	BEQ	.2S
	DEC	-2,X		;yes, count it down
	LDB	-1,X		;valid close flag set?
	BEQ	.2S
	LDA	SLAMTIM		;yes, no slam?
	BNE	.2S
	STA	-1,X		;flag not closed
	STA	-2,X		;reset timer
	JSR	[COINRO-DOTIMER-2,X] ;register coin, save X, uses none		;Fixme was: JSR	[COINROU-DOTIMER-2,X] 
.2S	CMPX	#ENDTIME	;done?
	BLO	.1S
	LDA	SLAMTIM		;slam switch timer on?
	BEQ	.3S
	DEC	SLAMTIM		;yes?, count it down
.3S	LDA	PIA+$0C		;coin door scan:  read pia
	STA 	IRQTEMP		;save reads
	EORA	DSCAN		;find changes
	BEQ	.4S		;any changes?
	LDB	IRQTEMP		;yes, get reads
	STB	DSCAN		;save reads
	LDX	#DOOR		;get table address
	BSR	SSCAN		;scan switches, save none, uses A,B,X,Y,U
.4S	LDA	NPLAYER		;play timer: game playing?
	BEQ	.5S
	LDA	AMDEMO		;yes, playing real game?
	BNE	.5S
	INC	PTIME+1		;yes, count play timer fraction, carry?
	BNE	.5S
	INC	PTIME		;yes, count play timer, carry?
	BNE	.5S
	RADIX	10
	LDD	#-60*60		;yes, re-initialize play timer for one minute	;Fixme was: LDD	#-60.*60.
	RADIX	16
	STD	PTIME
	LDB	#6		;add one minute of play time to the books
	JSR	AUD1S		;save none, uses none			;Fixme was: JSR	AUD1$
.5S	HOOK	INTVECT
	PULS	A		;restore ctl byte
	STA	PMEMCTL
	STA	MEMCTL
	RTI
	ENDSECTION COINDOOR
	
;;	SUBTTL	SCREEN READING ROUTINES AND SUBROUTINES

;* switch scan		pass vector table addr in X, reads in B, changes in A
SSCAN1	LEAX	4,X		;next switch vectors
	ASLB			;next switch read
SSCAN	ASLA			;check switch change
	BCC	SSCAN1		;changed?
	PSHS	CC,D,X		;save regs
	TSTB			;opened or closed?
	BPL	.1S              
	LEAX	2,X		;closed
.1S	JSR	[X]		;opened - save none, uses A,B,X,Y,U
	PULS	CC,D,X		;restore regs	
	BNE	SSCAN1		;done?
	RTS

;* right coin switch open
RCOINO	LDX	#DRCOIN
	BRA	COPEN

;* right coin switch close
RCOINC	LDX	#DRCOIN
	BRA	CCLOSE

;* center coin switch open
CCOINO	LDX	#DCCOIN
	BRA	COPEN

;* center coin switch close
CCOINC	LDX	#DCCOIN
	BRA	CCLOSE

;* left coin switch open
LCOINO	LDX	#DLCOIN

;* open coin switch routine	pass switch debounce timer address in X
COPEN	LDA	X		;is switch debounced?
	BNE	INVALCO
	LDA	#9		;yes?, set debounce time 
	STA	X
	STA	1,X		;set valid close flag
	RTS

;* left coin switch close
LCOINC	LDX	#DLCOIN

;* close coin switch routine	pass switch debounce timer address in X
CCLOSE	LDA	X		;is switch debounced?
	BEQ	INVALCO
	LDA	#2		;yes?, set debounce time
	STA	X
	RTS

;* invalid coin
INVALCO	CLR	X		;invalid coin, clear timer
	CLR	1,X		;clear valid close flag
	RTS

;* coin handling routines
COINRO	FDB	COINL,COINC,COINR

;* slam switch routine
	RADIX	10							;;(SLAM is a duplicate symbol in
									;; PHRASE.ASM...fixed)
SLAM	LDA	#120		;disable switches for 2 seconds		;Fixme was: LDA	#120.
	RADIX 	16
	STA	SLAMTIM
	RTS

;* null subroutine
NULL	RTS

;* trap vector TEMPORARY
TRAP	SWI

;* coin door switch vector table
DOOR	FDB	NULL		;bit 7 low  - sound board handshake
	FDB	NULL		;bit 7 high - sound board handshake
	FDB	SLAM		;bit 6 low  - slam switch
	FDB	SLAM		;bit 6 high - slam switch
	FDB	CCOINO		;bit 5 low  - center coin open
	FDB	CCOINC		;bit 5 high - center coin close
	FDB	LCOINO		;bit 4 low  - left coin open
	FDB	LCOINC		;bit 4 high - left coin close
	FDB	NULL		;bit 3 low  - unused
	FDB	NULL		;bit 3 high - high score reset
	FDB	RCOINO		;bit 2 low  - right coin open
	FDB	RCOINC		;bit 2 high - right coin close
	FDB	NULL		;bit 1 low  - unused
	FDB	$F003		;bit 1 high - advance switch in diagnostics
	FDB	NULL		;bit 0 low  - auto
	FDB	NULL		;bit 0 high - manual

	PULLORG	HISAV

;;	SUBTTL	INTERRUPT VECTORS

	IFDEF	ROM
	PUSHORG	$FFF0
	ELSE
	PUSHORG	$EFF0
	ENDIF
	FDB	RESTART,RESTART,RESTART,RESTART,IRQ,RESTART,RESTART,RESTART
	PULLORG
	
	PULLORG ROMSAVE		;;Had to add this to get the ROMTEST sub-macro working again