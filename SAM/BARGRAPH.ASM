;	INCLUDE	START
;	INCLVER	SAM,SINISTAR


	PUSHORG	RAMSAV								;;Fixme was: PUSHORG	RAMSAVE (Should be $A1E1, don't go past $A225)
PGRAPH	RMB	10	;\	previous bar graph lengths ( values/4)
GRAPH	RMB	10	;/	bar graph values
	PULLORG	RAMSAV								;;Fixme was: PULLORG	RAMSAVE

	PUSHORG	GRAFORG								;;Fixme was: PUSHORG	ROMSAVE (to get this to work, we need to overwrite the rug test)

	VECTOR	INIVECT
BARGRAPH set	*
	LDD	#$9999		;draw bar graph right end line
	LDX	#$75DA		
.BAR1S	STD	X								;;Fixme was: 1$	STD	X
	LEAX	100,X		
	CMPX	#$8EDA		
	BLO	.BAR1S		
	LDX	#PGRAPH		;set bar graph lengths/zero initial values
	LDU	#GRAPH		
	LDD	#$0F3F
.BAR2S	STB	A,X								;;Fixme was: 2$	STB	A,X
	CLR	A,U
	DECA			
	BPL	.BAR2S
	RTS		

	VECTOR	EXEVECT
	LDA	PANMASK		;player flying on?
	BITA	#8
	BNE	.BAR10S
	RTS			;no?, that's all folks
;*
.BAR10S	LDA	PMEMCTL		;update bar graphs: dma inhibit off		;;Fixme was: 10$	LDA	PMEMCTL
	PSHS	A
	ANDA	#~$4								;;Fixme was: ANDA	#!N4
	STA	PMEMCTL
	STA 	MEMCTL
	LDA	#1!4		;* * *TEMPORARY FOR DMA BUG			;;Fixme was: LDA	#1!X4
	STA	DHIGH		;set DMA height
	LDA	#$0F		;initialize bar number
	LDX	#PGRAPH         
	LDU	#GRAPH          
.BARG1S	LDB	A,U		;get new value					;;Fixme was: 1$	LDB	A,U
	LSRB			;convert to lengths
	LSRB                    
	CMPB	A,X		;has it changed?
	BEQ	.BARG4S              
	PSHS	CC		;save change
	STB	A,X		;save new length
	STA	TEMP		;save bar #
	PULS	CC		;longer or shorter?
	BMI	.BARG2S             
	EORB	#4		;* * *TEMPORARY FOR DMA BUG
	STB	DWIDE		;set DMA width
	LDB	#$11		;longer, compute color
	MUL                     
	STB	DCONS		;set DMA constant
	LDA	TEMP		;get bar #
	ADDA	#$79		;compute screen position
	LDB	#$9B             
	STD	DDEST		;set DMA destination
	BRA	.BARG3S              
.BARG2S	ADDD	#$799B		;compute screen position			;;Fixme was: 2$	ADDD	#799B	
	STD	DDEST		;set DMA destination
	COMB			;compute width
	ADDB	#$40+$9B          
	EORB	#4		;* * *TEMPORARY FOR DMA BUG
	STB	DWIDE		;set DMA width
.BARG3S	LDA	#DCNS+DWBL	;draw or erase bar
	STA	DCTRL           
	LDA	TEMP		;restore bar # / wait for DMA
	CLR	DCONS		;zero constant
.BARG4S	DECA			;done?
	BGE	.BARG1S             
	PULS	A		;dma inhibit on
	STA	PMEMCTL
	STA 	MEMCTL
	RTS

	PULLORG	GRAFORG								;;Fixme was: PULLORG	ROMSAVE