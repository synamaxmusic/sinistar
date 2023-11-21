;*
	INCLUDE "../WITT/SYMRICH.ASM"	;* Rich's symbols
	INCLUDE "../WITT/RAMRICH.ASM"		;* Ram variables
	INCLUDE "../WITT/INIRICH.ASM"		;* VECTOR INIVECTs
;*
	INCLUDE "../WITT/DISP.ASM"		;* Message display routines
	;INCLVER	RICH,display		;* Message display macros
;*
;* * *	INCLVER	RICH,button			;* Control panel routines
	INCLUDE "../WITT/COLLISIO.ASM"		;* Collision effects
	;INCLVER	RICH,copyright		;* EBCDIC copyright
	;INCLVER	RICH,difficult		;* Difficulty factor tables
	;INCLVER	RICH,krsini		;* Sinistar Killing routine
	;INCLVER	RICH,leavesec		;* Leaving sector vectors
	;INCLVER	RICH,tables
	;INCLVER	RICH,worker
	;INCLVER	RICH,warrior
	;INCLVER	RICH,sinibomb
	;INCLVER	RICH,sini
;*
	;INCLVER	RICH,stubs		;* To fake Noah's stuff.
;*


	INCLUDE "../SAM/FIXDAMPD.ASM"		;;TEMPORARY