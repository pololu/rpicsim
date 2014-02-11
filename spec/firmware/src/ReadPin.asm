  #include p10F322_and_config.inc
  udata
x res 1
  code 0
ClearAnselAndReadPin
  clrf  ANSELA
ReadPin
  clrf  x
  btfsc PORTA, 0
  bsf   x, 0
  return

ClearASetTReadPin
  clrf  ANSELA
  bsf   TRISA, 0
  clrf  x
  btfsc PORTA, 0
  bsf   x, 0
  return
  
  end