;;	INCLUDE "../SAM/START.ASM"
;	INCLVER	SAM,SINISTAR.EQU
FIXDAMPDM
;	ORG	ROMSAV

;* romove old task initialization
	ORG	$5156
	JMP	.100S
;	PULLORG
	ORG	$8E31		;;(needed to add this, maybe fix later?)
.100S  	jsr	StartDemo	;* Fake the Player 1 button hit.
  	jmp	Starts		;* Sieze control of the system.
PATCHSAV SET	*		;;(added new scratch address here to keep track)
	
;* make old task initialization a subroutine to save rom in patch
	ORG	$5167
	RTS
;	PULLORG

;* patch task initialization into correct place
	ORG	$527E
	JSR	.101S
;	PULLORG
	ORG PATCHSAV		;;(needed to add this)
.101S	CLRB
	std	OMTLen+2,X
	JMP	$5159
PATCHSAV SET	*		;;(added new scratch address here to keep track)
	
;* fix garbage velocity save
	ORG	$517C
	ADDD	OMTLEN+2,Y	;*   add it to previous s velocity
;	PULLORG

;	PULLORG	ROMSAVE	
;ROMSAV	SET	*