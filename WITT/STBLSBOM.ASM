;	INCLVER	RICH,table			;* ORG Macro

	PUSHORG	ROMSAVE

;	TABLE	stblsbomb
stblsbomb SET	*						;; I used SET * here because the label name is slightly longer than usual
	
	RADIX 	10
	
	fdb	(4000),($7FFF),asrd3				;;Fixme was: fdb	(4000.),($7FFF),asrd3
	fdb	(512),($1100),asrd4                             ;;Fixme was: fdb	(512.),($1100),asrd4 
	fdb	(128),($0600),asrd3                             ;;Fixme was: fdb	(128.),($0600),asrd3 
	fdb	(064),($0400),asrd3                             ;;Fixme was: fdb	(064.),($0400),asrd3 
	fdb	(032),($0200),asrd3                             ;;Fixme was: fdb	(032.),($0200),asrd3 
	fdb	(016),($0100),asrd2                             ;;Fixme was: fdb	(016.),($0100),asrd2 
	fdb	(008),($00C0),asrd1                             ;;Fixme was: fdb	(008.),($00C0),asrd1 
	fdb	(000),($0040),asrd0                             ;;Fixme was: fdb	(000.),($0040),asrd0 
;	PAD	(8-((*-stblsbomb)/OSTBLZ))*OSTBLZ	;* Pad entries
	RMB	(8-((*-stblsbomb)/OSTBLZ))*OSTBLZ
;	ENDTBL

	RADIX	16

	PULLORG	ROMSAVE