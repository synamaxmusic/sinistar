	INCLUDE "../SAM/START.ASM"

ODYNFIX	EQU	$2		;  Fix for incorrect OINDEX value.
				;  Using ODYNOVH was giving OINDEX
				;  $FFFC, but $FFFE shows up in
				;  the EQU files instead.
	
	;SUBTTL	SAM'S EQUATES
	
SAMEQUATES
;* assembly flags and counters
TRUE	SET	-1		;  Fixme was: TRUE  EQU -1
FALSE	SET	0		;  Fixme was: FALSE EQU 0
_STMODE   SET	FALSE		;initialize tune interpreter off	;Fixme was: .$TMODE SET	FALSE
ROMSAV	SET	0		;starting address of rom	;(Renaming ROMSAVE to ROMSAV for consistency)
BASSAVE	SET	$9800		;starting address of direct page ram
RAMSAVE	SET	$9900		;starting address of extended ram
SRAMSAV	SET	$D000		;starting address of static ram
HISAV	SET	$E000		;starting address of high rom

;* hardware constants
CARRY	EQU	$1		;* The carry bit position in the CC register
DRBL	EQU	$1		;dma read block
DWBL	EQU	$2		;dma write block
DSCY	EQU	$4		;dma slow cycle
DZSP	EQU	$8		;dma zero suppression
DCNS	EQU	$10		;dma constant substitution
DTFL	EQU	$20		;dma top flavor
DXWB	EQU	$40		;dma ex-or write enable bottom pixel
DXWT	EQU	$80		;dma ex-or write enable top pixel
WDOGC	EQU	$39		;watchdog constant
DINHIB	EQU	$74		;DMA inhibit address
;PMEMCTL	EQU	$BFFF	;pseudo memory control byte	(double defined...already in MESSAGE.ASM)
;STACK	SET	0C000		;stack bottom
;	IFNDEF	ROM
STACK	SET	$C000-100	;for DCON
;	ENDIF
;CRAM	EQU	$C000		;color ram			(double defined...already in MESSEQU1.ASM)
PIA	EQU	$C800		;start of pias
;MEMCTL	EQU	$C900		;memory control byte		(double defined...already in MESSAGE.ASM)
DCTRL	EQU	$CA00		;dma status byte
DCONS	EQU	$CA01		;dma constant
DSOUR	EQU	$CA02		;dma source address
DDEST	EQU	$CA04		;dma destination address
DHIGH	EQU	$CA06		;dma height
DWIDE	EQU	$CA07		;dma width
SCNLIN	EQU	$CB00		;screen vertical line counter
;WDOG	EQU	$CBFF		;watchdog address		(double defined...already in MESSEQU1.ASM)

;* game constants
STACKAL	SET	$40		;stack allocation
FUDGE	EQU	$20		;vertical allowance for objects beam avoidance
NOBJS	EQU	$30		;number of object workspaces
NSTARS	EQU	$0A		;number of stars
NTNREPT	EQU	$4		;maximum number of tune repeat counters
ODYNOVH	EQU	$4		;dynamic memory overhead
SALLOW	EQU	$110		;extra storage allowance
;*				;(max for 1 wake or collision + max block size)
NINDEXS	EQU	$180		;maximum number of workspace indexes
BHSCROL	EQU	$8		;bottom hard scroll limit
THSCROL	EQU	$6C		;top hard scroll limit
LHSCROL	EQU	$10		;left hard scroll limit
RHSCROL	EQU	$F0		;right hard scroll limit
DAMPTIM	EQU	$40		;scroll damping time delay (in screens)
SINIHIG	EQU	$1A		;sinistar height ( bytes)
SINIWID	EQU	$31		;sinistar width ( pixels)
SINILCE	EQU	$19		;sinistar l axis center offset ( pixels)
SINISCE	EQU	$18		;sinistar s axis center offset ( pixels)
MHPIECE	EQU	$10		;maximum height of sinistar piece
NCOLLIS	EQU	$0B		;number of collision types