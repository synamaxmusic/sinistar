;	INCLVER	RICH,table			;* ORG Macro

	PUSHORG	ROMSAVE
;***
;*	Single warrior pilot attack plan #1.
;*	Track and intercept target.
;*	Tuned for revised distance calculations.
;***

	RADIX	10

;	TABLE	stblW1
stblW1
	fdb	($7FFF),($0FFF),asrd3		;;Fixme was: fdb	($7FFF),($0FFF),asrd3
	fdb	(0512),($0450),asrd4            ;;Fixme was: fdb	(0512.),($0450),asrd4
	fdb	(0256),($03C5),asrd4            ;;Fixme was: fdb	(0256.),($03C5),asrd4
	fdb	(0128),($0320),asrd3            ;;Fixme was: fdb	(0128.),($0320),asrd3
	fdb	(0064),($0200),asrd3            ;;Fixme was: fdb	(0064.),($0200),asrd3
	fdb	(0032),($0180),asrd2            ;;Fixme was: fdb	(0032.),($0180),asrd2
	fdb	(0016),($00E0),asrd2            ;;Fixme was: fdb	(0016.),($00E0),asrd2
	fdb	(0000),($0090),asrd1            ;;Fixme was: fdb	(0000.),($0090),asrd1
;	ENDTBL

	RADIX	16

	PULLORG	ROMSAVE