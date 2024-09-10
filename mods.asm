;;
;;               SSSS  IIIII  N   N  IIIII  M   M   OOO   DDDD    SSSS
;;              S        I    NN  N    I    MM MM  O   O  D   D  S
;;               SSS     I    N N N    I    M M M  O   O  D   D   SSS
;;                  S    I    N  NN    I    M   M  O   O  D   D      S
;;              SSSS   IIIII  N   N  IIIII  M   M   OOO   DDDD   SSSS
;;
;;
;;   This was originally in MAKE.ASM but I moved any defines debug or mod related
;;   to a new file, "MODS.ASM".  This was done for two reasons: 1) to reduce
;;   clutter in the makefile and 2) to help separate the original code from any
;;   new code.
;;
;;   PROMS is still the only define here that's required for the original final
;;   build of Sinistar.
;;
;===============================================================================
;;
;;   DDDD   EEEEE  BBBB   U   U   GGGG
;;   D   D  E      B   B  U   U  G
;;   D   D  EEEE   BBBB   U   U  G GGG
;;   D   D  E      B   B  U   U  G   G
;;   DDDD   EEEEE  BBBB    UUU    GGG
;;
;;   These are defines that re-enable debug features written by the original
;;   Sinistar dev team but were removed or disabled in the final build.
;;
;;   Defines that use original debug features are:
;;
;;   PROMS
;;   FakeChecksums
;;   NOTEST
;;   SAMDEBUG
;;   InfiniteShips
;;   NoDeath
;;   Witt
;;   WittRock
;;
;;   A couple of helper defines are included to make the original code work:
;;
;;   DisableKenChk
;;   DisableSinistarCollision
;;
;;   Lastly, the FakeChecksums option is new but very important and is used for
;;   both debugging and implementing mods.

;                               <<< DEBUG DEFINES >>>

PROMS   EQU     1               ;* Define before burning proms

;;  PROMS is on by DEFAULT!
;;
;;  Taken from WITT/RICHFIXE.ASM
;;
;;  During development, a routine in EXECJNK called "VRLOAD" was used for
;;  overload handling. If the program is unable to finish processing everything
;;  in the executive loop before drawing the next frame on the CRT screen, then
;;  the game would get overloaded and slow down would occur.
;;
;;  To immediately signal when a overload occurs, VRLOAD causes the screen to
;;  flash white for a frame.  This is most noticable whenever the game starts
;;  up or transitions to a status screen.  In the final game, NOPs are used to
;;  patch over the instructions that flash the screen white.
;;
;;  If PROMS is not defined, then the screen flashing returns.
;;
;;  It also DISABLES KENCHK so that copyright protection doesn't trigger during
;;  debugging.
;;
;;  Note: This doesn't take affect until AOE.ASM is included, so use
;;  DisableKenChk if the magic byte at address $A1B3 is still showing up as
;;  non-zero during attract mode/gameplay.
;;
;;  Moving this from RICHFIXE.ASM was kinda unnecessary as this define is
;;  usually left on all the time, but I figured it would be easier to
;;  enable/disable it here rather than having it separate from the other debug
;;  options.

;DisableKenChk EQU 1

;;  The problem with PROMS is that it is defined in RICHFIXE.ASM, which is
;;  referenced in AOE.ASM.  If AOE is not included in the build, then KenChk
;;  will still trigger.
;;
;;  Enable this to force the copyright protection to stay off no matter what.
;;
;;  This can be useful for when the diagnostic rom is not included in the build

;FakeChecksums EQU 1

;;  Taken from SAM/T13.ASM
;;
;;  If you are including the diagnostic ROM 11 in the build, then use this for
;;  debugging.  This is really important if you want to mess around with the
;;  code or work on mods.  Also useful for enabling several different mods
;;  at once.
;;
;;  During power up, the ROM test uses a checksum table at $F34F to verify file
;;  integrity.  To make debugging with mods much easier, enable this to zero
;;  out the checksum table and cheat the ROM test so that you can gain access
;;  to the "Game Adjustment" menu.
;;
;;  Zeroing out the checksums also should prevent the copyright protection from
;;  triggering.  Look at address $A1B3 to ensure the byte is zero, otherwise
;;  the game will start acting weird.
;;

;NOTEST EQU     1

;;  Uncommenting this EQU can be useful for debugging and greatly decreases
;;  wait times by skipping the power up ROM/RAM Rug Test.  It does not disable
;;  the ROM/RAM "Rug" test itself, as it is still accessible by pressing the
;;  service (aka "advance") button.

;SAMDEBUG EQU   1

;;  Recommended for invincible cheat
;;
;;  This debug define found in Sam's module allows the player to respawn
;;  forever, even if they run out of extra ships.  This only changes two bytes
;;  in the code and doesn't mess up any symbol addresses.  This was originally
;;  labeled as "DEBUG" but I renamed it to differentiate from the next two
;;  defines which were also called "DEBUG".

;InfiniteShips EQU 1

;;  Enable this to never run out of lives.  This is from Rich's module and
;;  while it takes up more space, it increases the player's number of ships
;;  upon every Turn initialization so the player never runs out.

;NoDeath        EQU     1

;;  This disables player deaths.  Warrior shots don't hurt anymore (yay!), but
;;  if the player gets caught by the Sinistar, they'll get soft-locked (boo!).
;;  This was taken from Rich's module as well.

;DisableSinistarCollision EQU   1

;;  This new hack makes the player pass through the Sinistar and prevent
;;  getting soft-locked while NoDeath is enabled.

;Witt   EQU     1

;;  Uncomment "Witt" to force the Sinistar to spawn instantly and prevent the
;;  warriors from shooting at the player.

;WittRock EQU   1

;;  This new define enables a previously-unknown sprite edit of the tiny
;;  Planetoid image that was used to denote Rich's developmental build
;;  from the final ROM.

;===============================================================================
;;
;;   M   M   OOO   DDDD    SSSS
;;   MM MM  O   O  D   D  S
;;   M M M  O   O  D   D   SSS
;;   M   M  O   O  D   D      S
;;   M   M   OOO   DDDD   SSSS
;;
;;  Use "DisableTests" below to make mods possible in Sinistar.  Several of the
;;  following mods can be combined together (see MOD COMBOS below).
;;
;;  Originally, I had the RAM and ROM tests in ROM 11 ($F09F - $F370)
;;  overwritten to fit "MarqueeFix" and "PauseMod" but this doesn't work on
;;  real hardware, as we were running into issues with the watchdog chip.
;;
;;  Any new mods are now relocated so that they overwrite the CRT Test Pattern,
;;  Color Bars and Switch tests in the diganostics ROM ($F4FB - $F928).  To
;;  make this space available for adding mods, uncomment the "DisableTests"
;;  define.
;;
;;  Again, these mods can be combined with others, however if you are running
;;  into "ROM ERROR" messages on power up, then enable "FakeChecksums" to fix
;;  this.
;;

;DisableTests EQU 1

;;  To make mods possible for Sinistar, we use the space between addresses
;;  $F4FB - $F928 in diagnostic ROM 11. This is where the cross hatch test,
;;  color bar tests and switch tests are located. Enable this define to make
;;  the diagnostics skip these routines and give us $42C bytes of space to
;;  overwrite.
;;
;;  This is already enabled for both MarqueeFix and PauseMod.

;                               <<< MOD COMBOS >>>

;;
;;  To make it easier to identify which ROM set we're running, we'll borrow a
;;  trick from Eugene Jarvis and Larry DeMar in the Robotron Tie-Die ROMs and
;;  use the high score to denote a "version" number.
;;
;;  Normally, the first high score entry in the "Survivors Today" table is
;;  always set to 19045.
;;
;;  We'll change the zero here to ID the mod combo:
;;
;;    19145 = Pause Mod / MarqueeFix
;;    19245 = Pause Mod / MarqueeFix / DifficultyMod
;;    19345 = MarqueeFix / DifficultyMod
;;    19445 = Pause Mod / MarqueeFix / DifficultyMod / SAMTAIL
;;    19545 = MarqueeFix / DifficultyMod / SAMTAIL
;;    19645 = MarqueeFix / SAMTAIL / ExtraShipFix (Closest to "Perfect" ROMs)
;;
;;  Important: 19645 requires a factory reset in order to copy the new default
;;  Extra Ship value to NVRAM.
;;
;;  Note: only enabling MarqueeFix doesn't change the high score entries.
;;
;;  19345 and 19545 are great for arcade operators who want to install these
;;  mods but prefer not to have players pause the game.
;;
;;  Disclaimer: PauseMod has the potential to cause screen burn-in if the
;;  "PAUSED" text is displayed for an extended period of time.  I, SynaMax,
;;  assume no responsibility or liability if the PauseMod causes burn-in damage
;;  to your monitor.
;;
;;  Lastly, some really creative hacking was needed in order to fit SAMTAIL
;;  alongside these other mods.  If SAMTAIL and MarqueeFix are combined
;;  together, then the sound test in the diagnostics ($FE6C) is overwritten and
;;  skipped.  If SAMTAIL and PauseMod are combined, then the routine that sends
;;  a signal to the ROM board LED is overwritten ($F211).

;MarqueeFix EQU 1

;;  This restores the awesome original "Marquee" title screen found in the
;;  prototype AMOA '82 build.  Due to space constraints, this was not included
;;  in the final build.
;;
;;  To get this to work, I had to overwrite the cross hatch, color bar and
;;  switch tests in ROM 11 and then patched ROM 9 to make RJ's attract mode
;;  routines load the AMOA graphic.
;;
;;  "DisableTests" is already enabled for this mod.  New Checksums for the ROM
;;  test are also enabled.  Can be combined with "PauseMod" and/or
;;  "DifficultyMod" and/or "SAMTAIL" with valid checksums.
;;
;;                                              Changes ROMs: 9, 11

;DifficultyMod EQU 1

;;  This reduces the difficulty of the game by modifying the enemy population
;;  values starting at $7ABE.  You can watch my video for more detailed info on
;;  how this mod works and why I chose these new values:
;;  https://youtu.be/HnfcAudPPS4
;;
;;  Adds valid checksums for ROM 11.
;;
;;                                              Changes ROMs: 8, 11

;PauseMod EQU   1

;;  Press the Player 1 button during gameplay to pause!  Pressing it again
;;  resumes the game.  This mod was inspired by the Joust Pause Mod found on
;;  Coinoplove.com and uses very similar code to achieve the same effect.  The
;;  "PAUSED" text displayed on screen uses a routine inspired by Witt's code
;;  responsible for drawing the "EMPTY" text at the start of the game.
;;
;;  This mod can be enabled with MarqueeFix!  "DisableTests" is already enabled
;;  for this mod.  New Checksums for the ROM test are also enabled.
;;
;;                                              Changes ROMs: 4, 10, 11

;SAMTAIL        EQU     1

;;  Taken from SAM/TAIL.SRC, this mod restores a unused jet exhaust "tail" to
;;  the player ship!
;;
;;  This code was first discovered back in October 2023, but it wasn't until
;;  February 2024 that the unused source code was correctly implemented into
;;  the final game.  Initially, I thought the tail was supposed to be a blue
;;  color, but I now realized that is incorrect.  This mod produces an effect
;;  that much better resembles a rocket flame trail by using a combination of
;;  red and yellow pixels.  The tail also appears to react to how far the
;;  49-way joystick is being pushed.  Slightly pulling on the stick results in
;;  a diminished flame tail, while not pressing it at all turns the effect off.
;;
;;  This unused feature explains why Jack Haeger's marquee artwork depicts the
;;  player ship with a jet exhaust!
;;
;;                                              Changes ROMs: 4, 8, 9, 11
;;
;;  If you enable SAMTAIL by itself then you will need to turn on
;;  "FakeChecksums" and "DisableTests", or you will get checksum errors in the
;;  ROM test.

;ExtraShipFix EQU 1

;;  This restores the original "Additional Extra Ship Point Factor" to it's
;;  original value of 5,000 (per SAM/DEFAULT.SRC).  This makes it much easier
;;  to score extra lives!
;;
;;  You'll need to do a factory reset or clear/delete your NVRAM in order for
;;  the new default value to be copied over.
;;
;;  Because this is just a one-byte edit, this can be combined with other mods
;;  like MarqueeFix and/or DifficultyMod.
;;
;;  This mod is kinda not really needed, since you can just change the value in
;;  the "Game Adjustments" menu to 5000 and then save.
;;
;;  The only time this mod is being used is for V19645.
;;
;;  If enabled, then the checksums for V19645 mod will be used, but otherwise
;;  there are no valid checksums yet for this mod, so enable "FakeChecksums"
;;
;;                                              Changes ROMs: 5

;QuickOperatorEntry EQU 1

;;  This one-byte mod makes it much quicker to edit the title screen's operator
;;  message, which can be accessed from the Game Adjustments service menu.  The
;;  only caveat is that the operator message entry screen and high score entry
;;  screen use the same routines, so changing the value to make it go faster
;;  also affects the input for high score initials.
;;
;;  I'm assuming that RJ purposely patched this value to make editing slower
;;  because play-testers were messing up their high score initials with the
;;  shorter time.
;;
;;  No valid checksum yet for this mod, enable "FakeChecksums" to pass ROM test
;;
;;                                              Changes ROMs: 9


;                       <<< EXPERIMENTAL BROKEN DEFINES >>>

;BargraphEnable EQU 1           ;* Define this symbol to include Graphic Diagnostics

;;  This was originally called "DIAGNOSE" but I renamed it to BargraphEnable to better
;;  describe what this does.  Defining this enables a debug "BARGRAPH" display that
;;  shows different parameters such as Play time in Minutes and Seconds, Warrior Aggression,
;;  Elapsed time since player death, number of enemies, etc.
;;
;;  The file "RICH.EQU" has the list of what the different color bars mean but it is
;;  inverted.  Here is the correct guide for what each bar represents:
;;
;;              rmb     1       * F                                     YELLOW (unused)
;;              rmb     1       * E <SPECIAL EFFECT>                    BLACK (unused) (The Sinistar's glowing eye color)
;;GMWaInt       rmb     1       * D The # of Intercepting warriors      RED
;;GMWaTail      rmb     1       * C The # of Guarding warriors          DARK RED
;;GMWaMine      rmb     1       * B The # of Mining warriors            DARK PURPLE
;;GMWaAttack    rmb     1       * A The # of Attacking warriors         DARK TEAL
;;GMWaDrift     rmb     1       * 9 The # of Drifting warriors          BLUE
;;              rmb     1       * 8   Effects                           BLACK (unused)
;;              rmb     1       * 7 Special                             BLACK (unused)
;;GFLANG        rmb     1       * 6 Flight angle of squadron leader.    BLUE-GRAY
;;GVelocity     rmb     0       * 6 Velocity                            BLUE-GRAY (unused)
;;GANANG        rmb     1       * 5 Animation angle of squadron leader. GRAY
;;GDistance     rmb     0       * 5 Distance                            GRAY (unused)
;;GDeathTime    rmb     1       * 4 Time since Player death             TAN-GRAY
;;GAggression   rmb     1       * 3 Warrior aggression (high byte)      SALMON PINK
;;GSeconds      rmb     1       * 2   and seconds.                      CREAM
;;GMinutes      rmb     1       * 1 Play time in minutes                WHITE
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

;                       <<< DEPRECATED DEFINES BELOW!!! DON'T USE >>>

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
