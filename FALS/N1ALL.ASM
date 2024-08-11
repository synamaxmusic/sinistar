;;===============================================================================
;;
;;  A lot of local labels had to be renamed here.  Sometimes, {AS} doesn't like
;;  the replacement labels that I've been using previously.  I noticed longer names
;;  will work so that's the current solution.  The naming scheme I chose is to
;;  abbreviate the routine/label name and add the original label number at The end.
;;
;;  For example, the local label 1$ in AddVib is now .ADDV1S
;;
; EQUs to remove later
;Vibrate        EQU     $6FDF
;VibIni EQU     $708D
;VIBNEW EQU     $709B
;VIBREV EQU     $70BF
;TosCrys        EQU     $711E
;VIBSTP EQU     $70DE
;Shatter        EQU     $7074
;PLXQUE EQU     $7C6A
;WRXQUE EQU     $7C67
;HanSolo        EQU     $7965
;DTimer EQU     $7A3C
;POPFIL EQU     $7900
;ADJPOP EQU     $78EC
;SINCON EQU     $79BB
;InWorker EQU   $7574
;PlSecIn        EQU     $7899
;CrSecIn        EQU     $77EC
;PreCal EQU     $764F
;Quota  EQU     $7A48
;PRIOS  EQU     $7A5C
;MisAss EQU     $7A52
;EPOPVL EQU     $A03C
;ScOCDT EQU     $7AA8
;RSOEND EQU     $7AB6
;DifTmr EQU     $A03F
;;===============================================================================

;       Include [Sam]Start

;       InclVer SAM,Sinistar.equ
;       InclVer RICH,Speak              * Speak macro

        PushOrg RomSave                                                         ;;Fixme was: PushOrg  RomSav
;*****
;*      VERSION 17 SINISTAR - Noah's module
;*
;*      Changes to the last version:
;*
;*      Populations tuned
;*
;*****
;       Subttl  - Pre-Noahish code
;       SubTtl  - Vibration routines
;****
;*                      PreBou - Prepares potentially vibrating object
;*                               with object WS in X for a bounce
;*                               passes vibration block back in U
;****
        Routine PreBou
        pshs    D               ;* Save them for later
        ldx     [OScan,X]       ;* Point to scanner WS of shaking thing
        ldu     OSChar,X        ;* Get characteristic descriptor
        lda     OViBas,U        ;* Get base address of vibration block
        leau    A,X             ;* Point to vibration block in scanner WS
        ldx     OSScWSA,X       ;* Point back to object workspace
        ldd     OLVel,X         ;* Get long velocity
        subd    OSLVib,U        ;* Subtract vibration (will be zero if still)
        std     OLVel,X         ;* Replace it
        ldd     OSVel,X         ;* Do the same for short direction
        subd    OSSVib,U
        std     OSVel,X
        puls    D,PC            ;* Sorry Sam and Rich
;*
;****
;*                      PosBou - Puts vibration back in object WS in X
;****
        Routine PosBou
        pshs    D,U             ;* Save them for later
        ldx     [OScan,X]       ;* Point to scanner WS of shaking thing
        ldu     OSChar,X        ;* Get characteristic descriptor
        lda     OViBas,U        ;* Get base address of vibration block
        leau    A,X             ;* Point to vibration block in scanner WS
        ldx     OSScWSA,X       ;* Point back to object workspace
        ldd     OLVel,X         ;* Get long velocity
        addd    OSLVib,U        ;* Add vibration (will be zero if still)
        std     OLVel,X         ;* Replace it
        ldd     OSVel,X         ;* Do the same for short direction
        addd    OSSVib,U
        std     OSVel,X
        puls    D,U,PC          ;* Sorry Sam and Rich


;****
;*                      AddVib - Start object vibrating or add to vibration
;*                               Assumes Object WS in X
;****

        Routine AddVib
        pshs    D,X,Y,U                 ;* Save them for duration
        ldu     OChar,X                 ;* Point to Charac. Descr. Table
        ldy     [OScan,X]               ;* See if this object
        cmpy    SinIndex                ;* Is the SiniStar
        bne     .ADDV4S                                                                 ;;Fixme was: bne  4$ (Replaced all local labels with .ADDV<#>S)
;*                              Special Add for SiniStar
        lda     #RchMax/2               ;* Extra large shake (chocolate) for him
        sta     Temp
        jmp     .ADDV5S

.ADDV4S ldb     OSPers,Y                ;* Get pseudo-mass of object
        RPT     4,lsrb                  ;* Divide it by sixteen
        bne     .ADDV6S                 ;* If it's zero
        incb                            ;* Make it one
.ADDV6S clra                            ;* Compute offset into Inverse Table
        addd    #InvTbl                 ;*
        std     Temp                    ;* Compute inverse mass
        lda     [Temp]                  ;*
        RPT     2,lsra                  ;* Scale inverse mass
        sta     Temp                    ;* Save inverse pseudo-mass in Temp
.ADDV5S lda     OViBas,U                ;* Give A offset of vibrate block
        ldu     [OScan,X]               ;* Point to scanner workspace
        leau    A,U                     ;* Point to vibrate block in scan WS
        ldd     OSVibA,U                ;* Look at pointer to intelligence
        bne     .ADDV1S                 ;* If not zero, use it
        ldd     OScan,X                 ;* Get index to scanner WS of object
        NEW_SLEEP       Task4,Vibrate,OWISLen
        std     OWSCon,X
        ldx     OIndex,X                ;* Get index to intelligence
        stx     OSVibA,U                ;* Save it as vibration intel. address
.ADDV1S lda     OSRcht,U                ;* Get current Richter scale
        cmpa    #RchMax                 ;* See if it is over maximum
        bge     .ADDV2S                 ;* If so don't bother increasing

        adda    Temp                    ;* Add degree of vibration for this mass
        sta     OSRcht,U                ;* And store it
.ADDV2S puls    D,X,Y,U
        rts


;*
;* vibrating object off screen
VIBOFF  LEAX    Y               ;get object workspace in X
        JSR     PreBou          ;kill vibration - returns vib block in U
        clrd                    ;* Noah strikes again
        std     OSLVib,U        ;* zero long vibration
        std     OSSVib,U        ;* zero short vibration
        JMP     SCROFF

;******
;*              GivCrys - Gives a crystal to a worker with scanner WS in X
;******
        Routine GivCrys
        pshs    D               ;* Save it from tampering
        ldd     OSScWSA,X       ;* Get on screen WS address
        beq     .GIVC1S         ;* Skip this section if off screen
;*
        pshs    X               ;* Worker on screen, save scanner WS
        ldx     OSScWSA,X       ;* Point to on screen address
        ldd     #DCryWor        ;* Get new draw routine vector
        std     OPDrwVe,X       ;* Update screen object data
        ldd     #CWorkCr        ;* New characteristic descriptor
        std     OChar,X         ;* Added to object WS
        puls    X               ;* Restore scanner WS
;*
.GIVC1S ldd     #CWorkCr        ;* New characteristic descriptor
        std     OSChar,X        ;* Added to scanner WS
        ldd     SinIndex        ;* Get index to SiniStar
        std     OScWCR,X        ;* This is new caller
        lda     #OMWoCrystal    ;* Give mission of Sinterception with crystal           ;;Fixme was: lda  #OMWoCrys
        sta     OSMis,X         ;* To WorkerCr

;*      lda     #SintrP         ;* Put SiniStar Intercept Priority
;*                      SAM - please remove the next line, uncomment
;*                      the previous, and change the equate of SintrP
;*                      to SintrP       equ     $FF
        lda     #$FF
;*
        sta     OCalPri,X       ;* In calling priority of this worker
        puls    D
        rts

;********
;*              VIBRATE
;*
;*      Shakes things around based on their Richter scale
;*
;*      This routine is set up as a sleep task by GoVib routine
;*      The Richter scale is a one byte value that ranges from zero
;*      to RchMax (and slightly above and below, but is quickly corrected
;*      to zero (vibration stops when negative, planet shatters when over
;*      maximum)).
;*
;********

Vibrate pshs    Y                       ;* Save workspace for exit
        jsr     VibIni                  ;* Load registers for vibration
        beq     .5S                     ;* If offscreen, damp vibration
.4S     jsr     VibNew                  ;* Generate and start new vibration
        puls    Y                       ;* Restore pointer to sleep task
        Sleep   HERE                    ;* Let it move first leg
;*
        pshs    Y                       ;* Save workspace for exit
        jsr     VibIni                  ;* Load registers for vibration
        beq     .5S                     ;* If offscreen, damp vibration
        jsr     VibRev                  ;* Reverse the course of vibration
        puls    Y                       ;* Restore pointer to sleep task
        Sleep   HERE                    ;* Let it move back to origin
;*
        pshs    Y                       ;* Save workspace for exit
        jsr     VibIni                  ;* Load registers for vibration
        beq     .5S                     ;* If offscreen, damp vibration
        jsr     TosCrys                 ;* Else try and toss off a crystal
;*
        jsr     VibStp                  ;* Stop current vibration

;*
;*                      Damp Richter scale, see if we are done
;*                      Crystal tossing routine will go here
;*
        ldd     OScan,X                 ;* See if scanner index
        cmpd    SinIndex                ;* Matches the Sinistar
        beq     .10S                    ;* If so do special damping
;*
        lda     OSRcht,U                ;* Get Richter value
        suba    #VibDamp                ;* Damp it down
        sta     OSRcht,U                ;* Replace it
        cmpa    #RchMax                 ;* Is it above max?
        blt     .2S                     ;* if not, go on
;*
        jsr     Shatter                 ;* Else die off in spectacular manner
        clrd                            ;* Zero out pointer
        std     OSVibA,U                ;* From scanner WS to vib intelligence
        clr     OSRcht,U                ;* And zero richter scale
        std     OSLVib,U                ;* And long
        std     OSSVib,U                ;* And short vibrations
        puls    Y                       ;* Restore pointer to sleep task
        jmp     Die                     ;* After it has shattered, kill vibrator
;*                      Exit point
;*
;*                      Max out Richter (for sinistar only)
.10S    lda     OSRcht,U                ;* Get Richter value
        suba    #VibDamp*2              ;* Damp it down
        bvc     .11S                    ;* If we underflow
        clra                            ;* Zero it out
.11S    sta     OSRcht,U                ;* Replace it
        cmpa    #RchMax                 ;* Is it above max?
        blt     .2S                     ;* if not, go on
        lda     #RchMax                 ;* Get maximum value
        sta     OSRcht,U                ;* into scale
;*
.2S     lda     OSRcht,U                ;* Get value again
        bpl     .4S                     ;* if still positive, do another vibe
;*
.1S     clr     OSRcht,U                ;* Else zero it out
        clrd                            ;* Zero out pointer
        std     OSVibA,U                ;* From scanner WS to vib intelligence
        std     OSLVib,U                ;* And long
        std     OSSVib,U                ;* And short vibrations
        puls    Y                       ;* Restore pointer to sleep task
        jmp     Die                     ;* And kill process off
;*                      Exit point
;*
;*                              OffScreen -  damp vibration
.5S     lda     OSRcht,U
        suba    #VibDamp
        sta     OSRcht,U                ;* Damp vibration
        bmi     .1S                     ;* If negative, zero it all out
        puls    Y
        sleep   Vibrate                 ;* Else wait a little longer
;*                      Exit point

;****
;*                      Shatter - Die off appropriately
;****
Shatter pshs    D,X,U                   ;* Save them from tampering
        Tune    QBang                   ;* Make an explosion
        ldd     #$0005                  ;* Five points
        jsr     AddScore
        ldu     OChar,X                 ;* Get Char. Desc.
        ldx     [OScan,X]               ;* Point to scanner workspace
        jsr     [OKiVec,U]              ;* Kill off the caller
;*
.2S     puls    D,X,U                                                           ;;Fixme was: 2$ puls    D,X,U (is this local label unneeded?)
        rts
;*
;*
;*****
;*                      VibIni - Initialize registers for Vibrate routines
;*                               On exit, zero flag set if offscreen,
;*                               X = Object WS, U = Vib Block (in scan WS)
;*                               Y = Characteristic descriptor
;*****

VibIni  ldx     [OWSCon,Y]              ;* Point X to Scanner WS of Shakee
        ldy     OSChar,X                ;* Get characteristic descriptor
        lda     OViBas,Y                ;* Grab vibration base offset
        leau    A,X                     ;* Point U to vibration block of this WS
        ldx     OSScWSA,X               ;* Point X to Object WS (X=0 offscreen)
        rts

;*****
;*                      VibNew - Start a vibration from rest
;*****
VibNew  ldb     OSRcht,U                ;* Get Richter scale value
        clra                            ;*
        RPT     2,aslb,rola             ;* Multiply by 4
        pshs    D                       ;* Save it for later
        jsr     RndNeg                  ;* Negate it half the time
        jsr     RndScl                  ;* Scale it down by half half the time
        std     OSLVib,U                ;* This is new Long vibration rate
        addd    OLVel,X                 ;* Add it to current object velocity
        std     OLVel,X                 ;* And update that velocity
;*
        puls    D                       ;* Do the same for Short direction
        jsr     RndNeg                  ;* Negate it half the time
        jsr     RndScl                  ;* Scale it down by half half the time
        std     OSSVib,U                ;* This is new Short vibration rate
        addd    OSVel,X                 ;* Add it to current object velocity
        std     OSVel,X                 ;* And update that velocity
;*
        rts

;****
;*                      VibRev - Reverse direction of current vibration
;****

VibRev  ldd     OSLVib,U                ;* Get current long vibration
        coma                            ;* Negate D
        comb
        addd    #01
        std     OSLVib,U                ;* Save it as new vibration factor
        addd    OSLVib,U                ;* Double it in order to
        addd    OLVel,X                 ;* Subtract original twice
        std     OLVel,X                 ;* From actual velocity
;*
        ldd     OSSVib,U                ;* Get current short vibration
        coma                            ;* Negate D
        comb
        addd    #01
        std     OSSVib,U                ;* Save it as new vibration factor
        addd    OSSVib,U                ;* Double it in order to
        addd    OSVel,X                 ;* Subtract original twice
        std     OSVel,X                 ;* From actual velocity
;*
        rts

;****
;*                      VibStp - Stop current vibration
;****

VibStp  ldd     OLVel,X                 ;* Get long velocity
        subd    OSLVib,U                ;* Remove vibration factor
        std     OLVel,X                 ;* Replace it
        clr     OSLVib,U                ;* Zero vibration factor
        clr     OSLVib+1,U
;*
        ldd     OSVel,X                 ;* Get short velocity
        subd    OSSVib,U                ;* Remove vibration factor
        std     OSVel,X                 ;* Replace it
        clr     OSSVib,U                ;* Zero vibration factor
        clr     OSSVib+1,U
;*
        rts

;****
;*                      RndNeg - Negates D half the time
;****

RndNeg  pshs    A
        RANDOM  OSEED1,BYTE
        inca                            ;* Play with it to set flag randomly
        bmi     .1S
        puls    A
        jmp     .2S
.1S     puls    A
        coma                            ;* Negate D
        comb
        addd    #01
;*
.2S     rts
;****
;*                      RndScl - Scales D to 1/2 value half the time
;****

RndScl  pshs    A
        RANDOM  OSEED1,BYTE
        inca                            ;* Play with it to set flag randomly
        bmi     .1S
        puls    A
        jmp     .2S
.1S     puls    A
        asra                            ;* Shift D right
        rorb
;*
.2S     rts

;*****
;*              Toscrys - tosses crystals out - expects to be called from
;*                        within Vibrate - X = object ws of viber, U = Vib
;*                        block with L and S velocity of vibration
;*****
;*
        ROUTINE TOSCRYS
        pshs    D,X,Y           ;* Save for exit
        ldd     #CSini          ;* Compare sinistar
        cmpd    OChar,X         ;* With this object's char desc.
        beq     .1S             ;* If same, don't toss crystals
;*
;*                      See if a crystal should be tossed
;*
        lda     OSRcht,U        ;* Get vibration Richter scale
        suba    #CrProb         ;* Must exceed minimum vibration
        bls     .1S
        pshs    A               ;* Save excess
        RANDOM  OSEED1,BYTE
        cmpa    S+              ;* Probability of tossing crystal proportional
        bhi     .1S             ;  vibration above minimum Richter scale
;*
        pshs    X               ;* Save object WS for now
        ldy     [OScan,X]       ;* Get scanner WS of vibrating rock
        lda     OSPers,Y        ;* Get rock's pseudo-mass
        suba    #8              ;* Lower it
        bcc     .4S             ;* Never lower it past zero
        clra                    ;* Zero is the lowest
.4S     sta     OSPers,Y        ;* Save new pseudo-mass
        ldd     OSLPos,Y        ;* Get L and S position
        addd    #0101           ;* Offset into center of rock
        ldy     #CCrystal       ;* Point to crystal's CD
        jsr     [OInVec,Y]      ;* Initialize crystal
;*                      X now has Scanner WS of crystal
        puls    Y               ;* Put object WS of rock into Y
        ldx     OSScWSA,X       ;* Get object WS of crystal
        beq     .3S             ;* If that is offscreen, skip the rest
;*                              ;  hence offscreen crystals are motionless
;*
        ldd     OLVel,Y         ;* Then get long velocity
        subd    OSLVib,U        ;* Remove vibration effect
        std     OLVel,X         ;* Save it
        RANDOM  OSEED1,BYTE     ;* Generate a random number
        tfr     A,B             ;* Put it in low order position
        sex                     ;* Didja hear about the assembler - it had a
;*                                premature ORG-ASM
        addd    OLVel,X         ;* Add this random factor to velocity
        std     OLVel,X         ;* Replace it
;*
        ldd     OSVel,Y         ;* Do the same for short velocity
        subd    OSSVib,U        ;* Remove vibration effect
        std     OSVel,X         ;* Save it
        RANDOM  OSEED2,BYTE     ;* Generate a random number
        tfr     A,B             ;* Put it in low order position
        sex                     ;* Not bad, only microseconds later
        addd    OSVel,X         ;* Add this random factor to velocity
        std     OSVel,X         ;* Replace it
;*
.3S     lda     OSRcht,U        ;* Get richter scale
        lsra                    ;* Subtract crystal damping factor
        sta     OSRcht,U        ;* Replace it
        jmp     .2S             ;* All done
;*
.1S     jsr     Null            ;* Jug piece tossing could go here
;*      <<< Remove this if we don't use it for jug stuff eventually >>>
.2S     puls    D,X,Y
        rts

;       SubTtl  - Killing subroutines
;*
;*                      KiSubs - Killing subroutines for scanner objects
;*                               expects scanner WS in X
;*
;*                      To use for any type of object, load
;*                      its scanner WS into X, and its charac. desc. into
;*                      another index register - R in this example, then
;*                      jsr [OKiVec,R]          If you know what type of
;*                      object it is, such as Worker, you can jump directly
;*                      avoiding loading the C.D. as in
;*                      jsr KRWork              X still must have scanner WS
;*
;*              KRWork - Workers
;*
        Routine KRWorker                                                        ;;Fixme was: Routine  KRWork
        jsr     KilWor
        rts
;*
;*              KRWarr - Warriors
;*
KRWarr  jsr     KilWar
        rts
;*
;*              KRWoCr - Workers with Crystals
;*
KRWoCr  pshs    D,U
        ldd     OIndex,X                ;* Get index to scanner WS of WorkCr
        std     OScWCR,X                ;* Make it its own caller
        ldu     OSScWSA,X               ;* Point to on-screen WS
        beq     .1S                     ;* If not on screen, don't give velocity
;*
        ldd     OLVel,U                 ;* Get long screen velocity
        std     Temp                    ;* Save it for later
        ldd     OSVel,U                 ;* Do same for short velocity
        std     Temp+2
.1S     ldu     OSLPos,X                ;* Get its position
        jsr     KilWor                  ;* Kill it
        tfr     U,D                     ;* Put position in for crystal init
        addd    #0101                   ;* Offset it into center
        ldu     #CCrystal               ;* Get crystal C.D.
        jsr     [OInVec,U]              ;* Initialize a crystal where worker was
;*                              X now has scanner WS of crystal
        ldu     OSScWSA,X               ;* Get on-screen WS
        beq     .2S                     ;* If none, no velocity needed
;*
        ldd     Temp                    ;* Get long velocity of dead worker
        std     OLVel,U                 ;* Give it to crystal
        ldd     Temp+2                  ;* Do same for short velocity
        std     OSVel,U
.2S     puls    D,U
        rts
;*
;*              KRPl1 - Planet type 1
;*
KRPl1   jsr     KilVib                  ;* Kill off vibration if present
        jsr     KilNorm                 ;* Kill off the rock
        rts
;*
;*              KRPl2 - Planet type 2
;*
KRPl2   jsr     KilVib                  ;* Kill off vibration if present
        jsr     KilNorm                 ;* Kill off the rock
        rts
;*
;*              KRPl3 - Planet type 3
;*
KRPl3   jsr     KilVib                  ;* Kill off vibration if present
        jsr     KilNorm                 ;* Kill off the rock
        rts
;*
;*              KRPl4 - Planet type 4
;*
KRPl4   jsr     KilVib                  ;* Kill off vibration if present
        jsr     KilNorm                 ;* Kill off the rock
        rts
;*
;*
;*
;*              KRPl5 - Planet type 5
;*
KRPl5   pshs    D,U
        ldu     [OIWScIn,X]             ;* Get secondary intelligence WS
        ldd     #Die
        std     OExec,U                 ;* Kill it
        jsr     KilVib                  ;* Zero vibration
        jsr     KilCall                 ;* Kill it off as caller                ;;Fixme was: jsr  KilCal
        puls    D,U
        rts
;*
;*              KRCrys - Crystal
;*
        Routine KRCrys
        pshs    D,U
        ldu     [OIWScIn,X]             ;* Get secondary intelligence WS
        ldd     #Die
        std     OExec,U                 ;* Kill it
        jsr     KilCall                 ;* Kill it off as caller                ;;Fixme was: jsr  KilCal
        puls    D,U
        rts
;*
;*              KRSBomb - Sinibomb
;*
KRSBomb pshs    D,U
        ldu     [OIWScIn,X]             ;* Get secondary intelligence WS
        ldd     #Die
        std     OExec,U                 ;* Kill it
        jsr     KilCall                 ;* Kill it off as caller                ;;Fixme was: jsr  KilCal
        dec     InBombs
        puls    D,U
        rts
;*
;*              KRSini - Sinistar
;*
;*                      In Rich's stuff
;*
;*              KRPlay - Player
;*
KRPlay  jsr     KilCall                 ;* This may not work right.....         ;;Fixme was: jsr  KilCal
;*                                        It will try to kill screen image
        rts
;*
;*              KRPiec - Sinitstar Piece
;*
KRPiec  jsr     KilNorm                 ;* Kill off the piece
        rts

;*
;*
;*                      KilVib - Stops vibration (if any) with scan WS in X
;*
KilVib  pshs    D,X,Y                   ;* They all may get used...
        ldy     OSChar,X                ;* Get characteristics descriptor
        lda     OViBas,Y                ;* Get base offset of vibration block
        ldy     [A,X]                   ;* Load Y with sleep task WS of vib task
        beq     .1S                     ;* If grounded, just return
        ldd     #Die                    ;* Else make it die when it wakes up
        std     OExec,Y
.1S     puls    D,X,Y,PC                ;* Done
;       LOCAL

;********************
;*
;*              Killer routines - lobotomizes objects, then forces them
;*                                to commit suicide
;*
;*              These routines expect scanner WS address in X on entry
;********************

KilWor
        pshs    D,Y,U                   ;* Kill Worker entry point
        lda     #OWorker                ;* Get offset for worker
        jmp     ComSta                  ;* Go to common starting point
;*
KilWar
        pshs    D,Y,U                   ;* Kill Warrior entry point
        lda     #OWarrior               ;* Warrior offset
;*
ComSta  pshs    A                       ;* Save callee offset
        ldd     OSScWsA,X               ;* Look at on-screen WS address
        beq     .2S                     ;* Skip next section if not on screen
;*
;*                      Kill off On-Screen Object
;*
        pshs    X                       ;* Save scanner workspace we are killing
        tfr     D,X                     ;* Load in on-screen WS address
        jsr     ExpObj                  ;* Explode it
        ldd     #NoPost                 ;* Make sure it doesn't
        std     OPDrwVec,X              ;* Leave a crystal behind
        puls    X                       ;* And restore the scanner WS pointer
;*
.2S     ldy     [OScnIn,X]              ;* Get controlling intelligence task
        ldd     #Die                    ;* Kill it off
        std     OExec,Y                 ;* When it wakes up
        ldy     OIndex,X                ;* Get index to scanner WS
        cmpy    OScWCr,X                ;* Is this callee called by itself?
        beq     .3S                     ;* If so, don't bother to notify caller
;*
;*                      Send condolences to the caller of this craft
;*
        ldu     [OScWCr,X]              ;* Point to caller's scanner WS
        lda     ,S                      ;* Get callee type
        leay    OQuota,U                ;* Point to quota bytes
        dec     A,Y                     ;* Remove this craft from quota
        lsla                            ;* Double callee ofset for 2 byte use
        adda    #OCleLs                 ;* Point to callee list
        ldy     OIndex,X                ;* Get index of craft we are killing
        cmpy    A,U                     ;* Is it the same as the first entry?
        beq     .4S                     ;* If so, we don't have to look for him
        ldu     [A,U]                   ;* Point to first workspace
        lda     #OScSqI                 ;* And pass the offset of squadron list
        jsr     Look4Y                  ;* Then search until we find ID in Y
;*
.4S     ldy     OScSqI,X                ;* Get squadron pointer of goner
        sty     A,U                     ;* Save it in next squadron member
;*
;*                      Now De-link our callee from type list
;*
.3S     lda     ,S                      ;* Get the good old offset
        lsla                            ;* Double it for 2 byte operation
        ldu     #KeyClee                ;* Point to keystone of callees
        ldy     OIndex,X                ;* Get our callee's index
        cmpy    A,U                     ;* Is ours first in line?
        beq     .5S                     ;* If so we're all set
;*
        ldu     [A,U]                   ;* Point to first workspace in list
        lda     #OScTypt                ;* Set up correct offset                ;;Fixme was:     lda  #OScTyp
        jsr     Look4Y                  ;* Look for a match with Y
;*
.5S     ldy     OScTypt,X               ;* Get the next link from the goner     ;;Fixme was: 5$  ldy  OScTyp,X
        sty     A,U                     ;* Give it to his predecessor
        tfr     X,Y                     ;* Load in goner's scanner WS
        jsr     BumOut                  ;* Depress him to death
        leas    1,S                     ;* Remove callee offset from stack
        puls    D,Y,U                   ;* And we're all done
        rts
;       local

;***
;*                      KilCall - Kills off caller intelligent object
;***

KilCall pshs    D,Y,U

        ldu     OSChar,X        ;* Look at characteristics descriptor
        lda     OViBas,U        ;* Vibration base offset
        beq     .2S             ;* If it can't vibrate skip next section

;*                      Stop Vibration task if present

        pshs    X               ;* Save scanner WS
        ldy     [A,X]           ;* Get WS of vibrating sleep task
        ldd     #Die            ;* And if it dies when it does wake
        std     OExec,Y         ;* I pray EXEC its soul to take
        puls    X               ;* Restore scanner workspace

;*                      Kill Onscreen object

.2S     ldd     OSScWSA,X
        beq     .1S             ;* If not on screen, skip this section
        pshs    X               ;* Save scanner WS
        ldx     OSScWSA,X       ;* Get screen object WS
        ldd     OChar,X         ;* Check to see
        cmpd    #CCrystal       ;* If it is a crystal
        beq     .8S             ;* If so, kill it
        jsr     ExpObj          ;* Else explode it
        jmp     .9S
.8S     jsr     KillObj
.9S     puls    X               ;* Restore scanner workspace

;*                      Tell the slaves their master is dead

.1S     lda     #OMWoEvade      ;* This is new mission
        ldu     [OCleLs,X]      ;* Get scanner WS of first worker
        jsr     Lincoln         ;* Free the slaves
        lda     #OMWaDrift      ;* This is new mission
        ldu     [OCleLs+2,X]    ;* Get scanner WS of first warrior
        jsr     Lincoln         ;* Do it again
        ldy     [OSCOCAI,X]     ;* Get WS of controlling caller intelligence
        ldd     #Die            ;* Make it die when it wakes
        std     OExec,Y
        tfr     X,Y             ;* Set up for killing scanner workspace
        jsr     Bumout          ;* Cause scanner process to die on wakeup
        puls    D,Y,U           ;* Restore stuff
        rts


;****
;*                      Lincoln - go down squadron list freeing callees
;*                                Alters D,Y,U
;****
Lincoln pshs    A
.2S     beq     .1S             ;* If workspace is grounded, return
        lda     ,S              ;* Get mission
        sta     OSMis,U         ;* Give it new mission
        ldd     #$FFFF          ;* With faked maximum distance
        std     OScLDC,U        ;* To that caller
        lda     #1
        sta     OSSqSiz,U       ;* And a squadron size of 1
        lda     #WrstPri        ;* Get worst possible priority
        sta     OCalPri,U       ;* New calling priority
        ldd     OIndex,U        ;* Get index to this callee
        std     OScWCr,U        ;* It is its own caller
        ldy     OScSqI,U        ;* Get index to next member of squadron
        ldd     #Ground         ;* Ground out
        std     OScSqI,U        ;* That pointer
        ldu     ,Y              ;* Point to workspace of next guy
        jmp     .2S             ;* Keep going
;*
.1S     puls    A
        rts

;*****
;*                      KilNorm - Kills off scanner WS in X and screen object
;*****

;       local
KilNorm pshs    D,X
        ldd     #ScanDie                ;* Put scanner killer
        std     OExec,X                 ;* Into execution vector
        ldx     OSScWSA,X               ;* Get screen workspace
        beq     .1S                     ;* If zeroed, no screen object
        jsr     ExpObj                  ;* Explode it if there
.1S     puls    D,X,PC
;       local


;************
;*              SUBROUTINES
;************

;*                      Look4Y - searches through links in workspaces for index
;*                               value in Y.  U is first WS, A is offset of
;*                               link.  On exit U is WS with link = Y
Look4Y
        cmpy    A,U                     ;* Is this link the right one?
        beq     .1S
        ldu     [A,U]                   ;* Point to next
        jmp     Look4Y
.1S     rts

;*
;*                      BumOut - Cause WS in Y to commit suicide on wakeup
;*
Bumout
        pshs    D
        ldd     #ScanDie                ;* Get address of death code
        std     OExec,Y                 ;* New execution (how appropriate)
        puls    D,PC

;       SubTtl  - Explosion routines

;       Local
;*****
;*              EXPOBJ - Explodes object - gets object WS in X
;*****

        Routine SExpObj
        pshs    D,X,Y,U
        ldy     #$FFFF          ;* Set flag for time delay explosion
        jmp     ExEntr          ;* Go to explosion entry point

        Routine ExpObj
        pshs    D,X,Y,U
        ldy     #0              ;* Set flag for immediate explosion

        Routine ExEntr
        jsr     FragExp         ;* Toss off fragments if needed
;*
;*                      Call up Bob's special explosion routines if needed
;*
        CMPX    #WPLAYER
        BNE     .22S
        JSR     PLXQUE                  ;* START UP PLAYER EXPLOSION            ;; TAIL overwrites this instruction
        BRA     .23S
.22S    LDD     OCHAR,X
        CMPD    #CWARRIOR                                                       ;;Fixme was: CMPD  #CWARRI
        BNE     .23S
        JSR     WRXQUE                  ;* START UP WARRIOR EXPLOSION

.23S    ldd     #CExplo         ;* Give this object WS explosion charac. desc.
        std     OChar,X
        leau    ,X              ;* Transfer X over to U
        cmpy    #0              ;* See if we need a time delay
        beq     .2S             ;* If not, go do immediate explosion
;*
;*                              Delayed explosion
;*
        New_Sleep       Task8,PrePlo,OExpLen    ;* Spawn controlling task
        jmp     .3S
;*
;*                              Immediate explosion
;*
.2S     New_Sleep       Task1,PrePlo,OExpLen    ;* Spawn controlling task

        ldd     #INull          ;* Immediate explosion, nullify image right away
        std     ONiDesc,U       ;* Null new image descriptor
        ldd     #ChgObj         ;* Make sure it changes to null object
        std     ODrwVec,U       ;* Next time it wakes


.3S     stu     OSWSA,X         ;* Save object ws address for sleep task
        clr     OImNo,X         ;* So tell sleep task we are on image number 0
        dec     OImNo,X         ;* Then bring it to -1 so we START with image 0
        ldx     OIndex,X        ;* Get index to this sleep task
        stx     OScan,U         ;* Not really a scanner WS, but will do for now
        puls    D,X,Y,U
        rts
;*
;*                      PrePlo  - Precedes Plode routine, changes sleep times
;*
PrePlo  Sleep   .1S             ;* Go back to sleep for another cycle
.1S     Change_Sleep    Task4,Plode     ;* Tell it to wake at Plode

;       local
;*                      Plode   - Sleep task to control explosion
;*
        Routine Plode
        pshs    D,X,Y
        ldx     OSWSA,Y         ;* Get on-screen WS of our explosion
        lda     OImNo,Y         ;* Find out what image number we are on
        inca                    ;* Go to next
        cmpa    #4              ;* See if we are done
        bge     .1S             ;* Go die if so
        sta     OImNo,Y         ;* Else save it for next time
        ldb     #OILen          ;* Multiply image descr. length
        mul                     ;* By number of image in A
        addd    #IExplo         ;* Add this offset to first image
        std     ONIDesc,X       ;* Update screen image
        ldd     #ChgObj
        std     ODrwVec,X       ;* And tell it to change object
        puls    D,X,Y
        sleep   LOOP            ;* Sleep till next update
;*
.1S     cmpx    #WPlayer
        bne     .5S
        ldd     #INull
        std     ONiDesc,X
        ldd     #ChgObj
        std     ODrwVec,X
        jmp     .6S

.5S     jsr     KillObj         ;* Kill image off first
.6S     puls    D,X,Y
        jmp     Die             ;* Then die too
;       local

;       SubTtl  - Initialization

;*
;*              Player Initialization
;*
        Vector  PlaVect                                                         ;;Fixme was: Vector  PlaVec

        clr     SiniKills       ;* I clear it so initial rstpop is correct
        jsr     RstPop          ;* Reset population and difficulty tables

        rts
;*
;*                              Turn Initialization
;*

        Vector  IniVect                                                         ;;Fixme was: Vector  IniVec

;*                      Entry Point for Turn initialization
        ldu     #Pop
.1S     clr     ,U              ;* Zero out current number of things in sector
        leau    3,U             ;* Point to next thing
        cmpu    #Pop+21         ;* See if we are at end of list
        blt     .1S             ;* If not keep going
;*
;       local
        ldx     #Ground
        stx     KeyClee
        stx     KeyClee+2       ;* Start out the type lists empty

        ldy     #8080           ;* Load code for random positioning
        clra
        sta     Edge            ;* And set flag so they are not created on edge
        jsr     PopFil          ;* And fill the sector to match desired pop.
;* Initialize Player
        ldu     #CPlayer
        jsr     [OInvec,U]
;* Create Sinistar
        lda     #$FF
        sta     Edge            ;* On edge
        ldd     #$8080          ;* random position
        ldu     #CSini          ;* Point to Char. Descr.
        jsr     [OInVec,U]      ;* Jump to initialization subroutine

        New_Sleep       Task256,DTimer

        New_Sleep       Task0,AdjPop    ;* Start population adjuster going

        New_Sleep       Task64,SinCon   ;* Start Sinistar Hector build and taunt

;*
;*              If in Void zone (sinikill mod 4 = 0) do not have swarms
;*
;       local
        lda     SiniKills                                                       ;;Fixme was: lda  SiniKill
        beq     .SWRM1S         ;* do it on first time                          ;;Fixme was: beq  1$
        anda    #$03            ;* Mod 4
        beq     .SWRM2S                                                         ;;Fixme was: beq  2$
;*                              Start swarms

.SWRM1S New_Sleep       Task256,HanSolo

.SWRM2S nop                     ;* Probably unnecessary
;*
;       local
;       IFN     Version-Final
;       Local                   ;* Patch for Rich to add workCR at init
RicPat  lda     #0
        ldu     #CWorkCr
        sta     Temp
.1S     dec     Temp
        bmi     .2S
        jsr     [OInvec,U]      ;* Make a WorkCr
        jmp     .1S
;       ENDIF
;
.2S     rts


;       SubTtl  - Initialization Subroutines

;*                      InSubs - Initialization subroutines
;*                               Expect position in D, return index to
;*                               Scanner WS in X
;*
;*                      To call these routines, either load characteristic
;*                      descriptor of object to initialize into a register -
;*                      R in this example - load scanner position into D, and
;*                      jsr     [OInVec,R]
;*                      Or if you need only a specific characteristic object
;*                      such as workers, you can skip loading a register and
;*                      jsr     IRWork          with position in D
;*
;*              IRWork - Workers
;*
IRWork  New_Scan        CWorker         ;* Get scanner WS
        jsr     InWorker                ;* Give it Worker primary intelligence
        rts
;*
;*              IRWarr - Warriors
;*
IRWarr  New_Scan        CWarrior        ;* Get scanner WS
        jsr     InWarrior               ;* Give it Warrior primary intelligence
        rts
;*
;*              IRWoCr - Workers with Crystals
;*
IRWoCr  New_Scan        CWorkCr         ;* Get scanner WS
        jsr     InWorker                ;* Give it Worker primary intelligence
        jsr     GivCrys                 ;* Give it a crystal
        rts
;*
;*              IRPl1 - Planet type 1
;*
IRPl1   New_Scan        CPlan1          ;* Get scanner WS
        jsr     Vibzer                  ;* Zero out vibration block
        rts
;*
;*              IRPl2 - Planet type 2
;*
IRPl2   New_Scan        CPlan2          ;* Get scanner WS
        jsr     Vibzer                  ;* Zero out vibration block
        rts
;*
;*              IRPl3 - Planet type 3
;*
IRPl3   New_Scan        CPlan3          ;* Get scanner WS
        jsr     Vibzer                  ;* Zero out vibration block
        rts
;*
;*              IRPl4 - Planet type 4
;*
IRPl4   New_Scan        CPlan4          ;* Get scanner WS
        jsr     Vibzer                  ;* Zero out vibration block
        rts
;*
;*              IRPl5 - Planet type 5
;*
IRPl5   pshs    U
        New_Scan        CPlan5          ;* Get scanner WS
        pshs    X                       ;* Save scanner WS
        jsr     VibZer                  ;* Zero out vibration block
        jsr     InCaller                ;* Give it Caller primary intelligence
        New_Sleep       Task64,PlSecIn,OWISLen  ;* Start secondary intelligence
        ldu     ,S                      ;* Get planet scanner WS
        ldd     OIndex,U                ;* Get index to scanner WS
        std     OWSCon,X                ;* This is controlled WS of sec. intel.
        ldd     OIndex,X                ;* Then save index of secondary intel.
        std     OIWScIn,U               ;* In appropriate place in scanner WS
        puls    X,U                     ;* Restore old values - scan WS in X
        rts
;*
;*
;*              IRCrys - Crystal
;*
        Routine IRCrys
        pshs    U
        New_Scan        CCrystal        ;* Get scanner WS
        pshs    X                       ;* Save scanner WS
        jsr     InCaller                ;* Give it Caller primary intelligence
        New_Sleep       Task64,CrSecIn,OCrSILn  ;* Start secondary intelligence
        ldu     ,S                      ;* Get crystal scanner WS
        ldd     OIndex,U                ;* Get index to scanner WS
        std     OWSCon,X                ;* This is controlled WS of sec. intel.
        ldd     OIndex,X                ;* Then save index of secondary intel.
        std     OIWScIn,U               ;* In appropriate place in scanner WS
        clr     OCrAge,X                ;* Zero out age of crystal
        puls    X,U                     ;* Restore old values - scan WS in X
        rts
;*
;*              IRSBomb - Sinibomb
;*
IRSBomb pshs    U
        New_Scan        CSbomb          ;* Get scanner WS
        pshs    X                       ;* Save scanner WS

.1S     RANDOM  OSEED1,BYTE     ;* Give the Sinibomb a (pseudo) random
        sta     OSPERS,X        ;*   personality so that it THINKS better.
;***
;*      The personality must be set so that all the Sinibombs don't "think"
;*      at the same time.
;***
        jsr     InCaller                ;* Give it Caller primary intelligence
        New_Sleep       Task8,SiniBomb,OWISLen  ;* Start secondary intelligence ;;Fixme was: New_Sleep  Task8,SiniBo,OWISLen
        ldu     ,S                      ;* Get sinibomb scanner WS
        ldd     OIndex,U                ;* Get index to scanner WS
        std     OWSCon,X                ;* This is controlled WS of sec. intel.
        ldd     OIndex,X                ;* Then save index of secondary intel.
        std     OIWScIn,U               ;*   in appropriate place in scanner WS
        puls    X,U                     ;* Restore old values - scan WS in X
        rts
;*
;*              IRSini - Sinistar
;*
IRSini  New_Scan        CSini           ;* Get scanner WS
;*
;*                              This section from RICH
        RANDOM  OSEED1,BYTE
        anda    #~(PSiniInhibit)                                                ;;Fixme was: anda  #!N(PSiniInhibit)
        ora     #MaxSinOrbit
        sta     OSPERS,X
;*
;*
        jsr     Vibzer                  ;* Zero out its vibration block
        jsr     InCaller                ;* Give it Caller primary intelligence
        ldd     OIndex,X                ;* Get index to Sinistar
        std     SinIndex                ;* Save it for others to use
        New_Sleep       Task256,SiniPa  ;* Pre-sinistar intelligence
        rts
;*
;*              SiniPause - Pauses for two seconds before starting to move
;*
SiniPa  Change_Sleep    Task8,Sini      ;* Make it wake on faster list
;*
;*              IRPlay - Player
;*
        Routine IRPlay
        pshs    A,B,X,Y,U       ;* Save work registers
        ldx     [PlaIndex]      ;* X -> Player's scanner workspace.
        tst     AMDemo          ;* If in attract mode demo
        bne     .1S             ;*   then create a special player.
        jsr     InCaller        ;* Give the player calling intelligence.
        bra     .99S            ;* Exit
;***
;*      Start the auto pilot.
;***
.1S     jsr     InWarrior       ;* <<< Temporary, as a warrior >>>
.99S    puls    A,B,X,Y,U       ;* Restore work registers
        rts


;* InWorker - gives intelligence to worker - WS in X on entry
InWorker
        pshs    D               ;* Save D from subsequent tampering
        ldd     KeyClee         ;* Get the pointer to the first worker
        std     OScTyPt,X       ;* Save it in our 'same type' pointer
        clra                    ;* Zero out
        sta     OCalPri,X       ;* Calling priority
        sta     OSSqSiz,X       ;* And squadron size
        ldd     #$FFFF          ;* Save maximum possible distance
        std     OSCLDC,X        ;* In the distance to caller (special init)
        ldd     #Ground         ;* Then ground out
        std     OScSqI,X        ;* Pointer to index of next squadron member
        lda     #OMWoDrift      ;* Put a drift mission
        sta     OSMis,X         ;* In the mission slot
        RANDOM  OSEED1,BYTE     ;* Create a random personality
        sta     OSPERS,X        ;*   for each of the workers.
        ldd     OIndex,X        ;* Get the index to this worker
        std     OScWCr,X        ;* It is calling itself now
        std     KeyClee         ;* It is also new first worker on type list
        New_Sleep       Task8,Worker,OWISLen    ;* Start intelligence sleep task
;* X now has WS of intelligence sleep task, not Scanner task
        std     OWsCon,X        ;* Put controlled scanner ws index in sleep task
        ldd     OIndex,X        ;* Then get this index to return the favor
        ldx     [OWSCon,X]      ;* Point X back at scanner WS
        std     OScnIn,X        ;* Save it as pointer to intelligence task
        puls    D,PC            ;* And we are done

;* InWarrior - gives intelligence to Warrior - WS in X on entry

        Routine InWarrior
        pshs    D               ;* Save D from subsequent tampering
        ldd     KeyClee+2       ;* Get the pointer to the first Warrior
        std     OScTyPt,X       ;* Save it in our 'same type' pointer
        clra                    ;* Zero out
        sta     OCalPri,X       ;* Calling priority
        sta     OSSqSiz,X       ;* And squadron size
        ldd     #$FFFF          ;* Save maximum possible distance
        std     OSCLDC,X        ;* In the distance to caller (special init)
        ldd     #Ground         ;* Then ground out
        std     OScSqI,X        ;* Pointer to index of next squadron member
        lda     #OMWaDrift      ;* Put a drift mission
        sta     OSMis,X         ;* In the mission slot
        RANDOM  OSEED1,BYTE     ;* Create a random personality
        pshs    Y               ;* Save Y for later
        leay    ,X              ;* Get warrior scanner WS into Y
        jsr     Inhibit         ;* Initialize warrior inhibitions.
        puls    Y               ;* restore value
        sta     OSPERS,X        ;*   for each of the warriors.
        ldd     OIndex,X        ;* Get the index to this Warrior
        std     OScWCr,X        ;* It is calling itself now
        std     KeyClee+2       ;* It is also new first Warrior on type list
        New_Sleep       Task8,Warrior,OWISLen   ;* Start intelligence sleep task
;* X now has WS of intelligence sleep task, not Scanner task
        std     OWsCon,X        ;* Put controlled scanner ws index in sleep task
        ldd     OIndex,X        ;* Then get this index to return the favor
        ldx     [OWSCon,X]      ;* Point X back at scanner WS
        std     OScnIn,X        ;* Save it as pointer to intelligence task
        puls    D
        rts                     ;* And we are done

;* InCaller - give intelligence to Caller - Scan WS in X on entry, IQ WS on exit
        Routine InCaller
        pshs    D,U             ;* Save D from subsequent tampering
        ldd     #Ground         ;* First ground out
        std     OCleLs,X        ;* Pointer to list of workers
        std     OCleLs+2,X      ;* Pointer to list of warriors
        clrd
        ldu     OSChar,X        ;*
        cmpu    #CCrystal       ;*
        bne     .INCA1S         ;*                                              ;;Fixme was: bne  1$
        tst     AMDemo          ;* Ask Sam about this.
        bne     .INCA1S         ;*                                              ;;Fixme was: bne  1$
        incb                    ;* Fake out the quota as filled.
.INCA1S std     OQuota,X        ;* Then zero quotas - none filled so far
        ldd     OIndex,X        ;* Get the index to this Caller
        New_Sleep       Task1,PreCal,OWISLen    ;* Start intelligence sleep task
;* X now has WS of intelligence sleep task, not Scanner task
        std     OWsCon,X        ;* Put controlled scanner ws index in sleep task
        ldd     OIndex,X        ;* Then get this index to return the favor
        ldx     [OWSCon,X]      ;* Point X back at scanner WS
        std     OSCoCaI,X       ;* Save pointer to Controlling Caller Intel.
        puls    D,U             ;* And we are done
        rts
;*
;*
;*                      VibZer - Zeros out vibration block of Scan WS in X
;*                               and initializes pseudo-mass
;*
        ROUTINE VibZer
        pshs    D,X,U           ;* Save them for later
        ldu     OSChar,X        ;* Point to characteristic descriptor
        lda     OMass,U         ;* Get the object mass
        sta     OSPers,X        ;* Copy it into the personality byte
        lda     OViBas,U        ;* Get the offset of base of vibration block
        leau    A,X             ;* Point U to block in scanner WS
        clrd                    ;* Put zeros into
        std     ,U++            ;* Vibration task address
        std     ,U++            ;* Long vibration added
        std     ,U++            ;* Short vibration added
        sta     ,U              ;* Richter scale value
        puls    D,X,U
        rts

;* intelligence routines
;       SubTtl  - Calling Intelligence

;*              PRECAL - precedes first call, sets CalOne flag
;*
PreCal  clr     CalOne
        dec     CalOne          ;* Set it to FF without using registers
        jmp     Caller          ;* Go do the first call
;*
;*
;*              POSCAL - after first calling, resets calling to slow list
;*
PosCal  clr     CalOne          ;* Now we are no longer on first call
        ldd     #SPlayer
        cmpd    OWSCon,Y        ;* See if it is the player being called
        bne     .1S
        Change_Sleep    Task64,Caller   ;* Player calls twice as often as others
;*
.1S     Change_Sleep    Task256,Caller  ;* Make them wake at caller routine
;       Local

;* Enter from sleep - Y points to Sleep Task of Caller

Caller  pshs    Y                       ;* Save pointer for sleep at exit
        ldy     [OWsCon,Y]              ;* Reposition Y to Controlling Intel. WS
        ldx     OSChar,Y                ;* Point X to characteristic descriptor
        lda     OInType,X               ;* Grab the intelligence type for TLU
        sta     Temp+OCler              ;* Save it as "Caller" type
        lda     #OWorker                ;* Start out by calling Workers
        sta     Temp+OClee              ;* To keep track of Callee type
;* See if we have our quota of callees yet
.1S     adda    Temp+OCler              ;* Add Caller to Callee now in A
        sta     Temp+OCombo             ;* This is our combined calling code
        ldx     #Quota                  ;* Quota table `Eventually in RAM`
        ldb     A,X                     ;* Load correct quota for this Combo
        lda     Temp+OClee              ;* Get Callee offset again
        leax    OQuota,Y                ;* Point to Quota slots for caller
        cmpb    A,X                     ;* See if number of callees equals quota
        bhi     .4S                     ;* If quota greater, quota is unfilled
;* A pass is completed, see if another is to be done
.2S     lda     Temp+OClee              ;* See who our callee is
        beq     .3S                     ;* if still worker, keep on going
        jmp     .17S                    ;* If not zero (worker) is warrior, done
;* First pass - workers - done, now check for warriors
.3S     lda     #OWarrior               ;* Get offset for Warriors
        sta     Temp+OClee              ;* They are callee type now
        jmp     .1S                     ;* Go back to quota checking loop
;* Quota unfilled, calculate our modified priority
.4S     ldb     A,X                     ;* Number of Callees of type on call
        lda     #QuoMod                 ;* How importance quota is to priority
        mul                             ;* Scale current quota filled
        stb     Temp+OQtaFct            ;* Save this modified quota factor
;* Find our unmodified priority for this combo
        lda     Temp+OCombo             ;* Number unique to Caller/Callee pair
        ldx     #Prios                  ;* Address of priority table
        ldb     A,X                     ;* Do Table Look Up for unmodified prio
        subb    Temp+OQtaFct            ;* Subtract quota contribution from Prio
        stb     Temp+OPriMod            ;* This is our modified priority
;* Set up for searching through callees
        addb    #DMoMax                 ;* Add in the best possible distance mod
        stb     Temp+OPriMax            ;* For our maximum possible calling prio
        lda     #WrstPri                ;* Worst acceptable priority
        sta     Temp+OBstPri            ;* Best priority found so far
        clrd
        std     Temp+ObstClee           ;* Best callee found - initialized to 0
        lda     Temp+OClee              ;* Get current callee type offset
        asla                            ;* Double it for 2 byte offset
        ldx     #KeyClee                ;* Point to keystone lookup for callees
        ldx     A,X                     ;* Grab the appropriate Callee Keystone
        jmp     .6S                     ;* On first pass, skip type pointer load
;* Top of search loop - look through callees
.5S     ldx     OScTyPt,X               ;* get pointer to next callee of type
.6S     cmpx    #Ground                 ;* Does next callee exist?
        beq     .11S                    ;* If not, see if we found real one yet
        ldx     ,X                      ;* Point X to Scanner WS of next callee
        ldd     OScWCr,X                ;* See if this callee's caller
        cmpd    OIndex,Y                ;* Is the caller now trying to call it
        beq     .5S                     ;* If so, go on to next callee
        lda     Temp+OPriMax            ;* Check our best possible priority
        cmpa    OCalPri,X               ;* Against callee's mission priority
        bls     .5S                     ;* If less, we can't possibly override
        lda     #$FF                    ;* Check for 'override' value
        cmpa    OCalPri,X               ;* In callee priority slot
        beq     .5S                     ;* If FF, is on special call, ignore
;* May be possible to call this one - check dist, make sure
        lda     OSLPos,X                ;* Get his long position
        cmpa    OSLPos,Y                ;* Compare it with our long position
        blt     .7S                     ;* If ours is higher (signed)
        suba    OSLPos,Y                ;* Then subtract his
        jmp     .8S
.7S     lda     OSLPos,Y                ;* Else subtract us from him
        suba    OSLPos,X
.8S     ldb     OSSPos,X                ;* Get his short position
        cmpb    OSSPos,Y                ;* Compare it with our short position
        blt     .9S                     ;* If ours is higher (signed)
        subb    OSSPos,Y                ;* Then subtract his
        jmp     .10S
.9S     ldb     OSSPos,Y                ;* Else subtract us from him
        subb    OSSPos,X
.10S    std     Temp+OHisDs             ;* Save his distance, he may be best
        jsr     CalDm                   ;* Then calculate the distance modifier
        sta     Temp+OMoDst             ;* This is modified distance factor
        adda    Temp+OPriMod            ;* Add it to modified priority
        sta     Temp+OurPri             ;* To get our actual final priority
;* Calculate callee's real priority given his distance
        ldd     OSCLDC,X                ;* Distance of callee from its caller
        jsr     CalDm                   ;* Calculate its distance modifier
        adda    OCalPri,X               ;* Add it to its base calling priority
        sta     Temp+OHisPri
        lda     Temp+OurPri             ;* Get our priority
        cmpa    Temp+OHisPri            ;* Compare it with his current priorty
        bls     .5S                     ;* If no better, look at next callee
;* Eligible Callee found, see if it is the best so far
        cmpa    Temp+OBstPri            ;* Compare this prio with best so far
        bls     .5S                     ;* If no better, keep going
        sta     Temp+OBstPri            ;* Else this is now the best priority
        ldd     OIndex,X                ;* Get index to the callee
        std     Temp+OBstClee           ;* Save it as index to best callee
        ldd     Temp+OHisDs             ;* Get his distance to us
        std     Temp+OBstDs             ;* Distance of best callee found
;* Do Minimum Unconditional Acceptance Distance modifier check
        lda     Temp+OMoDst             ;* Get the distance mod to this callee
        cmpa    #MUAD                   ;* This should be RAM location `
        bls     .5S                     ;* if not over MUAD, keep looking
;* Got one - or checked all without finding one within MUAD
.11S    lda     Temp+OBstPri            ;* Look at the best priority we found
        cmpa    #WrstPri                ;* Is it better than worst acceptable?
        lbls    .2S                     ;* If not, see if we need another pass
;* Valid Callee found - update him, his caller, this caller
        ldx     [Temp+OBstClee]         ;* Point X to best callee's workspace
        ldu     [OScWCr,X]              ;* Point to former caller of callee
        cmpu    [OIndex,X]              ;* See if it's calling itself (uncalled)
        beq     .16S                    ;* If so, no list to delete it from
        lda     Temp+OClee              ;* Get offset for this callee type
        adda    #OQuota                 ;* Point A to right callee/quota
        dec     A,U                     ;* One less callee of that type now
        bpl     .12S                    ;* Error check - should not be needed`
        swi             ;*      'No Callee in list'`
;* In final version, delete the bpl 12$ and swi`
.12S    lda     Temp+OClee              ;* Get callee offset
        lsla                            ;* Double it for two byte offset
        adda    #OCleLs                 ;* Point to start of proper callee list
        ldu     A,U                     ;* Look at first callee
        cmpu    OIndex,X                ;* See if he is the one we want
        bne     .13S                    ;* If not, search down list
;* First callee is one we want
        ldu     [OScWCr,X]              ;* Point to former caller of callee
        leau    A,U                     ;* Point to its first callee entry
        ldd     OScSqI,X                ;* Get next member of callee's squadron
        std     ,U                      ;* Now is new first callee of old caller
        jmp     .16S                    ;* Go attend to callee
;* Not first callee - look down list til you find it
.13S    ldd     OIndex,X                ;* This is our callee's ID
        ldu     ,U                      ;* Point U to Workspace of first callee
.14S    cmpd    OScSqI,U                ;* Compare each callee in list to ours
        beq     .15S
        ldu     [OScSqI,U]              ;* Point to WS of next squadron member
;       IFE     VERSION-FINAL                                                   ;;Commenting this out makes the code match up.
;       bra     .14S
;       ELSE
        cmpu    #Ground                 ;* See if we missed it somehow
        bne     .14S
        swi             ;*      'Callee not present on Caller list'`
;       ENDIF
.15S    ldd     OScSqI,X                ;* Get next member of callee's squadron
        std     OScSqI,U                ;* Now it takes place of callee
;* Now update our Caller's quota and list
.16S    lda     Temp+OClee
        adda    #OQuota                 ;* Calculate proper quota byte addr.
        inc     A,Y                     ;* Update our caller's quota total
        lda     Temp+OClee
        lsla                            ;* Double offset for two byte lookup
        leau    OCleLs,Y                ;* Point to callee list origin
        leau    A,U                     ;* Point to correct set of callees
        ldd     ,U                      ;* Get old first squadron member
        pshs    D                       ;* Save it for below
        ldd     OIndex,X                ;* Get index to callee
        std     ,U                      ;* New callee becomes first squ. member
;* Now tell the callee his new destination
        lda     Temp+OPriMod            ;* Get our priority for this call
        sta     OCalPri,X               ;* Save it in Callee's WS
        ldd     OIndex,Y                ;* Get caller's index
        std     OScWCr,X                ;* Save as Scanner Ws of Caller
        ldd     Temp+OBstDs             ;* Get his distance to us
        std     OSCLDC,X                ;* Save this as distance to caller
        puls    D                       ;* Get first (most junior) old sq member
        std     OScSqI,X                ;* Link into new squadron list
        ldu     #MisAss                 ;* Point to table of mission assignments
        lda     Temp+OCombo             ;* Get our unique combination code
        lda     A,U                     ;* Get mission
        sta     OSMis,X                 ;* Give it to new callee
        jmp     .2S                     ;* See if we need another pass
.17S    puls    Y                       ;* Restore index to sleep task
        lda     CalOne                  ;* See if its the first call for caller
        beq     .20S
        jmp     PosCal                  ;* Do changesleep if so, else
.20S    Sleep   LOOP                    ;* Return to sleep


;*      CALDM - Calculate squared distance between scanner coords and modify
;*              Coords in A,B, returns distance modifier in A
CalDm   coma                            ;* Reverse the magnitude of A and B to
        comb                            ;* gain accuracy on small distances
        pshs    B                       ;* Use stack for temporary storage
        tfr     A,B                     ;* Get long coord
        mul                             ;* Square it
        lsra                            ;* Scale it to avoid overflow
        pshs    A                       ;* Save result
        lda     1,S                     ;* Get short dist.
        ldb     1,S
        mul
        lsra                            ;* Scale it to avoid overflow
        adda    ,S                      ;* Add in square of long distance
        leas    2,S                     ;* Clear garbage from stack, result in A
        ldb     #DstMod                 ;* Scale it by distance modifier
        mul
        rts

;       SubTtl  - Secondary Intelligences - Crystals, Planets
;****
;*
;*                      CrSecIn - Crystal secondary intelligence - WS in Y
;*
CrSecIn inc     OCrAge,Y        ;* Age it
        bvc     .1S             ;* No problem if no overflow
        dec     OCrAge,Y        ;* Else bring it back down to FF
.1S     lda     OCrAge,Y        ;* Then grab it for later
        ldx     [OWSCon,Y]      ;* Get scanner WS this intelligence controls
        ldu     OSScWSA,X       ;* Look at its object WS
        bne     .7S             ;* If onscreen, zero its age and return
        cmpa    #MaxCrA         ;* Compare this age to maximum crystal age
        blo     .3S             ;* If this age is lower, don't kill the crystal
;*
        jsr     KRCrys          ;* Crystal dies of old age
        jmp     .2S             ;* Then return
;*
.7S     clr     OCrAge,Y        ;* Crystal back on screen - new lease on life
        JMP     CRONSEC
;*
.3S     lda     OQuota,X        ;* Look at quota of workers now called
        beq     .2S             ;* If zero, forget it
        FRANDOM OSEED1,BYTE
        cmpa    #CatPrb         ;* Do a random check against catching probabil.
        bhi     .2S             ;* If higher, no one has caught this crystal
;*                                else someone gets it if they're near enough
        ldu     [OCleLs,X]      ;* Point to WS of first worker
;*
.4S     lda     #CryDis         ;* Get minimum crystal catch distance acceptable
        cmpa    OScLDC,U        ;* Compare to long dist. to caller
        blo     .5S             ;* If too far, look at next worker
        cmpa    OScSDC,U        ;* Else check short distance too
        blo     .5S             ;* With same consequences
;*
        ldd     OSScWSA,U       ;* It is close enough - see if it is on screen
        beq     .6S             ;* If not on screen, go give it the crystal
;*
.5S     ldu     [OScSqI,U]      ;* Look at WS of next squadron member
        bne     .4S             ;* If not at end of list, check him out
;*
.2S     Sleep   LOOP            ;* Exit point
;*
.6S     jsr     KRCrys          ;* Kill the crystal off
        tfr     U,X             ;* Point to worker getting crystal
        jsr     GivCrys         ;* Give it to him
        jmp     .2S             ;* All done
;* crystal onscreen secondary intelligence
CRONSEC CHANGE_SLEEP TASK8,HERE ;switch to faster list for flashing
        BSR     .2S             ;still on screen?
        FRANDOM OSEED1,BYTE     ;50% chance of flashing
        BMI     .1S             ;flash this time?
        SLEEP   LOOP            ;no, try again next time
.1S     RANDOM  OSEED1,WORD     ;yes, don't all flash at once
        CHANGE_SLEEP TASK1,HERE ;switch to one list for effect
        BSR     .2S             ;still on screen?, get screen WS address in U
        LDD     #ICFLASH        ;change crystal image to flash image
        STD     ONIDESC,U
        LDD     #CHGOBJ
        STD     ODRWVEC,U
        TUNE    QCRYFLA         ;play crystal flash tune
        SLEEP   HERE            ;wait one screen before erasing
        BSR     .2S             ;still on screen?, get screen WS address in U
        LDD     #ICRYSTA        ;change crystal image back to normal image
        STD     ONIDESC,U
        LDD     #CHGOBJ
        STD     ODRWVEC,U
        BRA     CRONSEC         ;back to flashing list
;*
.2S     LDX     [OWSCON,Y]      ;get scanner WS this intelligence controls
        LDU     OSSCWSA,X       ;get at its object WS in U
        BEQ     .3S             ;if offscreen, switch to offscreen sec intel
        RTS
;*
.3S     LEAS    2,S             ;offscreen, forget about returninig
        CHANGE_SLEEP TASK64,CRSECIN ;change back to offscreen intelligence
;       LOCAL
;*
;*
;*                      PlSecIn - Calling Planet sec. intelligence - WS in Y
;*
PlSecIn ldx     [OWSCon,Y]      ;* Get scanner WS this intelligence controls
        ldu     OSScWSA,X       ;* Look at its object WS
        bne     .2S             ;* If onscreen, ignore it and return
;*
        lda     OQuota+OWorker,X        ;* Look at quota of workers now called
        beq     .2S             ;* If zero, forget it
;*
        lda     OQuota+OWarrior,X       ;* Look at quota of warriors now called
        beq     .2S             ;* If zero, forget it
        RANDOM  OSEED1,BYTE
        cmpa    #MinPrb         ;* Do a random check against mining probabil.
        bhi     .2S             ;* If higher, no mining this check
;*                                else someone gets it if they're near enough
;*
;*                      Check to see if the warrior is nearby
;*
        ldu     [OCleLs+2,X]    ;* Point to WS of first warrior
;*
        lda     #MinDis         ;* Get minimum mining distance acceptable
        cmpa    OScLDC,U        ;* Compare to long dist. to caller
        blo     .2S             ;* If too far, forget it
        cmpa    OScSDC,U        ;* Else check short distance too
        blo     .2S             ;* With same consequences
;*
;*                      Warrior close, look for a worker close enough
;*
        ldu     [OCleLs,X]      ;* Point to WS of first worker
;*
.4S     lda     #MinDis         ;* Get minimum crystal catch distance acceptable
        cmpa    OScLDC,U        ;* Compare to long dist. to caller
        blo     .5S             ;* If too far, look at next worker
        cmpa    OScSDC,U        ;* Else check short distance too
        blo     .5S             ;* With same consequences
;*
        ldd     OSScWSA,U       ;* It is close enough - see if it is on screen
        beq     .6S             ;* If not on screen, go give it the crystal
;*
.5S     ldu     [OScSqI,U]      ;* Look at WS of next squadron member
        bne     .4S             ;* If not at end of list, check him out
;*
.2S     Sleep   LOOP            ;* Exit point
;*
.6S     ldd     OSLPos,U        ;* Get scanner position of this worker
        tfr     U,X             ;* Put his WS in X
        jsr     KRWorker        ;* Kill him                                     ;;Fixme was: jsr  KRWork
        jsr     IRWoCr          ;* Make a worker with crystal in his place
        jmp     .2S             ;* All done
;       LOCAL

;*
;       SubTtl  - Misc. constant-running processes
;*
;*
;*              ADJPOP - Adjust Population to desired levels
;*                              Wakes with sleep task in Y
;*
;       Local
AdjPop  pshs    Y
        ldy     #8080           ;* Flag to create randomly, avoiding player ship
        lda     #-1             ;* Edge flag
        sta     Edge            ;* Save it so we initialize on edge of sector
        jsr     PopFil          ;* Fill the sector to desired population level
        puls    Y
        SLEEP   LOOP

;*
;*              POPFIL - Fills out current population to desired level
;*                       Expects location/random create flag in Y
;*                       Expects EDGE to be non-zero to create on edge only
;*                       Uses TEMP
;       Local
        Routine PopFil
        pshs    D,X,U
        LDA     EDGE            ;is this initialization?
        BEQ     .6S
        CLRA                    ;no, determine how far behind we are: total in A
        LDX     #POP            ;get start of population table in X
.4S     LDB     1,X             ;get number needed
        SUBB    X               ;subtract number in existance
        BLS     .5S             ;need more?
        PSHS    B               ;add to total needed
        ADDA    S+
        BCC     .5S             ;over 255?
;       IFE     VERSION-FINAL
;       LDA     #-1             ;are you kidding?
;       ELSE
        SWI
;       ENDIF
.5S     LEAX    3,X             ;next entry
        CMPX    #EPOPVL         ;done
        BLO     .4S
        TSTA                    ;any to populate?
        BEQ     .3S
        RPT     3,LSRA          ;divide by 8 (create about 16 at a time max.)
        BEQ     .6S             ;only need a few? zero flags create all
        LDX     #INVTBL         ;find inverse
        LDA     A,X
.6S     STA     TEMP            ;save percentage to create (or zero for 100%)
        ldx     #ScOCDT         ;* X points at scanner object CD table
        ldu     #Pop            ;* U points at Population current/desired table
;*
.2S     LDA     1,U             ;get desired pop level for this type
        SUBA    U               ;subtract current level
        BLS     .1S             ;if we are at or past desired level, do next
        LDB     TEMP            ;get percentage to create
        BEQ     .7S             ;flaged as create all?
        MUL                     ;no, compute how many to create
.7S     TSTA                    ;make any?
        BEQ     .1S
        pshs    X,A             ;* Save pointer to SCOCDTable and number to make
.8S     ldd     Free            ;* Check free space
        cmpd    #MinFree        ;* Don't create if less than a minimum
        blt     .9S
        ldx     [1,S]           ;* Put Char. Desc. in X
        tfr     Y,D             ;* Put it on the edge of the screen if so told
        jsr     [OInVec,X]      ;* Initialize the object
        DEC     S               ;more to create
        BNE     .8S
.9S     puls    X,A             ;* Restore pointer
;*
.1S     leau    3,U             ;* Point at next entry
        leax    2,X             ;* Point to next CD
        cmpx    #RSOEnd         ;* At the end of the replacable scanner objects?
        bne     .2S             ;* If not, look at next
;*
.3S     puls    D,X,U
        rts

;       Local
;*
;*                      HANSOLO - Famous flyer through asteroid swarms
;*
HanSolo lda     Pop+0D          ;* Look at number of smallest planetoids desrd.
        cmpa    20              ;* See if it is at swarm value
        blt     .1S             ;* If not, we are OK
;*
        lda     #2              ;* Otherwise put desired number of two
        sta     Pop+0D          ;* In smallest
        sta     Pop+0A          ;* And second smallest planet 'desired' count
        jmp     HANS2S                                                          ;;Fixme was: jmp  2$ (Had to make label global for PHRASE)
;*
.1S     Random  OSeed1,BYTE
        cmpa    #SwrPrb         ;* See if we are within swarm probability
        bhi     HANS2S          ;* if not just return
;*
        lda     20              ;* Else put a whole mess of small planets
        sta     Pop+0D
        sta     Pop+0A          ;* Into the desired count
        DISPLAY YELLOW          ;* Point to text window
        Phrase  YELLOW,35,Entering,Swarm
        Phrase  YELLOW,35,Of,Planetoids
        Tune    QMesg
;*                              Warn the player
;*
HANS2S  sleep   LOOP            ;* Go back to sleep while they multiply
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ROMSAVE SET     *               ;; Save the current address

        ORG     PHRSAV          ;; Jump over to PHRSAV to save our pointers
;       FDB     _ENTERING
        FDB     _SWARM
        FDB     _OF
;       FDB     _PLANETOIDS

PHRSAV  SET     *               ;; Mark the new address for PHRSAV to add
                                ;; more phrases later

        ORG     ROMSAVE         ;; Back to our regularly scheduled programming...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;*
;*              SinCon  - SiniStar controlling process - speech and O-Sec build
;*
SinCon  pshs    D
        ldd     Finish
        cmpd    #Alive
        beq     .1S             ;* See if SiniStar is alive yet
;*
;*                      SiniStar dormant
;*
        tst     SiniSec         ;* not alive yet, see if in sector
        beq     .4S             ;* if not, no action this iteration
        RANDOM  OSEED2,BYTE
        cmpa    #$40            ;* Some of the time build him up automatically
        nop
        nop
        nop             ;* room for operator adjust stuff
        bhi     .4S             ;* Sometimes don't
;*
        jsr     AddPart
        jmp     .4S
;*
;*                      SiniStar LIVES!
;*
.1S     RANDOM  OSEED2,BYTE
        cmpa    #$38            ;* Toss a random number
        bhi     .4S             ;* sometimes don't say anything
        jsr     Taunt           ;* Else say something nasty
;*
.4S     puls    D
        SLEEP   LOOP

;*
;*              Taunt - speak out a random taunt
;*
        Routine Taunt
        pshs    A
        RANDOM  OSEED1,BYTE
        anda    #$7F                    ;* Knock it down to 1-7F
        adda    RnSpch                  ;* Add in the last random speech
        sta     RnSpch                  ;* Update it for next time
;*
        cmpa    #$28
        bhi     .TAUN1S

        Speak   3
        jmp     .TAUN10S
;*
.TAUN1S cmpa    #$50
        bhi     .TAUN2S

        Speak   4
        jmp     .TAUN10S
;*
.TAUN2S cmpa    #$78
        bhi     .TAUN3S

        Speak   5
        jmp     .TAUN10S
;*
.TAUN3S cmpa    #$A0
        bhi     .TAUN4S

        Speak   6
        jmp     .TAUN10S
;*
.TAUN4S cmpa    #$C8
        bhi     .TAUN5S

        Speak   7
        jmp     .TAUN10S
;*
.TAUN5S Speak   8
.TAUN10S puls   A
        rts             ;* End of TAUNT

;       Local
;*
;       SubTtl  - Difficulty adjustment code

        Routine DTimer
        lda     #01
        jsr     ChgA
        fdb     DifTmr                                          ;;Fixme was: fdb  .DifTmr
        Sleep   LOOP

;* Temporary tables for caller intelligence
;       SubTtl  - Caller Intelligence Tables
;*****
;*
;* Unusual notes:
;*
;*      The attract mode demonstration was kludged to allow planets and
;*      crystals to call the player.  Normally only workers and warriors
;*      are called by anything.  But, to make the demo work, the player
;*      is given a special warrior intelligence during attract mode.  As
;*      a consequence, the quota for crystals calling warriors is 1 (one)
;*      instead of 0 (zero).  Also, the mission for crystals calling warriors
;*      is OMWaInt(ercept) instead of OMWaDrift and the priority is $34+1
;*      instead of $00.  (The $34 is the same as the planet calling priority
;*      and the +1 causes it to prefer crystal pickup to mining.)
;*
;*****
;* Quota assignments - temporarily in ROM
Quota   fcb     3,1             ;* 3 workers, 1 warrior for planets
        fcb     3,9             ;* lots of each for the player
        fcb     0,6             ;* 6 warriors for the sinistar
        fcb     1,1             ;* 1 of each for sinibombs
        fcb     3,1             ;* 3 workers for crystals
;*                                3 rings for the Elven kings under the sky
;*                                7 for the Dwarf-lords in their halls of stone
;*                                9 for the Mortal Men, doomed to die
;*                                1 for the SiniStar, when its full grown

;* Mission assignments - SHOULD STAY IN ROM
MisAss          fcb     OMWoTail,OMWaMine       ;* Planets
                fcb     OMWoTail,OMWaAttack     ;* Player
                fcb     OMWoDrift,OMWaTail      ;* Sinistar
                fcb     OMWoIntercept,OMWaInt           ;* Sinibombs            ;;Fixme was: fcb  OMWoInt,OMWaInt
                fcb     OMWoIntercept,OMWaInt           ;* Crystals             ;;Fixme was: fcb  OMWoInt,OMWaInt

;*                      Base Priorities - temporarily in ROM
Prios   fcb     $58,$58         ;* Temporary base priorities for planets
        fcb     $48,$5B         ;* Player
        fcb     $00,$54         ;* Sinistar
        fcb     $70,$70         ;* Sinibomb
        fcb     $68,$58+3       ;* Crystals

;*
;*
;*                      KExplo  - offscreen routine for explosion
;*
KExplo  ldx     [OScan,Y]
        ldd     #Die
        std     OExec,X         ;* Kill off controlling task
        leax    ,Y              ;* Point X to object WS
        jsr     KillObj         ;* Kill on screen object
        jmp     Exec2           ;* I think this is where I'm supposed to go???


;* sinistar piece onto screen transition
        ROUTINE SPIECON
        JSR     SEXPOBJ         ;slowly blow it up
        WAKE_AT SCANDIE
        RTS


        PULLORG ROMSAVE

        PushOrg CExplo+OOffScr                                          ;;Fixme was: PushOrg  CExplo+OOffSc
        fdb     KExplo  ;* Offscreen routine
        PullOrg

;       SubTtl  - Population tables
;*
;*                      Characteristic Table additions
;*
        Pushorg CWorker+OCDInd
        fdb     Pop+0
        PullOrg
;*
        Pushorg CWarrior+OCDInd
        fdb     Pop+3
        PullOrg
;*
        Pushorg CWorkCr+OCDInd
        fdb     Pop+0
        PullOrg
;*
        Pushorg CPlan1+OCDInd
        fdb     Pop+6
        PullOrg
;*
        Pushorg CPlan2+OCDInd
        fdb     Pop+9
        PullOrg
;*
        Pushorg CPlan3+OCDInd
        fdb     Pop+0C
        PullOrg
;*
        Pushorg CPlan4+OCDInd
        fdb     Pop+0F
        PullOrg
;*
        Pushorg CPlan5+OCDInd
        fdb     Pop+12
        PullOrg
;*
        Pushorg CSBomb+OCDInd
        fdb     Pop+15
        PullOrg
;*
        Pushorg CCrystal+OCDInd                                         ;;Fixme was: Pushorg  CCryst+OCDInd
        fdb     Pop+18
        PullOrg
;*
        Pushorg CSini+OCDInd
        fdb     Pop+1B
        PullOrg
;*
        Pushorg CPlayer+OCDInd
        fdb     Pop+1E
        PullOrg
;*

        PushOrg RomSave                                                 ;;Fixme was: PushOrg  RomSav

ScoCdt  fdb     CWorker         ;* Scanner Object Charac. Descrip. Table
        fdb     CWarrior
        fdb     CPlan1
        fdb     CPlan2
        fdb     CPlan3
        fdb     CPlan4
        fdb     CPlan5
RSOEnd  equ     *               ;* End of replaceable scanner objects
        fdb     CSBomb
        fdb     CCrystal                                                ;;Fixme was: fdb  CCryst
        fdb     CSini
        fdb     CPlayer
CdtEnd  equ     *               ;* End of table

;*
;*                      Initial Population table
;*
;*      SAM - you can put those new tables here
;*
;*
;*                      Initial Population tables
;*      Population tables have one-byte current population, two byte
;*      desired population (LSB is fractional part) for each CD in
;*      Scanner Object Char. Desc. Table (see ScOCDT)
;*      Sequence of waves: InPop0,2,3,4,1,2,3,4,1,2,3,4 etc.
;*

;*              InPop0 - Initial population for first wave only

        RADIX   10                                                      ;;Need this for the decimal values

InPop0  fcb     0,6,0           ;* Workers
        fcb     0,0,0           ;* Warriors
        fcb     0,10,0          ;* Type 1 planets                       ;;Fixme was: fcb  0,10.,0
        fcb     0,2,0           ;* Type 2 planets
        fcb     0,2,0           ;* Type 3 planets
        fcb     0,2,0           ;* Type 4 planets
        fcb     0,2,0           ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0,0,0           ;* SiniBombs
        fcb     0,0,0           ;* Crystals
        fcb     0,1,0           ;* SiniStar
        fcb     0,1,0           ;* Player

IP0End  rmb     0               ;* Marks end of table
;*
;*
;*              Difficulty increase figures for this population
;*
InDif0  fdb     DTime
        fcb     6
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     -8
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0

ID0End  rmb     0               ;* Marks end of diff. table

;*              InPop1 - Void Zone

InPop1  fcb     6               ;* Workers
        fcb     8               ;* Warriors
        fcb     1               ;* Type 1 planets
        fcb     1               ;* Type 2 planets
        fcb     1               ;* Type 3 planets
        fcb     1               ;* Type 4 planets
        fcb     3               ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0               ;* SiniBombs
        fcb     0               ;* Crystals
        fcb     1               ;* SiniStar
        fcb     1               ;* Player
;*
;*
;*              Difficulty increase figures for this population
;*
        fdb     DTime
        fcb     6
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     -1
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     -1
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0

ID1End  rmb     0               ;* Marks end of diff. table

;*              InPop2 - Worker Zone

InPop2  fcb     $10             ;* Workers                              ;;Fixme was: fcb  10
        fcb     3               ;* Warriors
        fcb     10              ;* Type 1 planets                       ;;Fixme was: fcb  10.
        fcb     2               ;* Type 2 planets
        fcb     2               ;* Type 3 planets
        fcb     2               ;* Type 4 planets
        fcb     2               ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0               ;* SiniBombs
        fcb     0               ;* Crystals
        fcb     1               ;* SiniStar
        fcb     1               ;* Player
;*
;*
;*              Difficulty increase figures for this population
;*
        fdb     DTime
        fcb     10                                                      ;;Fixme was: fcb  10.
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     -8
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0

;*              InPop3 - Warrior Zone

InPop3  fcb     4               ;* Workers
        fcb     10              ;* Warriors                             ;;Fixme was: fcb  10.
        fcb     10              ;* Type 1 planets                       ;;Fixme was: fcb  10.
        fcb     2               ;* Type 2 planets
        fcb     2               ;* Type 3 planets
        fcb     2               ;* Type 4 planets
        fcb     2               ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0               ;* SiniBombs
        fcb     0               ;* Crystals
        fcb     1               ;* SiniStar
        fcb     1               ;* Player
;*
;*
;*              Difficulty increase figures for this population
;*
        fdb     DTime
        fcb     4
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     -8
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0

;*              InPop4 - Planetoid Zone

InPop4  fcb     6               ;* Workers
        fcb     8               ;* Warriors
        fcb     $10             ;* Type 1 planets                       ;;Fixme was: fcb  10
        fcb     2               ;* Type 2 planets
        fcb     $10             ;* Type 3 planets                       ;;Fixme was: fcb  10
        fcb     2               ;* Type 4 planets
        fcb     5               ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0               ;* SiniBombs
        fcb     0               ;* Crystals
        fcb     1               ;* SiniStar
        fcb     1               ;* Player
;*
;*
;*              Difficulty increase figures for this population
;*
        fdb     DTime
        fcb     6
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     10                                                      ;;Fixme was: fcb  10.
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     $10                                                     ;;Fixme was: fcb  10
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0



;*
;*              DEMO Population figures
;*

InPopD  fcb     0,2,0           ;* Workers
        fcb     0,0,0           ;* Warriors
        fcb     0,4,0           ;* Type 1 planets
        fcb     0,4,0           ;* Type 2 planets
        fcb     0,4,0           ;* Type 3 planets
        fcb     0,4,0           ;* Type 4 planets
        fcb     0,5,0           ;* Type 5 planets
;*                      NOTE: objects past this point are NOT initialized
;*                              automatically, but are included for con-
;*                              sistency, and to zero out the current values
        fcb     0,0,0           ;* SiniBombs
        fcb     0,0,0           ;* Crystals
        fcb     0,1,0           ;* SiniStar
        fcb     0,1,0           ;* Player
;*
;*
;*              Difficulty increase figures for this population
;*
        fdb     DTime
        fcb     6
        fdb     _PWor           ;* Workers                              ;;Fixme was: fdb  .PWor
        fcb     1
        fdb     _PWar           ;* Warriors                             ;;Fixme was: fdb  .PWar
        fcb     1
        fdb     _PPl1           ;* Plan1's                              ;;Fixme was: fdb  .PPl1
        fcb     1
        fdb     _PPl3           ;* Plan3's                              ;;Fixme was: fdb  .PPl3
        fcb     3
        fdb     _PPl5           ;* Plan5's                              ;;Fixme was: fdb  .PPl5
        fcb     $7F
        fdb     _WAgg           ;* Warrior aggression                   ;;Fixme was: fdb  .WAgg
        fcb     0

        RADIX   16                                                      ;;Switching back to hex
;*
InOEnd  rmb     0               ;* End of table

_PPL1   fdb     Pop+7           ;* Type 1 planet difficulty table root  ;;Fixme was: .PPL1  fdb  Pop+7
        fcb     0

_PPL3   fdb     Pop+0D          ;* Type 3 planet difficulty table root  ;;Fixme was: .PPL3  fdb  Pop+0D
        fcb     0


;*      Following routine goes after tables so assembler does not object

;****
;*              RstPop  - Resets population initial values and increments
;*                        To be called at PLAVEC and after each sinistar death
;****

        Routine RstPop
        pshs    D,X,Y,U
        clrd                    ;* Zero out difficulty stuff
        std     Dtime
        std     WAgg

        tst     AmDemo          ;* See if we are in demo mode
        beq     .RST5S          ;* Go see sinikills if not in demo mode         ;;Fixme was: beq  5$

        ldx     #InPopD         ;* And load X with beginning of demo for loading
        jmp     .RST2S          ;* Go load demo table in

.RST5S  lda     SiniKills       ;* See how many SiniStars have been killed
        bne     .RST1S          ;* Go do special init if we are not on first

        ldx     #InPop0
        jmp     .RST2S          ;* Go load in Pop 0 tables

.RST1S  anda    #$03            ;* Screen out lowest two bits for wave value
        ldb     #(ID1End-InPop1)
        mul                     ;* Multiply wave (0-3) by length of table
        addd    #InPop1         ;* Add in beginning location
        tfr     D,X             ;* Put it in X for special load beginning loc

        LDU     #POP            ;special load: start at beginning of population
.RST7S  LDA     X+              ;get population value
        CLRB                    ;no fraction
        STD     1,U             ;reset population to new value
        LEAU    3,U             ;next extry
        CMPU    #EPOPVL         ;done?
        BLO     .RST7S
        BRA     .RST6S          ;now load difficulty

.RST2S  ldu     #Pop            ;* Tell it to start at the beg of the population
        ldd     #EPopVl         ;* Tell it to stop at the end of the population
        std     EndPop
        jsr     SloLod          ;* Load the chosen init pop table
.RST6S  ldu     #DifTmr         ;* Tell it to start at beg of diff. table       ;;Fixme was: 6$  ldu  #.DifTmr
        ldd     #EDifVl         ;* Tell it to stop at end of diff. table
        std     EndPop
        jsr     SloLod          ;* Load the diff table following the pop table

.RST4S  cmpb    SiniKills       ;* in number of sinistars killed
        bhs     .RST3S          ;* If so, return
        stb     Temp            ;* Save it for next try

        lda     #06             ;* Else take a number

        pshs    X
        ldx     #GA1            ;* Operator difficulty adjust
        jsr     RCmosB          ;* Read from CMOS
        puls    X

        mul                     ;* Calculate difficulty add based on oper. diff.
        tfr     B,A             ;* Put result in A (will be 30. for avg. diff.)
        jsr     ChgA            ;* Add that difficulty
        fdb     DifTmr          ;* To difficulty timing structure               ;;Fixme was: fdb  .DifTmr
        ldb     Temp            ;* Get counter of difficulty waves advanced
        addb    #4              ;* Set it ahead another set of waves
        jmp     .RST4S          ;* And see if that is enough for now


.RST3S  pshs    X
        ldx     #GA1            ;* Operator difficulty adjust
        jsr     RCmosA          ;* Read from CMOS
        puls    X


        jsr     ChgA            ;* bump up the difficulty a bit at the beginning
        fdb     DifTmr          ;* depending on operator setting                ;;Fixme was: fdb  .DifTmr

        LDA     SINIKILLS       ;get number of sinistars killed                 ;;Fixme was: LDA  SINIKIL
        BNE     .RST11S
        LDA     #99             ;first zone use blue
        BRA     .RST22S
.RST11S LDX     #ZCOLTBL        ;get address of zone color table
        ANDA    #3              ;offset into table # of sinistar kills mod 4
        LDA     A,X             ;get color
.RST22S STA     ZONECOL         ;save as new color
        JSR     FRAME           ;re-draw frame with new color
;* * *
        PULS    D,X,Y,U

        rts

;****
;*              SloLod  - Slow data load for population stuff - source in X
;*                        Dest. in U, destination end stored in ENDPOP
;*                        Destoys B
;****

SloLod  ldb     ,X+
        stb     ,U+
        cmpu    EndPop
        blo     SloLod
        rts

        PullOrg RomSav

        PushOrg PlaySav
DifTmr  rmb     (ID0End-InDif0)                                         ;;Fixme was: DifTmr     rmb     (ID0End-InDif0)
;*                               reserve space for difficulty table
        PullOrg PlaySav

EPopVl  equ     Pop+(IP0End-InPop0)
EDifVl  equ     DifTmr+(ID0End-InDif0)                                  ;;Fixme was: EDifVl     equ     .DifTmr+(ID0End-InDif0)

        PushOrg RomSav

        VECTOR  IAMVECT

        New_Sleep       Task1,Attract,OTimer

        RTS

Attract
        nop
        nop
        rts


WrXQue
        nop
        nop
        rts             ;* Warrior explosion, ROUTINE'd by Bob

PlXQue
        nop
        nop
        rts             ;* Player explosion, likewise

        PullOrg RomSave                                                         ;;Fixme was: PullOrg  RomSav