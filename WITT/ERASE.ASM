	ORG	ROMSAV
;*****
;*
;* ERASE
;*	This is a process routine which is awoken every second to clear
;*	messages off the display.
;*
;* Needs:
;*	MesgTime = +N for a message posted that should live for N seconds.
;*		    0 for a message posted to be immediately cleared.
;*		   -1 for no messages and a clear display.
;*
;* Returns:
;*	MesgTime = N-1 for a message posted that should live for N-1 seconds.
;*		    0 for a message posted that will be cleared next awakening.
;*		   -1 for no messages and a clear display.
;*
;*****
;	ROUTINE	Erase
Erase	tst	MesgTim		;* If there are no messages and they have all
	blt	.1S		;*   been erased, then exit.
	dec	MesgTim		;* If there was a message
	bge	.1S		;*   leave it alone one time
	jsr	dispe		;*   and erase it the next.
.1S	SLEEP	LOOP

;	PULLORG	ROMSAVE
ROMSAV	SET	*

;	INCLVER	RICH,disp		;* Message to player positioning
;	INCLVER	RICH,dispe		;* Message to player erasing