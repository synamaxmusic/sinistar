;       INCLUDE [SAM]START
;       INCLVER SAM,SINISTAR.EQU

        PUSHORG ROMSAVE

;* display game over in player window
        ROUTINE GAMOVER
        DISPLAY 0               ;point to text window
        PHRASE  RED,35,GAME,OVER
        RTS

        PULLORG ROMSAVE