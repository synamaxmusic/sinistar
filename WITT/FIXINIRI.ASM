;       IFE     Version-17.
fixinirich
        PUSHORG $5282
        lda     #%00111011      ;* To check Sinibomb button during demo.
        PULLORG
;*
        PUSHORG $5286
        RADIX   10                                                                      ;;(more decimal values)
        ldd     #(60*60)        ;* 60 seconds not 45 for the max demo length.           ;;Fixme was: ldd  #(60.*60.)
        RADIX   16                                                                      ;;(return to hex)
        PULLORG
;*
        PUSHORG ROMSAVE                                                                 ;;($8E5E)
        VECTOR  PowVect
        clr     WECheck         ;* To reset court check.
        rts
        PULLORG ROMSAVE
;*
;       ENDIF   Version-17.