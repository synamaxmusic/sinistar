;	INCLVER	RICH,table		;* ORG Macro

	ORG	ROMSAV
	
	RADIX	10
	
;	TABLE	stblheavy		;* Workers with crystals
stblheavy
	fdb	(1536),(65<<4),asrd3
	fdb	(0048),($0240),asrd4
	fdb	(0032),($0200),asrd3
	fdb	(0008),($0100),asrd2
	fdb	(0000),($0080),asrd1
;	PAD	(9.-((*-stblheavy)/OSTBLZ))*OSTBLZ	;* Pad entries
	RMB	(9-((*-stblheavy)/OSTBLZ))*OSTBLZ
;	ENDTBL

	RADIX	16
	
;	PULLORG	ROMSAVE
ROMSAV	SET	*