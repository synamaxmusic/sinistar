	INCLUDE "../SAM/START.ASM"
;	INCLVER	SAM,SINISTAR.EQU

;====================================
;  Equates to remove later

NPLAYERS EQU	$988A

;====================================

FIXOPENT
	ORG	ROMSAV

;* fixes operator entry
	ORG	$8995
	JSR	FIXOPENT.100S
;	PULLORG
	ORG	$8E3D		;(This had to be added in order to get
				; the alignment right.)
FIXOPENT.100S
;* * *	
	LDA	#98		;set direct page
	TFR	A,DPR
	CLR	NPLAYERS	;zeros number of players
	JSR	INIPIAS		;initialize pias
;* * *
	JMP	SYSTINI		;Wipe clean thy slate, oh master

;* make pia initialization a subroutine
	ORG	$2E6E
	JMP	FIXOPENT.1S
;	PULLORG		
	ORG	$8E49		;(This had to be added in order to get
				; the alignment right.)
FIXOPENT.1S	STB	BUNITS
;* * *
	JSR	INIPIAS
;* * *
	LDA	PIA+6		;initialize control panel state
	JMP	$2E90
INIPIAS	EQU	$2E71
	ORG	$2E8D
	RTS
;	PULLORG

;	PULLORG	ROMSAVE