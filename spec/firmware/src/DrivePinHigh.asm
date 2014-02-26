  #include p10F322_and_config.inc
  code 0
  goto $
  
ClearAClearTSetL
  clrf  ANSELA
  bcf   TRISA, 0
  bsf   LATA, 0
  return

ClearTSetL
  bcf   TRISA, 0
  bsf   LATA, 0
  return

SetLClearT
  bsf   LATA, 0
  bcf   TRISA, 0
  return

ClearAClearTSetLClearT
  clrf  ANSELA
  bcf   TRISA, 0
  bsf   LATA, 0
  bcf   TRISA, 0
  return

  end