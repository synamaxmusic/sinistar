	INCLUDE "../SAM/START.ASM"

;===============================================================================
; EQUs to remove later
;ALLOC	EQU	$46FB	;SLEEP1
;ESCIVEL	EQU	$5035	;SAMTABLE
;CSCRON	EQU	$5037	;SAMTABLE
;CCRYSTA	EQU	$4D2D	;SAMTABLE
;DCRYWOR	EQU	$4547	;DRAWOBJ
;===============================================================================
	
	ORG	ROMSAV

SCANNER
	;SUBTTL	SCANNER ROUTINES

;* scanner position update task
SCANVEL	LDD	SLPOS		;compute change in l scroll relative to player
	SUBB	OLPOS+WPLAYER	
	SBCA	#0
	RPT	1,ASRA,RORB
	SUBB	OSULPOS,Y
	STB	SCLVEL		;save l scroll relative to player
	ADDB	OSULPOS,Y
	STB	OSULPOS,Y	;save l scroll relative to player
	LDD	SSPOS		;compute change in s scroll relative to player
	SUBB	OSPOS+WPLAYER
	SBCA	#0
	RPT	2,ASRA,RORB
	SUBB	OSUSPOS,Y
	STB	SCSVEL		;save s scroll relative to player
	ADDB	OSUSPOS,Y
	STB	OSUSPOS,Y	;save s scroll relative to player
	LDA	OLPOS+WPLAYER	;compute scanner screen border screen l position
	LDB	#18
	MUL
	COMA
	STA	SBORD		;save scanner screen border screen l position
	LDA	OSPOS+WPLAYER	;compute scanner screen border screen s position
	LDB	#0C
	MUL
	NEGA
	ADDA	#7F
	STA	SBORD+1		;save scanner screen border screen s position
	SLEEP	LOOP

;* get scanner object	char after call, positn in D, returns scanner wsa in X
;	ROUTINE	GETSCN
GETSCN	PSHS	D,U		;> uses X
	LDX	4,S		;get return address
	LDU	X++		;get char descriptor addr, advance return addr
	STX	4,S		;save new return address
	inc	[OCDInd,U]	;* increment population counter
	LDB	OOSCLEN,U	;get size of scanner workspace
	CLRA                    
	JSR	ALLOC		;get workspace  save U,Y, uses A,B,X
	LDD	#VSCAN		;initialize wakeup address for visible loop
	TST	OVSCFLG,U	;test visible/invisible on scanner flag
	BNE	.1S              
	LDD	#ISCAN		;change wakeup address for invisible loop
.1S	STD	OEXEC,X	        
	STU	OSCHAR,X	;initialize characteristics
	CLRD			;zero screen workspace addr (no screen object)
	STD	OSSCWSA,X       
	LDD	[SCANIVE]	;get scanner velocity from table
	STD	OSLVEL,X        
	LDD	SCANIVE		;advance scanner velocity table pointer
	ADDD	#2              
	CMPD	#ESCIVEL	;beyond table?
	BLO	.2S              
	LDD	#SCIVELT	;yes, start at beginning of table
.2S	STD	SCANIVE		;save new scanner velocity table pointer
	LDD	S		;set initialize position
	STD	OSLPOS,X        
	CMPD	#8080		;does it need a random position? (pos=$8080)
	LBNE	.9S              
 	RANDOM	OSEED1,WORD	;yes, set position randomly
	STD	OSLPOS,X        
	TST	EDGE		;does it need to be placed on edge? (edge <> 0)
	LBEQ	.12S             
	RANDOM	OSEED2,WORD	;add a random factor to scanner scrolling
	ANDB	#7
	ANDA	#7
	SUBB	#4
	SUBA	#4
	ADDB	SCSVEL
	ADDA	SCLVEL
	PSHS	D		;save scrolling for sign
	BPL	.17S		;find absolute value of l scrolling
	NEGA                    
.17S	PSHS	A		;save it
	TSTB			;find absolute value of s scrolling
	BPL	.18S             
	NEGB                    
.18S	ADDB	S		;add for absolute sum
	RANDOM	OSEED1,BYTE	;get a random number between 0 and absolute sum
	MUL                     
	CMPA	S+		;compare with absolute l scrolling
	BHI	.3S		;which edge?
	LDB	S		;place on top or bottom edge
	SEX
	ADDA	#80
	STA	OSLPOS,X
	BRA	.4S
.3S	LDB	1,S		;place on left or right edge
	SEX
	ADDA	#80
	STA	OSSPOS,X
.4S	LEAS	2,S
	LDD	OSLVEL,X	;is it stationary relative to l edge?
	ADDA	SCLVEL
	BNE	.5S
	PSHS	A		;yes, raise or lower it l velocity
	FRANDOM	OSEED2+1,BYTE
	BMI	.16S
	INC	OSLVEL,X
	INC	S
	BRA	.13S
.16S	DEC	OSLVEL,X
	DEC	S
.13S	PULS	A
.5S	ADDA	OSLPOS,X	;is it going to scroll off the sector?
	BVC	.6S
	COM	OSLPOS,X	;yes, place it on the other side
.6S	ADDB	SCSVEL		;is it stationary relative to s edge?
	BNE	.7S
	PSHS	A		;yes, raise or lower it s velocity
	FRANDOM	OSEED2+1,BYTE
	ASLA
	BMI	.14S
	INC	OSSVEL,X
	INCB
	BRA	.15S
.14S	DEC	OSSVEL,X
	DECB
.15S	PULS	A
.7S	ADDB	OSSPOS,X	;is it going to scroll off the sector?	
	BVC	.12S
	COM	OSSPOS,X	;yes, place it on the other side
	BRA	.12S
.9S	TST	SFREE		;are there more screen objects available?
	BEQ	.12S
	SUBD	OSCHIGH,U	;yes, add scanner size of object
	CMPA	SCTEDGE		;below top edge of screen?
	BGE	.12S
	CMPB	SCREDGE		;yes, left of right edge of screen?
	BGE	.12S
	LDD	OSLPOS,X	;yes, get position
	ADDD	OSCHIGH,U	;add scanner size of object
	CMPA	SCBEDGE		;above bottom edge of screen?
	BLE	.12S
	CMPB	SCLEDGE		;yes, right of left edge of screen? 
	BLE	.12S
	PSHS	Y		;place on screen: save Y register
	TFR	X,Y		;scanner workspace in Y	
	TFR	U,D		;get characterics in D
	JSR	GETCOBJ		;get screen object  save none, uses A,B,X
	LDA	OSLPOS,Y	;compute l position
	SUBA	SCBEDGE
	RPT	1,ASLA
	STA	OLPOS,X
	LDA	OSSPOS,Y	;compute s position
	SUBA	SCLEDGE
	BPL	.10S
	CLRA
.10S	RPT	2,ASLA
	STA	OSPOS,X		;initialize s position
	STA	OLEFT,X
	ADDA	[OIDESC,X]
	BCC	.11S
	LDA	ODWIDTH,X
	NEGA
	STA	OSPOS,X
	STA	OLEFT,X
.11S	JSR	FINON		;finish onscreen initialization
	TFR	Y,X		;scanner worspace in X
	PULS	Y		;restore Y
.12S	LDU	#TASK8		;get sleep list keystone address
	LDD	U		;link-in
	STD	OTLINK,X
	LDD	OINDEX,X
	STD	U
	PULS	D,U,PC

;* scroll scanner
;	ROUTINE	SCROLSC
SCROLSC	LDU	OSCHAR,Y	;characteristic table addr in U > uses A,B,X,U
	LDD	OSLVEL,Y	;get l and s velocity
	ADDA	SCLVEL		;add l scanner scroll velocity
	ADDA	OSLPOS,Y	;add to l position
	BVS	.1S		;out of sector?
	ADDB	SCSVEL		;no, add s scanner scroll velocity
	ADDB	OSSPOS,Y	;add to s position
	BVC	.2S		;out of sector?
.1S	JMP	[OLSVEC,U]	;yes, uses A,B,X,U
.2S	STD	OSLPOS,Y	;no, save new position
	SUBD	OSCHIGH,U	;add scanner size of object
	CMPA	SCTEDGE		;below top edge of screen?
	BGE	.3S              
	CMPB	SCREDGE		;yes, left of right edge of screen?
	BGE	.3S              
	LDD	OSLPOS,Y	;yes, get position
	ADDD	OSCHIGH,U	;add scanner size of object
	CMPA	SCBEDGE		;above bottom edge of screen?
	BLE	.3S              
	CMPB	SCLEDGE		;yes, right of left edge of screen? 
	BLE	.3S              
	LDA	SFREE		;yes, are we out of screen available objects?
	LBNE	PLACEON         
.3S	RTS			;don't place on screen

;* visible scanner task off screen
VSCAN	BSR	ERASCAN		;erase scanner image  save Y, uses A,B
	BSR	SCROLSC		;scroll scanner  save Y, uses A,B
	BSR	DRWSCAN		;no, draw scanner image  save Y, uses A,B,X
	SLEEP	LOOP

;* invisible scanner task off screen
ISCAN	BSR	SCROLSC		;scroll scanner
	SLEEP	LOOP

;* erase scanner image	pass scanner task workspace address in Y
ERASCAN	LDA	#30		;compute screen l pos   > uses A,B and TEMP 0,1
	LDB	OSLPOS,Y
	MUL
	BPL	.1S
	SUBA	#30
.1S	ASRA
	PSHS	CC		;save flavor
	ADDA	#81
	STA	TEMP
	LDA	#30		;compute screen s pos
	LDB	OSSPOS,Y
	MUL
	BPL	.2S
	SUBA	#30
.2S	ADDA	#80
	STA	TEMP+1
	PULS	CC
	BCS	.3S
	LDD	#0		;bottom flavor - store to erase
	STD	[TEMP]
	RTS
.3S	LDA	PMEMCTL		;top flavor - dma to erase    write inhibit off
	PSHS	A
	ANDA	#-$5		;Fixme was: ANDA	#!N4
	STA	PMEMCTL
	STA	MEMCTL
	LDD	#202!404	;Fixme was: LDD	#202!X404 ;* * * TEMPORARY FOR DMA BUG
	STD	DHIGH
	LDD	TEMP
	STD	DDEST
	LDD	#ISCANN		;Fixme was: LDD	#ISCANNE
	STD	DSOUR
	LDA	#DWBL+DZSP+DCNS
	STA	DCTRL
	PULS	A		;write inhibit on
	STA	PMEMCTL
	STA	MEMCTL
	RTS

;* draw scanner image   	pass scanner workspace address in Y, char table in U
DRWSCAN	LDA	#30		;compute screen l pos  > uses A,B,X and TEMP 0,1
	LDB	OSLPOS,Y
	MUL
	BPL	.1S
	SUBA	#30
.1S	ASRA
	PSHS	CC		;save flavor
	ADDA	#81
	STA	TEMP
	LDA	#30		;compute screen s pos
	LDB	OSSPOS,Y
	MUL
	BPL	.2S
	SUBA	#30
.2S	ADDA	#80
	STA	TEMP+1
	PULS	CC
	BCS	.3S
	LDD	OBSCIMG,U	;bottom flavor - store to draw
	STD	[TEMP]
	RTS
.3S	LDA	PMEMCTL		;top flavor - dma to draw    write inhibit off
	PSHS	A
	ANDA	#-$5		;Fixme was: ANDA	#!N4
	STA	PMEMCTL
	STA	MEMCTL
	LDD	#202!404	;Fixme was: LDD	#202!X404 ;* * * TEMPORARY FOR DMA BUG
	STD	DHIGH
	LDD	TEMP
	STD	DDEST
	LEAX	OTSCIMG,U
	STX	DSOUR
	LDA	#DWBL+DZSP
	STA	DCTRL
	PULS	A		;write inhibit on
	STA	PMEMCTL
	STA	MEMCTL
	RTS

;* scanner object on screen transition   scanner wsa in Y, char in U
;	ROUTINE	PLACEON
PLACEON	LDD	SCTEDGE		;find closest edge:  compute distance to top
	ADDD	OSCHIGH,U	
	SUBA	OSLPOS,Y	;save distance to top
	STA	TEMP
	LDX	#OTOPON+CSCRON	;save top edge routine address
	SUBB	OSSPOS,Y	;compute distance to right
	CMPB	TEMP		;closer?
	BGE	.1S
	STB	TEMP		;yes, save distance to right
	LDX	#ORIGON+CSCRON	;save right edge routine address
.1S	LDD	OSLPOS,Y	;compute distance to bottom
	ADDD	OSCHIGH,U
	SUBA	SCBEDGE
	CMPA	TEMP		;closer?
	BGE	.2S
	STA	TEMP		;yes, save distance to bottom
	LDX	#OBOTON+CSCRON	;save bottom edge routine address
.2S	SUBB	SCLEDGE		;compute distance to left
	CMPB	TEMP		;closer?
	BGE	.3S
	LDX	#OLEFON+CSCRON	;yes, save left edge routine address
.3S	CMPU	#CCRYSTA	;is object a crystal?
	BNE	.4S
	LEAX	8,X		;yes, use non-clipping on screen routine
.4S	LDD	X
	STD	TEMP+1
	TFR	U,D		;get characterics in D
	JSR	GETCOBJ		;get screen object  save none, uses A,B,X
	JMP	[TEMP+1]	;initialize position for edge
;* place clipping object on top edge
CONTOP	LDD	#$FF00+DINHIB-1	;initialize l position
	STD	OLPOSF,X
	BRA	CTOPBOT
;* place clipping object on bottom edge
CONBOT	LDA	[OIDESC,X]	;get height, initialize l position
	NEGA
	STA	OLPOS,X
CTOPBOT	CLR	OSTATUS,X	
	LDA	OSSPOS,Y	;compute s position
	SUBA	OSCWIDE,U
	SUBA	SCLEDGE
	BMI	CONLEF		;left clipped?, place on left edge
	RPT	2,ASLA
	STA	OSPOS,X		;initialize s position
	STA	OLEFT,X
	ADDA	ODWIDTH,X
	BCC	FINON
;* place clipping object on right edge
CONRIG	LDA	#$FF		;initialize s position
	STA	OSPOS,X
	STA	OLEFT,X
	LDA	#40		;set right clip flag
	BRA	CRIGLEF
;* place clipping object on left edge
CONLEF	CLR	OLEFT,X		;initialize s position
	LDA	ODWIDTH,X
	NEGA
	STA	OSPOS,X
	LDA	#80		;set left clip flag
CRIGLEF	STA	OSTATUS,X
	LDA	OSLPOS,Y	;compute l position
	SUBA	OSCHIGH,U
	SUBA	SCBEDGE
	RPT	1,ASLA
	STA	OLPOS,X
	BRA	FINON
;* place non-clipping on top edge
NONTOP	LDD	#$FF00+DINHIB-1	;initialize l position
	STD	OLPOSF,X
	BRA	NTOPBOT
;* place non-clipping on bottom edge
NONBOT	CLR	OLPOS,X		;get height, initialize l position
NTOPBOT	LDA	OSSPOS,Y	;compute s position
	SUBA	SCLEDGE
	BMI	NONLEF		;left clipped?, place on left edge
	RPT	2,ASLA
	STA	OSPOS,X		;initialize s position
	STA	OLEFT,X
	ADDA	[OIDESC,X]
	BCC	FINON
;* place non-clipping on right edge
NONRIG	LDA	ODWIDTH,X	;initialize s position
	NEGA
	STA	OSPOS,X
	STA	OLEFT,X
	BRA	NRIGLEF
;* place non-clipping on left edge
NONLEF	CLR	OLEFT,X		;initialize s position
	CLR	OSPOS,X
NRIGLEF	LDA	OSLPOS,Y	;compute l position
	SUBA	SCBEDGE
	RPT	1,ASLA
	STA	OLPOS,X
;*
FINON	LDA	OLPOS,X		;initialize top
	ADDA	[OIDESC,X]
	STA	OTOP,X
	LDD	OINDEX,Y	;save scanner wsi in screen object workspace
	STD	OSCAN,X	
	LDA	OSLVEL,Y	;get l velocity
	CLRB			;scale for screen
	RPT	2,ASRA,RORB
	STD	OLVEL,X		;initialize l velocity
	LDA	OSSVEL,Y	;get s velocity
	CLRB			;scale for screen
	RPT	1,ASRA,RORB
	STD	OSVEL,X		;initialize s velocity
	STX	OSSCWSA,Y	;save screen workspace in scanner workspace
	JSR	PUTOBJ		;save none, uses none
	JMP	[OONSCR,U]	;yes, setup on screen routine

;* crystal on screen routine
;	ROUTINE	CRYON
CRYON	LDD	#DCRYWOR	;add crystal display to crystal post display
	STD	OPDRWVE,X
;* invisible scanner object onto screen transition
ISCRON	WAKE_AT	.1S		;change wake-up addr for on screen scanner loop
	RTS
;* invisible scanner task on screen
.1S	BSR	UPSCAN		;update scanner position, save Y, uses A,B,X,U
	SLEEP	LOOP

;* worker with crystals onto screen transition
WORKON	LDD	#DCRYWOR	;add crystal display to worker post display
	STD	OPDRWVE,X
;* visible scanner object onto screen transition
VSCRON	WAKE_AT	.1S		;change wake-up addr for on screen scanner loop
	RTS
;* visible scanner task on screen
.1S	JSR	ERASCAN		;erase scanner image  save Y, uses A,B
	BSR	UPSCAN		;update scanner position, save Y, uses A,B,X,U
	JSR	DRWSCAN		;draw scanner image   save Y, uses A,B,X
	SLEEP	LOOP

;* update scanner position on screen
UPSCAN	LDU	OSCHAR,Y	;characteristics in U > uses A,B,X,U
	LDX	OSSCWSA,Y	;screen wsa in X
	LDB	OSPOS+WPLAYER	;compute s position relative to player
	LSRB
	LSRB
	STB	TEMP
	LDB	OSPOS,X
	LSRB
	LSRB
	LDA	OSTATUS,X	;correct for left clip
	BPL	.1S
	ADDB	#$C0
.1S	SUBB	TEMP
	LDA	OLPOS+WPLAYER	;compute l position relative to player
	LSRA
	STA	TEMP
	LDA	OLPOS,X
	ADDA	#50
	LSRA
	SUBA	#50>>1		;Fixme was: SUBA #50!>1
	SUBA	TEMP
	ADDA	OSCHIGH,U	;correct for height
	STD	OSLPOS,Y	;save new position
	RTS

;	PULLORG	ROMSAVE
ROMSAV	SET	*