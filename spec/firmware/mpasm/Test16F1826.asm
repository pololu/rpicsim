  #include p16f1826.inc

rst code 0
    goto start

main code 0x40
start
    goto $

emptyRoutine
    return
    
testNops
    nop
    nop
    
; == Byte-oriented instructions ==

ins_addwf:
    addwf   4, F
    addwf   5, W

ins_andwf:
    andwf   4, F
    andwf   5, W

ins_addwfc:
    addwfc  4, F
    addwfc  5, W

ins_asrf:
    asrf    4, F
    asrf    5, W

ins_clrf:
    clrf    4
    clrf    5

ins_clrw:
    clrw

ins_comf:
    comf    4, F
    comf    5, W

ins_decf:
    decf    4, F
    decf    5, W

ins_incf:
    incf    4, F
    incf    5, W

ins_iorwf:
    iorwf   4, F
    iorwf   5, W

ins_lslf:
    lslf    4, F
    lslf    5, W

ins_lsrf:
    lsrf    4, F
    lsrf    5, W

ins_movf:
    movf    4, F
    movf    5, W

ins_movwf:
    movwf   4
    movwf   5

ins_rlf:
    rlf     4, F
    rlf     5, W

ins_rrf:
    rrf     4, F
    rrf     5, W

ins_subwf:
    subwf   4, F
    subwf   5, W

ins_subwfb:
    subwfb   4, F
    subwfb   5, W

ins_swapf:
    swapf   4, F
    swapf   5, W

ins_xorwf:
    xorwf   4, F
    xorwf   5, W


; == Byte-oriented skip operations ==

ins_decfsz:
    decfsz  4, F
    decfsz  5, W

ins_incfsz:
    incfsz  4, F
    incfsz  5, W


; == Bit-oriented operations ==

ins_bcf:
    bcf     4, 6
    bcf     5, 7

ins_bsf:
    bsf     4, 6
    bsf     5, 7


; == Bit-oriented skip operations ==

ins_btfsc:
    btfsc   4, 6
    btfsc   5, 7

ins_btfss:
    btfss   4, 6
    btfss   5, 7


; == Literal operations ==

ins_addlw:
    addlw    9

ins_andlw:
    andlw    9

ins_iorlw:
    iorlw    9

ins_movlb:
    movlb    9

ins_movlp:
    movlp    9

ins_movlw:
    movlw    9

ins_sublw:
    sublw    9

ins_xorlw:
    xorlw    9


; == Control operations ==

ins_bra:
    bra     $ + 5
    bra     $ - 3
    bra     $ + 1
    bra     $ + 0x100
    bra     $ - 0xFF

ins_brw:
    brw

ins_call:
    call     2
    call     3

ins_callw:
    callw

ins_goto:
    goto     2

ins_retfie:
    retfie

ins_retlw:
    retlw    9

ins_return:
    return


; == Inherent operations ==

ins_clrwdt:
    clrwdt

ins_nop:
    nop

ins_option:
    errorlevel -224
    option
    errorlevel +224

ins_reset:
    reset

ins_sleep:
    sleep

ins_tris:
    errorlevel -224
    tris     5
    tris     7
    errorlevel +224

; C-compiler optimized

ins_addfsr:
    addfsr   0, 9
    addfsr   1, d'64'-9
    addfsr   0, 0
    addfsr   0, d'31'
    addfsr   0, d'64'-d'32'

ins_moviw:
    moviw    ++FSR1
    moviw    2[FSR0]

ins_movwi:
    movwi    ++FSR1
    movwi    2[FSR0]
  end
