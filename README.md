# Sinistar
A game by Sam Dicker, Noah Falstein, R.J. Mical and Richard Witt

Source code rewrite by SynaMax, started November 6th, 2023
****

The original source code for the game can be found at https://github.com/historicalsource/sinistar/

A recreation of the source code for Sinistar's sound roms can be found here: https://github.com/synamaxmusic/Sinistar-Sound-ROM/

Sinistar's speech roms are separate from the sound roms and have not been disassembled yet.
****

<!-- vim-markdown-toc GFM -->

* [Important Milestones](#important-milestones)
* [Overview](#overview)
* [Build Instructions](#build-instructions)
* [About the source code](#about-the-source-code)
	* [Macros](#macros)
	* [Working with the BSO Assembler and VAX/VMS](#working-with-the-bso-assembler-and-vaxvms)
   	* [Choosing a new assembler](#choosing-a-new-assembler)
* [Rewriting the source code](#rewriting-the-source-code)
	* [PUSHORG and PULLORG](#pushorg-and-pullorg)
 	* [ROUTINE](#routine)
  	* [PAD](#pad)
  	* [TEXT/PHRASE](#textphrase)  
	* [Inconsistent label names](#inconsistent-label-names)
 	* [Local labels](#local-labels)
 	* [BSO Syntax](#bso-syntax)
  	* [Decimal numbers](#decimal-numbers)
  	* [Common fixes](#common-fixes)
<!-- vim-markdown-toc -->

## Important Milestones
* 01/03/2024 - I cleaned up some of my older comments and replaced my old ```PUSH/PULLORG``` hacks with the actual macros.  The same goes for the ```ROUTINE``` macro; it's actually pretty useful as it shows messages in the listing output and makes it easier to understand.  ```PAD``` doesn't work exactly the same with the new assembler so it's only used sparringly in this rewrite when there are no macro arguments; any ```PAD``` macros that need to generate new lable names have been replaced with three lines of code that reproduces exactly what we need (see [PAD](#pad) for more info).
* 12/30/2023 - I got [several important and heavily-used macros](https://github.com/synamaxmusic/sinistar/commit/f8ace13ec0a8a5db5baac7f346cc17ed26605bbd) to work properly after several tests.  These macros include ```PUSHORG```,```PULLORG```,```ROUTINE```,```PAD```, and the Copyright string macro.  Implementing these will require more work as I would have to undo edits, but this will make the assembly process more accurate to how the game was originally built. 
* 11/14/2023 - Sam Dicker's section of code is buildable and will produce a playable ROM that only has the player ship, joystick controls and background starfield scrolling.  The scanner's "fin" graphics are drawn but the scanner logic itself does not work.

  ![0023](https://github.com/synamaxmusic/sinistar/assets/11140222/da73cf47-451c-4fc3-a624-98b837eaba6c)
* 11/06/2023 - Rewriting commences.
* May 2023 - Started looking over the original codebase for the first time.

## Overview

Four main programmers worked on Sinistar and each directory in the source code belongs to one of them (however there's evidence that all of them were modifying and editing each other's code).

The four modules that make up the codebase are assembled in this order:

* SAM
* WITT
* FALS
* MICA

Sam Dicker was the first software engineer to work on the game and his code deals with critical routines related to the game engine, the player's ship, and the Sinistar itself.  This also includes joystick control handling, rendering graphics, sound call tables, and background multi-tasking routines for enemy AI and gameplay logic.  Jack Haeger's pixel artwork is also represented in this module (located in the ```SAM/IMAGE.ASM``` file).

After Sam's code, we move on to Rich Witt's files.  He worked a large chunk of the game logic routines, sometimes modifying Sam's pre-existing code.  Rich's work includes the Sinistar death/player warp routines, sinibomb pickups, enemy speed tables and AI, collsion handling, and the Sinistar's lip sync animation.

Noah Falstein's module is up next and he worked on further AI programming for the enemies, planetoid logic (vibrating, tossing crystals, swarming, shattering), enemy population difficulty tables, and the Sinistar's speech calls.

Finally, RJ Mical's code involves the game's attract mode, high score table, operator message/high score initial entry, and death explosion routines for the warriors, the Sinistar, and player ship.  There's a fair amount of unused code located in this directory including an earlier version of RJ's explosion routine as well as Mike Metz and Ken Lantz's "Marquee" title screen that's only found in the AMOA '82 prototype build.

The ```MAKE.ASM``` file in the top directory grabs all the source code files from all four folders and tells the assembler which order they go in the binary ROM data.

## Build Instructions

This source code was rewritten to target [Macro Assembler {AS}](http://john.ccac.rwth-aachen.de:8000/as/index.html).  

To build Sinistar, place the four folders (```SAM, WITT, FALS, MICA```) and the ```MAKE.ASM``` file into the same directory as ASL and P2BIN.

Then, open a command prompt and type in:

```sh
asl make.asm -o sinistar.p
```
This will generate a .p file that we can feed into p2bin:

```sh
p2bin sinistar.p sinistar.bin
```

Finally, split the .BIN into separate 4KB ROM files and rename those files to match with the MAME ROM set filenames:

Address|ROM #|MAME ROM set Filename
| --- | --- | --- |
0000-0FFF|ROM 1|sinistar_rom_1-b_16-3004-53.1d
1000-1FFF|ROM 2|sinistar_rom_2-b_16-3004-54.1c
2000-2FFF|ROM 3|sinistar_rom_3-b_16-3004-55.1a
3000-3FFF|ROM 4|sinistar_rom_4-b_16-3004-56.2d
4000-4FFF|ROM 5|sinistar_rom_5-b_16-3004-57.2c
5000-5FFF|ROM 6|sinistar_rom_6-b_16-3004-58.2a
6000-6FFF|ROM 7|sinistar_rom_7-b_16-3004-59.3d
7000-7FFF|ROM 8|sinistar_rom_8-b_16-3004-60.3c
8000-8FFF|ROM 9|sinistar_rom_9-b_16-3004-61.3a
9000-DFFF| |(SPACE RESERVED FOR RAM)
E000-EFFF|ROM 10|sinistar_rom_10-b_16-3004-62.4c
F000-FFFF|ROM 11|sinistar_rom_11-b_16-3004-63.4a

This is how you would do that in P2BIN:

```sh
p2bin sinistar.p sinistar_rom_1-b_16-3004-53.1d -r $0000-$0FFF
p2bin sinistar.p sinistar_rom_2-b_16-3004-54.1c -r $1000-$1FFF
p2bin sinistar.p sinistar_rom_3-b_16-3004-55.1a -r $2000-$2FFF
p2bin sinistar.p sinistar_rom_4-b_16-3004-56.2d -r $3000-$3FFF
p2bin sinistar.p sinistar_rom_5-b_16-3004-57.2c -r $4000-$4FFF
p2bin sinistar.p sinistar_rom_6-b_16-3004-58.2a -r $5000-$5FFF
p2bin sinistar.p sinistar_rom_7-b_16-3004-59.3d -r $6000-$6FFF
p2bin sinistar.p sinistar_rom_8-b_16-3004-60.3c -r $7000-$7FFF
p2bin sinistar.p sinistar_rom_9-b_16-3004-61.3a -r $8000-$8FFF
p2bin sinistar.p sinistar_rom_10-b_16-3004-62.4c -r $E000-$EFFF
p2bin sinistar.p sinistar_rom_11-b_16-3004-63.4a -r $F000-$FFFF
```

## About the source code

Back in May 2023, I stumbled upon the fact that Sinistar's source code was leaked in 2021 and available on Github.  After deliberating for a few months and conducting several tests with various 6809 macro assemblers, I decided to do something I've never done before and accept the challenge of rewriting the source code for Sinistar so that it can be buildable with a newer assembler.  Considering the size of the codebase, this was not an easy or quick task.

Other Williams games have be rewritten before, such as [mwenge's work for Defender](https://github.com/mwenge/defender/) and [Robotron](https://github.com/mwenge/robotron/), both targeting the asm6809 assembler.  His work inspired me to make the attempt at recreating the missing 6800 assembly code for Sinistar's [Video Sound ROM 9 and 10](https://github.com/synamaxmusic/Sinistar-Sound-ROM).  

[Here is a video](https://youtu.be/Msc6hqyTW6U) on how I achieved this and how the sound ROMs in Sinistar work.  

The goal of both of these Sinistar repositories is to recreate the game's ROMs from scratch.  With Video Sound ROM 9, two disassemblies were heavily relied on in order to piece together the ROM since the source code was missing and had to be cobbled together from looking at the surviving source code and comments from the [other sound roms](https://github.com/historicalsource/williams-soundroms/).  With this project however, we have the [original source code](https://github.com/historicalsource/sinistar), so there's not as much guesswork involved (in theory).  I did tests with several different assemblers, including asm6809 and vasm (which I used previously for Sinistar's sound ROM) but I was running into several issues.  I wondered why Robotron and Defender were able to be retargeted for asm6809, but not Sinistar or even Joust.

Joust and Sinistar were the first two games developed by the new internal dev team at Williams, after Eugene Jarvis and Larry DeMar left Williams to form Vid Kidz. Because of this, the source code for both Joust and Sinistar are similar to each other but show a lot of differences from the code for Defender and Robotron, especially when it comes to the use of macros.

### Macros

For those who don't know, a macro is sequence of instructions that can be inserted into the final code when called.  They can be very flexible and powerful in that they can generate many lines of code with just one reference.  Several important routines in Sinistar rely on macros for various tasks, like compressing the font sprites or parsing ASCII strings and converting them into Williams Electronics's pseudo codepage standard.  Another set of macros called ```PUSHORG``` and ```PULLORG``` use an internal stack to keep track of where sections of the ROM code begin and end. 

Macros do show up for Defender and Robotron, but there's not too many of them, and whenever they do show up, they are very simple and short.  Joust's source utilizes more complex macros with more parameters but they too consist of just several lines of code.  Meanwhile, Sinistar defines at least 33 macros in just [one file alone](https://github.com/historicalsource/sinistar/blob/main/SAM/MACROS.SRC), with some macros reaching [50+ lines of code](https://github.com/historicalsource/sinistar/blob/main/WITT/TEXT.SRC).  The surprising complexity of some of these macros required several days of troubleshooting to get them working in this rewrite.

### Working with the BSO Assembler and VAX/VMS

Like Joust, Sinistar was written on VAX/VMS workstations.  I'm not sure what assembler was used for Joust, but both codebases appear to use the same syntax and we know that Sinistar was written for a cross-assembler by the now-defunct Boston System Office (BSO).  It had support for several macro instructions that only a few 6809 assemblers still use today, such as ```IRP```, ```IRPC``` and ```REPT```.  This particular assembler is currently lost (which is one of the main reasons why this project was started in the first place).

The BSO assembler also caused a lot of headaches for the dev team; one of the biggest issues was that the asssembler's symbol table size was very small, which made Sinistar's development even more difficult.  To directly quote the developers from the source code's readme file:

```
	The problem history with managing sources for 4 people while using
an assembler with a very limited symbol table size is not amusing.  Let it
suffice that we did what was neccessary at the time.
```

As a result, additional precautions had to be made in order for the code to build properly and that all the symbols matched up with everyone else's library.  For example, each of the four main software engineers had to generate their own files that listed every single ```EQU```, ```SET```, and symbol they used in their section of the game.  Due to the limited table size, any symbol in these files that's over 6 characters in length is truncated.

At the end of the toolchain, a batch script file written in VAX DCL language collected all of the source files and fed them into the assembler in a specific order.  It was a lot of work to make sure everything matched up but in the end, I'm really glad they were kinda forced to generate all these symbol definitions because it has made a lot of this reverse engineering work much, much easier.  

### Choosing a new assembler

Even just taking a quick glance over the code, it quickly becomes apparent that we need an modern and easily-obtainable assembler that supports several different kinds of macros or otherwise this project wouldn't be possible.  I decided to target the source code rewrite to work with [Macro Assembler {AS}](http://john.ccac.rwth-aachen.de:8000/as/index.html) because it supports a lot of those specific macro instructions previously mentioned and the syntax is very similar to what is in the original code so any rewrites are kept to a minimum.

[Alan R. Baldwin's ASxxxx cross-assembler](https://shop-pdp.net/ashtml/asxxxx.php) was also considered as it also supports the ```IRP```, ```IRPC``` and ```REPT``` macro instructions, but the amount of syntax changes needed in order for the code to build would be unfeasible. 

Admittedly, working with Macro Assembler {AS} has been a bit of a challenge as it does some things differently from other assemblers that I've come across and the documentation is rather daunting.  Unlike ASxxxx's manual, there's not many examples or concise instructions on how the assembler works.  In fact, I feel I learned more from looking at Sonic 1 and 2 disassemblies targeting {AS} than the manual itself.  Once I got the hang of the new syntax changes though, I started getting into the flow of things and was able to rewrite all of Sam Dicker's code in a week.  It was a rough start but I did get used to how {AS} operates and I'm happy with the results so far.

## Rewriting the source code

I soon realized that because of the new syntax, I would have to rewrite more code than I initially intended.  I tried my best to show all the changes to the code that I did with comments but I may have missed some minor edits here or there.  My intention has always been to leave as much original code in as possible and change only what is necessary.  Any major drastic changes will be pointed out in the comments.  Any new comments by me will use two semi-colons (```;;```), while original comments will only use one (```;```).

Because we're not using VMS to build this, I made a new file called ```MAKE.ASM```, based off the original ```MAKE.COM``` batch file.  This file loads in all the required source files for {AS} to process and also has defines for enabling debug features.

### PUSHORG and PULLORG 

When I first started rewriting the codebase, the first two macros that I commented out were ```PUSHORG```/```PULLORG```, but now I have implemented them back into the code.  Nearly all the source files use these two macros to define the start and stop addresses for that code section. 

They were used to hold various ```ORG``` addresses in an internal stack for the programmers as they worked on different sections of code.  ```PUSHORG``` is basically just a regular ```ORG``` instruction but is "pushing" the last address off the stack.  Conversely, ```PULLORG``` is saving that current address to the stack for a later ```PUSHORG```.

Before rewriting the macros, I used a standard ```ORG``` instruction for ```PUSHORG```.  If a symbol is next to ```PULLORG```, then I added a new "```<label> SET   *```" instruction to mark the new address for that symbol:

```
	;PUSHORG ROMSAVE
	ORG	ROMSAVE		;;Start code at last ROMSAV address

	...

	;PULLORG ROMSAVE
ROMSAVE	SET	*		;;Set current address to ROMSAV
```

When ```ORG ROMSAVE``` is called again at the beginning of the next assembly file, it will use the new address we previously assigned to ```ROMSAV```, essentially beginning where we previously left off in the ROM.

### ROUTINE

The ```ROUTINE``` macro basically handles multiple occurances of symbols.  If two symbols with the same name are defined, then a new symbol with a "Z" in front is created and a ```JMP``` instruction to the new symbol is inserted into the location of the old symbol.  For example the routine ```GAMOVER``` was first defined by Sam but at a later point in developement, the address for this symbol is used to immediately jump over to ```ZGAMOVER``` (defined by R.J.).  

```
* ROUTINE
* first occurance	- creates symbol
* second occurance	- types 'REPLACING' message
* first occurance	- types 'DUP REPLACE' error message
ROUTINE	MACRO	N1
	BLIST
	IFNDEF	N1
N1
	MESSG	"			CREATING N1"
	ELSE
	IFNDEF	ZN1
ZN1
	MESSG	"						REPLACING N1"
	ELSE
	LOCAL
	MESSG	"DUP						REPLACE N1"
	ENDIF	
.$$	SET	*
	ORG	N1
	JMP	.$$
	ORG	.$$
	ENDIF
	MLIST
	ENDM
```
Because of how Macroassembler {AS} handles macro arguments, an underscore has to be used between the "Z" and the routine label, so in this build ```ZGAMOVER``` is now ```Z_GAMOVER```.

The problem with this macro is that it doesn't say when this symbol renaming occurs until actually building the code and since no complete listing file exists for the codebase, the only remaining evidence of this renaming occurring can be seen in the old ```EQU``` and ```SET``` files.

### PAD

```PAD``` is another macro that gets used a lot to either create padding or reserve memory bytes and by "bookending" those bytes with two new labels: ```<label>SAV``` and ```<label>LEN```.  Unfortunately, this won't work with {AS} without having to change the label names to: ```<label>_SAV``` and ```<label>_LEN```.  While this underscore is acceptable for ```ROUTINE``` since replacing routines doesn't happen too often, ```PAD``` is used more frequently and will require a lot of rewriting to fix mismatching labels with the new underscore character.  I chose to not use this macro when new label names are being defined because of this.

### TEXT/PHRASE

The ```TEXT``` and ```PHRASE``` macros are very important as they create the strings of text that are displayed on-screen throughout gameplay.  

```
	TEXT	4B,60
	PHRASE	RED,68,GAME,OVER
```

To save space, every single word is assigned a Phrase Number and saved in a chunk of ROM called ```PHRSAV```.  Any duplicate words are then automatically eliminated as pre-defined words that are used over and over again just use one reference.  The ```TEXT``` macro assigns the screen position of the text while the ```PHRASE``` macro assigns which color and font size to use, as well as creating the strings of text.

This macro was very difficult to troubleshoot and gave me a lot of headaches.  In order to get this to work with {AS}, I have to take part of the ```PHRASE``` macro code outside the macro itself and insert it at the end of the routine that initially called the macro.  This has to be done everytime new words are defined.  I think {AS} wasn't working earlier because the macro is using ```ORG``` and starts messing up the other branches inside the previous routine that called the macro.  This workaround is a slightly different way of doing it compared to what the devs did by having the macro do all the work, but this more manual workaround gets the job done regardless.

Here's what this new code looks like and how it works:

```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE	SET	*		;; Save the current address

	ORG	PHRSAV		;; Jump over to PHRSAV to save our pointers
	FDB	_GAME		
	FDB	_OVER

PHRSAV	SET	*		;; Mark the new address for PHRSAV to add
				;; more phrases later

	ORG	ROMSAVE		;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
```
### Inconsistent label names

Thanks to the BSO's small symbol table size, several symbols appear in different files with slightly longer names, creating inconsistenties and assembly errors.  For example, ```ROMSAVE``` and ```ROMSAV``` are used interchangably in the original code, but this rewrite uses ```ROMSAVE``` exclusively.  To keep edits down to a minimum and leave the original longer symbol names untouched, a new file called ```new_equates.ASM``` was created that defines the longer symbol names and matches them up with their shorter counterparts.

```
SinIndex EQU	SinInde
addscore EQU	addscor
subpiece EQU	subpiec
PiecePtr EQU	PiecePt
PieceTbl EQU	PieceTb
MAXBOMBS EQU	MAXBOMB
MesgTime EQU	MesgTim
ScoreAddr EQU	ScoreAd
SiniSector EQU	SiniSec
AddBombs EQU	AddBomb
DCredits EQU	DCredit
PlaIndex EQU	PlaInde
PlyrAngl EQU	PlyrAng
addpiece EQU 	addpiec
```

### Local labels

{AS}  has some quirks with local labels so I had to redo them.  For example, here's what local labels look like for the BSO assembler:

```
1$	lda	lol
	jmp	2$
2$	lda	lmao
```

This is what this code would look like rewritten for {AS}:

```
.1S	lda	lol
	jmp	.2S
.2S	lda	lmao
```

Sometimes, ```SECTION/ENDSECTION``` are used to make local sections of code, especially when there's lots of routines using local labels.

Every once in a while I have to change local labels into global ones in order for the code to build at all, but I try to avoid this as much as possible.

### BSO Syntax

Thankfully, I found some [documentation](https://www.pagetable.com/docs/cbmasm/cy6502.txt) for another [missing BSO assembler](https://www.pagetable.com/?p=1538#fn:1) that explains some of the syntax and expressions used in the original Sinistar source code.  Here are some important ones to point out:

```

        UNARY:  +       Identity
                -       Negation
                >       High byte
                <       Low byte
                !N      Logical one's complement

        BINARY: +       Addition
                -       Subtraction
                *       Multiplication
                /       Division.  Any remainder is discarded.
                !.      Logical AND
                !+      Logical OR
                !X      Logical Exclusive OR

     Expressions will be evaluated according to the following operator
     precedence, and from left to right when of equal precedence:


                1)  Unary +, unary -, !N, <, >
                2)  *, /, !., !+, !X
                3)  Binary +, binary -
```

```

          Pseudo-     Syntax                Condition tested
            op

          .IF       .IF logical expr      true 
          .IF       .IF expr              expr <> 0
          .IFE      .IFE expr             expr = 0
          .IFN      .IFN expr             expr <> 0
          .IFLT     .IFLT expr            expr < 0
          .IFGT     .IFGT expr            expr > 0
          .IFLE     .IFLE expr            expr <= 0
          .IFGE     .IFGE expr            expr >= 0
          .IFDEF    .IFDEF sym            sym is a defined symbol
          .IFNDEF   .IFNDEF sym           sym is an undefined symbol
          .IFB      .IFB <string>         string is blank
          .IFNB     .IFNB <string>        string is not blank
          .IFIDN    .IFIDN <str1>,<str2>  str1 and str2 are identical
                                          character strings
          .IFNIDN   .IFNIDN <str1>,<str2> str1 and str2 are not 
                                          identical
```
These conditional pseudo-ops get used a lot so having this guide was extremely important for getting macros to work with Macroassembler {AS}; I'm really lucky to have stumbled across it.

### Decimal numbers

* ```RADIX 16``` is declared very early on and decimal numbers are defined by using ```.``` after the integer.
```
 	NITURRET	EQU	8.	;* The number of warrior images
	NIWORKER	EQU	16.	;* The number of worker images
	NIPLSHOT	EQU	32.	;* The number of player shot images
	NIWASHOT	EQU	32.	;* The number of warrior shot images
	NISBOMB		EQU	3.	;* The number of sinibomb images
```
These periods have been removed and ```RADIX 10``` is used instead when needed.  

At first, I tried changing the ```RADIX 16``` at the very beginning of the code but it created a lot of headaches.  Using the ```RADIX 10``` instructions also helps when browsing through the code as it makes it easier to distinguish the hex values from the decimal ones. 

### Common fixes

* Exclusive OR ```!X``` are now just ```!```.
* Bit shift operators ```!<``` and ```!>``` are now ```<<``` and ```>>```.
* ```#!N4``` is a value used a lot for fixing a DMA bug for the blitter graphic chip.  This value has been replaced with ```#~$4```.
