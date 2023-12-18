;===============================================================================
; EQUs to remove later
LSSBomb	EQU	$5D2F
LSSINI	EQU	$5DBE
LSWOCR	EQU	$5D6A
;===============================================================================

	ORG	ROMSAV
;*****
;*
;* LEAVESECTOR
;*
;* Needs:
;*	Y -> scanner workspace of object leaving sector
;*	U -> characteristics descriptor of object leaving sector
;*
;* Returns:
;*	Nothing
;*
;*****
LeaveSector
	pshs	X		;* Save work register	
	leax	Y		;* Y -> scanner workspace of object
	jsr	[OKiVec,U]	;* Kill object
	puls	X,PC		;* Restore work register and return

;	PULLORG	ROMSAV
ROMSAV	SET	*

;* player ship
	ORG	CPLAYER+OLSVEC
	FDB	TRAP			;vector to leave-sector routine
;	PULLORG
;* planetoid 1
	ORG	CPLAN1+OLSVEC
	FDB	LeaveSector		;vector to leave-sector routine
;	PULLORG
;* planetoid 2
	ORG	CPLAN2+OLSVEC
	FDB	LeaveSector		;vector to leave-sector routine
;	PULLORG
;* planetoid 3
	ORG	CPLAN3+OLSVEC
	FDB	LeaveSector		;vector to leave-sector routine
;	PULLORG
;* planetoid 4
	ORG	CPLAN4+OLSVEC
	FDB	LeaveSector		;vector to leave-sector routine
;	PULLORG
;* planetoid 5
	ORG	CPLAN5+OLSVEC
	FDB	LeaveSector		;vector to leave-sector routine
;	PULLORG
;*sinibomb
	ORG	CSBOMB+OLSVEC
	FDB	LSSBomb			;vector to leave-sector routine
;	PULLORG
;* worker
	ORG	CWORKER+OLSVEC
	FDB	LeaveSector		;vector to leave-sector routine
;	PULLORG
;* warrior
	ORG	CWARRIO+OLSVEC
	FDB	LeaveSector		;vector to leave-sector routine
;	PULLORG
;* sinistar
	ORG	CSINI+OLSVEC
	FDB	LSSini			;vector to leave-sector routine
;	PULLORG
;* crystal
	ORG	CCRYSTA+OLSVEC
	FDB	LeaveSector		;vector to leave-sector routine
;	PULLORG
;* worker with crystal
	ORG	CWORKCR+OLSVEC
	FDB	LSWoCr			;vector to leave-sector routine
;	PULLORG
;* sinistar piece
	ORG	CPIECE+OLSVEC
	FDB	LeaveSector		;vector to leave-sector routine
;	PULLORG

;	INCLVER	RICH,lssbomb		;* Sinibomb leaving sector
;	INCLVER	RICH,lswocr		;* Worker with crystal leaving sector
;	INCLVER	RICH,lssini		;* Sinistar leaving sector