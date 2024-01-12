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
;
;   Sinistar's source code is split into four "modules" (one for each programmer).
;
;   With the exception of Sam's, it is not possible to build a programmer's section of code
;   separately.  If you want to build Noah's files, you need to build Sam's and Rich's as well.
;
;   The order of the modules is as follows:
;   SAM > WITT > FALS > MICA
;
;   If you want to emulate a version of Sinistar with missing modules, you will need to
;   modify ROM 11 so that the game can boot.  Simply copy the last 16 bytes of ROM 10:
;   E0 00 E0 00 E0 00 E0 00 E0 0B E0 00 E0 00 E0 00
;   and paste them at ROM 11 address $0FF0.  This will give the correct IRQ vectors to the CPU.
;
;===============================================================================
;  Macro Assembler AS Instructions
	CPU 6809
	
;===============================================================================
;  <<< IMPORTANT DEFINES >>>

PROMS	EQU	1		;* Define before burning proms

;;  PROMS is on by DEFAULT!  Taken from WITT/RICHFIXE.ASM, this fixes a bug where the screen flashes
;;  white for a frame whenever the game starts up or transitions to a status screen.
;;  If PROMS is not defined, then the screen flashing bug returns (to help remind us that is not the final game)
;;  It also DISABLES KENCHK so that copyright protection doesn't trigger during debugging!
;;  Put a semi-colon in front of PROMS if you want to mess around with the code.

;ROM	EQU	1		;;Change to 1 to build the final ROM
;DEBUG	EQU	1		;* Define this symbol to include test code
;DIAGNOSE EQU	1		;* Define this symbol to include Graphic Diagnostics
;PROMS	EQU	1		;* Define before burning proms
;KENSMARQ EQU	1		;;Adds AMOA '82 title screen "Marquee" graphic

;===============================================================================
;
;   SSSS   AAA   M   M
;  S      A   A  MM MM
;   SSS   AAAAA  M M M
;      S  A   A  M   M
;  SSSS   A   A  M   M
;

	INCLUDE SAM/MESSAGE.ASM		;;This is based off of code from Joust but modified to work wtih a vertical screen
	INCLUDE SAM/EQUATES.ASM

	INCLUDE SAM/IMAGE.ASM		;;Sprites by Jack Haeger
	INCLUDE	SAM/SAMS.ASM
	
;===============================================================================
;
;  RRRR   IIIII   CCCC  H   H
;  R   R    I    C      H   H
;  RRRR     I    C      HHHHH
;  R  R     I    C      H   H
;  R   R  IIIII   CCCC  H   H
;

	INCLUDE	WITT/new_equates.ASM	;;Added to support longer symbol names

	INCLUDE WITT/RICHS.ASM
	INCLUDE WITT/RICHS2.ASM		;;(Control Panel Button handling with Easter Egg routine)

;===============================================================================
;
;  N   N   OOO    AAA   H   H
;  NN  N  O   O  A   A  H   H
;  N N N  O   O  AAAAA  HHHHH
;  N  NN  O   O  A   A  H   H
;  N   N   OOO   A   A  H   H
;

	INCLUDE FALS/NOAHS.ASM
	
;	INCLUDE FALS/disable_kenchk.ASM		;;Noah's module isn't playable unless this new file is included.
						;;(Be sure to not include this when building the original ROM)

;===============================================================================
;
;  BBBB    OOO   BBBB
;  B   B  O   O  B   B
;  BBBB   O   O  BBBB
;  B   B  O   O  B   B
;  BBBB    OOO   BBBB
;
	
	INCLUDE MICA/BOBS.ASM
		
;===============================================================================
;
;  FFFFF  IIIII  N   N   AAA   L
;  F	    I    NN  N  A   A  L
;  FFF      I    N N N  AAAAA  L
;  F        I    N  NN  A   A  L
;  F      IIIII  N   N  A   A  LLLLL

	INCLUDE WITT/AOE.ASM
	INCLUDE FALS/LAST.ASM			;Final patches found in (Revision 3) rom
	
	END