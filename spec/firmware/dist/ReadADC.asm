  #include p10F322_and_config.inc
  code 0
ReadADC
  movlw   b'10100101'         ;Turn on the ADC, select AN1 and FOSC/16.
  movwf   ADCON
  bsf     ADCON, GO_NOT_DONE  ;Start the ADC reading.
analogReadLoop
  btfsc   ADCON, GO_NOT_DONE
  goto    analogReadLoop      ;Reading is not done yet.
  return
  end