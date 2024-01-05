;	SUBTTL	WASHODDS	The odds for a warrior to fire are determined.
;*****
;*
;* WASHODDS
;*	The Warrior shooting odds are determined from the difficulty factor.
;*	As the warrior aggression increases from 0 to 127., the odds increase
;*	from 1 in 5 to 1 in 1.
;*
;* Needs:
;*	WAgg = An aggression rating increasing from 0 to 127
;*
;* Returns:
;*	CARRY CLEAR - Warrior may shoot this round.
;*	CARRY  SET  - Warrior may not shoot.
;*
;*****
;	IFE	Version-17.
	PUSHORG	Washodds
;	ELSE
;	PUSHORG	ROMSAVE
;	ENDIF	Version-17.
;
	RADIX	10		;;(Needed to add this)

;	ROUTINE	washodds								;;(Commenting this out as it creates a duplicate label)
	pshs	A,B		;* Save work registers
	RANDOM	OSEED1,160	;* Generate a random num from 0 to 159			;;Fixme was: RANDOM  OSEED1,160.
	pshs	A		;*   and save it on stack
	lda	WAgg		;* Get the warrior aggression and
	adda	#32		;*   add 32. to it (32/160 = 1/5, 160/160 = 1/1)	;;Fixme was: adda    #32.
	cmpa	S+		;* Compare in with number on stack affection CC
	puls	A,B		;* Restore work registers
	rts
	
	RADIX	16		;;(Needed to add this)
;*
;	IFE	Version-17.
	PULLORG
;	ELSE
;	PULLORG	ROMSAVE
;	ENDIF	Version-17.