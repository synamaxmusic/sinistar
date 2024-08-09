;;      INCLUDE "../SAM/START.ASM"

        PushOrg RomSave                                                         ;;Fixme was: PushOrg RomSav
;       Local
;*
;*              Speech Calls
;*
SC1     _IPRIO  3C                                                              ;;Fixme was: .IPRIO
        _SOUND  $0D             ;* I AM SINISTAR                                ;;Fixme was: .SOUND
        _PRIO   3B                                                              ;;Fixme was: .PRIO
        _TIME   80                                                              ;;Fixme was: .TIME
        _STOP                                                                   ;;Fixme was: .STOP
;*
SC2     _IPRIO  3C
        _SOUND  $0E             ;* BEWARE, I LIVE
        _PRIO   3B
        _TIME   80
        _STOP
;*
SC3     _IPRIO  3A
        _SOUND  $0F             ;* I HUNGER
        _PRIO   3B
        _TIME   60
        _STOP
;*
SC4     _IPRIO  3A
        _SOUND  $13             ;* BEWARE, COWARD
        _PRIO   3B
        _TIME   80
        _STOP
;*
SC5     _IPRIO  3A
        _SOUND  $0B             ;* RUN, COWARD
        _PRIO   3B
        _TIME   80
        _STOP
;*
SC6     _IPRIO  3A
        _SOUND  $1D             ;* RUN**3
        _PRIO   3B
        _TIME   80
        _STOP
;*
SC7     _IPRIO  3A
        _SOUND  $06             ;* I HUNGER, COWARD
        _PRIO   3B
        _TIME   80
        _STOP
;*
SC8     _IPRIO  3A
        _SOUND  $02             ;* EEERRAAURGH!
        _PRIO   3B
        _TIME   $A0
        _STOP
;*
SC9     _IPRIO  3C
        _SOUND  $02             ;* EEERRAAURGH!
        _PRIO   3B
        _TIME   $A0
        _STOP

        PullOrg RomSave                                                         ;;Fixme was: PullOrg RomSav