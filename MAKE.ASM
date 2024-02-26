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
;   To make an incomplete version of Sinistar playable on MAME, IRQ vectors are
;   automatically inserted at the very end of ROM 11 so that the emulator can launch
;   the game.
;
;   Once the incomplete build is running in the emulator, you'll need to insert a coin first
;   then press either the Player 1 or 2 buttons to start playing.
;
;===============================================================================
;  Macro Assembler AS Instructions
	CPU 6809
	
;===============================================================================
;  				<<< DEBUG DEFINES >>>

PROMS	EQU	1		;* Define before burning proms

;;  PROMS is on by DEFAULT!
;;
;;  Taken from WITT/RICHFIXE.ASM, this fixes a bug where the screen flashes
;;  white for a frame whenever the game starts up or transitions to a status screen.
;;  If PROMS is not defined, then the screen flashing bug returns (to help remind us that
;;  we're playing a dev build).
;;  It also DISABLES KENCHK so that copyright protection doesn't trigger during debugging!
;;
;;  Note: This doesn't take affect until AOE.ASM is included, so use DisableKenChk
;;  if the magic byte at address $A1B3 is still showing up as non-zero during
;;  attract mode/gameplay.
;;
;;  Moving this from RICHFIXE.ASM was kinda unnecessary as this define is usually left on
;;  all the time, but I figured it would be easier to enable/disable it here rather than
;;  having it separate from the other debug options.

;DisableKenChk EQU 1

;;  The problem with PROMS is that it is defined in RICHFIXE.ASM, which is referenced
;;  in AOE.ASM.  If AOE is not included in the build, then KenChk will still trigger.
;;  Enable this to force the copyright protection to stay off no matter what.
;;
;;  This can be useful for when the diagnostic rom is not included in the build.

;FakeChecksums EQU 1

;;  If you are including the diagnostic ROM 11 in the build, then use this for debugging.
;;  This is really important if you want to mess around with the code or work on mods.
;;  Also useful for enabling several different mods at once.
;;
;;  During power up, the ROM test uses a checksum table at $F34F to verify file integrity.
;;  To make debugging with mods much easier, enable this to zero out the checksum table
;;  and cheat the ROM test so that you can gain access to the "Game Adjustment" menu.
;;
;;  Zeroing out the checksums also should prevent the copyright protection from
;;  triggering.  Look at address $A1B3 to ensure the byte is zero, otherwise the
;;  game will start acting weird.
;;

;DisableTests EQU 1

;;  To make mods possible for Sinistar, we use the space between addresses $F4FB - $F928
;;  in diagnostic ROM 11. This is where the cross hatch test, color bar tests and switch
;;  tests are located. Enable this define to make the diagnostics skip these routines and
;;  give us $42C bytes of space to overwrite.
;;
;;  This is already enabled for both MarqueeFix and PauseMod.

;NOTEST	EQU	1

;;  Uncommenting this EQU can be useful for debugging and greatly decreases wait times
;;  by skipping the power up ROM/RAM Rug Test.  It does not disable the ROM/RAM "Rug" test
;;  itself, as it is still accessible by pressing the service (aka "advance") button.

;SAMDEBUG EQU	1

;;  This debug define found in Sam's module allows the player to respawn forever, even
;;  if they run out of extra ships.  This only changes two bytes in the code and doesn't
;;  mess up any symbol addresses.  This was originally labeled as "DEBUG" but I renamed it
;;  to differentiate from the next two defines which were also called "DEBUG".

;InfiniteShips EQU 1

;;  Enable this to never run out of lives.  This is from Rich's module and while it
;;  takes up more space, it increases the player's number of ships upon every Turn
;;  initialization so the player never runs out. 

;NoDeath	EQU	1

;;  This disables player deaths.  Warrior shots don't hurt anymore (yay!), but if
;;  the player gets caught by the Sinistar, they'll get soft-locked (boo!).
;;  This was taken from Rich's module as well.

;DisableSinistarCollision EQU	1

;;  This new hack makes the player pass through the Sinistar and prevent getting
;;  soft-locked while NoDeath is enabled.

;Witt	EQU	1

;;  Uncomment "Witt" to force the Sinistar to spawn instantly and prevent the
;;  warriors from shooting at the player.

;WittRock EQU	1

;;  This new define enables a previously-unknown sprite edit of the tiny
;;  Planetoid image that was used to denote Rich's developmental build
;;  from the final ROM.

;  				<<< MOD DEFINES >>>

;;
;;  "EnableMods" and "DiagnosticTestFix" are now deprecated.  Use "FakeChecksums"
;;  and "DisableTests" instead.  Any modifications to the final version of the game
;;  requires us to either change the checksums in diagnostic ROM 11 or fake them.
;;
;;  Originally, the RAM and ROM tests in ROM 11 ($F09F - $F370) were overwritten to
;;  fit "MarqueeFix" and "PauseMod" but this doesn't work on real hardware, as we
;;  were running into issues with the watchdog.
;;
;;  Any new mods are now relocated so that they overwrite the "Cross Hatch",
;;  Color Bars and Switch tests in the diganostics ROM ($F4FB - $F928).  To make
;;  this space available for adding mods, uncomment the "DisableTests" define.
;;
;;  These mods can be combined with others, however if you are running into "ROM ERROR"
;;  messages on power up, then enable "FakeChecksums" to fix this.
;;

;MarqueeFix EQU 1

;;  This restores the awesome original "Marquee" title screen found in the prototype
;;  AMOA '82 build.  Due to space constraints, this was not included in the final build.
;;
;;  To get this to work, I had to overwrite the cross hatch, color bar and switch tests
;;  in ROM 11 and then patched ROM 9 to make RJ's attract mode routines load the AMOA
;;  graphic.
;;  
;;  "DisableTests" is already enabled for this mod.  New Checksums for the ROM test
;;  are also enabled.  Can be combined with "PauseMod" and "DifficultyMod" with valid
;;  checksums.
;;
;;  Changes ROMs: 9, 11

;DifficultyMod EQU 1

;;  This reduces the difficulty of the game by modifying the enemy population values
;;  starting at $7ABE.  You can watch my video for more detailed info on how this mod works
;;  and why I chose these new values: https://youtu.be/HnfcAudPPS4
;;
;;  Adds valid checksums for ROM 11.
;;
;;  Changes ROMs: 8, 11

;PauseMod EQU	1

;;  Press the Player 1 button during gameplay to pause!  Pressing it again resumes
;;  the game.  This mod was inspired by the Joust Pause Mod found on Coinoplove.com and uses
;;  very similar code to achieve the same effect.  The "PAUSED" text displayed on screen
;;  uses a routine inspired by Witt's code responsible for drawing the "EMPTY" text at
;;  the start of the game.
;;
;;  This mod can be enabled with MarqueeFix!  "DisableTests" is already enabled for this mod.
;;  New Checksums for the ROM test are also enabled.  
;;
;;  Changes ROMs: 4, 10, 11

;ExtraShipFix EQU 1

;;  This restores the original "Additional Extra Ship Point Factor" to it's original
;;  value of 5,000 (per SAM/DEFAULT.SRC).  This makes it much easier to score extra lives!
;;
;;  You'll need to do a factory reset or clear/delete your NVRAM in order for the
;;  new default value to be copied over.
;;
;;  Because this is just a one-byte edit, this can be combined with other mods like
;;  MarqueeFix and/or DifficultyMod.
;;
;;  This mod is kinda not really needed, since you can just change the value in the
;;  "Game Adjustments" menu to 5000 and then save.
;;
;;  No valid checksum yet for this mod, enable "FakeChecksums" to pass ROM test.
;;
;;  Changes ROMs: 5

;QuickOperatorEntry EQU 1

;;  This one-byte mod makes it much quicker to edit the title screen's operator message,
;;  which can be accessed from the Game Adjustments service menu.  The only caveat is that
;;  the operator message entry screen and high score entry screen use the same routines, so
;;  changing the value to make it go faster also affects the input for high score initials.
;;
;;  I'm assuming that RJ purposely patched this value to make editing slower because
;;  play-testers were messing up their high score initials with the shorter time.
;;
;;  No valid checksum yet for this mod, enable "FakeChecksums" to pass ROM test.
;;
;;  Changes ROMs: 9


;  			<<< EXPERIMENTAL BROKEN DEFINES >>>

;BargraphEnable EQU 1		;* Define this symbol to include Graphic Diagnostics

;;  This was originally called "DIAGNOSE" but I renamed it to BargraphEnable to better
;;  describe what this does.  Defining this enables a debug "BARGRAPH" display that 
;;  shows different parameters such as Play time in Minutes and Seconds, Warrior Aggression,
;;  Elapsed time since player death, number of enemies, etc.  
;;
;;  The file "RICH.EQU" has the list of what the different color bars mean but it is
;;  inverted.  Here is the correct guide for what each bar represents:
;;
;;		rmb	1	* F					YELLOW (unused)
;;		rmb	1	* E <SPECIAL EFFECT>			BLACK (unused) (The Sinistar's glowing eye color)
;;GMWaInt	rmb	1	* D The # of Intercepting warriors	RED
;;GMWaTail	rmb	1	* C The # of Guarding warriors		DARK RED
;;GMWaMine	rmb	1	* B The # of Mining warriors		DARK PURPLE
;;GMWaAttack	rmb	1	* A The # of Attacking warriors		DARK TEAL
;;GMWaDrift	rmb	1	* 9 The # of Drifting warriors		BLUE
;;		rmb	1	* 8   Effects				BLACK (unused)
;;		rmb	1	* 7 Special				BLACK (unused)
;;GFLANG	rmb	1	* 6 Flight angle of squadron leader.	BLUE-GRAY
;;GVelocity	rmb	0	* 6 Velocity				BLUE-GRAY (unused)
;;GANANG	rmb	1	* 5 Animation angle of squadron leader.	GRAY
;;GDistance	rmb	0	* 5 Distance				GRAY (unused)
;;GDeathTime	rmb	1	* 4 Time since Player death		TAN-GRAY
;;GAggression	rmb	1	* 3 Warrior aggression (high byte)	SALMON PINK
;;GSeconds	rmb	1	* 2   and seconds.			CREAM
;;GMinutes	rmb	1	* 1 Play time in minutes		WHITE
;;  
;;  BargraphEnable only works if DisableKenChk is on and that AOE.ASM and DIAG.ASM are not
;;  built.  Use NOTEST instead of FakeChecksums to skip ROM test. 
;;
;;  High score entry doesn't work but you can still insert a coin and hit the player 1 button
;;  to start playing again.
;;

;BargraphAlt EQU 1

;;  In the previous list, two variables are not enabled, "GVelocity" and "GDistance".
;;  Instead, "GFLANG" and "GANANG" for the warrior squadron leader are shown in blue-gray
;;  and gray colors respectively.
;;
;;  Uncomment this define to have the BARGRAPH routine display the Velocity and Distance
;;  parameters instead and disable the squadron leader color bars.
;;

;  			<<< DEPRECATED DEFINES BELOW!!! DON'T USE >>>

;EnableMods EQU 0

;;  Turn this on if you want to enable mods like the Marquee Fix or Difficulty Mod.
;;  Please leave PROMS defined!
;;
;;  This disables the Rug test, just like NOTEST, but this also zeros out the
;;  ROMTBL checksum table, so that we don't trigger the copyright protection.
;;  If the ROM/RAM tests have been untouched, hitting the service (aka "advance")
;;  button should still work.  With the "auto up" switch enabled, pressing the
;;  advance button will take you directly to the Bookkeeping and Game Adjustment
;;  screens.

;DiagnosticTestFix EQU 0

;;  Only works if EnableMods is defined.  Restores access to diagnostic tests for
;;  CMOS, Sound, Switches and Color bars by skipping the ROM/RAM tests.  This is
;;  automatically enabled for MarqueeFix.  This is needed for any mods that overwrite
;;  the RAM/ROM rug test area ($F09F-$F370) and/or before the CMOS test screen at $F404.
;;
;;  When this is enabled, the game will wipe away the screen and wait forever until the
;;  "advance" button (aka F2 in MAME) is pressed again.  Keep pressing the advance
;;  button to go through the remaining diagnostic screens.

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

	INCLUDE SAM/DIAG.ASM
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