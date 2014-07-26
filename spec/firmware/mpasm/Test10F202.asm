  #include p10f202.inc
  __config (_MCLRE_OFF & _CP_OFF & _WDT_OFF)

rst code 0
    goto start

main code 0x40
start
    goto $

; == Byte-oriented instructions ==

ins_addwf:
    addwf   4, F
    addwf   5, W

ins_andwf:
    andwf   4, F
    andwf   5, W

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

ins_decfsz:
    decfsz  4, F
    decfsz  5, W

ins_incf:
    incf    4, F
    incf    5, W

ins_incfsz:
    incfsz  4, F
    incfsz  5, W

ins_iorwf:
    iorwf   4, F
    iorwf   5, W

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

ins_swapf:
    swapf   4, F
    swapf   5, W

ins_xorwf:
    xorwf   4, F
    xorwf   5, W

; == Bit-oriented operations ==

ins_bcf:
    bcf     4, 6
    bcf     5, 7

ins_bsf:
    bsf     4, 6
    bsf     5, 7

ins_btfsc:
    btfsc   4, 6
    btfsc   5, 7

ins_btfss:
    btfss   4, 6
    btfss   5, 7


; == Literal and control operations ==

ins_andlw:
    andlw   9

ins_call:
    call    2
    call    3

ins_clrwdt:
    clrwdt

ins_iorlw:
    iorlw   9

ins_goto:
    goto    2

ins_movlw:
    movlw   9

ins_nop:
    nop

ins_option:
    option

ins_retlw:
    retlw   9

ins_sleep:
    sleep

ins_tris:
    tris    5
    tris    7

ins_xorlw:
    xorlw   9

  end
