	INCLUDE "../SAM/START.ASM"
	
;===============================================================================
; EQUs to remove later
;TRASCOM	EQU	$3807	;TRASCOM
;TNLOAD	EQU	$38BA	;NEWTUNE
;CRYTBL	EQU	$4F98	;SAMTABLE
;SPANEL	EQU	$37DA	;EXECJNK
;SCROLL	EQU	$36C3	;EXECJNK
;JOYSWI	EQU	$4E01	;SAMTABLE
;JOYRTP	EQU	$4E09	;SAMTABLE
;SINCOS	EQU	$47DA	;FUNCTION
;CHGOBJ	EQU	$43B8	;DRAWOBJ
;PLSHOOT	EQU	$391D	;PLSHOOT
;SSCAN	EQU	$E146	;IRQ
;===============================================================================

	ORG	ROMSAV

;	SUBTTL	EXECUTIVE ROUTINES

;* miscellaneous exec stuff
;	ROUTINE	EXECJNK
EXECJNK	LDU	TLEVEL		;save current task pointer > uses A,B,X,U
	LDD	PRTASK
	STD	OTPTR,U
	INC	TCLOCK		;increment task clock
	BEQ	.4S		;find this ticks task list
	LDX	#TASK1
	LDB	#OTLEN
	LDA	TCLOCK
.1S	ABX
	LSRA
 	BCC	.1S
	LDA	OTBACK,X	;increment this ticks task backlog counter
	INCA
	BNE	.2S		;* * *TEMPORARY
	SWI			;* * *TRAP
.2S	STA	OTBACK,X
	CMPA	OTBACK,U	;point U to most backlogged task
	BLO	.4S
	BNE	.3S		;equally backlogged?
	CMPX	TLEVEL		;yes, use shortest time task list
	BHS	.4S
.3S	LEAU	X
.4S	LDA	OTBACK+TASK1	;increment task 1 backlog counter
	INCA
	BNE	.5S		;* * *TEMPORARY
	SWI			;* * *TRAP
.5S	STA	OTBACK+TASK1
	CMPA	OTBACK,U	;point U to most backlogged task
	BLO	.6S
	LDU	#TASK1
.6S	STU	TLEVEL		;set current level to most backlogged task
	LDD	OTPTR,U		;set next task pointer to most backlogged task
	STD	PRTASK
	JSR	TRASCOM		;trash compact storage  save none, uses A,B,X,U
;	LOCAL
	SECTION TNTIME
	LDA	TNTIME		;tune playing?
	BEQ	.1S		
	DEC	TNTIME		;yes, decrement tune timer, next instruction?
	BNE	.1S
	LDU	TNPC		;yes,  save none, uses A,B,X,U
	JSR	TNLOAD
.1S	RANDOM	OSEED1,WORD	;randomize OSEED1
	RANDOM	OSEED2,BYTE	;randomize OSEED2
	ANDA	#06		;random crystal animation routine
	LDX	#CRYTBL
	LDD	A,X
	STD	CRYANI
;	LOCAL
	ENDSECTION TNTIME
	SECTION SCANPANEL
	JSR	SPANEL		;scan control panel, uses A,B,X,Y,U, save none
	LDA	NPLAYER		;attract mode?
	BNE	.5S
	RTS			;yes?, stop here
;*
.5S	CLR	PLACCEL		;zero player acceleration
	LDD	#2222		;draw player scanner image
	STD	8180
	ENDSECTION SCANPANEL
	;LOCAL
	LDA	PMEMCTL		;write inhibit off
	PSHS	A
	ANDA	#~$4		;Fixme was: ANDA	#!N4
	STA	PMEMCTL
	STA	MEMCTL
	LDD	#70E!404	;Fixme was: LDD	#70E!X404	;draw scanner screen border: * * * FOR DMA ERROR
	STD	DHIGH
	LDD	#ISBORD
	STD	DSOUR
	LDD	SBORD		;has border moved?
	CMPD	PSBORD
	BEQ	SCAN2S		;Fixme was: BEQ 2$ (Had to use global labels because of the HOOK macro, I'm assuming)
	STD	TEMP		;yes, save new position
	LDD	PSBORD		;erase old scanner screen border
	ADDA	#3
	RORA
	STD	DDEST
	LDA	#DWBL+DZSP+DCNS
	BCC	SCAN1S		;Fixme was: BCC 1$
	ORA	#DTFL
SCAN1S	STA	DCTRL
	LDD	TEMP		;save new border
	STD	PSBORD
SCAN2S	ADDA	#3		;draw scanner border
	RORA
	STD	DDEST
	LDA	#DWBL+DZSP+DCNS
	BCC	SCAN3S		;Fixme was: BCC 3$
	ORA	#DTFL
SCAN3S	LDB	ZONECOL		;get zone color
	STB	DCONS
	STA	DCTRL
	PULS	A		;write inhibit on
	STA	PMEMCTL
	STA	MEMCTL
	CLR	DCONS		;zero dma constant for erase
	HOOK	EXEVECT
	LDY	#WPLAYER	;get player object wsa in Y
	LDA	PANMASK		;player joystick on?
	BITA	#4
	LBEQ	SCROLL
;	LOCAL
	SECTION JOYSTICK
	LDX	#JOYSWI		;yes, joystick routine:  get joystick conv table
	LDA	PIA+4		;read joystick pia
	ANDA	#$70		;s position only
	RPT	4,LSRA		;convert to direction and magnitude
	LDB	A,X             
	ASLB			;shift magnitude for rectangular to polar convs
	ASLB                    
	STB	TEMP		;save s direction and magnitude
	LDA	PIA+4		;read joystick pia
	ANDA	#07		;l position only
	LDB	A,X		;convert to direction and magnitude
	ORB	TEMP		;add in s magnitude for rect to polar conversion
	LBEQ	SCROLL		;zero magnitude?, skip accelerate and rotate
	LDX	#JOYRTP		;get r-p conversion table
	LDD	B,X		;get radius and angle
	STA	PLACCEL		;save radius
	LDA	PIA+4		;convert angle to four quadrants
	BMI	.1S 		
	NEGB
.1S 	BITA	#8
	BNE	.2S 
	NEGB
	ADDB	#80
.2S 	SUBB	PLYRANG		;rotate player: find angle from joystick to ship
	LDA	PLACCEL		;get joystick radius
	STB	TEMP		;save difference angle
	MUL			;multiply joystick radius by difference angle
	BPL	.3S              
	SUBA	PLACCEL         
.3S	ADDD	#80		;round off correctly
	TFR	A,B		;get product into B
	ADDA	PLYRANG		;rotate ship
	STA	PLYRANG		;save new rotation angle
	JSR	SINCOS		;compute players unit vector
	STD	PLSUNIT		;save players unit vector
	LDB	TEMP		;check angle from joystick to player ship
	ADDB	#20             
	CMPB	#40             
	BHS	SCROLL		;to great?, skip acceleration
	LDB	PLLUNIT		;accelerate player:  get l unit vector
	SEX			;get l component of unit vector
	RPT	2,ASLB,ROLA	;scale l component for maximum velocity
	SUBD	OLVEL,Y		;compute difference from players l velocity
	STA	TEMP		;multiply by joystick radius
	LDA	PLACCEL
	MUL
	STA	TEMP+2
	LDA	PLACCEL
	LDB	TEMP
	MUL
	BPL	.6S
	SUBA	PLACCEL
.6S	ADDB	TEMP+2
	ADCA	#0
	RPT	3,ASRA,RORB	;scale down l acceleration
	ADCB	#0		;round off l acceleration
	ADCA	#0              
	ADDD	OLVEL,Y		;add to player l velocity
	STD	OLVEL,Y		;save new player l velocity
	LDB	PLSUNIT		;get s component of unit vector
	SEX                     
	RPT	3,ASLB,ROLA	;scale s component for maximum velocity
	SUBD	OSVEL,Y		;compute difference from players s velocity
	STA	TEMP		;multiply by joystick radius
	LDA	PLACCEL
	MUL
	STA	TEMP+2
	LDA	PLACCEL
	LDB	TEMP
	MUL
	BPL	.5S
	SUBA	PLACCEL
.5S	ADDB	TEMP+2
	ADCA	#0
	RPT	3,ASRA,RORB	;scale down s acceleration
	ADCB	#0		;round off s acceleration
	ADCA	#0
	ADDD	OSVEL,Y		;add to player s velocity
	STD	OSVEL,Y		;save new player s velocity
	ENDSECTION JOYSTICK
SCROLL	LDA	PANMASK		;scrolling and stars on?
	BITA	#8
	SECTION SCROLL
	BNE	.1S
	RTS			;no?, that's all folks
;*
.1S	LDA	OLPOS,Y		;hard scrolling:
	LDB	OLPOS+1,Y	;compute next player l screen position
	ADDD	OLVEL,Y
	ADDD	SLVEL
	CMPA	#BHSCROL	;check bottom limit
	BLO	.2S
	CMPA	#THSCROL	;check top limit
	BLO	.3S
.2S	LDD	OLVEL,Y		;hard scroll l axis
	NEGD
	STD	SLVEL
.3S	LDD	OSVEL,Y		;compute next player s screen position
	ADDD	SSVEL
	ADDD	OSPOS,Y
	CMPA	#LHSCROL	;check left limit
	BLO	.4S
	CMPA	#RHSCROL	;check right limit
	BLO	.5S
.4S	LDD	OSVEL,Y		;hard scroll s axis
	NEGD
	STD	SSVEL
.5S	EQU	*
	ENDSECTION SCROLL
;	LOCAL
	LDD	PLSUNIT		;soft scrolling: get player ship unit vector
	RPT	3,ASRA		;scale down to add to players position
	RPT	3,ASRB
	STD	TEMP		;save players angle vector
	LDB	#7B		;compute player s axis distance from center
	SUBB	OSPOS,Y
	ASRB			;convert it to bytes
	SUBB	TEMP		;add s component of players angle
	SEX			;scale down
	RPT	3,ASLB,ROLA
	SUBD	OSVEL,Y		;add to players screen s velocity for damping
	SUBD	SSVEL
	RPT	5,ASRA,RORB	;adjust s axis scrolling velocity
	PSHS	D
	ASRA
	RORB
	ADDD	S++
	ADDD	SSVEL
	STD	SSVEL
	LDB	#38		;compute player l axis distance from center
	SUBB	OLPOS,Y
	SUBB	TEMP+1		;add l component of players angle
	SEX			;scale down
	RPT	3,ASLB,ROLA
	SUBD	OLVEL,Y		;add to players screen l velocity for damping
	SUBD	SLVEL
	RPT	5,ASRA,RORB	;adjust l axis scrolling velocity
	PSHS	D
	ASRA
	RORB
	ADDD	S++
	ADDD	SLVEL
	STD	SLVEL
;	LOCAL
	LDD	SLVEL		;add l axis screen velocity to position
	BPL	.1S
	ADDD	SLPOS+1
	BCS	.2S
	DEC	SLPOS
	BRA	.2S
.1S	ADDD	SLPOS+1
	BCC	.2S
	INC	SLPOS
.2S	STD	SLPOS+1
	LDD	SSVEL		;add s axis screen velocity to position
	BPL	.3S
	ADDD	SSPOS+1
	BCS	.4S
	DEC	SSPOS
	BRA	.4S
.3S	ADDD	SSPOS+1
	BCC	.4S
	INC	SSPOS
.4S	STD	SSPOS+1
	LDB	PLYRANG		;get player rotation angle
	ADDB	#4		;compute correct angle image
	ANDB	#$F8
	LDX	#IPLAYER
	ABX
	CMPX	OIDESC,Y	;new image?
	BEQ	.5S
	STX	ONIDESC,Y	;yes, setup to change image
	LDX	#CHGOBJ
	STX	ODRWVEC,Y
.5S	LDA	OLPOS,Y		;compute scanner screen l edges
	RPT	1,LSRA
	NEGA
	STA	SCBEDGE		;save scanner screen bottom edge
	ADDA	#3A
	STA	SCTEDGE		;save scanner screen top edge
	LDA	OSPOS,Y		;compute scanner screen s edges
	RPT	2,LSRA
	NEGA
	STA	SCLEDGE		;save scanner screen left edge	
	ADDA	#3F
	STA	SCREDGE		;save scanner screen right edge
;	LOCAL
	SECTION FLASHING_SHIP_TIMER
	DEC	FLASHTI		;count down flashing ship timer
	BPL	.1S		;time to erase?
	RADIX 10
	LDD	#(29<<8)+DCNS+DWBL ;Fixme was: LDD #29.!<8+DCNS+DWBL ;yes, set timer to draw next and erase ship
	RADIX 16
	BRA	.2S
.1S	DEC	FLASHTI		;count down flashing ship timer
	BPL	.3S		;time to draw?
	RADIX 10
	LDD	#(28<<8)+DWBL	;Fixme was: LDD	#28.!<8+DWBL ;yes, set timer to erase next and draw ship
	RADIX 16
.2S	STA	FLASHTI		;save new timer setting
	LDA	SHIPS		;get ship count
	JSR	UPSHIPS		;erase or draw it,  save none, uses none
.3S	LDA	RAPTIME		;get rapid fire count, is it on?
	BEQ	.5S              
	DEC	RAPTIME		;yes, count time
	BNE	.5S		;time to fire
	JSR	PLSHOOT		;yes, fire a shot
	LDX	#CONTFI		;is continuous fire enabled?
	JSR	RCMOSA
	BEQ	.5S
	LDA	RAPRATE		;yes, get rate
	RADIX 10
	CMPA	#10		;Fixme was: CMPA #10. ;at slowest?
	RADIX 16
	BHS	.4S
	ADDA	#0		;no, increase it (disabled for now)
	STA	RAPRATE
.4S	STA	RAPTIME		;set count
.5S	RTS
	ENDSECTION FLASHING_SHIP_TIMER
	
;* scan control panel
SPANEL	LDA	PIA+6		;read B side pia > uses A,B,X,Y,U
	STA 	TEMP		;save B side reads
	EORA	SCAN		;find B side changes
	ANDA	PANMASK		;mask switches
	BNE	.1S		;any changes?
	RTS                     
.1S	LDB	TEMP		;yes, get B side reads
	STB	SCAN		;save B side reads
	LDX	#PANEL		;get B side table address
	JMP	SSCAN		;scan switches, save none, uses A,B,X,Y,U

;* overload handling
VRLOAD	LDA	#-1		;white background > uses none
	STA	PCRAM		;;(This gets overwritten by a NOP patch in RICHFIXE.ASM)
	DEC	ESTATE
	JMP	EXEC

;	PULLORG	ROMSAVE
ROMSAV	SET	*