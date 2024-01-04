;	INCLVER	RICH,table			;* ORG Macro

	PUSHORG	ROMSAVE
;***
;*	Worker in orbit. (TASKLIST 8 and 16) Tuned for old distance routines.
;***

	RADIX	10

;	TABLE	stblworker
stblworker
	fdb	(1536<<2),(65<<4),asrd3				;;Fixme was: fdb	(1536.!<2),(65.!<4),asrd3
	fdb	(0800<<2),(42<<4),asrd2                         ;;Fixme was: fdb	(0800.!<2),(42.!<4),asrd2
	fdb	(0384<<2),(25<<4),asrd1                         ;;Fixme was: fdb	(0384.!<2),(25.!<4),asrd1
	fdb	(0320<<2),(24<<4),asrd1                         ;;Fixme was: fdb	(0320.!<2),(24.!<4),asrd1
	fdb	(0256<<2),(22<<4),asrd1                         ;;Fixme was: fdb	(0256.!<2),(22.!<4),asrd1
	fdb	(0192<<2),(18<<4),asrd1                         ;;Fixme was: fdb	(0192.!<2),(18.!<4),asrd1
	fdb	(0128<<2),(12<<4),asrd1                         ;;Fixme was: fdb	(0128.!<2),(12.!<4),asrd1
	fdb	(0064<<2),(07<<4),asrd3                         ;;Fixme was: fdb	(0064.!<2),(07.!<4),asrd3
	fdb	(0000<<2),(03<<4),asrd4                         ;;Fixme was: fdb	(0000.!<2),(03.!<4),asrd4
;	PAD	(10-((*-stblworker)/OSTBLZ))*OSTBLZ	;* Pad entries
	RMB	(10-((*-stblworker)/OSTBLZ))*OSTBLZ
;	ENDTBL

	RADIX	16

	PULLORG	ROMSAVE