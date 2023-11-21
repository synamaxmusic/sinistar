	INCLUDE "../WITT/SPEAK.ASM"		;* Speak macro
;	INCLVER	RICH,Table			;* Table macro

	ORG	ROMSAV
;	SUBTTL	AniSinistar - Animates Sinsitar Eyebrows
;****
;*
;* ANISINISTAR
;*
;*	Animate the Sinistar based on who knows what right now.
;*	Anyway, for now it just goes munch, munch, munch!
;*
;* Needs:
;*	Y -> scanner workspace of Sinistar
;*	More is needed but undertermined.
;*
;* Returns:
;*	Nothing
;*
;*****
;	ROUTINE	anisinistar
ANISINI	pshs	A,B,X,Y		;* Save work registers
	PSHS	D,X
	LDX	[SININDE]	;is sinistar on screen?
	LDA	OSSCWSA,X
	BEQ	.2S
	ldx	Finish		;* If sinistar is not alive, exit.
	cmpx	#Alive
	bne	.2S
	LDX	ANIMPTR		;yes?, get animation pointer
;*
	leay	-ANIMTBL,X
	tfr	Y,D
	RPT	3,asra,rorb
	tfr	D,Y
	lda	.100S,Y
	sta	PCRAM+$0E
;*
	LDD	#DZSP		;setup for drawing without collision table
;***
;* The mouth draw was removed when the speech synchronization was added.
;*
;*	JSR	MODSINI		draw mouth
;***
	LEAX	OSPLEN,X	;advance to eye brows
	JSR	MODSINI		;draw eye brows
	LEAX	OSPLEN,X	;advance to next piece
	CMPX	#ANIMEND	;end to table?
	BLO	.1S
	LDX	#ANIMTBL	;yes?, start over
.1S	STX	ANIMPTR		;save animation pointer
.2S	PULS	D,X
.99S	puls	A,B,X,Y		;* Restore work registers
	rts

.100S	fcb	7,3,0		;* Eye colors

;	SUBTTL	AniSCS	- Animate (Sinistar) Speech Call Starter
;*****
;*
;* ANISCS
;*	Animate (Sinistar) Speech Call Starter.  The Sinistar is kept from
;*	speaking when it is out of sector and, of course, the Sinistar will
;*	not speak if it is not yet alive.  In addition, the Sinistar will not
;*	talk if the player has started dying.  This compliments the fact that
;*	the player must continue to live/die as long as the Sinistar speaks.
;*
;* Calling sequence:
;*	jsr	AniSCS
;*	fcb	n		* Where n is 1 to 10.
;*
;*	is generated via one of the calls:
;*
;*	SPEAK	1.		I am SiniStar	(won't interupt other speech)
;*	SPEAK	2.		Beware, I Live	(won't interupt other speech)
;*	SPEAK	3.		I Hunger	(won't interupt other speech)
;*	SPEAK	4.		Beware, Coward!	(won't interupt other speech)
;*	SPEAK	5.		Run, Coward!	(won't interupt other speech)
;*	SPEAK	6.		Run, Run, Run!	(won't interupt other speech)
;*	SPEAK	7.		I Hunger, Coward! (won't interupt other speech)
;*	SPEAK	8.		ROAR		(won't interupt other speech)
;*	SPEAK	9.		ROAR		(will interupt anything)
;*	SPEAK	10.		(Shut up the Sinistar)
;*	SPEAK	11.		Beware, I live! (for status page)
;*
;* Needs:
;*	Return address -> Animation sequence number
;*	SiniSector	= Non-zero when the Sinistar is out of sector.
;*		  Zero when the Sinistar is within the sector.
;*	DeaTime		= Death marker for the player.  Non-zero when the
;*			  player is dying.
;*
;* Returns:
;*	ASCPtr -> Animation sequence data
;*	ASCTime = 0 (I.E. no time remaining in previous call)
;*	ASCInt  = Clear if no tune is pending.
;*		  Set if a tune has started.
;*
;*****
	RADIX	10
LiveSC	EQU	2		;* "Beware, I Live!" In/Out of sector.
RoarSC	EQU	8		;* Roar (interuptable) Speach Call
DieSC	EQU	9		;* Death Roar will interupt other speech calls.
StatSC	EQU	11		;* Animation Speach Call for Status Page
	RADIX	16
;*                               
;	Routine	AniSCS		;* Animate Speech Call Starter

AniSCS	pshs	A,X		;* Save work register
	SECTION	ANISCS								;;(had to add this)                                
	ldx	Finish		;* If sinistar is
	cmpx	#Alive		;*   not yet alive,
	bne	.99S		;*   then it cannot talk.
	lda	[3,S]		;* A = Animation sequence number
	cmpa	#StatSC		;* The Status Page animation call
	beq	.2S		;*   can always talk.
	tst	ASCInt		;* If there is no speech animation
	beq	.1S		;*   in progress, a new animation may start.
                                
	cmpa	#RoarSC		;* A Roar may interupt
	beq	.1S		;*   a running animation.
	cmpa	#DieSC		;* A Death Roar may interupt
	bne	.99S		;*   a running animation.
;***
;*	Out of sector, the Sinistar only announces that it lives.
;***
.1S	cmpa	#LiveSC		;* If the Sinistar is saying "Beware, I Live!"
	beq	.2S		;*   it can do so in or out of sector.
	tst	SiniSec		;* If the Sinistar is				;;Fixme was: SiniSector
	bne	.99S		;*   out of sector, then exit.
                                
.2S	ldx	#.100S		;* Call the routine entry corresponding
	asla			;*   to the argument number to the SPEAK call.
;***                             
;*	IFN	Version-Final	;* Check
;*	cmpa	#(.101S-.100S)	;*   for
;*	blt	.3S		;*   an
;*	swi			;*   invalid
;*	bra	.99S		;*   SPEAK
;*	ENDIF	Version-Final	;*   macro call.
;***                             
.3S	jsr	[A,X]		;* Speak.
;***
;*	X -> interpretor speech data
;***
	inc	ASCInt		;* Mark this animation in progress and save the
	stx	ASCPtr		;*   data pointer for the animation interpretor.
	clr	ASCTime		;* Stop any currently running animation.
.99S	ldx	3,S		;* Revise the return address
	leax	1,X		;*   to point past the
	stx	3,S		;*   sequence data pointer.
	puls	A,X		;* Restore work register
	rts

.100S	fdb	rts		;* Dummy table entry
	fdb	.101S		;* SPEAK 1 - SC1
	fdb	.102S		;* SPEAK 2 - SC2
	fdb	.103S		;* SPEAK 3 - SC3
	fdb	.104S		;* SPEAK 4 - SC4
	fdb	.105S		;* SPEAK 5 - SC5
	fdb	.106S		;* SPEAK 6 - SC6
	fdb	.107S		;* SPEAK 7 - SC7
	fdb	.108S		;* SPEAK 8 - SC8 - Roar!
	fdb	.109S		;* SPEAK 9 - SC9 - Roar and leave mouth open!
	fdb	.110S		;* SPEAK DIESC - Shut up Sinistar.
	fdb	.111S		;* SPEAK 11 - Status page "Beware, I Live!"
.101S	TUNE	SC1
	ldx	#AniSC1
	rts
.102S	TUNE	SC2
	ldx	#AniSC2
	rts
.103S	TUNE	SC3
	ldx	#AniSC3
	rts
.104S	TUNE	SC4
	ldx	#AniSC4
	rts
.105S	TUNE	SC5
	ldx	#AniSC5
	rts
.106S	TUNE	SC6
	ldx	#AniSC6
	rts
.107S	TUNE	SC7
	ldx	#AniSC7
	rts
.108S	TUNE	SC8		;* Normal roar.
	clr	ASCInt		;* Mark any current tune interuptable.
	ldx	#AniSC8
	rts
.109S	TUNE	SC9		;* Final roar.
	clr	ASCInt		;* Mark any current tune interuptable.
	ldx	#AniSC9
	rts
.110S	TUNE	.112S		;* Sound of Silence.
	ldx	#AniSCF		;* Shut up, Sinistar.
	rts
.111S	TUNE	SC2		;* Status page.
	clr	ASCInt		;* Mark any current tune interuptable.
	ldx	#AniSC2
	rts
;* Sinistar Shut-up tune
.112S	_IPRIO	3F								;;Fixme was: .IPRIO
	_SOUND	1F								;;Fixme was: .SOUND
	_PRIO	1								;;Fixme was: .PRIO
	_TIME	1								;;Fixme was: .TIME
	_STOP									;;Fixme was: .STOP
	
	ENDSECTION ANISCS							;;(had to add this)

;	SUBTTL	AniSC	- Animate (Sinistar) Speech Call
;	Routine	AniSC		;* Animate Speech Call
AniSC	pshs	A,B,X,Y,U	;* Save work registers
                                
	dec	ASCTime		;* If there is time remaining on a pending
	bge	Ani99S		;*   animation, wait for it to complete.
                                
.Ani1S	ldx	ASCPtr		;* X -> current animation interpretable data	
	beq	Ani98S		;* (On system start up, this is ZERO)
                                
	ldd	0,X		;* A = Mouth Position, B = Animation time.
	cmpa	#EOA		;* If this is the end of the animation
	beq	Ani98S		;*   then clean up and exit.
;***
;*	Animate.
;***
	leax	2,X		;* Advance the interpretor to the
	stx	ASCPtr		;*   next segment of the animation data.
;***
;*	A position time of ZERO (0) acts as a NO-OPERATION and goes on the
;*	the next position/time data pair.
;***
	decb			;* Count off this frame of the animation.
	blt	.Ani1S		;* If the time was zero, skip this position.
	stb	ASCTime		;* Mark the time remaining for the next wake-up.
;***
;*	The animation sequence always runs, but it may not draw anything
;*	when the Sinistar is off screen, or not yet "alive".
;***
	ldx	[SinInde]	;* If the Sinistar is				;;Fixme was: ldx [SinIndex]
	ldx	OSSCWSA,X	;*   not on screen,
	beq	Ani99S		;*   then exit.
	ldx	Finish		;* If sinistar is
	cmpx	#Alive		;*   not yet alive,
	bne	Ani99S		;*   then exit.
;***
;*	A = Animation position at which to set mouth.
;*	    0 = Shut
;*	    4 = Open
;*	    8 = Wide open
;*	   -1 = Terminate animation
;***
EOA	EQU	-1		;* End Of Animation sequence
Shut	EQU	0		;* Mouth position shut
Open	EQU	Shut+OSPLen	;* Mouth position open (halfway)		;;(Duplicate symbol found in SAM/PHRASE.ASM)
Wide	EQU	Open+OSPLen	;* Mouth position open (fully)
;***
;*	IFN	Version-Final
;*	cmpa	#Shut		* Test
;*	beq	4$		*   for
;*	cmpa	#Open		*     valid
;*	beq	4$		*	animation
;*	cmpa	#Wide		*	  data.
;*	beq	4$
;*	swi			* Invalid data.  Stop!
;*	bra	.98S
;*4$	nop
;*	ENDIF	Version-Final
;***
	ldx	#Ani100S		;* X -> mouth animation image table
	leax	A,X		;* X -> mouth animation image entry
	ldd	#DZSP		;* A = Collision type 0, B = Drawing setup
	jsr	ModSini		;* Draw new mouth animation
	bra	Ani99S		;* Exit
                                
Ani98S	ldx	#AniSCE		;* Mark the current animation			;;Fixme was: 98$ (changed local label to global)
	clr	ASCInt		;*   interuptable and
	stx	ASCPtr		;*   complete (the data is EOA,Notime)
	clr	ASCTime		;* Mark no time remaining.
Ani99S	puls	A,B,X,Y,U	;* Restore work registers			;;Fixme was: 99$ (changed local label to global)
	rts
;***
;*	Mouth Animation Image Table
;***
Ani100S	fdb	AMout1,$060C	;* 1 - Mouth shut
	fdb	AMout3,$060C	;* 3 - Mouth open (halfway)
	fdb	AMout2,$060C	;* 2 - Mouth wide open
;*****
;*
;* The interpreted animation data.
;*
;*****

	RADIX	10								;;(had to add this)
	
;* I am Sinistar.
;	TABLE	AniSC1
AniSC1	fcb	Shut,1
	fcb	Wide,14,Open,8
	fcb	Wide,6,Shut,20
	fcb	Open,12,Shut,1,Open,10,Shut,3,Wide,25,Open,3,Shut,1
	fcb	EOA,6
;	PAD	0
;	ENDTBL
;* Beware!  I Live!
;	TABLE	AniSC2
AniSC2	fcb	Shut,1
	fcb	Wide,2,Open,16,Shut,5,Open,3,Wide,7,Open,14,Shut,13
	fcb	Wide,12,Open,8
	fcb	Wide,7,Shut,3,Open,15,Shut,1
	fcb	EOA,6
;	PAD	0
;	ENDTBL
;* I hunger!
;	TABLE	AniSC3	
AniSC3	fcb	Shut,1
	fcb	Wide,5,Open,11
	fcb	Wide,12,Open,24,Shut,1
	fcb	EOA,6
;	PAD	0
;	ENDTBL
;* Beware, Coward!
;	TABLE	AniSC4
AniSC4	fcb	Shut,1
	fcb	Wide,2,Open,16,Shut,7,Open,3,Wide,5,Open,14,Shut,13
	fcb	Open,8,Shut,6,Open,3,Wide,5,Open,13,Shut,13
	fcb	EOA,6
;	PAD	0
;	ENDTBL
;* Run, Coward!
;	TABLE	AniSC5
AniSC5	fcb	Shut,1
	fcb	Open,4,Wide,14,Open,6,Shut,13
	fcb	Open,8,Shut,6,Open,3,Wide,5,Open,13,Shut,13
	fcb	EOA,6
;	PAD	0
;	ENDTBL
;* Run!  Run!  Run!
;	TABLE	AniSC6
AniSC6	fcb	Shut,1
	fcb	Open,4,Wide,14,Open,6,Shut,13
	fcb	Open,4,Wide,14,Open,6,Shut,13
	fcb	Open,4,Wide,14,Open,6,Shut,13
	fcb	EOA,6
;	PAD	0
;	ENDTBL
;* I Hunger, Coward!
;	TABLE	AniSC7
AniSC7	fcb	Shut,1
	fcb	Wide,5,Open,11
	fcb	Wide,12,Open,24,Shut,13
	fcb	Open,8,Shut,6,Open,3,Wide,5,Open,13,Shut,13
	fcb	EOA,6
;	PAD	0
;	ENDTBL
;* Roar!
;	TABLE	AniSC8
AniSC8	fcb	Shut,1
	fcb	Open,20,Wide,126,Open,2,Shut,1
	fcb	EOA,6
;	PAD	0
;	ENDTBL
;* Death Roar!
;	TABLE	AniSC9		;* This leaves the Sinistar's mouth open.
AniSC9	fcb	Shut,1
	fcb	Open,20,Wide,126,Open,2
	fcb	EOA,6
;	PAD	0
;	ENDTBL
;* Shut up the Sinistar.
;	TABLE	AniSCF
AniSCF	fcb	Shut,1,EOA,0				;* Shut mouth.
;	ENDTBL
;* End (do nothing) speech.
;	TABLE	AniSCE
AniSCE	fcb	EOA,0					;* End animation.
;	ENDTBL
	
	RADIX	16								;;(had to add this)

;	PULLORG	ROMSAVE
ROMSAV	SET	*

	INCLUDE "../FALS/SC1.ASM"		;* Speech tunes