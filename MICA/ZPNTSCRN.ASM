

	PUSHORG	ROMSAVE

	ROUTINE	PNTSCRN
;******************************************************************************
;* PNTSCRN
;*   clears out the system, sets up the information tasks, restarts the system

	JSR	SYSTINI
	NEW_SLEEP	TASK1,.PN255S,OTIMER
	NEW_SLEEP	TASK1,NATMSG,OMTLEN+1	;NATMSG
	NEW_SLEEP	TASK1,CDTask,OMTLEN+1	;DCREDITS
	JMP	STARTS


.PN255S	PSHS	Y								;;Fixme was: 255$	PSHS	Y

	LDA	#%00110011	;Allow Player 1/2, Fire and Sinibomb buttons
	STA	PANMASK

	JSR	CLRSCR

	LDA	PMEMCTL		;Turn off DMA-inhibit
	PSHS	A
	ANDA	#~$4								;;Fixme was: ANDA	#!N4
	STA	PMEMCTL
	STA	MEMCTL

	LDX	#PNTIMT		;Image Addresses Table
	LDY	#PNTSCT		;Screen Position Table
				
.PNTS1S	LDU	,X++		;Get next image address				;;Fixme was: 1$	LDU	,X++
	BEQ	.PN100S		;Done when zero
	LDD	,U++		;Get size
	EORA	#4
	EORB	#4
	STD	$CA06
	LDD	,U++		;Get image data address
	STD	$CA02
	LDD	,Y++		;Get screen location
	STD	$CA04
	LDA	#$0E
	STA	$CA00
	BRA	.PNTS1S


.PN100S	TEXT	$80,$60								;;Fixme was: 100$	TEXT	$80,$60
	PHRASE	PINK,35,PLANETOIDS
	WORD	BLUE,35,5
	WORD	SILVER,35,POINTS
	TEXT	$72,$60
	PHRASE	PINK,35,WORKER
	WORD	BLUE,35,150
	WORD	SILVER,35,POINTS
	TEXT	$64,$60
	PHRASE	PINK,35,CRYSTALS						;;Fixme was: PHRASE	PINK,35,CRYSTAL
	WORD	BLUE,35,200
	WORD	SILVER,35,POINTS
	TEXT	$56,$60
	PHRASE	PINK,35,WARRIOR
	WORD	BLUE,35,500
	WORD	SILVER,35,POINTS
	TEXT	$48,$60
	PHRASE	PINK,35,SINISTAR,PIECES						;;Fixme was: PHRASE	PINK,35,SINISTAR,PIECE
	WORD	BLUE,35,500
	WORD	SILVER,35,POINTS
	TEXT	$37,$3E
	PHRASE	RED,68,DESTROY,THE,SINISTAR
	TEXT	$31,$59
	PHRASE	BLUE,68,15000
	WORD	SILVER,68,POINTS

	PULS	A,Y		;Fetch DMA inhibit and workspace pointer
	STA	PMEMCTL		;Restore DMA
	STA	MEMCTL

	RADIX	10								;;(decimal value ahead)
	LDD	#(60*7)								;;Fixme was: LDD	#(60.*7.)
	RADIX	16								;;(back to hex)
	JSR	TIMER
	JMP	IAMODE


PNTIMT	FDB	IPLAN2,IWORKER
	FDB	ICRYSTAL,IWARRIOR,IBARREL,S1L					;;Patched over in BOBFIXES ($8E15) "THIS TINY LITTLE PATCH changes the Crystal Image from the yucky yellow"
	FDB	0
PNTSCT	FDB	$7C3A,$7140
	FDB	$6544,$543D,$5945,$473E

IBARREL	FDB	$0201,.1S
.1S	FCB	$42,$20								;;Fixme was: 1$ 	FCB	$42,$20

	PULLORG	ROMSAVE