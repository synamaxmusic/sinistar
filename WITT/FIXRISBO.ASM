;*****
;*
;* FIXRISBomb
;*
;*      NONE of these changes affect the version sources except to patch
;*      The RISBomb value which will be corrected in a version reassembly.
;*
;*****
;       IFE     Version-17.
fixrisbom
;       SYMVER  RISBomb,$D4FE+$77C      ;* RISBomb      rmb     1+2+8+(3*5)
;*
        PUSHORG $4C99
        fdb     RISBomb+1+2     ;* First Image Descriptor
        PULLORG
;*
        PUSHORG $5118
        ldx     #RISBomb        ;* X -> RAM image information block             ;;Fixme was: 2$ ldx  #RISBomb (No need for local label here)
        PULLORG
;*
        PUSHORG $51F0
        ldx     #RISBomb+1+2
        PULLORG
;*
        PUSHORG $51FB
        ldu     #RISBomb+1+2+8
        PULLORG
;*
        PUSHORG $5208
        ldx     #RISBomb+1      ;* X -> RAM image descriptor block
        PULLORG

;       ENDIF   Version-17.