;	INCLVER	RICH,table			;* ORG Macro

	PUSHORG	ROMSAVE

	RADIX	10

;	TABLE	STBLSinistar
STBLSinistar
	fdb	($7FFF),($07FF),asrd5		;;Fixme was: fdb	($7FFF),($07FF),asrd5
	fdb	(4000),($2000>>1),asrd4         ;;Fixme was: fdb	(4000.),($2000!>1),asrd4
	fdb	(1024),($0100>>1),asrd1         ;;Fixme was: fdb	(1024.),($0100!>1),asrd1
	fdb	(0600),($0280>>1),asrd5         ;;Fixme was: fdb	(0600.),($0280!>1),asrd5
	fdb	(0080),($0200>>1),asrd3         ;;Fixme was: fdb	(0080.),($0200!>1),asrd3
	fdb	(0064),($0180>>1),asrd4         ;;Fixme was: fdb	(0064.),($0180!>1),asrd4
	fdb	(0032),($0100>>1),asrd4         ;;Fixme was: fdb	(0032.),($0100!>1),asrd4
	fdb	(0016),($00C0>>1),asrd3         ;;Fixme was: fdb	(0016.),($00C0!>1),asrd3
	fdb	(0000),($0080>>1),asrd2         ;;Fixme was: fdb	(0000.),($0080!>1),asrd2
;	ENDTBL

	RADIX	16
	
	PULLORG	ROMSAVE
	
	
	
	
	
	
	
	
	
	