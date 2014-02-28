  #include p10f322.inc
  __config(0x3E06)
  code 0
  clrf  ANSELA
  bcf   TRISA, 1
loopStart
  btfss PORTA, 0
  bcf   LATA, 1
  btfsc PORTA, 0
  bsf   LATA, 1
  goto  loopStart
  end
