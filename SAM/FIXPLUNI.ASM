;	INCLUDE	START
;	INCLVER	SAM,SINISTAR.EQU
FIXPLUNIT

;* initialize player unit vector
	PUSHORG	ROMSAVE
	VECTOR	INIVECT						;;($82F1)
;* * *
	LDD	#007E		;initialize player unit vector	;;($8E55)
	STD	PLSUNIT
;* * *
	RTS
	PULLORG	ROMSAVE