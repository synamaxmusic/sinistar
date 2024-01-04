;; Original file name is labled as STBLOSIN, not STBL0SIN

;	INCLVER	RICH,table			* ORG Macro

	PUSHORG	ROMSAVE
;***
;*	New Sinistar orbital approach!
;***

	RADIX	10

;	TABLE	STblOSini
STblOSini
	fdb	($7FFF),($1FFF),asrd3
	fdb	(0100),($0200),asrd4			;;Fixme was: fdb	(0100.),($0200),asrd4
	fdb	(0048),($01C0),asrd3                    ;;Fixme was: fdb	(0048.),($01C0),asrd3
	fdb	(0040),($0170),asrd3                    ;;Fixme was: fdb	(0040.),($0170),asrd3
	fdb	(0032),($0148),asrd3                    ;;Fixme was: fdb	(0032.),($0148),asrd3
	fdb	(0024),($00F8),asrd2                    ;;Fixme was: fdb	(0024.),($00F8),asrd2
	fdb	(0016),($0080),asrd2                    ;;Fixme was: fdb	(0016.),($0080),asrd2
	fdb	(0008),($0030),asrd1                    ;;Fixme was: fdb	(0008.),($0030),asrd1
	fdb	(0004),($0000),asrd1                    ;;Fixme was: fdb	(0004.),($0000),asrd1
	fdb	(0000),($0000),asrd0                    ;;Fixme was: fdb	(0000.),($0000),asrd0
;	ENDTBL

	RADIX	16

	PULLORG	ROMSAVE