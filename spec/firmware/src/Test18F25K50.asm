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
    
ins_goto:
    goto    2
    goto    3

    ; TODO: add the rest of the instructions
    
    
  end