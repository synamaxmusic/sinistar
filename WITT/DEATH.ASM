;	INCLVER	RICH,Speak		* Speak macro

;===============================================================================
; EQUs to remove later
EXPOBJ	EQU	$6C61	;STUBS
;===============================================================================

	ORG	ROMSAV
;*****
;*
;* DEATH
;*	The player ship dies!
;*
;* Notes:
;*	This routine should kill off one ship.  The ship count display will
;*	be updated.  The player will loose control of the joystick
;*	and firing buttons.  The screen will flash.  A HUGE explosion
;*	effect will occur.  The sinistar will be moved offscreen (if on).
;*	All on screen workers, warriors, planets and crystals will be killed.
;*
;*****
;	ROUTINE	Death
Death	LDA	AMDEMO		;in attract mode demo?
	BEQ	Mortal
	CLR	AMDEMO		;yes?, end attract mode demo
	CLR	NPLAYER		;zero player count
;*	nop
;	ROUTINE	PntScrn		;* Point screen entry
PntScrn	jmp	IAMode		;*   for attract mode.				;; Gets patched over by MICA/ZPNTSCRN.ASM ($583B)
;*
;	ROUTINE	Mortal		;* RTS here to be IMMORTAL.
Mortal	TUNE	Qpldie		;* Play a tune at the destruction of the player
	lda	#-1		;* Flash the
	sta	PCRAM		;*   screen.
	CLRD		
	STD	OLVEL+WPLAYER	;kill the players velocity
	STD	OSVEL+WPLAYER
	STD	SLVEL		;kill the scrolling
	STD	SSVEL	
	CLR	PANMASK		;disable player controls
	LDA	SHIPS		;get ship count
	LDB	#DCNS+DWBL	;erase one ship
	JSR	UPSHIPS		;save Y, uses none
	DEC	SHIPS		;count down ships
	LDB	#7		;add a one ship played to the books
	JSR	AUD1S		;save none, uses none				;;Fixme was: JSR AUD1$
	inc	PlaGrave	;* Mark grave.  Cleared only by turn start.
	LDX	#WPLAYER
	JSR	EXPOBJ
	LDD	#CNULL		;disable player collisions
	STD	OCHAR+WPLAYER
	New_Sleep	Task1,.1S,OTIMER
	RTS
	
.1S	LDA	DEATHFL		;not ready to die,
	ORA	ASCINT		;or speeking?
	BEQ	.2S
	SLEEP	LOOP		;yes, keep waiting
;*
	RADIX	10
.2S	LDD	#60		;sleep 1 second
	RADIX	16
	JSR	TIMER
	ldx	[SinIndex]	;* If the Sinistar
	ldx	OSSCWSA,X	;*   is on the screen
	bne	.99S		;*   when the player dies,
	SPEAK	1		;*   say "I am Sinistar"
	RADIX	10
	LDD	#60		;sleep 1 second
	RADIX	16
	JSR	TIMER
.99S	JSR	DISPE		;erase status display area
	SLEEP	HERE
	tst	ASCInt		;* Don't start the next turn
	lbeq	TurnIni		;*   until the Sinistar has finished speaking.
	SLEEP	LOOP

;	PULLORG	ROMSAVE
ROMSAV	SET	*