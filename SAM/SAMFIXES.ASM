;	INCLUDE "../SAM/START.ASM"
;	INCLVER	SAM,SINISTAR.EQU
SAMFIXES

;* fixes live sinistar leaving sector
	;INCLVER	SAM,FIXLSSINI
;* fixes player bounce damping during the attract mode demo
	;INCLVER	SAM,FIXDAMPDM
;* fixes playes getting smashed off the screen
	;INCLVER	SAM,FIXSMASH
;* fixes operator entry system initialization
	INCLUDE "../SAM/FIXOPENT.ASM"
;* fixes player starting position
	;INCLVER	SAM,FIXPLUNIT