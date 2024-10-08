        PUSHORG ROMSAVE
;*****
;*
;* FOLLOW
;*      Set the caller of this warrior to be the lead warrior.
;*
;* Needs:
;*      X -> scanner workspace of the lead warrior
;*      Y -> scanner workspace of the warrior which is to follow
;*
;* Returns:
;*      Warriors caller (OWSCON) changed to leader
;*      Temp+TFollow = saved actual caller.
;*
;*****
        ROUTINE Follow
        pshs    X,Y,U           ;* Save work registers
        ldy     [OSCNIN,Y]      ;* Y -> controlling intelligence task
        ldu     OWSCON,Y        ;* Save the pointer to the index of
        stu     Temp+TFollow    ;*   the calling scanner workspace.
;*
        ldx     [OSCNIN,X]      ;* X -> controlling intelligence task of leader
        ldu     OWSCON,X        ;* Pretend that the leader is really
        stu     OWSCON,Y        ;*   the caller.
        puls    X,Y,U           ;* Restore work registers
        rts
;***
;*
;***
        ROUTINE UnFollow
        pshs    Y,U             ;* Save work registers
        ldy     [OSCNIN,Y]      ;* Y -> controlling intelligence task
        ldu     Temp+TFollow    ;* Restore the pointer to the index
        stu     OWSCON,Y        ;*   the calling scanner workspace.
        puls    Y,U             ;* Restore work registers
        rts

        PULLORG ROMSAVE