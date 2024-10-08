;       INCLUDE "../SAM/START.ASM"

        ;SUBTTL SAM'S OFFSETS

SAMOFFSET
;* object workspace
        PUSHORG 0
OFLINK  RMB     2       ;       list forward pointer
OBLINK  RMB     2       ;       list backward pointer
OLPOSF  RMB     1       ;\      l position fraction ( msb = pixels)
OBOTTOM RMB     0       ; \     screen location of bottom of image
OLPOS   RMB     1       ; /     l position ( lsb = 2pixels )
OLEFT   RMB     1       ;/      screen location of left of image
OSPOS   RMB     1       ;\      s position ( lsb = pixels )
OSPOSF  RMB     1       ;/      s position fraction ( msb = 1/2pixels)
ODSOUR  RMB     2       ;       address of displayed image source
ODWIDTH RMB     1       ;       displayed width
OSVEL   RMB     2       ;       s velocity ( msby = pixels )
OLVEL   RMB     2       ;       l velocity ( msby = pixels )
OSTATUS RMB     1       ;       status byte
;*                      ;       b7 left clip flag
;*                      ;       b6 right clip flag
;*                      ;       b1-b0 bounce flag
OTOP    RMB     1       ;       screen location of top of image
OCHAR   RMB     2       ;       characteristics
OIDESC  RMB     2       ;       image descriptor
ONIDESC RMB     2       ;       new image descriptor ( for display change)
ODRWVEC RMB     2       ;       erase-update-draw routine vector
OPDRWVE RMB     2       ;       post-erase-update-displ rou vect ( for DOBJECT)
OSCAN   RMB     2       ;       scanner workspace index
OEFFECT RMB     4       ;       miscellaneous ram for effects
        PULLORG OLEN

;* dynamic workspace
        PUSHORG -ODYNFIX ;\
        RMB     2        ; >    size of workspace + ODYNOVH
OINDEX  EQU     *        ;/     index address for workspace (zero if free)
        PULLORG

;* task workspace
        PUSHORG 0
OTLINK  RMB     2               ;task list pointer (must be zero offset)
OEXEC   RMB     2               ;routine execution address
        PULLORG OMTLEN          ;minimum task length

;* scanner position update task workspace
        PUSHORG OMTLEN
OSULPOS RMB     1               ;old l pos
OSUSPOS RMB     1               ;old s pos
        PULLORG OSULEN

;* scanner task workspace
        PUSHORG OMTLEN
OSCHAR  RMB     2               ;characteristics descriptor address
OSLVEL  RMB     1               ;l velocity (in half pixels per 16 ms)
OSSVEL  RMB     1               ;s velocity (in half pixels per 16 ms)
OSLPOS  RMB     1               ;l position (in 4 pixels)
OSSPOS  RMB     1               ;s position (in 4 pixels)
OSSCWSA RMB     2               ;screen workspace address
OSPERS  RMB     1               ;miscellaneous personality byte
        PULLORG OSCLEN

;* timer task workspace
        PUSHORG OMTLEN
OTIME   RMB     2               ;time left in ticks
OWAKE   RMB     2               ;wake address
        PULLORG OTIMER

;* characteristics descriptor
        PUSHORG 0
        RMB     2               ;collision mask  ( msbit = 1 = no care ) FIRST
OMYTYPE RMB     2               ;my collision type
OCLTYPE RMB     1               ;collision type
OInVec  rmb     2               ;* Vector to initialization routine
OKiVec  rmb     2               ;* Vector to killing routine
OMASS   RMB     1               ;object mass
OFIDESC RMB     2               ;first image descriptor
OOFFSCR RMB     2               ;offscreen routine
OONSCR  RMB     2               ;onscreen routine
OLSVEC  RMB     2               ;vector to leave-sector routine
OCDInd  rmb     2               ;* Index to scanner object CD Table
OOSCLEN RMB     1               ;scanner workspace length
OSCHIGH RMB     1               ;scanner height
OSCWIDE RMB     1               ;scanner width
OVSCFLG RMB     0               ;visible/invisible on scanner flag
OBSCIMG RMB     2               ;bottom flavor scanner image
OTSCIMG RMB     4               ;top flavor scanner image
OINTYPE rmb     1               ;intelligence type
OPFRAG  RMB     1               ;percentage of screen spaces for fragments
OFRAGIM RMB     2               ;first fragment image descriptor
OViBas  rmb     2               ;* Points to base address of vib offsets

        PULLORG OSCDLEN

;* image descriptor
        PUSHORG 0
OHEIGHT RMB     1               ;image height (bytes)
OWIDTH  RMB     1               ;image width
OIMAGE  RMB     2               ;image data address
OCOLTBL RMB     2               ;collision table address
OLCENT  RMB     1       ;\      ;l offset from bottom-right to center
OSCENT  RMB     1       ;/      ;s offset from bottom-right to center
        PULLORG OILEN

;* task list data
        PUSHORG 0
        RMB     2               ;task list keystone (must be first)
OTKEYI  RMB     2               ;task list keystone index
OTPTR   RMB     2               ;task list pointer
OTBACK  RMB     1               ;task list backlog
        PULLORG OTLEN

;* star data
        PUSHORG 0
        RMB     2               ;screen address (msb = 1, if not drawn)
OSCOLOR RMB     1               ;star color
OSTMASK RMB     1               ;star last written to screen pixel mask
        PULLORG OSTLEN

;* tune repeat counters
        PUSHORG 0
        RMB     2               ;counter program address
OTNRCNT RMB     1               ;repeat counter
        PULLORG OTNRLEN

;* random seeds
        PUSHORG 0
OSEED1  RMB     2               ;random seed 1
OSEED2  RMB     2               ;random seed 2
        PULLORG ORSPACE         ;random seeds space

;* offsets for on scroll on screen vectors
        PUSHORG 0
OTOPON  RMB     2               ;scroll onto top edge of screen
OBOTON  RMB     2               ;scroll onto bottom edge of screen
ORIGON  RMB     2               ;scroll onto right edge of screen
OLEFON  RMB     2               ;scroll onto left edge of screen
        PULLORG

;* sinistar piece table offsets
        PUSHORG 0
OSPDESC RMB     2               ;descripter address
OSPLOFF RMB     1       ;\      ;piece l offset from bottom ( pixels)
OSPSOFF RMB     1       ;/      ;piece s offset from left ( pixels)
        PULLORG OSPLEN