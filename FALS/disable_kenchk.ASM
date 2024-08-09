;;===============================================================================
;;
;;   Assembling up to Noah's module results in triggering the copyright protection.
;;   The scanner "fins" and score will be drawn on screen but the game won't start.
;;   Include this code to make the incomplete game playable.
;;
;;   This can also be useful for modding the game since KenChk is made to produce
;;   unwanted issues when checksums don't match up.
;;
;;   It probably goes without saying that you shouldn't include this code if you're
;;   trying to build the original ROM.
;;
;;===============================================================================

        PUSHORG ROMSAVE
        VECTOR  POWVECT
;       SYMVER  KENCHK,KENCHK
        clr     KENCHK
        rts
        VECTOR  IniVect
        clr     KenChk
        rts
        PULLORG ROMSAVE
;       SYMVER  ZAPSIN,ZAPSini
        PUSHORG ZAPSini         ;* In the PowVect routine, ignore the
        tst     $0              ;*   copyright violation test routine.
        PULLORG