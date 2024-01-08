;	INCLUDE	[SAM]START
;	INCLVER	SAM,SINISTAR.EQU

;* player ship
	PUSHORG	CPLAYER
	FDB	M_PLAYER	;collision mask					;;Fixme was: FDB	MPLAYER
	FDB	4000>>L_PLAYER	;my collision type				;;Fixme was: FDB	4000!>LPLAYER
	FCB	L_PLAYER	;collision type					;;Fixme was: FCB	LPLAYER
	FDB	IRPlay		;* Vector to initialization routine
	FDB	KRPlay		;* Vector to killing routine
	PULLORG
;* planetoid 1
	PUSHORG	CPLAN1
	FDB	M_PLANET	;collision mask					;;Fixme was: FDB	MPLANET
	FDB	4000>>L_PLANET	;my collision type				;;Fixme was: FDB	4000!>LPLANET
	FCB	L_PLANET	;collision mask					;;Fixme was: FCB	LPLANET
	FDB	IRPl1		;* Vector to initialization routine
	FDB	KRPl1		;* Vector to killing routine
	PULLORG
	PUSHORG	CPLAN1+OOFFSCR
	FDB	VibOff		;offscreen routine
	PULLORG
;* planetoid 2
	PUSHORG	CPLAN2
	FDB	M_PLANET	;collision mask					;;Fixme was: FDB	MPLANET
	FDB	4000>>L_PLANET	;my collision type				;;Fixme was: FDB	4000!>LPLANET
	FCB	L_PLANET	;collision mask					;;Fixme was: FCB	LPLANET
	FDB	IRPl2		;* Vector to initialization routine
	FDB	KRPl2		;* Vector to killing routine
	PULLORG
	PUSHORG	CPLAN2+OOFFSCR
	FDB	VibOff		;offscreen routine
	PULLORG
;* planetoid 3
	PUSHORG	CPLAN3
	FDB	M_PLANET	;collision mask					;;Fixme was: FDB	MPLANET
	FDB	4000>>L_PLANET	;my collision type				;;Fixme was: FDB	4000!>LPLANET
	FCB	L_PLANET	;collision mask					;;Fixme was: FCB	LPLANET
	FDB	IRPl3		;* Vector to initialization routine
	FDB	KRPl3		;* Vector to killing routine
	PULLORG
	PUSHORG	CPLAN3+OOFFSCR
	FDB	VibOff		;offscreen routine
	PULLORG
;* planetoid 4
	PUSHORG	CPLAN4
	FDB	M_PLANET	;collision mask					;;Fixme was: FDB	MPLANET
	FDB	4000>>L_PLANET	;my collision type				;;Fixme was: FDB	4000!>LPLANET
	FCB	L_PLANET	;collision mask					;;Fixme was: FCB	LPLANET
	FDB	IRPl4		;* Vector to initialization routine
	FDB	KRPl4		;* Vector to killing routine
	PULLORG
	PUSHORG	CPLAN4+OOFFSCR
	FDB	VibOff		;offscreen routine
	PULLORG
;* planetoid 5
	PUSHORG	CPLAN5
	FDB	M_PLANET	;collision mask					;;Fixme was: FDB	MPLANET
	FDB	4000>>L_PLANET	;my collision type				;;Fixme was: FDB	4000!>LPLANET
	FCB	L_PLANET	;collision mask					;;Fixme was: FCB	LPLANET
	FDB	IRPl5		;* Vector to initialization routine
	FDB	KRPl5		;* Vector to killing routine
	PULLORG
	PUSHORG	CPLAN5+OOFFSCR
	FDB	VibOff		;offscreen routine
	PULLORG
;* sinibomb
	PUSHORG	CSBOMB
	FDB	M_SBOMB		;collision mask					;;Fixme was: FDB	MSBOMB		
	FDB	4000>>L_SBOMB	;my collision type				;;Fixme was: FDB	4000!>LSBOMB
	FCB	L_SBOMB		;collision type					;;Fixme was: FCB	LSBOMB
	FDB	IRSBomb		;* Vector to initialization routine
	FDB	KRSBomb		;* Vector to killing routine
	PULLORG
	Pushorg	CSBomb+OCDInd
	fdb	DeathFlag
	PullOrg
;* worker
	PUSHORG	CWORKER
	FDB	M_WORKER	;collision mask					;;Fixme was: FDB	MWORKER
	FDB	4000>>L_WORKER	;my collision type				;;Fixme was: FDB	4000!>LWORKER
	FCB	L_WORKER	;collision type					;;Fixme was: FCB	LWORKER
	FDB	IRWork		;* Vector to initialization routine
	FDB	KRWorker	;* Vector to killing routine			;;Fixme was: FDB	KRWork
	PULLORG
;* warrior
	PUSHORG	CWARRIO
	FDB	M_WARRIOR	;collision mask					;;Fixme was: FDB	MWARRIO
	FDB	4000>>L_WARRIOR	;my collision type				;;Fixme was: FDB	4000!>LWARRIO
	FCB	L_WARRIOR	;collision type					;;Fixme was: FCB	LWARRIO	
	FDB	IRWarr		;* Vector to initialization routine
	FDB	KRWarr		;* Vector to killing routine
	PULLORG
;* sinistar
	PUSHORG	CSINI
	FDB	M_SINI		;collision mask					;;Fixme was: FDB	MSINI
	FDB	4000>>L_SINI	;my collision type				;;Fixme was: FDB	4000!>LSINI
	FCB	L_SINI		;collision type					;;Fixme was: FCB	LSINI
	FDB	IRSini		;* Vector to initialization routine
	FDB	KRSini		;* Vector to killing routine
	PULLORG
	PUSHORG	CSINI+OOFFSCR
	FDB	VibOff		;offscreen routine
	PULLORG
;* player shot
	PUSHORG	CPLSHOT
	FDB	M_PLSHOT	;collision mask					;;Fixme was: FDB	MPLSHOT	
	FDB	4000>>L_PLSHOT	;my collision type				;;Fixme was: FDB	4000!>LPLSHOT
	FCB	L_PLSHOT	;collision type					;;Fixme was: FCB	LPLSHOT
	PULLORG
;* warrior shot
	PUSHORG	CWARSHOT							;;Fixme was: PUSHORG	CWARSH
	FDB	M_WASHOT	;collision mask					;;Fixme was: FDB	MWASHO
	FDB	4000>>L_WASHOT	;my collision type				;;Fixme was: FDB	4000!>LWASHO
	FCB	L_WASHOT	;collision type					;;Fixme was: FCB	LWASHO
	PULLORG
;* crystal
	PUSHORG	CCRYSTA
	FDB	M_CRYSTAL	;collision mask					;;Fixme was: FDB	MCRYSTA
	FDB	4000>>L_CRYSTAL	;my collision type				;;Fixme was: FDB	4000!>LCRYSTA
	FCB	L_CRYSTAL	;collision type					;;Fixme was: FCB	LCRYSTA
	FDB	IRCrys		;* Vector to initialization routine
	FDB	KRCrys		;* Vector to killing routine
	PULLORG
;* worker with crystal
	PUSHORG	CWORKCR
	FDB	M_WORKCR	;collision mask					;;Fixme was: FDB	MWORKCR
	FDB	4000>>L_WORKCR	;my collision type				;;Fixme was: FDB	4000!>LWORKCR
	FCB	L_WORKCR	;collision type					;;Fixme was: FCB	LWORKCR
	FDB	IRWoCr		;* Vector to initialization routine
	FDB	KRWoCr		;* Vector to killing routine
	PULLORG

;* make sure no fragments when piece explodes
	PUSHORG	CPIECE
	FDB	M_Fragment	;collision mask					;;Fixme was: FDB	MFragment
	FDB	4000>>L_Fragment;my collision type bit				;;Fixme was: FDB	4000!>LFragment
	FCB	L_Fragment	;collision type					;;Fixme was: FCB	LFragment
	FDB	TRAP		;* Vector to initialization routine
	FDB	KRPiec		;* Vector to killing routine
	PULLORG
	PUSHORG	CPIECE+OONSCR
	FDB	SPiecOn		;onscreen routine
	PULLORG
	PushOrg	CPiece+OPFrag
	fcb	0		;* No fragments when a piece explodes
	PullOrg

	PUSHORG	CFragment
	FDB	M_Fragment	;collision mask					;;Fixme was: FDB	MFragment
	FDB	4000>>L_Fragment;my collision type bit				;;Fixme was: FDB	4000!>LFragment
	FCB	L_Fragment	;collision type					;;Fixme was: FCB	LFragment
	FDB	TRAP		;* Vector to initialization routine
	FDB	TRAP		;* Vector to killing routine
	FCB	0		;object mass
	FDB	IPLSHOT		;first image descriptor
	FDB	KOBJECT		;offscreen routine
	PULLORG