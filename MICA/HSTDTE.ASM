	INCLUDE "../SAM/START.ASM"

;	INCLVER	SAM,SINISTAR.EQU

;===============================================================================
;
;  This is a patch that I can't find anywhere in the source code except for a
;  reference to the original symbol name. Since it jumps to this routine I'm
;  including it here.

ZHSTDENT	EQU	$8784	;remove this later
	ORG	HSTDENT
	JMP	ZHSTDENT	;Renamed routine to ZHSTDENT to match up with
				;the original symbol.

;===============================================================================

;	PUSHORG	ROMSAVE

	
;	ROUTINE	HSTDENT
;*******************************************************************************
;* HSTDENT
;*   High Score To Date Entry routine
;*   Clears the system and takes complete control