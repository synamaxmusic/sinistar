	INCLUDE "../SAM/START.ASM"
	
;===============================================================================
; EQUs to remove later
;VRLOAD	EQU	$37F0	;EXECJNK
;EXECJNK	EQU	$353E	;EXECJNK
;EXEC2A	EQU	$34AF	;EXEC
;PIXCHK	EQU	$398E	;PIXCHK
;===============================================================================

	ORG	ROMSAV
	
CR3SAVE	SET	*	
CR3	fcc	"COPYRIGHT 1983 WILLIAMS ELECTRONICS, INC."

	;SUBTTL	EXECUTIVE LOOP

;* start object list
EXEC	DEC	ESTATE		;are we overloaded?
	BLE	.1S
	JMP	VRLOAD		;overload handling, use none
.1S	BPL	.3S		;should we start next object list?
.2S	LDX	[PRTASK]	;get next task
	LDY	[OTLINK,X]      
	JSR	[OEXEC,Y]	;execute next task, uses A,B,X,Y,U
	LDA	ESTATE		;should we start next object list?
	BMI	.2S		;yes:
.3S	JSR	EXECJNK		;misc. exec junk, save none, uses A,B,X,U
	LDY	SCRKEY		;start list
	BNE	EXEC2A		;are there any objects?
	BRA	EXEC		;end of list.
;* enter here from display routine- list swapper
EXEC1	LDX	OBLINK,Y	;are we already at left of list?
	BEQ	EXEC2
	LDA	OLEFT,Y		;are we above previous image?
	CMPA	OLEFT,X
	BHS	EXEC2
	LDU	OFLINK,Y	;swap back in new order, U-> next
	STU	TEMP		;save for end of swap(s)
	STU	OFLINK,X	;forward link-out
	STX	OBLINK,U	;backward link-out
.1S	LDX	OBLINK,X	;X-> last backlink
	CMPA	OLEFT,X		;do we continue searching back?
	BLO	.1S		;loop back if so
	LDU	OFLINK,X	;save last fwdlink
	STY	OFLINK,X	;forward link-in from last
	STX	OBLINK,Y	;back link-in to last
	STU	OFLINK,Y	;forward link-in to next
	STY	OBLINK,U	;back link-in from next
	LDY	TEMP		;swap done. pick up where we bottom off b4 swap.
	BNE	EXEC2A
	BRA	EXEC		;end of list.
;* enter here if it went off screen
EXEC2	LDY	OFLINK,Y	;point to next object
	BEQ	EXEC		;end of list
;* come here if we have next (from swap) - collision scan
EXEC2A	LDB	OLEFT,Y		;compute my right
	ADDB	ODWIDTH,Y
	BCC	.1S		;right clipped?
	LDB	#-1		;yes
.1S	STB	RIGHT		;save it
	LDA	[OCHAR,Y]	;do we care about collisions?
	BMI	.6S		;yes:
	LDX	OFLINK,Y	;compare my right with next objects left.
	CMPB	OLEFT,X
	BLS	.6S		;end of check
.2S
;* * *	LDA	OTOP,X
;* * *	SUBA	[OIDESC,X]
;* * *	CMPA	OLPOS,X
;* * *	BLS	100$
;* * *	SWI
;* * *100$	LDA	OTOP,Y
;* * *	SUBA	[OIDESC,Y]
;* * *	CMPA	OLPOS,Y
;* * *	BLS	101$
;* * *	SWI
;* * *101$	LDA	OLEFT,X
;* * *	CMPA	OSPOS,X
;* * *	TST	OSTATUS,X
;* * *	BMI	102$
;* * *	BHS	102$
;* * *	SWI
;* * *102$	LDA	OLEFT,Y
;* * *	CMPA	OSPOS,Y
;* * *	TST	OSTATUS,Y
;* * *	BMI	103$
;* * *	BHS	103$
;* * *	SWI
;* * *103$
	LDA	OTOP,Y		;compare my top with his bottom
	CMPA	OBOTTOM,X
	BLE	.5S
	LDA	OBOTTOM,Y	;compare my bottom with his top
	CMPA	OTOP,X
	BGE	.5S
	LDU	OCHAR,X		;check collision mask
	LDD	OMYTYPE,U
	ANDA	[OCHAR,Y]
	BNE	.3S
	STB	TEMP
	LDD	[OCHAR,Y]
	ANDB	TEMP
	BEQ	.4S
.3S	JSR	PIXCHK		;yes, save X,Y, uses A,B
.4S	LDB	RIGHT		;restore
.5S	LDX	OFLINK,X	;collision check done, link to next.
	CMPB	OLEFT,X
	BHI	.2S
.6S	LDA	ESTATE		;beam avoidance,	do we care about tasks?
	BGT	.11S
	LDA	RIGHT		;collide with beam?
	ADDA	#FUDGE
	BCS	.8S		;right clip
	CMPA	SCNLIN
	BLO	.11S		;beam inside
	STY	SAVEOBJ		;execute task  while waiting for beam
	LDX	[PRTASK]	;get next task
	LDY	[OTLINK,X]
	JSR	[OEXEC,Y]	;execute next task, uses A,B,X,Y,U
.7S	LDA	ESTATE		;do we care about tasks?
	BGT	.10S
	LDA	RIGHT		;collide with beam?
	ADDA	#FUDGE
	BCS	.9S		;right clip
	CMPA	SCNLIN
	BLO	.10S		;beam inside
	LDX	[PRTASK]	;get next task
	LDY	[OTLINK,X]
	JSR	[OEXEC,Y]	;execute next task, uses A,B,X,Y,U
	BRA	.7S		;check again
.8S	STY	SAVEOBJ		;right clip wait loop
.9S	LDX	[PRTASK]	;get next task
	LDY	[OTLINK,X]
	JSR	[OEXEC,Y]	;execute next task, uses A,B,X,Y,U
	LDA	ESTATE
	BLE	.9S
.10S	LDY	SAVEOBJ
.11S	JMP	[ODRWVEC,Y]	;erase/update/display, return to EXEC1 or EXEC2

;	PULLORG	ROMSAVE
ROMSAV	SET	*