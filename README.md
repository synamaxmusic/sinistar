# Sinistar
A game by Sam Dicker, Noah Falstein, R.J. Mical and Richard Witt

Source code rewrite by SynaMax, started 11/6/23

## Build Instructions

This source code was rewritten to target Macro Assembler {AS}.

To build Sinistar, place the four folders (FALS, SAM, WITT, MICA) and the "MAKE.ASM" file into the same directory as ASL and P2BIN.

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

### Changes Required
