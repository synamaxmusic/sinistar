;
;
;	 SSSS  IIIII  N   N  IIIII   SSSS  TTTTT   AAA   RRRR
;	S        I    NN  N    I    S        T    A   A  R   R
;	 SSS     I    N N N    I     SSS     T    AAAAA  RRRR
;	    S    I    N  NN    I        S    T    A   A  R  R
;	SSSS   IIIII  N   N  IIIII  SSSS     T    A   A  R   R
;
;
;    A game by Sam Dicker, Noah Falstein, Bob Mical and Richard Witt
;
;	    Source code rewrite by SynaMax, started 11/6/23
;
;===============================================================================
;
;   This source code was rewritten to target Macro Assembler {AS}.
;
;   To build Sinistar, place the four folders (FALS,SAM,WITT,MICA)
;   and this MAKE.ASM file into the same directory as ASL and P2BIN.
;   Then, open a command prompt and type in:
;
;   asl make.asm -o sinistar.p
;   p2bin sinistar.p sinistar.bin
;
;   Finally, split the .BIN into separate 1K ROM files:
;
;	Address:		MAME ROM set Filename:
;	0000-0FFF = ROM 1	;sinistar_rom_1-b_16-3004-53.1d
;	1000-1FFF = ROM 2	;sinistar_rom_2-b_16-3004-54.1c
;	2000-2FFF = ROM 3	;sinistar_rom_3-b_16-3004-55.1a
;	3000-3FFF = ROM 4	;sinistar_rom_4-b_16-3004-56.2d
;	4000-4FFF = ROM 5	;sinistar_rom_5-b_16-3004-57.2c
;	5000-5FFF = ROM 6	;sinistar_rom_6-b_16-3004-58.2a
;	6000-6FFF = ROM 7	;sinistar_rom_7-b_16-3004-59.3d
;	7000-7FFF = ROM 8	;sinistar_rom_8-b_16-3004-60.3c
;	8000-8FFF = ROM 9	;sinistar_rom_9-b_16-3004-61.3a
;	9000-DFFF =    (SPACE RESERVED FOR RAM)
;	E000-EFFF = ROM 10	;sinistar_rom_10-b_16-3004-62.4c
;	F000-FFFF = ROM 11	;sinistar_rom_11-b_16-3004-63.4a
;
;
;===============================================================================
;  Macro Assembler AS Instructions
	CPU 6809
	
;===============================================================================
;
;   SSSS   AAA   M   M
;  S      A   A  MM MM
;   SSS   AAAAA  M M M
;      S  A   A  M   M
;  SSSS   A   A  M   M
;
	
	INCLUDE SAM/MESSAGE.ASM
	INCLUDE SAM/EQUATES.ASM
	INCLUDE SAM/IMAGE.ASM
	INCLUDE SAM/MACROS.ASM		;(Moved from START.ASM)
	INCLUDE	SAM/SAMS.ASM
	
;===============================================================================
;
;  RRRR   IIIII   CCCC  H   H
;  R   R    I    C      H   H
;  RRRR     I    C      HHHHH
;  R  R     I    C      H   H
;  R   R  IIIII   CCCC  H   H
;

	INCLUDE	WITT/new_equates.ASM	;Added to support longer symbol names

	INCLUDE WITT/RICHS.ASM
	;INCLUDE WITT/RICHS2.ASM

;===============================================================================
;
;  N   N   OOO    AAA   H   H
;  NN  N  O   O  A   A  H   H
;  N N N  O   O  AAAAA  HHHHH
;  N  NN  O   O  A   A  H   H
;  N   N   OOO   A   A  H   H
;










;===============================================================================
;
;  BBBB    OOO   BBBB
;  B   B  O   O  B   B
;  BBBB   O   O  BBBB
;  B   B  O   O  B   B
;  BBBB    OOO   BBBB
;
	
;	INCLUDE MICA/BOBS.ASM
		
;===============================================================================
;
;  FFFFF  IIIII  N   N   AAA   L
;  F	    I    NN  N  A   A  L
;  FFF      I    N N N  AAAAA  L
;  F        I    N  NN  A   A  L
;  F      IIIII  N   N  A   A  LLLLL

;	INCLUDE WITT/AOE.ASM
	;INCLUDE FALS/LAST.ASM
;	INCLUDE SAM/!TEST.ASM