  #include p18F25K50_and_config.inc

  udata
var1 res 1
var2 res 2
resultVar res 2

rst code 0
  goto start
  
isr code 4
isr
  call emptyRoutine
  retfie

flashVars code 0x20
flashVar1
  dw 0x5544
flashVar2
  db 0x11, 0x22
  
main code 0x40
start
  bra $

emptyRoutine:
  return
  
invalidInstruction:
  dw 0x0001

testCall:
  call emptyRoutine
  return

readFlashVar1:
  movlw     low(flashVar1)
  movwf     TBLPTRL
  movlw     high(flashVar1)
  movwf     TBLPTRH
  tblrd*+
  movff     TABLAT, resultVar
  tblrd*
  movff     TABLAT, resultVar + 1
  return

  
instructions code 0x1000

; == Byte-oriented instructions ==

ins_addwf:
    addwf   4, F, ACCESS
    addwf   5, W, BANKED

ins_addwfc:
    addwfc  4, F, ACCESS
    addwfc  5, W, BANKED

ins_andwf: 
    andwf   4, F, ACCESS
    andwf   5, W, BANKED

ins_clrf:
    clrf    4, ACCESS
    clrf    5, BANKED

ins_comf:
    comf    4, F, ACCESS
    comf    5, W, BANKED
    
ins_cpfseq:
    cpfseq  4, ACCESS
    cpfseq  5, BANKED

ins_cpfsgt:
    cpfsgt  4, ACCESS
    cpfsgt  5, BANKED

ins_cpfslt:
    cpfslt  4, ACCESS
    cpfslt  5, BANKED

ins_decf:
    decf    4, F, ACCESS
    decf    5, W, BANKED

ins_decfsz:
    decfsz  4, F, ACCESS
    decfsz  5, W, BANKED

ins_dcfsnz:
    dcfsnz  4, F, ACCESS
    dcfsnz  5, W, BANKED

ins_incf:
    incf    4, F, ACCESS
    incf    5, W, BANKED

ins_incfsz:
    incfsz  4, F, ACCESS
    incfsz  5, W, BANKED

ins_infsnz:
    infsnz  4, F, ACCESS
    infsnz  5, W, BANKED

ins_iorwf:
    iorwf   4, F, ACCESS
    iorwf   5, W, BANKED

ins_movf:
    movf    4, F, ACCESS
    movf    5, W, BANKED

ins_movff:
    movff   6, 7

ins_movwf:
    movwf   4, ACCESS
    movwf   5, BANKED
    
ins_mulwf:
    mulwf   4, ACCESS
    mulwf   5, BANKED

ins_negf:
    negf    4, ACCESS
    negf    5, BANKED

ins_rlcf:
    rlcf    4, F, ACCESS
    rlcf    5, W, BANKED

ins_rlncf:
    rlncf   4, F, ACCESS
    rlncf   5, W, BANKED

ins_rrcf:
    rrcf    4, F, ACCESS
    rrcf    5, W, BANKED

ins_rrncf:
    rrncf   4, F, ACCESS
    rrncf   5, W, BANKED

ins_setf:
    setf    4, ACCESS
    setf    5, BANKED

ins_subwf:
    subwf   4, F, ACCESS
    subwf   5, W, BANKED

ins_subwfb:
    subwfb  4, F, ACCESS
    subwfb  5, W, BANKED

ins_swapf:
    swapf   4, F, ACCESS
    swapf   5, W, BANKED

ins_tstfsz:
    tstfsz  4, ACCESS
    tstfsz  5, BANKED

ins_xorwf:
    xorwf   4, F, ACCESS
    xorwf   5, W, BANKED

; == Bit-oriented operations ==

ins_bcf:
    bcf     4, 6, ACCESS
    bcf     5, 7, BANKED

ins_bsf:
    bsf     4, 6, ACCESS
    bsf     5, 7, BANKED

ins_btfsc:
    btfsc   4, 6, ACCESS
    btfsc   5, 7, BANKED

ins_btfss:
    btfss   4, 6, ACCESS
    btfss   5, 7, BANKED

ins_btg:
    btg     4, 6, ACCESS
    btg     5, 7, BANKED

    
; == Control operations ==

ins_bc:
    bc      $ + 0xC
    bc      $ - 0x8
    bc      $ + 2
    bc      $ + 0x100
    bc      $ - 0xFE

ins_bn:
    bn      $ + 0xC
    bn      $ - 0x8
    bn      $ + 2
    bn      $ + 0x100
    bn      $ - 0xFE

ins_bnc:
    bnc     $ + 0xC
    bnc     $ - 0x8
    bnc     $ + 2
    bnc     $ + 0x100
    bnc     $ - 0xFE

ins_bnn:
    bnn     $ + 0xC
    bnn     $ - 0x8
    bnn     $ + 2
    bnn     $ + 0x100
    bnn     $ - 0xFE

ins_bnov:
    bnov    $ + 0xC
    bnov    $ - 0x8
    bnov    $ + 2
    bnov    $ + 0x100
    bnov    $ - 0xFE

ins_bnz:
    bnz     $ + 0xC
    bnz     $ - 0x8
    bnz     $ + 2
    bnz     $ + 0x100
    bnz     $ - 0xFE

ins_bov:
    bov    $ + 0xC
    bov    $ - 0x8
    bov    $ + 2
    bov    $ + 0x100
    bov    $ - 0xFE
    
ins_bra:
    bra     $ + 0xC
    bra     $ - 0x8
    bra     $ + 2
    bra     $ + 0x800
    bra     $ - 0x7FE

ins_bz:
    bz      $ + 0xC
    bz      $ - 0x8
    bz      $ + 2
    bz      $ + 0x100
    bz      $ - 0xFE
    
ins_call:
    call    4, 0
    call    6, 1

ins_clrwdt:
    clrwdt
    
ins_daw:
    daw

ins_goto:
    goto    2

ins_nop:
    nop

ins_pop:
    pop

ins_push:
    push

ins_rcall:
    rcall    $ + 0xC
    rcall    $ - 0x8
    rcall    $ + 2
    rcall    $ + 0x800
    rcall    $ - 0x7FE
    
ins_reset:
    reset

ins_retfie:
    retfie   0
    retfie   1

ins_retlw:
    retlw    9

ins_return:
    return   0
    return   1

ins_sleep:
    sleep

; Literal operations

ins_addlw:
    addlw    9

ins_andlw:
    andlw    9

ins_iorlw:
    iorlw    9

ins_lfsr:
    lfsr     FSR0, 0x18
    lfsr     FSR2, 0x19

ins_movlb:
    movlb    9

ins_movlw:
    movlw    9

ins_mullw:
    mullw    9

ins_sublw:
    sublw    9
    
ins_xorlw:
    xorlw    9

; Program memory operations

ins_tblrd:
    tblrd*
    
ins_tblrd_postinc:
    tblrd*+

ins_tblrd_postdec:
    tblrd*-
    
ins_tblrd_preinc:
    tblrd+*
    
ins_tblwt:
    tblwt*
    
ins_tblwt_postinc:
    tblwt*+
    
ins_tblwt_postdec:
    tblwt*-
    
ins_tblwt_preinc:
    tblwt+*

  end