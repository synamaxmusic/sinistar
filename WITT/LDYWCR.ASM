        PUSHORG ROMSAVE
;*****
;*
;* LDYWCR
;*      The entomology is amusing.  This routine replaces the 6809
;*      instruction "LDY [OSCWCR,Y]" which provides the object's caller's
;*      scanner workspace address.  Now, instead, the returned workspace
;*      is dependant on the object's type or circumstance as shown below.
;*
;* Needed:
;*      Y -> scanner workspace of object acting as a callee.
;*
;* Returns:
;*      Y -> (psuedo) caller's scanner workspace.
;*
;*        Workspace returned | When object/condition is:
;*      ---------------------+--------------------------
;*      Caller's workspace   | for a real callee (worker/warrior).
;*      Player's workspace   | for SINISTAR acting as a callee.
;*      Sinistar's workspace | for SINIBOMB acting as a callee.
;*
;*****
        ROUTINE LdyWCR
        pshs    U               ;* Save work register
        ldu     OSCHAR,Y        ;* Determine the kind of craft.
        cmpu    #CSBomb         ;* If it is a sinibomb
        beq     .1S             ;*   then it is 'called' by the Sinistar.
        cmpu    #CSini          ;* If it is the Sinistar
        beq     .2S             ;*   then it is 'called' by the Player.
        ldy     [OSCWCR,Y]      ;* Return Y -> caller of callee.
        puls    U,PC
.1S     ldy     [SinIndex]      ;* Return Y -> caller of sinibomb.
        puls    U,PC
.2S     ldy     [PlaIndex]      ;* Return Y -> caller of Sinistar.
        puls    U,PC

        PULLORG ROMSAVE