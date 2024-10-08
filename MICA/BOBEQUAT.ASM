
;       INCLUDE [SAM]START

        RADIX   10              ;;(For decimal numbers)

DRAW    EQU     $06             ;These 3 equates are
SCRUB   EQU     $12             ;  for DMA control in the
DRAW1   EQU     $26             ;  HIgh Score and Marquee pages


SCRNLH  EQU     $74             ;Screen LONG High value
SCRNSL  EQU     $10             ;Screen SHORT Low Value
SCRNSH  EQU     $F0             ;Screen SHORT High value


;* Warrior Explosion Equates
WRXPCT  EQU     10
WRXISZ  EQU     $0305
WRXICT  EQU     6


;* Player Explosion Equates
PXPPCT  EQU     15              ;Piece count -- number of fragments per wave
PXPWVS  EQU     4               ;Number of waves -- MUST be an even power of 2
PLXISZ  EQU     $0203           ;Constant size of fragment images


;* High Score To Date/Operator Message entry table equates
HSENTCT EQU     30              ;HSTD entry count (per table)

MAXBNC  EQU     3               ;Bounce between input acceptance
MAXETV  EQU     30*60           ;Thirty seconds to enter your initials, jack

FORWARD EQU     %00000001       ;Joystick up bit (bit 0)
REVERSE EQU     %00000010       ;Joystick down bit (bit 1)
JYLEFT  EQU     %00000100       ;Joystick Left (bit 2)
JYRIGHT EQU     %00001000       ;Joystick Right (bit 3)
ENTER1  EQU     %00010000       ;Fire button bit (bit 5)

MINLET  EQU     0               ;Minimum letter in character set
MAXLET  EQU     46              ;Maximum letter

CBLANK  EQU     10              ;Blank character
CRUB    EQU     37              ;Rubout character

OPENMTM EQU     0               ;Operator Message Maximum Time to Make entry
OPENLEN EQU     27              ;Operator Message Length per Line


;* Player Extra-Explosion equates
PLEXTMR EQU     24              ;Timer value; defines how long task stays alive
PLEXWSZ EQU     9               ;Wave size; number of objects created per wave
PLEXWCT EQU     3               ;Wave count; number of waves created

        RADIX   16              ;;(back to hex)