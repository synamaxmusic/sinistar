;
;
;        SSSS  IIIII  N   N  IIIII   SSSS  TTTTT   AAA   RRRR
;       S        I    NN  N    I    S        T    A   A  R   R
;        SSS     I    N N N    I     SSS     T    AAAAA  RRRR
;           S    I    N  NN    I        S    T    A   A  R  R
;       SSSS   IIIII  N   N  IIIII  SSSS     T    A   A  R   R
;
;
;    A game by Sam Dicker, Noah Falstein, Bob Mical and Richard Witt
;
;           Source code rewrite by SynaMax, started 11/6/23
;         Matching ROM set first rebuilt on January 12th, 2024
;
;===============================================================================
;
;                         <<< HOW TO BUILD >>>
;
;   This source code was rewritten to target Macro Assembler {AS}.
;
;   To build Sinistar, place the four folders (SAM,WITT,FALS,MICA)
;   and this MAKE.ASM file into the same directory as ASL and P2BIN.
;   Then, open a command prompt and type in:
;
;   asl make.asm -o sinistar.p
;
;   Once the sinistar.p file is generated, we can use the BURN.BAT file
;   to create the 11 separate ROM files that make up Sinistar.
;
;   ROM Address guide:
;
;       Address:                MAME ROM set Filename:
;       0000-0FFF = ROM 1       sinistar_rom_1-b_16-3004-53.1d
;       1000-1FFF = ROM 2       sinistar_rom_2-b_16-3004-54.1c
;       2000-2FFF = ROM 3       sinistar_rom_3-b_16-3004-55.1a
;       3000-3FFF = ROM 4       sinistar_rom_4-b_16-3004-56.2d
;       4000-4FFF = ROM 5       sinistar_rom_5-b_16-3004-57.2c
;       5000-5FFF = ROM 6       sinistar_rom_6-b_16-3004-58.2a
;       6000-6FFF = ROM 7       sinistar_rom_7-b_16-3004-59.3d
;       7000-7FFF = ROM 8       sinistar_rom_8-b_16-3004-60.3c
;       8000-8FFF = ROM 9       sinistar_rom_9-b_16-3004-61.3a
;       9000-DFFF =    (SPACE RESERVED FOR RAM)
;       E000-EFFF = ROM 10      sinistar_rom_10-b_16-3004-62.4c
;       F000-FFFF = ROM 11      sinistar_rom_11-b_16-3004-63.4a
;
;   If it's not possible to use BURN.BAT, we can use a command prompt
;   and type in the following:
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
;                     <<< MODULES AND INCOMPLETE BUILDS >>>
;
;   Sinistar's source code is split into four "modules" (one for each
;   programmer).
;
;   With the exception of Sam's, it is not possible to build a programmer's
;   section of code separately.  If you want to build Noah's files, you need to
;   build Sam's and Rich's as well.
;
;   The order of the modules is as follows:
;   SAM > WITT > FALS > MICA
;
;   To make an incomplete version of Sinistar playable on MAME, IRQ vectors are
;   automatically inserted at the very end of ROM 11 so that the emulator can
;   launch the game.
;
;   Once the incomplete build is running in the emulator, you'll need to insert
;   a coin first then press either the Player 1 or 2 buttons to start playing.
;
;===============================================================================
;  Macro Assembler AS Instructions
        CPU 6809
        PLAINBASE ON            ; AS [1.42 Bld 262] no longer allows omission of
                                ; an empty index argument on 6809. This breaks
                                ; many instructions that do not use commas
                                ; before registers (like LDA  U+ or CMPX  S)
                                ; A lot of code changes would be needed so
                                ; "plainbase" is now enabled to fix this.

;===============================================================================

        INCLUDE MODS.ASM        ; Mods are now located here to make "MAKE.ASM"
                                ; less messy.  Edit this file to enable unused
                                ; content like debug features and new mods!

;===============================================================================
;
;   SSSS   AAA   M   M
;  S      A   A  MM MM
;   SSS   AAAAA  M M M
;      S  A   A  M   M
;  SSSS   A   A  M   M
;

        INCLUDE SAM/MESSAGE.ASM         ;; This is based off of code from Joust
                                        ;; but modified to work wtih a vertical
                                        ;; screen.  Font sprites are also here.
        INCLUDE SAM/EQUATES.ASM

        INCLUDE SAM/IMAGE.ASM           ;; Sprites by Jack Haeger
        INCLUDE SAM/SAMS.ASM

;===============================================================================
;
;  RRRR   IIIII   CCCC  H   H
;  R   R    I    C      H   H
;  RRRR     I    C      HHHHH
;  R  R     I    C      H   H
;  R   R  IIIII   CCCC  H   H
;

        INCLUDE WITT/new_equates.ASM    ;; Added to support longer symbol names

        INCLUDE WITT/RICHS.ASM
        INCLUDE WITT/RICHS2.ASM         ;; (Control Panel Button handling with
                                        ;; Easter Egg routine)

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
;  F        I     X X   E      S
;  FFF      I      X    EEEE    SSS
;  F        I     X X   E          S
;  F      IIIII  X   X  EEEEE  SSSS
;

        INCLUDE WITT/AOE.ASM            ;; Patches made after Nov '82 AMOA show

;===============================================================================
;
;  DDDD   IIIII   AAA    GGGG
;  D   D    I    A   A  G
;  D   D    I    AAAAA  G GGG
;  D   D    I    A   A  G   G
;  DDDD   IIIII  A   A   GGG
;

        INCLUDE SAM/DIAG.ASM            ;; Diagnostic ROM 11
        INCLUDE FALS/LAST.ASM           ;; Final patches found in Revision 3 rom
                                        ;; (can be built without DIAG.ASM)

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