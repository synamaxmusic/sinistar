	PUSHORG	ROMSAVE
	
;	SubTtl	- Difficulty tables

_DTime	fdb	DTime					;;Fixme was: .DTime
	fcb	6
	fdb	_PWor		;* Workers
	fcb	14
	fdb	_PWar		;* Warriors
	fcb	3
	fdb	_PPl5		;* Plan5's
	fcb	$7F
	fdb	_WAgg		;* Warrior aggression
	fcb	0
	PAD	.DTi,10					;;(Not sure what this padding was for)

_PWor	fdb	Pop+1					;;Fixme was: .PWor
	fcb	0

_PWar	fdb	Pop+4					;;Fixme was: .PWar
	fcb	0

_PPl5	fdb	Pop+13					;;Fixme was: .PPl5
	fcb	0

_Wagg	fdb	WAgg					;;Fixme was: .Wagg
	fcb	0

	PULLORG	ROMSAVE