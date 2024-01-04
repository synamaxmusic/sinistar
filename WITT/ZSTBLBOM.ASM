;	INCLVER	RICH,table			;* ORG Macro

	PUSHORG	ROMSAVE

	RADIX	10

;***
;*	Psuedo Warrior bombing in orbit. (TASKLIST 8/16)
;***
;	TABLE	stblbomber
stblbomber
	fdb	($7FFF),($1FFF),asrd3
	fdb	(0100),($00E8),asrd2            ;;Fixme was: fdb	(0100.),($00E8),asrd2 
	fdb	(0064),($00A0),asrd0            ;;Fixme was: fdb	(0064.),($00A0),asrd0 
	fdb	(0032),($0070),asrd0            ;;Fixme was: fdb	(0032.),($0070),asrd0 
	fdb	(0016),($0040),asrd1            ;;Fixme was: fdb	(0016.),($0040),asrd1 
	fdb	(0000),($0000),asrd2            ;;Fixme was: fdb	(0000.),($0000),asrd2 
;	ENDTBL

	RADIX	16
	
	PULLORG	ROMSAVE
