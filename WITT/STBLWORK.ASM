;	INCLVER	RICH,table			;* ORG Macro

	ORG	ROMSAV
;***
;*	Worker in orbit. (TASKLIST 8 and 16) Tuned for old distance routines.
;***

	RADIX	10

;	TABLE	stblworker
stblworker
	fdb	(1536<<2),(65<<4),asrd3
	fdb	(0800<<2),(42<<4),asrd2
	fdb	(0384<<2),(25<<4),asrd1
	fdb	(0320<<2),(24<<4),asrd1
	fdb	(0256<<2),(22<<4),asrd1
	fdb	(0192<<2),(18<<4),asrd1
	fdb	(0128<<2),(12<<4),asrd1
	fdb	(0064<<2),(07<<4),asrd3
	fdb	(0000<<2),(03<<4),asrd4
;	PAD	(10.-((*-stblworker)/OSTBLZ))*OSTBLZ	;* Pad entries
	RMB	(10-((*-stblworker)/OSTBLZ))*OSTBLZ
;	ENDTBL

	RADIX	16

;	PULLORG	ROMSAVE

;;;;;;;;;;;;;;;;
CR6SAVE	SET	*									;; We are now pass ROM address $6000, let's add a copyright message
CR6	fcc	"COPYRIGHT 1983 WILLIAMS ELECTRONICS, INC."
;;;;;;;;;;;;;;;;

ROMSAV	SET	*