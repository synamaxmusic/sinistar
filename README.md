# Sinistar
A game by Sam Dicker, Noah Falstein, R.J. Mical and Richard Witt

Source code rewrite by SynaMax, started 11/6/23

## Build Instructions

This source code was rewritten to target Macro Assembler {AS}.

To build Sinistar, place the four folders (```FALS, SAM, WITT, MICA```) and the "```MAKE.ASM```" file into the same directory as ASL and P2BIN.

Then, open a command prompt and type in:

```sh
asl make.asm -o sinistar.p
```
This will generate a .p file that we can feed into p2bin:

```sh
p2bin sinistar.p sinistar.bin
```

Finally, split the .BIN into separate 1KB ROM files and rename those files to match with the MAME ROM set filenames:

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

## About the source code

After deliberating for a few months and conducting several tests with various 6809 macro assemblers, I decided to take it upon myself to rewrite the source code for Sinistar.  Considering the size of the codebase, this was not an easy or quick task.

Other Williams games have be rewritten before, such as [mwenge's work for Defender](https://github.com/mwenge/defender/) and [Robotron](https://github.com/mwenge/robotron/), both targeting the asm6809 assembler.  His work inspired me to make the attempt at recreating the missing 6800 assembly code for Sinistar's [Video Sound ROM 9 and 10](https://github.com/synamaxmusic/Sinistar-Sound-ROM).  [Here is a video](https://youtu.be/Msc6hqyTW6U) on how I achieved this and how the sound ROMs in Sinistar work.  

The goal of both of these Sinistar repositories is to recreate the game's ROMs from scratch.  With Video Sound ROM 9, a disassembly was heavily relied on in order to piece together the ROM since the source code was missing and had to be cobbled together from looking at the surviving source code and comments from the [other sound roms](https://github.com/historicalsource/williams-soundroms/).  With this project however, we have the [original source code](https://github.com/historicalsource/sinistar) (leaked in 2021), so there's not as much guesswork involved.  I did tests with several different assemblers, including asm6809 and vasm (which I used previously for Sinistar's sound ROM) but I was running into several issues.  I wondered why Robotron and Defender were able to be retargeted for asm6809, but not Sinistar or even Joust.

Joust and Sinistar were the first two games developed by the new internal dev team at Williams, after Eugene Jarvis and Larry DeMar left Williams to form Vid Kidz. Because of this, the source code for both Joust and Sinistar are similar to each other but show a lot of differences from the code for Defender and Robotron, especially when it comes to the use of macros.

### Macros

For those who don't know, a macro is sequence of instructions that can be inserted into the final code when called.  They can be very flexible and powerful in that they can generate many lines of code with just one reference.  Several important routines in Sinistar rely on macros for various tasks, like compressing the font sprites or parsing ASCII strings and converting them into Williams Electronics's pseudo codepage standard.  Another set of macros uses an internal stack to keep track of where sections of the ROM code begin and end. 

Macros do show up for Defender and Robotron, but there's not too many of them, and whenever they do show up, they are very simple and short.  Joust's source utilizes more complex macros with more parameters but they too consist of just several lines of code.  Meanwhile, Sinistar defines at least 33 macros in just one file alone, with some macros reaching 50+ lines of code.  The surprising complexity of some of these macros required several days of troubleshooting to get them working in this rewrite.

### Working with the BSO Assembler and VAX/VMS

Like Joust, Sinistar was written on VAX/VMS workstations.  I'm not sure what assembler was used for Joust, but both codebases appear to use the same syntax and we know that Sinistar was written for a cross-assembler by the now-defunct Boston System Office (BSO).  It had support for several macro instructions that only a few 6809 assemblers still use today, such as IRP, IRPC and REPT.  This assembler is currently lost (which is one of the main reasons why this project was started in the first place).

The BSO assembler also had a very limited symbol table size which made Sinistar's development extra difficult and as a result, additional precautions had to be made in order for the code to build properly.  For example, each of the four main software engineers (Sam Dicker, Richard Witt, Noah Falstein and R.J. Mical) had to generate their own files that listed all the EQUs, SETs, and symbols they used in their section of the game.  Extra care was taken to make sure all the symbols matched up with everyone else's library.  At the end of the toolchain, a batch script file written in VAX DCL language collected all of the source files and fed them into the assembler in a specific order.  It was a lot of work to make sure everything matched up but in the end, I'm really glad they were kinda forced to generate lists of EQUs and SETs because having all these symbol definitions has made a lot of this reverse engineering work much, much easier.  

### Choosing a new assembler

Even just taking a quick glance over the code, it quickly becomes apparent that we need an newer assembler that supports several specific kinds of macros or otherwise this project wouldn't be possible.  I decided to target the source code rewrite to work with [Macro Assembler {AS}](http://john.ccac.rwth-aachen.de:8000/as/index.html) because it supports a lot of those specific macro instructions previously mentioned and the syntax is very similar to what is in the original code so any rewrites are kept to a minimum.

Alan R. Baldwin's ASxxxx cross-assembler was also considered as it also supports the IRP, IRPC, and REPT macro instructions, but the amount of syntax changes needed in order for the code to build would be unfeasible. 

Admittedly, working with Macro Assembler {AS} has been a bit of a challenge as it does some things differently from other assemblers that I've come across and the documentation is rather daunting.  Unlike ASxxxx's manual, there's not many examples or concise instructions on how the assembler works, so this was where a lot of guesswork was needed.  In fact, I feel I learned more from looking at Sonic 1 and 2 disassemblies targeting {AS} than the manual itself.  Once I got the hang of the new syntax changes though, I started getting into the flow of things and was able to rewrite all of Sam Dicker's code in a week.

## Changes Required

I soon realized that because of the new syntax, I would have to rewrite more code than I initially intended.  I tried my best to show all the changes to the code that I did with comments but I may have missed some minor edits here or there.  My intention has always been to leave as much original code in as possible and change only what is necessary.  Any major drastic changes will be pointed out in the comments.  Sometimes I'll use double semi-colons to denote my comments from the original ones.

Because we're not using VMS to build this, I made a new file called, "MAKE.ASM", based off the original MAKE.COM batch file.  This file loads in all the required source files for {AS} to process and also has defines for enabling DEBUG features.

### PUSHORG and PULLORG 

The first two macros that I have commented out are PUSHORG/PULLORG.  They were used to hold various ORG addresses for the programmers as they worked on different sections of code.  I have replaced them with a regular ORG for PUSHORG.  If a symbol is next to PULLORG, then I add a new "SET *" instruction to mark the new address for that symbol:

```
	;PULLORG MESSAV
MESSAV	SET	*
```

When ORG MESSAV is called again, the new address that we just set up will be used.

### Local labels

{AS}  has some quirks with local labels so sometimes I had to make
global labels in order for the code to build.  For example, here's what local
labels look like for the BSO assembler:

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

