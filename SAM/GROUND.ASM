	ORG 0

;* end of grounded intelligence lists
Ground	fdb	Ground		;* Points to itself for indirect use
;*
	JMP	INITALL		;starts at address 2
;* dummy last object workspace
;	RPT	OLEFT-*,<FCB 0>
;	FCB	-1
;	IFN	*-DSPACE
;	ERRMESS	"DUMMY WORKSPACE SIZE ERROR"
;	ENDIF
	FDB $00FF			;;This is originally created by the macro
					;;above, but this is just a lot easier
					;;to implement with FDB.