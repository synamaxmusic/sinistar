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
;   To do this in P2BIN:
;
;    p2bin sinistar.p sinistar_rom_1-b_16-3004-53.1d -r $0000-$0FFF
;    p2bin sinistar.p sinistar_rom_2-b_16-3004-54.1c -r $1000-$1FFF
;    p2bin sinistar.p sinistar_rom_3-b_16-3004-55.1a -r $2000-$2FFF
;    p2bin sinistar.p sinistar_rom_4-b_16-3004-56.2d -r $3000-$3FFF
;    p2bin sinistar.p sinistar_rom_5-b_16-3004-57.2c -r $4000-$4FFF
;    p2bin sinistar.p sinistar_rom_6-b_16-3004-58.2a -r $5000-$5FFF
;    p2bin sinistar.p sinistar_rom_7-b_16-3004-59.3d -r $6000-$6FFF
;    p2bin sinistar.p sinistar_rom_8-b_16-3004-60.3c -r $7000-$7FFF
;    p2bin sinistar.p sinistar_rom_9-b_16-3004-61.3a -r $8000-$8FFF
;    p2bin sinistar.p sinistar_rom_10-b_16-3004-62.4c -r $E000-$EFFF
;    p2bin sinistar.p sinistar_rom_11-b_16-3004-63.4a -l 00 -r $F000-$FFFF
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
;
;   E0 00 E0 00 E0 00 E0 00 E0 0B E0 00 E0 00 E0 00
;
;   and paste them at ROM 11 address $0FF0.  This will give the correct IRQ vectors to the CPU.
;   The rest of ROM 11 can be blank, as long as those IRQ vectors are found at the
;   end of the binary data, then the game will boot.  
;
;   Once the incomplete build is loaded into the emulator, you'll need to insert a coin first
;   then press either the Player 1 or 2 buttons to start.
;
;===============================================================================
;  Macro Assembler AS Instructions
	CPU 6809
	
;===============================================================================
;  <<< IMPORTANT DEFINES >>>

PROMS	EQU	1		;* Define before burning proms

;;  PROMS is on by DEFAULT!  Taken from WITT/RICHFIXE.ASM, this fixes a bug where the screen flashes
;;  white for a frame whenever the game starts up or transitions to a status screen.
;;  If PROMS is not defined, then the screen flashing bug returns (to help remind us that we're
;;  playing a dev build).
;;  It also DISABLES KENCHK so that copyright protection doesn't trigger during debugging!
;;  Put a semi-colon in front of PROMS if you want to mess around with the code.

;NOTEST	EQU	1

;;  Uncommenting this EQU can be useful for debugging and greatly decreases wait times
;;  by skipping the power up ROM/RAM Rug Test.  It does not disable the ROM/RAM "Rug" test
;;  itself, as it is still accessible by pressing the service button.

;SAMDEBUG EQU	1

;;  This debug define found in Sam's module allows the player to respawn forever, even
;;  if they run out of extra ships.  This only changes two bytes in the code and doesn't
;;  mess up any symbol addresses.

;InfiniteShips EQU 1

;;  Enable this to never run out of lives.  This is from Rich's module and while it
;;  takes up more space, it increases the player's number of ships upon every Turn
;;  initialization so the player never runs out. 

;NoDeath	EQU	1

;;  This disables player deaths.  Warrior shots don't hurt anymore (yay!), but if
;;  the player gets caught by the Sinistar, they'll get soft-locked (boo!).
;;  This was taken from Rich's module.

;DisableSinistarCollision EQU	1

;;  This new hack makes the player pass through the Sinistar and prevent getting
;;  soft-locked while NoDeath is enabled.

;Witt	EQU	1

;;  Uncomment "Witt" to force the Sinistar to spawn instantly and prevent the
;;  warriors from shooting at the player.

;WittRock EQU	1

;;  This new equate enables a previously-unknown sprite edit of the tiny
;;  Planetoid image that was used to denote Rich's developmental build
;;  from the final ROM.

;  <<< MOD DEFINES >>>

;EnableMods EQU 1

;;  Turn this on if you want to enable mods like the Marquee Fix or Difficulty Mod.
;;  Please leave PROMS defined!
;;
;;  This disables the Rug test, just like NOTEST, but this also zeros out the
;;  ROMTBL checksum table, so that we don't trigger the copyright protection.
;;  If the ROM/RAM tests have been untouched, hitting the service button should
;;  still work.  With the advance switch enabled, pressing the button will
;;  take you directly to the Bookkeeping and Game Adjustment screens.

;DiagnosticTestFix EQU 1

;;  Only works if EnableMods is defined.  Restores access to diagnostic tests for
;;  CMOS, Sound, Switches and Color bars by skipping the ROM/RAM tests.  This is
;;  automatically enabled for MarqueeFix.  This is needed for any mods that overwrite
;;  the RAM/ROM rug test area ($F09F-$F371).

;MarqueeFix EQU 1

;;  This restores the awesome original "Marquee" title screen found in the prototype
;;  AMOA '82 build.  
;;
;;  To get this to work, I had to overwrite the ROM/RAM tests in ROM 11 and then 
;;  patched ROM 9 to allow RJ's attract mode routines load the new graphics.
;;
;;  Finally a new patch was inserted to restore access to the Game Adjustments menu
;;  and to prevent the game from trying to load the trashed tests upon hitting the
;;  service button.
;;  
;;  Due to space constraints, this was not included in the final build of the game.
;;  

;ExtraShipFix EQU 1

;;  This restores the original "Additional Extra Ship Point Factor" to it's original
;;  value of 5,000 (per SAM/DEFAULT.SRC).  This makes it much easier to score extra lives!
;;  PROMS can be enabled as this fix also automatically adds a Rug test skip and
;;  zeros out the checksum table to avoid triggering copyright protection.
;;
;;  You'll need to do a factory reset or clear/delete your NVRAM in order for the
;;  new default value to be copied over.

;DifficultyMod EQU 1

;;  This reduces the difficulty of the game by modifying the enemy population values
;;  starting at $7ABE.  You can watch my video For more detailed info on how this mod works
;;  and why I chose these new values: https://youtu.be/HnfcAudPPS4

;  <<< EXPERIMENTAL BROKEN DEFINES >>>

;BargraphEnable EQU 1		;* Define this symbol to include Graphic Diagnostics

;;  This was originally called "DIAGNOSE" but I renamed it to BargraphEnable because
;;  it better describes what this define does.  Some changes had to be made to get
;;  the Debug Graphs functional again but the game starts acting weird when this is enabled.
;;  AOE.ASM must be disabled in order for the game to boot.  Disabling DIAG.ASM is
;;  a good idea as well.

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
;  FFFFF  IIIII  X   X  EEEEE   SSSS
;  F	    I     X X   E      S    
;  FFF      I      X    EEEE    SSS 
;  F        I     X X   E          S
;  F      IIIII  X   X  EEEEE  SSSS 
;

	INCLUDE WITT/AOE.ASM		
	
;===============================================================================
;  
;  DDDD   IIIII   AAA    GGGG
;  D   D    I    A   A  G    
;  D   D    I    AAAAA  G GGG
;  D   D    I    A   A  G   G
;  DDDD   IIIII  A   A   GGG 	
;

	INCLUDE SAM/DIAG.ASM		;;Build the diagnostic ROM first
	INCLUDE FALS/LAST.ASM		;;Final patches found in Revision 3 rom, can be built without DIAG.ASM
	
;===============================================================================
;
;  EEEEE  X   X  TTTTT  RRRR    AAA    SSSS  
;  E       X X     T    R   R  A   A  S      
;  EEEE     X      T    RRRR   AAAAA   SSS   
;  E       X X     T    R  R   A   A      S  
;  EEEEE  X   X    T    R   R  A   A  SSSS   
;
	
	INCLUDE WITT/debug_utilities.ASM
	INCLUDE MICA/marquee_fix.ASM
	
	END