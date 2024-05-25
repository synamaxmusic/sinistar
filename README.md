<p align="center">
<img src="https://github.com/synamaxmusic/sinistar/assets/11140222/c6747150-ce04-4901-b479-bb44202e4407" alt="Sinistar gameplay with the player ship evading a giant skull-planet">
</p>

<h1 align="center">Sinistar</h1>

A game by Sam Dicker, Noah Falstein, R.J. Mical and Richard Witt

Source code rewrite by SynaMax, started November 6th, 2023; complete ROM set rebuilt for the first time on January 12th, 2024 (sound and speech code added on the 15th and 16th respectively).

****

Original game concept by John Newcomer

Artwork by Jack Haeger
  
Sound ROM (VSNDRM9/VSNDRM10) programmed by Mike Metz
  
Speech routines programmed by John Kotlarik
  
Special thanks to: Kay Anderson, Harry Cline, Kristina Donofrio, Ken Fedesna, Ken Graham (RIP), Rich Grande, Ken Lantz, Pierre Maloka, Keith McMillen, John Meissen, Tim Murphy, Tom O'Meara, Bill Pfutzenreuter, Rudy Plemich, Dave Rzepka, Marc Stanis, Ed Suchocki, and Stewart West

SynaMax would like to thank: HistoricalSource, braedel, kgalocy, mecha, Daniel Lopez, Tony Temple, AT Gonzalez, Nick Bernhard, Alfred Arnold for creating {AS}, David "Haze" Haywood, "N-F", all my fans and subscribers from my YouTube channel, my Patreon supporters, everyone on KLOV who has shown their appreciation and encouragement; and last but not least, my spouse for their never-ending patience and support during this project.

****

The original source code for the game can be found at https://github.com/historicalsource/sinistar/

For the first time ever, the source code for the sound and speech ROMs are included with the game code.  The older version of the recreated sound ROM source can be found here: https://github.com/synamaxmusic/Sinistar-Sound-ROM/

****

<!-- vim-markdown-toc GFM -->

* [Important Milestones](#important-milestones)
* [Overview](#overview)
* [Build Instructions](#build-instructions)
  	* [Game code](#game-code)
  	* [Sound ROMs](#sound-roms)
  	* [Speech ROMs](#speech-roms)
	* [Decoder ROMs 4 & 6](#decoder-roms-4--6)
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
* [Source code map](#source-code-map)
* [Debug Options](#debug-options)
	* [PROMS](#proms)
	* [DisableKenChk](#disablekenchk)
  	* [FakeChecksums](#fakechecksums)
 	* [DisableTests](#disabletests)
	* [NOTEST](#notest)
	* [SAMDEBUG](#samdebug)
	* [InfiniteShips](#infiniteships)
	* [NoDeath](#nodeath)
	* [DisableSinistarCollision](#disablesinistarcollision)
	* [Witt](#witt)
	* [WittRock](#wittrock)
* [Mods](#mods)
  	* [MarqueeFix](#marqueefix)
   	* [ExtraShipFix](#extrashipfix)
	* [DifficultyMod](#difficultymod)
	* [QuickOperatorEntry](#quickoperatorentry)
	* [PauseMod](#pausemod)
 	* [Old deprecated defines](#old-deprecated-defines)
		* [EnableMods](#enablemods-deprecated)
		* [DiagnosticTestFix](#diagnostictestfix-deprecated)
<!-- vim-markdown-toc -->

## Important Milestones

{Warning: flashing images below)

* 05/24/2024 - I pushed an important fix for the new ```SAMTAIL``` mod.  Braedel discovered by accident that the watchdog chip was still triggering a system reset after the initial "rug screen" checksum test.  I narrowed down the problem to the initialization section of the TAIL routine where the ```INITRAM``` routine is called a lot to to generate the thruster plume graphic effect.  To insert the instructions needed to fix the issue, I found a ```CLRB``` instruction that allowed me to use the B register without messing up anything else in the routine.  According to Sean Riddle, preventing the watchdog from being triggered requires writing $39 to address $CBFF within 8 vertical blanking periods (about 133 milliseconds).  The Williams devs refer to this as "stroking" or "feeding the watchdog".  The ```TAIL``` routine was allowing just enough VBLANKs between writes to cause the watchdog to "bark" and reset the system.  Of course, this doesn't happen currently with MAME emulation so the watchdog never resets the machine, like it was doing on hardware.

  The fact that I had to add the watchdog instructions to this routine make me wonder if this special effect was removed early in development before the watchdog chip was enabled.

* 02/26/2024 - Relocated the Bargraph debug feature over to the new allocated area in ROM 11, it seems to run a bit more stable now!
  
  	More importantly, I reimplmented the unused "TAIL" routine from Sam's module.  This code draws a special effect jet exhaust behind the player ship.  When I initally tried injecting this routine into the ROM data last October, it seemed to be very buggy and would crash the game.  However, after inserting TAIL back into the rewritten codebase and using Macroassembler {AS} to build it, it works way better now!  To my surprise, the blue flames that I first witnessed back in October were actually a glitch as now they're a lovely combination of red and yellow pixels, which produces a much more interesting flame effect!

	![sinistar_tail_v2_60fps](https://github.com/synamaxmusic/sinistar/assets/11140222/614630af-147b-428e-834d-250d9d4afda9) 

  	No wonder why Jack Haeger's marquee artwork depicts the player ship with a flame trail!

	![sinistar_marquee_jet_exhaust_tail](https://github.com/synamaxmusic/sinistar/assets/11140222/463dfd13-9095-498e-9ce3-e1e85c741fca)

	The tail also appears to react to how far the 49-way joystick is being pushed.  Slightly pulling on the stick results in a diminished flame tail, while not pressing it at all turns the effect off.

	Use the ```SAMTAIL``` define in ```MAKE.ASM``` to build the game with this feature.  I made it to work with other mods as well, see [Mod Combos](#mod-combos) for more info.


* 02/13/2024 - Spent the last few days working with braedel on getting the pause mod and AMOA graphic to work on the original hardware.  The original process of overwriting the RAM/ROM tests proved to be troublesome as it was messing around with the watchdog and preventing the machine from powering up.  Instead, new mods are now relocated to overwrite the "Cross hatch", color bars and switch tests in ROM 11.  This fixes the boot issues and allows mods to finally work outside of emulation!

* 02/09/2024 - I have added a new mod that allows the player to pause the game!  Simply press the player 1 button during gameplay to pause; pressing it again resumes the action.  Huge thanks to braedel and Chris Brooks over at Coinoplove.com for inspiring me to implement this new feature.

* 01/30/2024 - As mentioned in the readme for my [Joust source code rewrite](https://github.com/synamaxmusic/joust), I have finally figured out how to get Tim Murphy's Walsh Function Sound Machine macros to work.  This means that we can reproduce the "Extra Ship" and "ERROAR" sound effects accurately by using these macros instead of just copying the bytes over from the sound ROM.  We are still missing a couple of macro instructions related to the pitch commands for "ERROAR" and one of the unused sounds,  as I'm still not sure how to recreate them with macros yet; however, all the data for the "Extra Ship" effect is now generated via these macros, exactly how it was done in 1982! 

* 01/29/2024 - The [source code for Joust](https://github.com/synamaxmusic/joust) has been completely rewritten and I have decided to add a new source file from that repository over here as well.  In order for Sinistar to launch in MAME, two decoder ROMs are needed.  Use [decoder_roms.asm](decoder_roms.asm) to build these two required files.

* 01/23/2024 - We have our first pull request!  Daniel Lopez verified that the game assembles with the unofficial [community-maintained package of Macroassembler {AS}](https://aur.archlinux.org/packages/mas) in Arch Linux; however, some minor changes were required.  All ```!=``` operators were changed to ```<>``` in order for the code to build because the package uses a older verison of {AS}.  The rest of the codebase uses ```<>``` so this actually makes things more consistent.

* 01/21/2024 - Added a mod called ```QuickOperatorEntry``` that allows the user to edit the attract mode operator message much faster than before.  This also affects the speed for inputting high score initials so it's possible that it can be easier to mess up when entering your name/initials.

* 01/20/2024 - Added a define that fixes the checksum byte found in the very beginning of ```VSNDRM9.ASM```.  The original byte is ```$AA``` but this is incorrect and the diagnostic test fails as a result.  Using ```$24``` for Video Sound ROM 9 or ```$70``` for Video Sound ROM 10 will fix this issue.

* 01/16/2024 - Took the plunge today and got the speech ROMs disassembled.  Managed to get the vast majority of the code figured out!
  
* 01/15/2024 - Video Sound ROM 9/10's recreated source code has been rewritten to target Macroassembler {AS} instead of vasm.  This is the first time ever that both sources for the sound rom and the game are included in the same repository!  Rewriting VSNDRM9 for {AS} actually made the sound rom source code more accurate to how it was originally written and instead of having two separate sources like how it was previously done in my old version, we now just have one complete file that builds a perfect copy of the sound rom.  I'm also planning on adding IFDEF instructions so that both sound roms can be built with the correct checksums, which will allow the test button on the sound board to function again!

* 01/12/2024 - 2:23pm, I fixed the last remaining byte in the ROM that was different from the source code.  We can finally produce a bit-perfect copy of the final version of Sinistar!

  I added a new file called ```BURN.BAT``` for those who want to quickly generate the ROM files from the ```sinistar.p``` file.  ROM 11 is handled slightly differently from the other ROMs so an additional option for P2BIN has to be given.
  Already implemented some debug functions and hope to add more soon, along with a fix to re-enable the original Marquee title screen from the AMOA build.  The debug defines are found in ```MAKE.ASM```.

* 01/12/2024 - At 12:23am, I finally finished rewriting all the game's code, with the exception of the diagnostic ROM (which is treated separately from the game).  This means 10 of Sinistar's 11 ROMs match up perfectly with this rewrite and that the game should be completely playable.  Once T13.ASM is rewritten, we should be all done.

* 01/11/2024 - All four modules and Sam's patches are finished.  This means all that's left are the patches from the three remaining programmers, plus seeing how much debug stuff we can get working again.  We're getting really close to wrapping this up!

* 01/08/2024 - Noah's module is complete!  Gameplay finally works, but with some caveats: the Sinistar now appears in the sector but with RJ's explosion routine missing, it behaves differently and is ultimately invincible as a result.  If the player hits the Sinistar with enough bombs, the Sinistar will "think" it's dead, however the warp sequence never starts and the Sinistar will stay stunned until the player gets killed by a warrior.  Once the player respawns, the Sinistar (still with one piece remaining) returns to its chasing state. Unless it is hit by another sinibomb again, it can bite the player.

  Also worth pointing out is that the sinibombs fire but they are only visible in the scanner and produce graphical glitches when near the Sinistar ~~(one of Rich's patches is needed to fix these issues)~~ (turns out I had a made a local section of code that was actually preventing the Sinibomb graphics from being drawn; removing the ```SECTION/ENDSECTION``` instructions fixed this issue).

  Currently working on rewriting RJ's module: this includes the attract mode, service menu, high score and status screens, and explosion effects.

  ![sinistar_noah_module](https://github.com/synamaxmusic/sinistar/assets/11140222/7a4302db-d0fc-480a-8408-cecb6ca4da69) ![sinistar_noah_module_sinibomb_glitch](https://github.com/synamaxmusic/sinistar/assets/11140222/9b66ca0a-c4b7-42f3-b3fd-917f6b291642)


* 01/06/2024 - Rich's module is finally complete, we're halfway done!
* 01/03/2024 - I cleaned up some of my older comments and replaced my old ```PUSH/PULLORG``` hacks with the actual macros.  The same goes for the ```ROUTINE``` macro; it's actually pretty useful as it shows messages in the listing output and makes it easier to understand.  ```PAD``` doesn't work exactly the same with the new assembler so it's only used sparringly in this rewrite when there are no macro arguments; any ```PAD``` macros that need to generate new lable names have been replaced with three lines of code that reproduces exactly what we need (see [PAD](#pad) for more info).
* 12/30/2023 - I got [several important and heavily-used macros](https://github.com/synamaxmusic/sinistar/commit/f8ace13ec0a8a5db5baac7f346cc17ed26605bbd) to work properly after several tests.  These macros include ```PUSHORG```,```PULLORG```,```ROUTINE```,```PAD```, and the Copyright string macro.  Implementing these will require more work as I would have to undo edits, but this will make the assembly process more accurate to how the game was originally built. 
* 11/14/2023 - Sam Dicker's section of code is buildable and will produce a playable ROM that only has the player ship, joystick controls and background starfield scrolling.  The scanner's "fin" graphics are drawn but the scanner logic itself does not work (because there are no enemies nearby).
 
  ![0023](https://github.com/synamaxmusic/sinistar/assets/11140222/da73cf47-451c-4fc3-a624-98b837eaba6c)
* 11/06/2023 - Source code rewrite commences.
* 10/14/2023 - Got previously undocumented player ship "tail" jet exhaust graphics from Sam's module working.  Hoping to get this working in the rewrite eventually.
  
  ![sinistar_tail_v2](https://github.com/synamaxmusic/sinistar/assets/11140222/ed8bda23-ff57-4d6e-b40e-af62edf34e97)
* 10/07/2023 - After several days of playtesting and experiments, I completed my Difficulty Mod which reduces the enemy populations to make the game easier.
* 10/05/2023 - Managed to get the original AMOA "Marquee" title screen graphic working in the final version of the game.  Turns out the source code is slightly different from the AMOA build and has the position of the graphics and copyright text slightly higher than before.
  
  ![0078](https://github.com/synamaxmusic/sinistar/assets/11140222/28dde0fb-d673-49e3-8795-61ab498bf300) ![0093](https://github.com/synamaxmusic/sinistar/assets/11140222/9dbdb5ff-5c8b-4683-94e5-0a622502e5cc)
![0091](https://github.com/synamaxmusic/sinistar/assets/11140222/32e793a2-b724-4aed-bca3-71a5bac5e8ec)


* 09/30/2023 - Not code-related but discovered that the Sinistar roar sound effect is actually [a recording of a gorilla entitled, "Gorilla Heavy Panting And Two Roars"](https://www.dewolfemusic.com/search.php?id=26618491&code=pTOgaZ) from a De Wolfe Sound Effects library originally released in 1975 (DW/FX LP No. 16 "Zoo Animals - Wildlife", track 12 on side A).
* 09/05/2023 - Started reverse-engineering the population tables for enemies and created [a repository for all my RE notes](https://github.com/synamaxmusic/sinistar-notes).
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

### Game code

This source code was rewritten to target [Macro Assembler {AS}](http://john.ccac.rwth-aachen.de:8000/as/index.html).  

To build Sinistar, place the four folders (```SAM, WITT, FALS, MICA```) and the ```MAKE.ASM``` file into the same directory as ASL and P2BIN.

Then, open a command prompt and type in:

```sh
asl make.asm -o sinistar.p
```
Once the ```sinistar.p``` file is generated, we can use the ```BURN.BAT``` file to create the 11 separate ROM files that make up Sinistar.

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

If it's not possible to use ```BURN.BAT```, this can be typed into a command prompt instead:

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

### Sound ROMs

Building Video Sound Rom 9 (VSNDRM9) just requires two commands:

```sh
asl VSNDRM9.ASM -o vsndrm9.p
```
Then use P2BIN to generate the binary ROM file:

```sh
p2bin vsndrm9.p -l 00 video_sound_rom_9_std.808.ic12
```

To build the cockpit-exclusive Video Sound Rom 10, simply remove the semi-colon in front of ```STEREO  EQU  1``` in ```VSNDRM9.ASM```, save the file and repeat the build instructions above (use ```video_sound_rom_10_std.ic12``` for the filename instead).

### Speech ROMs

Type this into a command prompt/terminal:

```sh
asl SPEECH.ASM -o speech.p
```

Then run ```SPEECH_BURN.BAT``` to generate the four speech ROMs.

If it's not possible to use ```SPEECH_BURN.BAT```, this can be manually typed into a command prompt instead:

```sh
p2bin speech.p 3004_speech_ic7_r1_16-3004-52.ic7 -r $B000-$BFFF
p2bin speech.p 3004_speech_ic6_r1_16-3004-51.ic6 -r $C000-$CFFF
p2bin speech.p 3004_speech_ic5_r1_16-3004-50.ic5 -r $D000-$DFFF
p2bin speech.p 3004_speech_ic4_r1_16-3004-49.ic4 -l 00 -r $E000-$EFFF
```

### Decoder ROMs 4 & 6

This is probably a little bit overkill but I also included code that builds the required decoder ROMs needed for the game to run.  MAME will refuse to launch the game if these files are not included so I added a [new source file](decoder_roms.asm), even though it's fairly easy to find these files online.  Regardless, I added them for completeness sake.

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


>	The problem history with managing sources for 4 people while using
> an assembler with a very limited symbol table size is not amusing.  Let it
> suffice that we did what was neccessary at the time.


As a result, additional precautions had to be made in order for the code to build properly and that all the symbols matched up with everyone else's library.  For example, each of the four main software engineers had to generate their own files that listed every single ```EQU```, ```SET```, and symbol they used in their section of the game.  Due to the limited table size, any symbol in these files that's over 6 characters in length is truncated.

At the end of the toolchain, a batch script file written in VAX DCL language collected all of the source files and fed them into the assembler in a specific order.  It was a lot of work to make sure everything matched up but in the end, I'm really glad they were kinda forced to generate all these symbol definitions because it has made a lot of this reverse engineering work much, much easier.  

### Choosing a new assembler

Even just taking a quick glance over the code, it quickly becomes apparent that we need an modern and easily-obtainable assembler that supports several different kinds of macros or otherwise this project wouldn't be possible.  I decided to target the source code rewrite to work with [Macro Assembler {AS}](http://john.ccac.rwth-aachen.de:8000/as/index.html) because it supports a lot of those specific macro instructions previously mentioned and the syntax is very similar to what is in the original code so any rewrites are kept to a minimum.

[Alan R. Baldwin's ASxxxx cross-assembler](https://shop-pdp.net/ashtml/asxxxx.php) was also considered as it also supports the ```IRP```, ```IRPC``` and ```REPT``` macro instructions, but the amount of syntax changes needed in order for the code to build would be unfeasible. 

Admittedly, working with Macro Assembler {AS} has been a bit of a challenge as it does some things differently from other assemblers that I've come across and the documentation is rather daunting.  Unlike ASxxxx's manual, there's not many examples or concise instructions on how the assembler works.  In fact, I feel I learned more from looking at Sonic 1 and 2 disassemblies targeting {AS} than the manual itself.  Once I got the hang of the new syntax changes though, I started getting into the flow of things and was able to rewrite all of Sam Dicker's code in a week.  It was a rough start but I did get used to how {AS} operates and I'm happy with the results so far.

## Rewriting the source code

I soon realized that because of the new syntax, I would have to rewrite more code than I initially intended.  I tried my best to show all the changes to the code that I did with comments but I may have missed some minor edits here or there.  My intention has always been to leave as much original code in as possible and change only what is necessary.  Any major drastic changes will be pointed out in the comments.  New comments by me will use two semi-colons (```;;```), while original comments will only use one (```;```).

Whenever possible, any changes to the code are marked by comments to the right that say ```;;Fixme was:``` followed by the original instructions.

```
    IF $4000>>L_N2&M_N1 <> 0		;;Fixme was: IFN 4000!>LN2!.MN1
```

Because we're not using VMS to build this, I made a new file called ```MAKE.ASM```, based off the original ```MAKE.COM``` batch file.  This file loads in all the required source files for {AS} to process and also has defines for enabling debug features.

I chose to change the original source filename extensions from *.SRC to *.ASM because 1) Notepad++ displays syntax highlighting with the *.ASM extension and 2) it makes it easier to identify the rewritten files from the original files.

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

Note that not all local label changes have been marked with ```;;Fixme was:``` comments as it would be too many to add and can clutter up the code.

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

Interestingly, there are a couple of expressions that don't appear here that do show up in the Sinistar and Joust codebases.  Here's a snippet of code from Joust as an example:

```
FCB  WAIT,!HCALL,!WCALL,MINUS-*,ZERO-*,PLUS-*,FLYVEL
```

```!H``` was used for separating the high byte of a word, while ```!W``` is used for the lower byte of a word.  The first one makes an appearance in Sinistar's codebase but ```!W``` is a new one that I haven't encountered before.

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
* Binary AND ```!.``` are now just ```&```
* Binary OR ```!+``` are now ```|```
* ```*``` asterisks were used to denote comments at the start of a new line.  These have now have semi-colons in front of them (```;*``` ) to tell the assembler this is a comment.  ```*``` is now exclusively used as the current value of the program counter.

## Source code map

This list shows all the files that are needed to build the game (in the order they are first loaded into the assembler, as opposed to {AS} displaying when files are finished processing).  A lot of these files have ```INCLUDE``` instructions inside other files, creating nested references which can make things confusing pretty quickly.  This map aims to make the code a little bit easier to navigate.

### MESSAGE

The very first files to be processed through the assembler are routines related to displaying the messages for diagnostic and in-game strings.  It is based off of previous code from Joust (but modified to work with vertical monitors).  Jack Haeger's pixel fonts also live here and are compressed with macros when assembled.  A routine decompresses these fonts and stores them in static RAM ($D000).

* [SAM/MESSAGE.ASM](SAM/MESSAGE.ASM) (Routines for text output and for compressing/decompressing the 5x7 and 3x5 pixel font tables)
  * [SAM/MESSEQU1.ASM](SAM/MESSEQU1.ASM) (Equates for allocating system-critical stuff like RAM, CMOS settings, watchdog, vectors, etc.)
    * [SAM/MESSEQU.ASM](SAM/MESSEQU.ASM) (Message equates for various system/diagnostic strings)
  * [SAM/MESSEQU2.ASM](SAM/MESSEQU2.ASM) (Williams Electronics codepage equates)
  * [SAM/PHRASE.ASM](SAM/PHRASE.ASM) (Strings and vectors for various messages like "INITIAL TESTS INDICATE", "BOOKKEEPING TOTALS", etc.)

### EQUATES

* [SAM/EQUATES.ASM](SAM/EQUATES.ASM)
  * [SAM/START.ASM](SAM/START.ASM) (Sets up 6809 direct page register and sets ```RADIX``` to 16) 
    * [SAM/MACROS.ASM](SAM/MACROS.ASM) (Macros for assembly counters, pseudo opcodes, RNGs, multitasking, sound calls, and copyright strings)
      * [WITT/DISPLAY.ASM](WITT/DISPLAY.ASM) (Message display macros)
  * [SAM/S1.ASM](SAM/S1.ASM)
    * [SAM/SAMEQUAT.ASM](SAM/SAMEQUAT.ASM) (Assembly counters, hardware constants, game constants)
    * [SAM/SAMOFFSE.ASM](SAM/SAMOFFSE.ASM) (Offsets for object/task workspaces, "characteristics descriptors", etc.)
  * [FALS/N1.ASM](FALS/N1.ASM)
    * [FALS/N1SYM.ASM](FALS/N1SYM.ASM) (Noah's equates and offsets needed for Sam's module)
  * [WITT/R1.ASM](WITT/R1.ASM)
    * [WITT/SYMSAM.ASM](WITT/SYMSAM.ASM) (Rich's equates needed for Sam's module)

### IMAGE

* [SAM/IMAGE.ASM](SAM/IMAGE.ASM) (Nearly all of the sprites are found here; ```ROMSAVE``` starts after image data)

### Sam's module

* [SAM/SAMS.ASM](SAM/SAMS.ASM)
  * [SAM/S2.ASM](SAM/S2.ASM)
    * [SAM/SAMRAM.ASM](SAM/SAMRAM.ASM) (Ram allocation)
    * [SAM/GROUND.ASM](SAM/GROUND.ASM) (end of grounded intelligence lists)
    * [WITT/TEXT.ASM](WITT/TEXT.ASM) (Text macro converts strings to Williams codepage and positions on screen)
    * [SAM/PANEL.ASM](SAM/PANEL.ASM) (control panel switch vector table)
    * [SAM/INITALL.ASM](SAM/INITALL.ASM) (Initialization routines)
    * [SAM/EXEC.ASM](SAM/EXEC.ASM) (Executive loop)
    * [SAM/EXECJNK.ASM](SAM/EXECJNK.ASM) (miscellaneous exec stuff)
    * [SAM/TRASCOM.ASM](SAM/TRASCOM.ASM) (dynamic storage 'trash compacting' routines)
    * [SAM/NEWTUNE.ASM](SAM/NEWTUNE.ASM) (Sound call routine)
    * [SAM/PLSHOOT.ASM](SAM/PLSHOOT.ASM) (player shooting)
    * [SAM/PIXCHK.ASM](SAM/PIXCHK.ASM) (pixel collision check routine)
    * [SAM/BOUNCE.ASM](SAM/BOUNCE.ASM) (bounce routine)
    * [SAM/ADDSCOR.ASM](SAM/ADDSCOR.ASM) (player score and sinibomb status display and change)
    * [SAM/ADDPIEC.ASM](SAM/ADDPIEC.ASM) (add and subtract sinistar pieces)
    * [SAM/FRAGEXP.ASM](SAM/FRAGEXP.ASM) (fragment explosion)
    * [SAM/SCANNER.ASM](SAM/SCANNER.ASM) (scanner routines)
    * [SAM/GETOBJ.ASM](SAM/GETOBJ.ASM) (screen list routines)
    * [SAM/DRAWOBJ.ASM](SAM/DRAWOBJ.ASM) (display routines)
    * [SAM/SLEEP1.ASM](SAM/SLEEP1.ASM) (multitasking routines)
    * [SAM/FUNCTION.ASM](SAM/FUNCTION.ASM) (Math functions)
    * [SAM/TB13.ASM](SAM/TB13.ASM) (Utility routines)
    * [SAM/SAMTABLE.ASM](SAM/SAMTABLE.ASM) (tables for characteristics descriptors, sound effects, math functions, color palette, etc.)
    * [SAM/IRQ.ASM](SAM/IRQ.ASM) (Interrupt routines)

### Rich's module

* [WITT/RICHS.ASM](WITT/RICHS.ASM)
  * [WITT/R2.ASM](WITT/R2.ASM)
    * [WITT/SYMRICH.ASM](WITT/SYMRICH.ASM) (Rich's symbols)
    * [WITT/RAMRICH.ASM](WITT/RAMRICH.ASM) (Ram variables)
    * [WITT/INIRICH.ASM](WITT/INIRICH.ASM) (Initialization routines for RICH)
      * [WITT/EMPTY.ASM](WITT/EMPTY.ASM) ("EMPTY" or bombs display)
        * [WITT/ZAPRTS.ASM](WITT/ZAPRTS.ASM) (Copyright checking RTS macro)
      * [WITT/ANISINI.ASM](WITT/ANISINI.ASM) (Animate Sinistar)
        * [WITT/SPEAK.ASM](WITT/SPEAK.ASM) (Speak macro)
        * [FALS/SC1.ASM](FALS/SC1.ASM) (Speech Tunes)
    * [WITT/DISP.ASM](WITT/DISP.ASM) (Message display routines)
      * [WITT/DISPE.ASM](WITT/DISPE.ASM) (Message to player erasing)
        * [WITT/ERASE.ASM](WITT/ERASE.ASM) (Message erasing intelligence)
    * [WITT/COLLISIO.ASM](WITT/COLLISIO.ASM) (Collision effects)
      * [SAM/COLLIDE.ASM](SAM/COLLIDE.ASM) (Collision macros)
      * [WITT/DEATH.ASM](WITT/DEATH.ASM) (Player death routine)
      * [WITT/SUBPART.ASM](WITT/SUBPART.ASM) (Kill a part of the sinistar)
    * [WITT/COPYRIGH.ASM](WITT/COPYRIGH.ASM) (EBCDIC copyright)
    * [WITT/DIFFICUL.ASM](WITT/DIFFICUL.ASM) (Difficulty factor tables)
    * [WITT/KRSINI.ASM](WITT/KRSINI.ASM) (Sinistar Killing routine)
      * [WITT/STBLIMP.ASM](WITT/STBLIMP.ASM) (Impulse engine speed table) [Gets patched over by ZSTBLIMP]
    * [WITT/LEAVESEC.ASM](WITT/LEAVESEC.ASM) (Leaving sector vectors)
      * [WITT/LSSBOMB.ASM](WITT/LSSBOMB.ASM) (Sinibomb leaving sector)
      * [WITT/LSWOCR.ASM](WITT/LSWOCR.ASM) (Worker with crystal leaving sector)
        * [WITT/ADDPART.ASM](WITT/ADDPART.ASM) (Build up the sinistar)
      * [WITT/LSSINI.ASM](WITT/LSSINI.ASM) (Sinistar leaving sector)
    * [WITT/TABLES.ASM](WITT/TABLES.ASM) (Distance/Velocity tables)
      * [WITT/STBLSBOM.ASM](WITT/STBLSBOM.ASM) (Sinibombs)
      * [WITT/STBLSINI.ASM](WITT/STBLSINI.ASM) (Sinistar)
      * [WITT/STBLOSIN.ASM](WITT/STBLOSIN.ASM) (New Sinistar orbital approach  <<< Added by Noah >>>)
      * [WITT/STBLMINE.ASM](WITT/STBLMINE.ASM) (Warriors mining)
      * [WITT/STBLL0.ASM](WITT/STBLL0.ASM) (Warriors leading)
      * [WITT/STBLW0.ASM](WITT/STBLW0.ASM) (Warriors following)
      * [WITT/STBLW1.ASM](WITT/STBLW1.ASM) (Warriors intercepting)
      * [WITT/STBLWORK.ASM](WITT/STBLWORK.ASM) (Workers circling player)
      * [WITT/STBLINT.ASM](WITT/STBLINT.ASM) (Workers picking up crystals)
      * [WITT/STBLHEAV.ASM](WITT/STBLHEAV.ASM) (Workers delivering crystals)
      * [WITT/STBLBOMB.ASM](WITT/STBLBOMB.ASM) (Player on demo bombing run)
    * [WITT/WORKER.ASM](WITT/WORKER.ASM)
      * [WITT/ANIWORK.ASM](WITT/ANIWORK.ASM) (Animate worker)
      * [WITT/DISTANCE.ASM](WITT/DISTANCE.ASM) (Distance Computations)
        * [WITT/GETLVX.ASM](WITT/GETLVX.ASM) (Velocity module for orbits)
      * [WITT/RETARGET.ASM](WITT/RETARGET.ASM) (Reposition Sinistar to center offset)
      * [WITT/UPDDTC.ASM](WITT/UPDDTC.ASM) (Update Distance to Caller)
      * [WITT/UPDFLANG.ASM](WITT/UPDFLANG.ASM) (Update Flight Angle)
      * [WITT/VELOCITY.ASM](WITT/VELOCITY.ASM) (Velocity computations)
        * [WITT/CHASE.ASM](WITT/CHASE.ASM) (Adjust a desired speed closer to the velocity of a moving target)
        * [WITT/LDYWCR.ASM](WITT/LDYWCR.ASM) (provides the object's caller's scanner workspace address)
    * [WITT/WARRIOR.ASM](WITT/WARRIOR.ASM)
      * [WITT/AIMWARR.ASM](WITT/AIMWARR.ASM) (Aiming to track moving target)
      * [WITT/ANIWARR.ASM](WITT/ANIWARR.ASM) (Animation)
      * [WITT/FOLLOW.ASM](WITT/FOLLOW.ASM) (Squadron leader targeting)
      * [WITT/SCREENCH.ASM](WITT/SCREENCH.ASM) (On/Off screen check)
      * [WITT/SHOOT.ASM](WITT/SHOOT.ASM) (Warrior shooting routine)
      * [WITT/THINK.ASM](WITT/THINK.ASM) (Animate/Intelligence check)
      * [WITT/WARRON.ASM](WITT/WARRON.ASM) (On Screen routine)
      * [WITT/WARROFF.ASM](WITT/WARROFF.ASM) (Warrior off screen routine)
      * [WITT/WASHODDS.ASM](WITT/WASHODDS.ASM) (Shooting odds computations)
      * [WITT/ZWASHODD.ASM](WITT/ZWASHODD.ASM)
    * [WITT/SINIBOMB.ASM](WITT/SINIBOMB.ASM)
    * [WITT/SINI.ASM](WITT/SINI.ASM)
    * [WITT/STUBS.ASM](WITT/STUBS.ASM) (To fake Noah's stuff)
* [WITT/RICHS2.ASM](WITT/RICHS2.ASM)
  * [WITT/BUTTON.ASM](WITT/BUTTON.ASM) (Button handling with Easter Egg routine)

### Noah's module

* [FALS/NOAHS.ASM](FALS/NOAHS.ASM)
  * [FALS/N2.ASM](FALS/N2.ASM) (Noah's current version release of rmb and src)
    * [FALS/N1RAM.ASM](FALS/N1RAM.ASM)
    * [FALS/N1ALL.ASM](FALS/N1ALL.ASM) (Vibration routines, Planetoid/Crystal logic, Calling Intelligence, Killing/Explosion subroutines, Difficulty adjustment code, Population tables)
  * [FALS/N3.ASM](FALS/N3.ASM) (Final "characteristics descriptors" for all game objects)

### RJ's module

* [MICA/BOBS.ASM](MICA/BOBS.ASM)
  * [MICA/B1.ASM](MICA/B1.ASM)
    * [MICA/BOBEQUAT.ASM](MICA/BOBEQUAT.ASM) (Warrior/Player Explosion and High Score/Operator Message entry equates)
    * [MICA/BOBOFFSE.ASM](MICA/BOBOFFSE.ASM)
  * [MICA/B2.ASM](MICA/B2.ASM)
    * [MICA/BOBRAM.ASM](MICA/BOBRAM.ASM)
    * [MICA/ZPLXQUE.ASM](MICA/ZPLXQUE.ASM) (Player Explosion Task Queuer)
    * [MICA/PLXTSK.ASM](MICA/PLXTSK.ASM) (Player Explosion Task)
    * [MICA/ZWRXQUE.ASM](MICA/ZWRXQUE.ASM) (Warrior Exploding-Fragments Task Queuer)
    * [MICA/WRXTSK.ASM](MICA/WRXTSK.ASM) (Warrior Explosion Task)
    * [MICA/ZSNXQUE.ASM](MICA/ZSNXQUE.ASM) (Sinistar Explosion Task Queuer)
    * [MICA/SNXTSK.ASM](MICA/SNXTSK.ASM) (Sinistar Explosion Task)
    * [MICA/ZZATTRAC.ASM](MICA/ZZATTRAC.ASM) (High Score To Date/Marquee Pages Task)
    * [MICA/MARQUEE.ASM](MICA/MARQUEE.ASM) (Marquee Page By Ken Lantz and Mike Metz) [Not included unless MarqueeFix is defined]
    * [MICA/ATTMSGS.ASM](MICA/ATTMSGS.ASM) (Attract Mode messages)
    * [MICA/STATUS.ASM](MICA/STATUS.ASM) (Status Page - Displayed at start of player turn)
    * [MICA/HSTDTE.ASM](MICA/HSTDTE.ASM) (High Score To Date Entry routine)
    * [MICA/HSTDIM.ASM](MICA/HSTDIM.ASM) (High Score Table of initials)
    * [MICA/ZGAMOVER.ASM](MICA/ZGAMOVER.ASM) (display game over in player window)
    * [MICA/ZZAMSINI.ASM](MICA/ZZAMSINI.ASM) (Attract Mode Demo)
    * [MICA/ZPNTSCRN.ASM](MICA/ZPNTSCRN.ASM) (clears out the system, sets up the information tasks, restarts the system)

### Fixes

* [WITT/AOE.ASM](WITT/AOE.ASM) (Final patches for AOE '83 show)
  * [SAM/SAMFIXES.ASM](SAM/SAMFIXES.ASM)
    * [SAM/FIXLSSIN.ASM](SAM/FIXLSSIN.ASM) (fixes live sinistar leaving sector)
    * [SAM/FIXDAMPD.ASM](SAM/FIXDAMPD.ASM) (fixes player bounce damping during the attract mode demo)
    * [SAM/FIXSMASH.ASM](SAM/FIXSMASH.ASM) (fixes player getting smashed off the screen) [not used; replaced by FALS/LAST.ASM]
    * [SAM/FIXOPENT.ASM](SAM/FIXOPENT.ASM) (fixes operator entry system initialization)
    * [SAM/FIXPLUNI.ASM](SAM/FIXPLUNI.ASM) (fixes player starting position)
  * [WITT/RICHFIXE.ASM](WITT/RICHFIXE.ASM)
    * [WITT/FIXBUTTO.ASM](WITT/FIXBUTTO.ASM) (FIREB version editing correction)
    * [WITT/FIXINIRI.ASM](WITT/FIXINIRI.ASM) (SINIB demo error and timing correction)
    * [WITT/FIXKRSIN.ASM](WITT/FIXKRSIN.ASM) (Dead man's warp correction)
    * [WITT/FIXRISBO.ASM](WITT/FIXRISBO.ASM) (Value error correction) [for Sinibomb sprite]
    * [WITT/ZSTBLIMP.ASM](WITT/ZSTBLIMP.ASM) (Impulse engine speed table tuned)
    * [WITT/ZSTBLBOM.ASM](WITT/ZSTBLBOM.ASM) (Demo bombing run speed table tuned)
  * [MICA/BOBFIXES.ASM](MICA/BOBFIXES.ASM)
  * [WITT/FIXSINI.ASM](WITT/FIXSINI.ASM)

### Diagnostic Test ROM ($F000)

* [SAM/DIAG.ASM](SAM/DIAG.ASM)
  * [SAM/T13.ASM](SAM/T13.ASM) (F000 test rom for 'sinistar' with auditing and adjustments)
* [FALS/LAST.ASM](FALS/LAST.ASM) (Final patches for "revision 3" rom set)

### Extras

* [WITT/debug_utilities.ASM](WITT/debug_utilities.ASM) (Old and new debug routines and cheats, as well as new mods to reduce difficulty)
  * [SAM/BARGRAPH.ASM](SAM/BARGRAPH.ASM) (Slightly modified version of Debug Bar Graphs)
    * [WITT/RICH.EQU](WITT/RICH.EQU) (Work file from Rich that has equates for Bar Graphs)
* [MICA/marquee_fix.ASM](MICA/marquee_fix.ASM) (This is a hack that restores the original MARQUEE title screen)

## Debug Options
  
A lot of debug code is buried inside the original codebase so ```MAKE.ASM``` has new defines to enable these again for those that are interested.  Use ```DisableKenChk``` if you are not building the last ROM (diagnostic ROM 11), otherwise use ```FakeChecksums```.

### PROMS

PROMS is on by DEFAULT!

Taken from WITT/RICHFIXE.ASM, this fixes a bug where the screen flashes;;  white for a frame whenever the game starts up or transitions to a status screen.  If PROMS is not defined, then the screen flashing bug returns (to help remind us that we're playing a dev build).  It also DISABLES KENCHK so that copyright protection doesn't trigger during debugging!

Note: This doesn't take affect until AOE.ASM is included, so use ```DisableKenChk``` if the magic byte at address $A1B3 is still showing up as non-zero during attract mode/gameplay.

Moving this from RICHFIXE.ASM was kinda unnecessary as this define is usually left on all the time, but I figured it would be easier to enable/disable it here rather than having it separate from the other debug options.

### DisableKenChk

The problem with PROMS is that it is defined in RICHFIXE.ASM, which is referenced in AOE.ASM.  If AOE is not included in the build, then KenChk will still trigger.  Enable this to force the copyright protection to stay off no matter what.

This can be useful for when the diagnostic rom is not included in the build.

### FakeChecksums

If you are including the diagnostic ROM 11 in the build, then use this for debugging.  This is really important if you want to mess around with the code or work on mods.  Also useful for enabling several different mods at once.

During power up, the ROM test uses a checksum table at $F34F to verify file integrity.  To make debugging with mods much easier, enable this to zero out the checksum table and cheat the ROM test so that you can gain access to the "Game Adjustment" menu.

Zeroing out the checksums also should prevent the copyright protection from triggering.  Look at address $A1B3 to ensure the byte is zero, otherwise the game will start acting weird.

### DisableTests

To make mods possible for Sinistar, we use the space between addresses $F4FB - $F928 in diagnostic ROM 11.  This is where the cross hatch test, color bar tests and switch tests are located.  Enable this define to make the diagnostics skip these routines and give us $42C bytes of space to overwrite.

### NOTEST

Uncommenting this EQU can be useful for debugging and greatly decreases wait times by skipping the power up ROM/RAM Rug Test.  It does not disable the ROM/RAM "Rug" test itself, as it is still accessible by pressing the service (aka "advance") button.

### SAMDEBUG

This debug define found in Sam's module allows the player to respawn forever, even if they run out of extra ships.  This only changes two bytes in the code and doesn't mess up any symbol addresses.  This was originally labeled as "DEBUG" but I renamed it to differentiate from the next two defines which were also called "DEBUG".

### InfiniteShips

Enable this to never run out of lives.  This is from Rich's module and while it takes up more space, it increases the player's number of ships upon every Turn initialization so the player never runs out. 

### NoDeath

This disables player deaths.  Warrior shots don't hurt anymore (yay!), but if the player gets caught by the Sinistar, they'll get soft-locked (boo!).
This was taken from Rich's module as well.

### DisableSinistarCollision

This new hack makes the player pass through the Sinistar and prevent getting soft-locked while NoDeath is enabled.

### Witt

Uncomment "Witt" to force the Sinistar to spawn instantly and prevent the warriors from shooting at the player.

### WittRock

This new define enables a previously-unknown sprite edit of the tiny Planetoid image that was used to denote Rich's developmental build from the final ROM.

![wittrock_crop](https://github.com/synamaxmusic/sinistar/assets/11140222/cff191c2-67e4-4af6-a182-f7451719dcd1)


## Mods

Several new mods have been added for Sinistar!  To enable a mod, open up ```MAKE.ASM``` and simply remove the semi-colon in front of the define for that mod.  Then, save the file and build the game per the [build instructions](#build-instructions).  Be sure to read the instructions next to the defines for further information.

### MarqueeFix

This restores the awesome original "Marquee" title screen found in the prototype AMOA '82 build.  Due to space constraints, this was not included in the final version of the game.

### ExtraShipFix

This restores the original "Additional Extra Ship Point Factor" to it's original value of 5,000 (per SAM/DEFAULT.SRC).  This makes it much easier to score extra lives!

You'll need to do a factory reset or clear/delete your NVRAM in order for the new default value to be copied over.

Because this is just a one-byte edit, this can be combined with other mods like MarqueeFix and/or DifficultyMod.

### DifficultyMod

This reduces the difficulty of the game by modifying the enemy population values starting at $7ABE.  You can watch my video for more detailed info on how this mod works and why I chose these new values: https://youtu.be/HnfcAudPPS4

This mod can be enabled with other mods like MarqueeFix and ExtraShipFix.

### QuickOperatorEntry

This one-byte mod makes it much quicker to edit the title screen's operator message, which can be accessed from the Game Adjustments service menu.  The only caveat is that the operator message entry screen and high score entry screen use the same routines, so changing the value to make it go faster also affects the input for high score initials.

I'm assuming that RJ purposely patched this value to make editing slower because play-testers were messing up their high score initials with the shorter time.

### PauseMod

Press the Player 1 button during gameplay to pause!  Pressing it again resumes the game.  This mod was inspired by the Joust Pause Mod found on Coinoplove.com and uses very similar code to achieve the same effect.  The "PAUSED" text displayed on screen uses a routine inspired by Witt's code responsible for drawing the "EMPTY" text at the start of the game.

This mod can be enabled with MarqueeFix!  However, if MarqueeFix is not defined then you'll need to enable DiagnosticTestFix to get the diagnostics working again.

### Old deprecated defines

"EnableMods" and "DiagnosticTestFix" are now deprecated.  Use "FakeChecksums" and "DisableTests" instead.  Any modifications to the final version of the game requires us to either change the checksums in diagnostic ROM 11 or fake them.

Originally, the RAM and ROM tests in ROM 11 ($F09F - $F370) were overwritten to fit "MarqueeFix" and "PauseMod" but this doesn't work on real hardware, as we were running into issues with the watchdog.

Any new mods are now relocated so that they overwrite the "Cross Hatch", Color Bars and Switch tests in the diganostics ROM ($F4FB - $F928).  To make this space available for adding mods, uncomment the "DisableTests" define.

These mods can be combined with others, however if you are running into "ROM ERROR" messages on power up, then enable "FakeChecksums" to fix this.

### EnableMods (deprecated)

Turn this on if you want to enable mods like the Marquee Fix or Difficulty Mod.  This disables the Rug test, just like NOTEST, but this also zeros out the ROMTBL checksum table, so that we don't trigger the copyright protection.

### DiagnosticTestFix (deprecated)

Only works if EnableMods is defined.  Restores access to diagnostic tests for CMOS, Sound, Switches and Color bars by skipping the ROM/RAM tests.  This is automatically enabled for MarqueeFix.  This is needed for any mods that overwrite the RAM/ROM rug test area ($F09F-$F370) and/or before the CMOS test screen at $F404.
 
When this is enabled, the game will wipe away the screen and wait forever until the "advance" button (aka F2 in MAME) is pressed again.  Keep pressing the advance button to go through the remaining diagnostic screens.
