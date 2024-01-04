;;===============================================================================
;;
;;  I feel pretty confident that this was originally Sam's code and then Rich
;;  modified it and put it here.  Rich's comments usually start with an asterisk,
;;  while Sam's comments usually don't have an asterisk and are mostly lowercase.
;;
;;  The lack of $ for hex values is also seen in the original file, which is how
;;  Sam wrote code for his section.  I have restored the $ symbols for hex numbers
;;  here and in Sam's files because it's easier to read that way.
;;
; EQUs to remove later
taunt	EQU	$6C80 
;;===============================================================================

	PUSHORG	ROMSAVE

;* routine for sinistar leaving sector
	ROUTINE	LSSINI								;; This gets patched over with SAM/FIXLSSIN.ASM ($5DBE)
	jsr	Sinhibit	;* Re-initialize Sinistar attack personality.
	LEAS	2,S		;never return to in-sector
	LDD	OSLPOS,Y	;transfer sector coordinates into supersector
	PSHS	A
	SEX
	STD	SSSPOS
	PULS	B
	SEX
	STD	SSLPOS
	DEC	SINISEC		;flag sinistar out of sector
	JSR	DISPE		;erase player message area
	WAKE_HERE
	LDB	OSLVEL,Y	;add l and s velocity to supersector position
	ADDB	SCLVEL
	SEX
	ADDD	SSLPOS
	STD	SSLPOS
	LDB	OSSVEL,Y
	ADDB	SCSVEL
	SEX
	ADDD	SSSPOS
	STD	SSSPOS
	ADDD	#$80		;is it in sector?
	TSTA
	BNE	.1S
	LDD	SSLPOS
	ADDD	#$80
	TSTA
	BEQ	.11S
.1S	LDX	SSSPOS		;yes, push supersector coordinates on stack
	LDD	SSLPOS
	PSHS	D,X
	BPL	.2S		;get absolute values of coords msbyte in A and B
	NEGA
.2S	LDB	SSSPOS
	BPL	.3S
	NEGB
.3S	LSR	S		;divide coords on stack by 2 until A and B are 0
	ROR	1,S
	LSR	2,S
	ROR	3,S
	TSTA
	BNE	.4S
	TSTB
	BEQ	.5S
.4S	LSRA
	LSRB
	BRA	.3S
.5S	LDA	1,S		;get scaled down coords off of stack
	LDB	3,S
	LEAS	4,S
	JSR	RECTANG		;convert to angle
	ADDA	#$20		;project angle onto edge on sector
	LDB	#$80
	ASLA
	BCS	.7S
	ASLA
	BCC	.6S
	COMA
	ADDA	#$80
	DECB
	BRA	.10S
.6S	ADDA	#$80
	DECB
	BRA	.9S
.7S	ASLA
	BCC	.8S
	ADDA	#$80
	BRA	.10S
.8S	COMA
	ADDA	#$80
.9S	EXG	A,B
.10S	STD	OSLPOS,Y	;save virtual sector edge position in scanner
	SLEEP	LOOP
;*
.11S	CLR	SINISEC		;flag sinistar in sector
	pshs	Y		;* Save message registers
	DISPLAY	RED
	PHRASE	RED,35,Sinistar,is,now
	PHRASE	RED,35,in,scanner,range
	puls	Y		;* Restore message resgisters
	jsr	taunt		;* Let the Sinistar taunt the player
	SLEEP	VSCAN		;wake in normal scanner loop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE	SET	*		;; Save the current address

	ORG	PHRSAV		;; Jump over to PHRSAV to save our pointers
	FDB	_NOW		
	FDB	_IN
	FDB	_SCANNER
	FDB	_RANGE

PHRSAV	SET	*		;; Mark the new address for PHRSAV to add
				;; more phrases later

	ORG	ROMSAVE		;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PULLORG	ROMSAVE