        PUSHORG ROMSAVE
;*****
;*
;* GETLVX - Get the LONG  velocity of the craft.
;* GETSVX - Get the SHORT velocity of the craft.
;*
;* Needs:
;*      X -> scanner workspace of the craft.
;*
;* Returns:
;*      D =  The 16-bit signed velocity (most significant byte = pixels/frame)
;*
;*****
        ROUTINE GetLVX
        pshs    U               ;* Save work registers
        ldu     OSSCWSA,X       ;* If the target is not on screen,
        beq     .10S            ;*   then scanner velocities are good enough.
;***
;*      Screen velocity computation
;***
        ldd     OLVEL,U         ;* Get the LONG screen velocity of the object.
        bra     .99S            ;* Return the LONG distance.
;***
;*      Scanner velocity computation
;***
.10S    nop
        lda     OSLVEL,X        ;* Get the LONG scanner
        clrb                    ;*   velocity of the object
        RPT     1,asra,rorb     ;*   scaled down to pixels/frame (in MSByte).
.99S    puls    U               ;* Restore work registers
        rts
;***
;*
;***
        ROUTINE GetSVX
        pshs    U               ;* Save work registers
        ldu     OSSCWSA,X       ;* If the target is not on screen,
        beq     .10S            ;*   then scanner velocities are good enough.
;***
;*      Screen velocity computation
;***
        ldd     OLVEL,U         ;* Get the LONG screen velocity of the object.
        bra     .99S            ;* Return the SHORT distance.
;***
;*      Scanner velocity computation
;***
.10S    nop
        lda     OSSVEL,X        ;* Get the SHORT scanner
        clrb                    ;*   velocity of the object
        RPT     1,asra,rorb     ;*   scaled down to pixels/frame (in MSByte).
.99S    puls    U               ;* Restore work registers
        rts

        PULLORG ROMSAVE