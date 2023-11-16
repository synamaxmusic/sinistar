	INCLUDE "../SAM/START.ASM"
	
;===============================================================================
; EQUs to remove later
;QCOIN	EQU	$4DFC	

	ORG	ROMSAV

	;SUBTTL	TUNE ROUTINE

;* new tune		pass tune address in word after call
;	ROUTINE	NEWTUNE
NEWTUNE	PSHS	D,X,U		;> uses none
	LDX	6,S		;get tune address and advance return stack
	LDU	X++
	STX	6,S
	LDA	AMDEMO		;in attract mode demo?
	BEQ	NUTUNE1		;Fixme was: BEQ 1$
	CMPU	#QCOIN		;yes, is it coin sound?
	BNE	NUTUNE2		;only play coin sound in attract mode
NUTUNE1	LDA	U+		;check priority
	CMPA	TNPRIO
	BLS	NUTUNE2
	CLRA			;clear repeat counters addresses
SS	SET	TNREPT
	REPT	NTNREPT
	STA	SS		;Fixme was .$$
SS	SET	SS+OTNRLEN
	ENDM			;Fixme was: ENDR
	BSR	TNLOAD		;load tune, save none, use A,B,X,U
NUTUNE2	PULS	D,X,U,PC

;* tune loader		pass tune address in U
TNLOAD	LDA	U		;fetch first instruction > uses A,B,X,U
	BITA	#$C0		;repeat or done?
	BNE	.7S
	TSTA			;yes, done?
	BNE	.1S
	CLR	TNPRIO		;zero priority
	LDA	#-1		;clear sound lines
	STA	PIA+0E
	LDA	#1E!1F		;Fixme was: LDA	#1E!X1F ;background sound off, for now
	STA	PIA+0E
	RTS			;quit
.1S	LDX	#TNREPT		;repeat, find counter
.2S	CMPU	X		;is this the counter?		
	BEQ	.5S
	LEAX	OTNRLEN,X	;no, check next
	CMPX	#TNREPT+NTNREPT*OTNRLEN
	BNE	.2S
	LDX	#TNREPT		;new repeat counter, find available counter
.3S	LDB	X		;this one available?
	BEQ	.4S
	LEAX	OTNRLEN,X	;no, check next
	BRA	.3S
.4S	STU	X		;make this one counter
	STA	OTNRCNT,X	
.5S	DEC	OTNRCNT,X	;decrement this repeat counter
	BEQ	.6S		;done?
	LDA	1,U		;repeat, find offset
	LEAU	A,U		;add to tune program counter
	BRA	TNLOAD		;load next instruction
.6S	CLR	X		;yes, clear repeat counter address to free it
	LEAU	2,U		;advance tune program counter
	BRA	TNLOAD		;load next instruction 
.7S	BPL	.8S		;sound?
	LDB	#-1		;yes?, clear sound lines
	STB	PIA+0E
;* THIS IS WHERE THE SOUND IS ACTUALLY PLAYED
	STA	PIA+0E		;play sound
	LEAU	1,U		;advance tune program counter
	BITA	#40		;time?
	BEQ	TNLOAD
	BRA	.9S		;yes, set timer
.8S	LDA	U+		;set priority
	ANDA	#3F
	STA	TNPRIO
.9S	LDA	U+		;set tune timer
	STA	TNTIME
	STU	TNPC		;save tune program counter
	RTS

;	PULLORG	ROMSAVE
ROMSAV	SET	*