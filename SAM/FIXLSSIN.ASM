;	INCLUDE	START
;	INCLVER	SAM,SINISTAR.EQU
FIXLSSINI

;* don't allow a live sinistar to leave sector
	PUSHORG	LSSINI								;;($5DBE)
	JMP	FIXLSSINI100S							
	PULLORG
;* * *	PUSHORG	ROMSAVE
	PUSHORG	HISAV								;;($E1B7)
FIXLSSINI100S									;;Fixme was: 100$ (Needed to convert to global labels)
;* * *
	LDD	FINISH		;is sinistar alive?
	CMPD	#ALIVE
	BNE	FIXLSSINI12S
	RTS			;yes, don't let it leave sector
FIXLSSINI12S									;;Fixme was: 12$
;* * *										;;($E1C1)
	jsr	Sinhibit	;* Re-initialize Sinistar attack personality.
	JMP	LSSINI+3
;* * *	PULLORG	ROMSAVE
	PULLORG	HISAV