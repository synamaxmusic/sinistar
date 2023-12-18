;===============================================================================
;
;    Until a better solution is found, all local labels have been replaced with
;    global ones.  1$ is now Kill1, 223$ is now Kill223, etc.
;
;===============================================================================
; EQUs to remove later
RSTPOP	EQU	$6C7C
ReTarget EQU	$6438
AimFlang EQU	$64DD	;UPDFLANG
getlodist EQU	$635A	;DISTANCE
;stblimpulse EQU	$5CF6   ;STBLIMP
NEWVEL	EQU	$6503	;VELOCITY
updlvel	EQU	$6540	;VELOCITY
getsodist EQU	$6396	;DISTANCE
updsvel	EQU	$6569	;DISTANCE
UnTarget EQU	$6479	;RETARGET
;===============================================================================

	ORG	ROMSAV
;*****
;*
;* KRSINI
;*	Killing routine for the Sinistar
;*
;* Needs:
;*	X -> scanner workspace of Sinistar
;*	U -> characteristics descriptor of Sinistar
;*	SiniKills - The number of Sinistars killed by player.
;*
;* Returns:
;*	Finish - contains the value #Piecend (no sinistar)
;*	SiniKills - incremented (one more Sinistar dead) to a maximum of
;*		    $7F and does not wrap around.
;*	InWarp - set NON-ZERO from the start of the Sinistar death,
;*		 and is ZERO when the player has finished warping to the
;*		 new Sinistar building site.
;*
;*****
;	Routine	KRSINI
KRSINI	pshs	D,X,Y		;* Save work registers
                                
	inc	InWarp		;* Mark the Sinistar not to build up.
	ldd	#Piecend	;* Finish off the
	std	Finish		;*   the Sinistar (for the next one to build)
                                
	inc	SiniKills	;* Mark that another
	bvc	Kill1		;*   Sinistar bit the dust
	dec	SiniKills	;*   (but no wrap around).
                                
Kill1	tst	PlaGrave	;* If the player is dead when the		;;This gets patched over in FIXKRSIN.ASM ($59C3)
	bne	Kill9		;*   Sinistar dies, then don't warp him.
	lda	#7		;* Flash the
	sta	PCRAM		;*   screen red

	New_Sleep	Task1,Kill10,OTIMER+4	;* Start master control task.

Kill9	puls	D,X,Y		;* Restore work registers
	rts
;***
;*	[ Master control task for warp sequence ]
;*
;*	This supervising task starts the task which displays the various
;*	text messages.  There are really two tasks.  One on the TASK0 and one
;*	on the TASK8 list.  These tasks keep running, but this supervising
;*	task will change the messages that they display.  The first message is:
;*			"CONGRATULATIONS"
;*		   "YOU DEFEATED THE SINISTAR"
;*	At this time, control is taken from the player and the ship is moved,
;*	by impulse engines, toward the Sinistar.
;*
;***
Kill10	NEW_SLEEP	TASK0,Kill221	;* Start "CONGRATULATIONS"
	LDX	OINDEX,X		;*   "YOU DEFEATED THE SINISTAR"
	STX	OTIMER+0,Y		;*   on Task Lists 0 and 4
	NEW_SLEEP	TASK4,Kill221	;*   to be changed later
	LDX	OINDEX,X		;*   to another set of messages
	STX	OTIMER+2,Y		;*   regarding the warp engines.
;***
;*	Impulse engine/Sinistar explosion timeline:
;*
;*	---------------000+++++++++++++++
;*	Engaged		|      Disengaged
;*		Sinistar explodes
;*
;***
	lda	#-1			;* Mark the impulse engines
	sta	InImpulse		;*   engaged.
	NEW_SLEEP	Task1,Kill50	;* Take control of the impulse engines.
;***
;*	Now, the master control task waits for the Impulse Engines to take
;*	the ship to the dying Sinistar.
;***
	SLEEP	HERE
	ldx	[SinIndex]	;* The master control task must
	ldx	OSSCWSA,X	;*   wait until the impulse engines
	bne	Kill13		;*   have brought the ship to the dying
	SLEEP	LOOP		;*   (on screen) Sinistar.
;***
;*	The Sinistar is on screen.  Wait a second and remove the
;*	"CONGRATULATIONS" message.  Watch the Sinistar explode.
;*	Switch off the impulse engines.
;***
	RADIX	10
Kill13	ldd	#(60*3/2)	;* Delay for the explosion				;;Fixme was: ldd #(60.*3/2)
	RADIX	16
	jsr	Timer		;*   effect.
	clr	InImpulse	;* Que the Sinistar to explode.
	jsr	PClrScr		;* Clear screen of message.
	LDX	[OTIMER+0,Y]	;* Change the message display tasks,
	LDD	#Kill249	;*   which are on TASK0 and TASK8 lists,
	STD	OEXEC,X		;*   to display a new message:
	LDX	[OTIMER+2,Y]	;*   (none)
	LDD	#Kill249	;*   " "
	STD	OEXEC,X		;*   " "
	RADIX	10
	ldd	#(60*3)		;* Delay for the explosion				;;Fixme was: ldd #(60.*3)
	RADIX	16
	jsr	Timer		;*   effect.
	inc	InImpulse	;* Stop the Impulse Engines.
;***
;*	Now that the dying Sinistar has been seen, engage warp 7.
;***
	jsr	PClrScr		;* Clear the screen of old messages.
	LDX	[OTIMER+0,Y]	;* Change the message display tasks,
	LDD	#Kill222	;*   which are on TASK0 and TASK8 lists,
	STD	OEXEC,X		;*   to display a new message:
	LDX	[OTIMER+2,Y]	;*
	LDD	#Kill222	;*   "THE BATTLE COMPUTER IS"
	STD	OEXEC,X		;*   "ENGAGING WARP ENGINES"
;***
;*	Take the current direction of the player's ship and use it
;*	to put the ship in Warp Drive aimed the same way.
;***
	pshs	A,B,X,Y		;* Save work registers
	lda	OvPlAng		;* Use the impulse engine direction
	jsr	sincos		;*   to establish warp direction velocities.
	pshs	A
	sex
	RPT	4+0,aslb,rola
	std	OvLVel
;*
	puls	B
	sex
	RPT	4+1,aslb,rola
	std	OvSVel
	New_Sleep	Task1,Kill100	;* Take control of warp engines.
	puls	A,B,X,Y
;*
	RADIX	10
	LDD	#2*60		;* After the first 2 seconds of warp ...		;;Fixme was: LDD #2*60.
	RADIX	16
	JSR	TIMER
;*	
	jsr	PClrScr		;* Clear screen of message.
	LDX	[OTIMER+0,Y]	;* Change the message display tasks,
	LDD	#Kill249	;*   which are on TASK0 and TASK8 lists,
	STD	OEXEC,X		;*   to display a new message:
	LDX	[OTIMER+2,Y]	;*   (none)
	LDD	#Kill249	;*   " "
	STD	OEXEC,X		;*   " "
;*
	RADIX	10
	LDD	#3*60		;* Allow another 3 seconds of warp.			;;Fixme was: LDD #3*60.
	RADIX	16
	JSR	TIMER
;***
;*	Slow down the player's ship and announce that the player
;*	is entering a new zone.  The population changes accordingly.
;*	The warping speed control tasks will kill themselves off.
;***
	pshs	A,B,X,Y		;* Save work registers
	New_Sleep	Task4,Kill200	;* Slow down the player's ship.
;*
	JSR	RSTPOP		;	populate new wave
	LDX	[OTIMER+0,Y]	;* Change the message display tasks,
	LDD	#Kill223	;*   which are on TASK0 and TASK8 lists,
	STD	OEXEC,X		;*   to display a new message:
	LDX	[OTIMER+2,Y]	;*
	LDD	#Kill223	;*   "ENTERING xxx ZONE"
	STD	OEXEC,X		;*   "PREPARE FOR BATTLE"
	puls	A,B,X,Y		;* Restore work registers
;*
	RADIX	10
	LDD	#2*60		;sleep 2 seconds					;;Fixme was: LDD #2*60.
	RADIX	16
	JSR	TIMER
;***
;*	There are no more messages.  Kill off the message tasks.
;***
	pshs	A,B,X,Y		;* Save work registers
	jsr	PClrScr		;* Clear screen of message.
	LDX	[OTIMER+0,Y]	;* Kill off the two
	LDD	#DIE		;*   tasks on lists TASK0 and TASK8
	STD	OEXEC,X		;*   by getting X -> each task workspace
	LDX	[OTIMER+2,Y]	;*   and forcing them to commit suicide
	LDD	#DIE		;*   when they wake up.
	STD	OEXEC,X		;*   
;***
;*	Reset the impulse engine/Sinistar explosion effects marker.
;***
	lda	#-1		;* Reset the impulse engine/special effect
	sta	InImpulse	;*   marker for the next Sinistar death.
;***
;*	Now, to create the effect that the player ship was really headed
;*	toward the next sector that the Sinistar was rebuilding in, the
;*	Sinistar is placed ahead of the player's direction of travel.
;***
	CLRD			;* Zero the velocity
	ldy	[SinIndex]	;*    of the Sinistar.
	ldx	OSSCWSA,Y	;* If the Sinistar is not on screen
	beq	Kill19		;*   then there is no screen object to affect.
	std	OLVEL,X		;* Zero the Sinistar
	std	OSVEL,X		;*   screen velocity
Kill19	sta	OSLVEL,Y	;*   and do the same with the
	sta	OSSVEL,Y	;*   scanner velocities.
;*
	LDA	OvPlAng		;hyper the sinistar ahead of player
	JSR	SINCOS
	PSHS	A
	SEX
	ASLB
	ROLA
	STD	SSLPOS
	PULS	B
	SEX
	ASLB
	ROLA
	STD	SSSPOS
;*
	clr	InWarp		;* Mark the end of warp and build the Sinistar.
	clr	SinGrave	;* Rebirth the Sinistar.
	puls	A,B,X,Y		;* Restore work registers
	jmp	DIE									;;This gets patched over in FIXKRSIN.ASM ($5B03)

;*****
;*
;* 50$
;*	Override the Player's velocity controls for impulse engines.
;*
;* Needs:
;*	InImpulse = 1 to signal this task to die (shuts off impulse engines).
;*		    0 or -1 to let this task continue (runs impulse engines).
;*
;*****
Kill50	tst	InImpulse	;* When the impulse engines are finally
	ble	Kill51		;*   marked to be off, this task
	jmp	DIE		;*   will shut down (die).
                                
Kill51	pshs	A,B,X,Y		;* Save work registers.
;	IFE	0               
	inc	AMDemo		;* Fake this to be the attract mode attack.
	ldy	[PlaIndex]	;* Y -> player scanner workspace
	ldx	[SinIndex]	;* X -> scanner workspace of Sinistar to attack.
	jsr	ReTarget        
	jsr	AimFlang	;* Animate the player ship
	adda	#(CIRCLE/2)	;*   based on the angle
	sta	PlyrAngl	;*   toward the Sinistar.
;*                               
	lda	#XOrbit		;* Around the Sinistar take an "outer" orbit.
	ldb	WarrOrbit	;*   using the direction of orbit from the
;*	nop			;*   personality of the keystone warrior.
	pshs	A,B,X		;* Save parameters for the SHORT computations.
	jsr	getlodist	;* D = long orbital distance from the target		;;This gets patched over in FIXKRSIN.ASM ($5B2C)
	ldx	#stblimpulse	;* X -> speed table for warrior
	jsr	newvel		;* D = velocity to achieve
	jsr	updlvel		;* Update the long velocity
	ldd	OLVEL+WPlayer	;* Give the screen
	NEGD			;*   a scroll velocity
	std	SLVEL		;*   will keep up with the player
;*                               
	puls	A,B,X		;* Restore parameters for SHORT computations.
	jsr	getsodist	;* D = short orbital distance from the target		;;This gets patched over in FIXKRSIN.ASM ($5B43)
	ldx	#stblimpulse	;* X -> speed table for warrior
	jsr	newvel		;* D = velocity to achieve
	jsr	updsvel		;* Update the short velocity
	ldd	OSVEL+WPlayer	;* Give the screen
	NEGD			;*   a scroll velocity
	std	SSVEL		;*   will keep up with the player
;*                               
	ldx	[SinIndex]	;* X -> scanner workspace of Sinistar to attack.
	jsr	UnTarget        
	dec	AMDemo		;* Restore actual mode.
;	ELSE                    
;	ldy	[SinIndex]	;* The direction of travel for the player
;	ldx	[PlaIndex]	;*   is the angle toward the Sinistar.
;	jsr	AimFlang	;* This angle is saved for the warp angle,
;	sta	OvPlAngl	;*   overrides the player angle for effect,
;	sta	PlyrAngl	;*   and is used to compute the long and
;	jsr	sincos		;*   short impulse engine velocities.
;	pshs	A
;	sex
;	RPT	2+0,aslb,rola
;;*	std	OvLVel
;;*	ldd	OvLVel
;	std	OLVEL+WPlayer	;* Give the player a
;	NEGD
;	std	SLVEL
;;*
;	puls	B
;	sex
;	RPT	2+1,aslb,rola
;;*	std	OvSVel
;;*	ldd	OvSVel
;	std	OSVEL+WPlayer	;*   high velocity.
;	NEGD
;	std	SSVEL
;	ENDIF
	puls	A,B,X,Y
	SLEEP	LOOP
;*****
;*
;* 100$
;*	Override the Player's velocity controls for warp 7.
;*
;*****
Kill100	pshs	A,B,X,Y		;* Save work registers

	ldd	OvSVel
	ABSD
	cmpd	#WarpVel*2
	bhs	Kill103
	ldd	OvLVel
	ABSD
	cmpd	#WarpVel
	blo	Kill104

Kill103	ldd	OvLVel
	std	OLVEL+WPlayer	;* Give the player a
	NEGD
	std	SLVEL
	ldd	OvSVel
	std	OSVEL+WPlayer	;*   high velocity.
	NEGD
	std	SSVEL

	puls	A,B,X,Y
	SLEEP	LOOP

Kill104	puls	A,B,X,Y
	jmp	DIE

;*****
;*
;* 200$
;*	Slow down the Player's high velocity.
;*
;*****
Kill200	pshs	A,B,X,Y		;* Save work registers

	ldd	OvSVel
	ABSD
	cmpd	#WarpVel*2
	bhs	Kill203
	ldd	OvLVel
	ABSD
	cmpd	#WarpVel
	blo	Kill204

Kill203	ldd	OvLVel		;* Give the player a
	RPT	4,asra,rorb
	NEGD
	addd	OvLVel
	std	OvLVel

	ldd	OvSVel		;* Give the player a
	RPT	4,asra,rorb
	NEGD
	addd	OvSVel
	std	OvSVel

	puls	A,B,X,Y		;* Restore work registers
	SLEEP	LOOP
;***
;* Return control to player.
;***
Kill204	puls	A,B,X,Y		;* Restore work registers
	jmp	DIE

ZNMTSK	SET	*		;* Bizzare label added by =RJ= on 25Feb83
Kill223	pshs	A,B,X,Y		;* Save message registers
	LDA	SINIKILLS
	ANDA	#3
	BNE	Kill230
	TEXT	$50,$43
	PHRASE	RED,68,ENTERING
	WORD	BLUE,68,VOID
	BRA	Kill240
Kill230	DECA
	BNE	Kill231
	TEXT	$50,$39
	PHRASE	RED,68,ENTERING
	WORD	BLUE,68,WORKER
	BRA	Kill240
Kill231	DECA
	BNE	Kill232
	TEXT	$50,$38						;;Fixme was: TEXT $50,$30 (This pushes the string:
								;;"ENTERING WARRIOR ZONE" to the left too much) 
								;;
								;; This is the first time that I've encountered
								;; different values in the source code than what's
								;; in the final ROM.  I haven't found a patch file
								;; that inserts these different values so I'm assuming
								;; this was done manually with hex editing and was
								;; never updated in the source code.
								;;
	PHRASE	RED,68,ENTERING
	WORD	BLUE,68,WARRIOR
	BRA	Kill240
Kill232	TEXT	$50,$2B						;;Fixme was: TEXT $50,$3B (This pushes the string:
								;;"ENTERING PLANETOIDS ZONE" to the right too much)
	PHRASE	RED,68,ENTERING
	WORD	BLUE,68,PLANETOIDS
Kill240	WORD	RED,68,ZONE
	TEXT	$3C,$40
	PHRASE	RED,68,PREPARE,FOR,BATTLE
	BRA	Kill250

Kill221	pshs	A,B,X,Y		;* Save message registers
	TEXT	$50,$4E
	PHRASE	BLUE,68,CONGRATULATIONS
	TEXT	$30,$2B
	PHRASE	BLUE,68,YOU,DEFEATED,THE,SINISTAR
	BRA	Kill250

Kill222	pshs	A,B,X,Y		;* Save message registers
	TEXT	$50,$36
	PHRASE	YELLOW,68,THE,BATTLE,COMPUTER,IS
SDSOFF	SET	SDSOFF+4						;;Fixme was: .$DSOFF	SET	.$DSOFF+4
	PHRASE	YELLOW,68,ENGAGING,WARP,ENGINES
	BRA	Kill250

Kill249	pshs	A,B,X,Y

Kill250	puls	A,B,X,Y		;* Restore message registers
	SLEEP	LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAV	SET	*		;; Save the current address

	ORG	PHRSAV		;; Jump over to PHRSAV to save our pointers
	
	FDB	_ENTERING
	FDB	_VOID

	FDB	_WORKER
	FDB	_WARRIOR
	FDB	_PLANETOIDS
	FDB	_ZONE
	FDB	_PREPARE
	FDB	_BATTLE
	
	FDB	_CONGRATULATIONS
	FDB	_YOU
	FDB	_DEFEATED
	FDB	_THE
	FDB	_SINISTAR
	
	FDB	_COMPUTER
	FDB	_IS
	FDB	_ENGAGING
;	FDB	_WARP	

PHRSAV	SET	*		;; Mark the new address for PHRSAV to add
				;; more phrases later

	ORG	ROMSAV		;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	PULLORG	ROMSAVE
ROMSAV	SET	*

	INCLUDE "../WITT/STBLIMP.ASM"	;* Impulse engine speed table