;	INCLUDE	START
;	INCLVER	SAM,SINISTAR

	INCLUDE "../WITT/RICH.EQU"						;;We need Rich's work EQUs

;;===============================================================================

	PUSHORG	RAMSAV								;;Fixme was: PUSHORG	RAMSAVE (Should be $A1E1, don't go past $A225)
PGRAPH	RMB	10	;\	previous bar graph lengths ( values/4)
GRAPH	RMB	10	;/	bar graph values
	PULLORG	RAMSAV								;;Fixme was: PULLORG	RAMSAVE

;;===============================================================================

;	PUSHORG	GrafxSAV							;;Fixme was: PUSHORG	ROMSAVE (to get this to work, we need to overwrite the rug test)
;										;;We need to disable KenChk entirely for this to work.
;	VECTOR	POWVECT
;;	SYMVER	KENCHK,KENCHK
;	clr	KENCHK
;	rts
;	VECTOR	IniVect
;	clr	KenChk
;	rts
;	PULLORG
;	
;;	SYMVER	ZAPSIN,ZAPSini
;	PUSHORG	ZAPSini		;* In the PowVect routine, ignore the
;	tst	$0		;*   copyright violation test routine.
;	PULLORG

;;===============================================================================

	PUSHORG	GrafxSAV							;;Now we start off with Sam's Bargraph code

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

	PULLORG GrafxSAV
	
;;===============================================================================	
;; Rich's stuff taken from AOE.ASM
	
	PUSHORG	Palette							;*
	fcb	@067,@377,@277,@256,@255,@244,@232,@067			;*
	fcb	@377,@311,@120,@113,@005,@007,@007,@067			;*
	PULLORG                                                         
;*									;*
	PUSHORG	RAMSAV							;*	;;Fixme was: PUSHORG	RAMSAVE	
JUNKTIME	rmb	2						;*
	PULLORG	RAMSAV							;*	;;Fixme was: PULLORG	RAMSAVE
;*									;*
	PUSHORG	GrafxSAV                                                
;	LOCAL								;*
	VECTOR	IniVect							;*
	clr	JUNKTIME						;*
	clr	JUNKTIME+1						;*
	New_Sleep	Task64,.JUNK1S					;*	;;Fixme was: New_Sleep	Task64,1$
	rts								;*
;**									;*
;*	Time clock							;*
;**									;*
.JUNK1S	pshs	D,X,U							;*	;;Fixme was: 1$	pshs	D,X,U
	ldd	JUNKTIME						;*
	addd	#(1*4)		;* Or (2*4) on the 128 list.		;*
	std	JUNKTIME						;*
	asla								;*
	asla								;*
	sta	Graph+GMinutes						;*
	stb	Graph+GSeconds						;*
	IF	1 = 1	;***************** This is turned off! ***********	;;Fixme was: IFE  1
;**									*
;*	Monitor Warrior Aggression					*
;**									*
	lda	WAgg			;* Monitor the high byte of	*
	asla				;*   (shifted to scale)		*
	sta	Graph+GAggression	;*   the warrior aggression	*
;**
;*	Monitor Missions
;**
	ldx	#Temp
	clr	TGMWaDrift,X
	clr	TGMWaAttack,X
	clr	TGMWaMine,X
	clr	TGMWaTail,X
	clr	TGMWaInt,X

	ldu	#Ground
	cmpu	KeyClee+2
	beq	.4S
	ldu	[KeyClee+2]
.2S	lda	OSMIS,U
	cmpa	#OMWaSav
	bge	.3S
	asra
	ldb	A,X	
	addb	#(4*4)								;;Fixme was: addb  #(4.*4.)  (Is decimal really needed here?)
	stb	A,X	
.3S	ldu	[OSCTYPT,U]
	cmpu	#Ground
	bne	.2S

.4S	lda	TGMWaDrift,X
	sta	Graph+GMWaDrift
	lda	TGMWaAttack,X
	sta	Graph+GMWaAttack
	lda	TGMWaMine,X
	sta	Graph+GMWaMine
	lda	TGMWaTail,X
	sta	Graph+GMWaTail
	lda	TGMWaInt,X
	sta	Graph+GMWaInt
	ENDIF	;1		;******* Turned off for now. *************
	puls	D,X,U							;*
	SLEEP	LOOP							;*
	PULLORG	GrafxSAV						;*
;	ENDIF	;Diagnose	;*****************************************	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	
;;; Patch to avoid triggering copyright protection and to skip
;;; ROM/RAM "Rug" test which has been overwritten by this new code.
;	ORG	$F063
;	NOP
;	NOP
;	ORG	$F069
;	NOP
;	NOP
;	NOP
;
;;; Patch to clear out ROM checksum table (this is probably unnecessary in this mod)
;
;	ORG	$F34F
;	FDB	$0000    
;	FDB	$1000    
;	FDB	$2000   
;	FDB	$3000  
;	FDB	$4000  
;	FDB	$5000  
;	FDB	$6000  
;	FDB	$7000  
;	FDB	$8000  
;	FDB	$9000  
;	FDB	$A000  
;	FDB	$B000  
;	FDB	$C000  
;	FDB	$D000  
;	FDB	$E000  
;	FDB	$F000  