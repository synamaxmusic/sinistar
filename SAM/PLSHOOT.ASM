;;	INCLUDE "../SAM/START.ASM"
;;	INCLVER	SAM,SINISTAR.EQU

;===============================================================================
; EQUs to remove later
;QFIRE	EQU	$4DAE
;GETOBJ	EQU	$434F	;GETOBJ
;CPLSHOT	EQU	$4D11	;SAMTABLE
;IMGOBJ	EQU	$4332	;GETOBJ
;===============================================================================

	PUSHORG	ROMSAVE

;* player shooting
	ROUTINE	PlShoot
	TUNE	QFIRE
	LDA	SFREE		;are there any screen workspaces available?
	BEQ	.1S
	JSR	GETOBJ		;yes, create shot  save none, uses A,B,X
	LDD	#CPLSHOT
	STD	OCHAR,X
	LDB	PLYRANG		;use same image rotation as player
	ADDB	#4
	ANDB	#$078		;angles 80-0F8 use 0-78
	CLRA
	ADDD	#IPLSHOT
	TFR	D,U
	JSR	IMGOBJ		;save X,U, uses none
	lda	PlyrAng		;* Determine the SHORT velocity based
	jsr	SinCos		;*   on the cosine of the player angle.
	pshs	A		;* Save the sine for the SHORT velocity.
	SEX
	RPT	3,ASLB,ROLA
	ADDD	OLVEL+WPLAYER
	STD	OLVEL,X
	puls	B		;* Determine the LONG velocity from player angle
	SEX
	RPT	4,ASLB,ROLA
	ADDD	OSVEL+WPLAYER
	STD	OSVEL,X
	LDY	OIDESC+WPLAYER	;coupute shot initial position
	LDA	OLCENT,Y
	SUBA	OLCENT,U
	CLRB
	ASRA
	RORB
	PSHS	D
	LDD	OSPOS+WPLAYER
	ADDA	OSCENT,Y
	SUBA	OSCENT,U
	STD	OSPOS,X
	STA	OLEFT,X
	PULS	D
	ADCB	OLPOSF+WPLAYER
	ADCA	OLPOS+WPLAYER
	STA	OLPOS,X
	STB	OLPOSF,X
	ADDA	OHEIGHT,U
	STA	OTOP,X
	JSR	PUTOBJ		;save none, uses none
.1S	RTS

	PULLORG	ROMSAVE