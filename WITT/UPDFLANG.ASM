        PUSHORG ROMSAVE
;*****
;*
;* UPDFLANG
;*      Update angle of flight ("FLight ANGle") towards target.
;*
;* Call levels:
;*      AimFlAng
;*              Rectang
;*
;* History:
;*      Before V13 was released, this routine incorporated the AIMFLANG code.
;*      As a change to V13, the code that did the computations was seperated
;*      out into AIMFLANG for use by other external routines.
;*
;*      As a change to V13, the B register is now saved and restored (in the
;*      new AIMFLANG routine) which was previously creamed by UPDFLANG.
;*
;* Needs:
;*      X -> scanner workspace of target
;*      Y -> scanner workspace of craft
;*
;* Returns:
;*      OSFLANG,Y - Updated to reflect current angle of the craft from target.
;*
;* Notes:
;*      The object of this routine is to return the angle at which a craft
;*      must travel from it's current position to rondevous with a target.
;*      This is done by providing the RECTANG routine with the signed distances
;*      in the long and short direction.
;*
;*      However, since the scanner coordinates are signed eight bit numbers,
;*      it is not possible to create a signed number large enough to reflect
;*      the distance across an entire sector in less than 9 bits.  Consider
;*      the diagram below in which a craft may wish to travel from point A
;*      to point B, where this distance is greater than $7F on one axis.
;*
;*      The solution is to maximize the distance in either axis to the
;*      largest positive ($7F) or negative ($80) signed 8-bit distance.
;*      This creates the path of travelling from point A to point C.
;*
;*      This path misses the target from this distance, but since the
;*      craft is in motion, it will eventually come to be less than the
;*      maximum 8-bit signed distance at some point D.  When this happens,
;*      the computations result in the correct angle from point D to point B.
;*
;*      In reality, the situation is not bad at all, since as the craft moves
;*      closer to point B, the pseudo-target point C continuously moves
;*      closer to the desired target point B.
;*
;*      +-----------------------------------------------+
;*      |       A                                       |
;*      |                                               |
;*      |               D                               |
;*      |                                               |
;*      |                                               |
;*      |                                               |
;*      |                               C ----> B       |
;*      +-----------------------------------------------+
;*
;*****
        ROUTINE updflang
        pshs    A               ;* Save work registers
        jsr     AimFlAng        ;* A = the a flight angle
        sta     OSFLANG,Y       ;*   saved for external reference.
        puls    A               ;* Restore work registers
        rts
;*****
;*
;* AIMFLANG
;*      Get angle of flight ("FLight ANGle") towards target.
;*
;* Calls:
;*      rectang - convert rectangular (long,short) coordinates to angle.
;*
;* Needs:
;*      X -> scanner workspace of target
;*      Y -> scanner workspace of craft
;*
;* Returns:
;*      A - current angle of the craft from target.
;*
;*****
        ROUTINE AimFlAng
        pshs    B               ;* Save work registers
        lda     OSLPOS,Y        ;* A = the long distance of the craft
        suba    OSLPOS,X        ;*   from the target.
        bvc     .AIM1S          ;* On overflow,                                 ;;Fixme was: bvc 1$
        pshs    CC              ;*   the distance is maximized
        lda     #$7F            ;*   to a signed 8-bit value
        puls    CC              ;*   that is the lowest or
        bgt     .AIM1S          ;*   the highest possible                       ;;Fixme was: bgt 1$
        coma                    ;*   scanner distance.
.AIM1S  ldb     OSSPOS,Y        ;* B = the short distance of the craft          ;;Fixme was: 1$ ldb  OSSPOS,Y
        subb    OSSPOS,X        ;*   from the target.
        bvc     .2S             ;* On overflow,
        pshs    CC              ;*   the distance is maximized
        ldb     #$7F            ;*   to a signed 8-bit value
        puls    CC              ;*   that is the lowest or
        bgt     .2S             ;*   the highest possible
        comb                    ;*   scanner distance.
.2S     jsr     rectang         ;* Make A = the angle of the craft's position
        puls    B               ;* Restore work registers
        rts

        PULLORG ROMSAVE