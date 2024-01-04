;	NCLIST			* Do not display unsatisfied conditionals
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*									      *
;*									      *
;*	RRRR   IIIII   CCCC  H   H  ''   SSSS         V   V   11    77777     *
;*	R   R    I    C      H   H  ''  S             V   V    1       7      *
;*	RRRR     I    C      HHHHH   '   SSS          V   V    1      7       *
;*	R   R    I    C      H   H          S          V V     1     7        *
;*	R   R  IIIII   CCCC  H   H      SSSS            V    11111  7         *
;*									      *
;*	    S	  I	N     I	    S	  T	A     R		  17	      *
;*									      *
;*	 A game by Sam Dicker, Noah Falstein, Bob Mical and Richard Witt      *
;*		 Copyright (c) 1982 by Williams Electronics Inc.	      *
;*									      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;	NLIST
;SINISTAR.EQU	SET	*
;;	INCLUDE "../SAM/START.ASM"
;	INCLVER	RICH,RICHS.SYM
;	INCLVER	RICH,RICHS.SET
;	INCLVER	RICH,R0
;	LIST
	INCLUDE R2.ASM
;* * *	INCLVER	SAM.SAV,SYMTEST
;	ENDTEST
;	END