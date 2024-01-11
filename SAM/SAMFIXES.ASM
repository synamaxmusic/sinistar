;	INCLUDE	START
;	INCLVER	SAM,SINISTAR.EQU
SAMFIXES

;* fixes live sinistar leaving sector
	INCLUDE "../SAM/FIXLSSIN.ASM"
;* fixes player bounce damping during the attract mode demo
	INCLUDE "../SAM/FIXDAMPD.ASM"
;* fixes playes getting smashed off the screen
	INCLUDE "../SAM/FIXSMASH.ASM"
;* fixes operator entry system initialization
	INCLUDE "../SAM/FIXOPENT.ASM"
;* fixes player starting position
	INCLUDE "../SAM/FIXPLUNI.ASM"