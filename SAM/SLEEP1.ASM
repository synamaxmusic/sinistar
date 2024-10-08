;;      INCLUDE "../SAM/START.ASM"

        PUSHORG ROMSAVE

;;      SUBTTL  MULTITASKING ROUTINES

;* last task on list (except free list) dummy workspace and index
LTWSI   FDB     LTWSI
        FDB     .1S
;* last task on list (except free list)
.1S     LDX     TLEVEL          ;set pointer for list to keystone index
        LEAU    OTKEYI,X
        STU     OTPTR,X
        DEC     OTBACK,X        ;decrement backlog counter for list
        CLRA                    ;find highest backlog list
.2S     CMPA    OTBACK,X
        BHS     .3S
        LEAU    X
        LDA     OTBACK,X
.3S     LEAX    OTLEN,X
        CMPX    #TASKEND
        BNE     .2S
        STU     TLEVEL          ;set current level to most backlogged task
        LDD     OTPTR,U         ;set next task pointer to most backlogged task
        STD     PRTASK
        RTS

;* last task on free list dummy workspace and index
LFTWSI  FDB     LFTWSI
        FDB     .1S
;* last task on free list
.1S     LDD     #TASK0+OTKEYI   ;set next task ptr to free list keystone index
        STD     PRTASK
        RTS

;* change sleep address and list
;*  pass addr on stack, list keystn in X, current task workspace address in Y
C1SLEEP PULS    D
;* change sleep address and list
;*  pass address in D, list keystn in X, current task workspace address in Y
C2SLEEP STD     OEXEC,Y
;* change sleep list
;*  pass sleep list keystone address in X, current task workspace address in Y
C3SLEEP LDD     OTLINK,Y        ;link-out current process
        LDU     PRTASK
        STD     [U]
        LDD     X               ;link-in at new keystone
        STD     OTLINK,Y
        LDD     OINDEX,Y
        STD     X
        RTS

;* new sleep,  pass after call: wakeup address, sleep list keystone address
SLEEP1  PSHS    D,Y,U           ;save registers   > uses X
        LDD     #OMTLEN         ;get 4 byte workspace
        BSR     ALLOC           ;save none, uses A,B,X
        LDY     6,S             ;get address after call address
        LDD     Y               ;get wakeup address
        LEAY    4,Y             ;advance return address
        STY     6,S
        STD     OEXEC,X         ;initialize wakeup address
        LDY     -2,Y            ;get sleep list keystone address
        LDD     Y               ;link-in
        STD     OTLINK,X
        LDD     OINDEX,X
        STD     Y
        PULS    D,Y,U,PC        ;restore registers and return

;* new sleep with extra bytes,
;*  after call: wakeup address, size of workspace, sleep list keystone address
SLEEP2  PSHS    D,Y,U           ;save registers   > uses X
        LDY     6,S             ;get address after call address
        LDU     Y               ;get wakeup address
        LEAY    5,Y             ;advance return address
        STY     6,S
        LDB     -3,Y            ;get number of bytes
        CLRA
        BSR     ALLOC           ;get workspace  save U,Y, uses A,B,X
        STU     OEXEC,X         ;initialize wakeup address
        LDY     -2,Y            ;get sleep list keystone address
        LDD     Y               ;link-in
        STD     OTLINK,X
        LDD     OINDEX,X
        STD     Y
        PULS    D,Y,U,PC        ;restore registers and return

        ;SUBTTL DYNAMIC STORAGE ALLOCATION AND DEALLOCATION ROUTINES

;* allocate dynamic storage
;*      pass # bytes in D, returns ws addr in X, free space in D, overfl in CC
ALLOC   PSHS    U               ;save regs  > uses A,B,X
        LDU     WSIKEY          ;link-out index
        BNE     .1S
        SWI                     ;TEMPORARY TRAP out of workspace indexes
.1S     LDX     U
        STX     WSIKEY
        ADDD    #ODYNOVH        ;add extra bytes overhead
        LDX     HIGHBUB         ;get high bubble
        LEAX    D,X             ;check space
        CMPX    #DYNEND         ;is it large enough?
        BHI     .2S
        LDX     HIGHBUB         ;yes?, allocate from high bubble
        STD     X               ;save size of allocated block
        ADDD    HIGHBUB         ;advance high bubble
        STD     HIGHBUB
        BRA     .4S
.2S     LDX     TRASBUB         ;get trash bubble
        LEAX    D,X             ;check space
        CMPX    TRASEND         ;is it large enough?
        BLO     .3S
        SWI                     ;TEMPORARY TRAP out of ram
.3S     LDX     TRASBUB         ;yes?, allocate from trash bubble
        STD     X               ;save size of allocated block
        ADDD    TRASBUB         ;advance trash bubble
        STD     TRASBUB
.4S     LDD     FREE            ;subtract size from free space
        SUBD    X++
        STD     FREE            ;out of free space?
        BCC     .6S
        LDD     SAVSTK          ;TEMPORARY TRAP, EMERGENCY TRASH KLUDGE FAILED
        BEQ     .5S
        SWI
.5S     LDD     STACK-2         ;yes?, save return addr for process or collision
        STD     SAVSTK
        LDD     #SPTRASH        ;replace with special trash collection routine
        STD     STACK-2
        LDD     FREE            ;restore free space in D
.6S     STU     X++             ;save index address
        STX     U               ;point index to workspace start
        PULS    U,PC

;* scanner die  current scanner task workspace address in Y
        ROUTINE SCANDIE
        JSR     ERASCAN         ;erase scanner image  save Y, uses A,B
        LDU     OSCHAR,Y        ;decrement family counter
        DEC     [OCDInd,U]
;* die          current task workspace address in Y
        ROUTINE DIE
        LDD     OTLINK,Y        ;link-out current process
        LDX     [PRTASK]
        BRA     .2S
.1S     LDX     [X]
.2S     CMPY    [OTLINK,X]
        BNE     .1S
        STD     X
        LEAX    Y               ;get workspace address in X
;* de-allocate dynamic storage  pass workspace address in X
DEALLOC PSHS    D,U             ;save regs  > uses none
        CMPX    TRASBUB         ;is block behind trash bubble?
        BHS     .1S
        CMPX    LDEAL           ;yes?, is it the lowest de-allocated block?
        BHS     .1S
        STX     LDEAL           ;yes?, save it's address
.1S     LDU     OINDEX,X        ;get index address
        LDD     WSIKEY          ;link-in index
        STD     U
        STU     WSIKEY
        CLRD                    ;zero index in workspace
        STD     OINDEX,X
        PULS    D,U,PC

        PULLORG ROMSAVE