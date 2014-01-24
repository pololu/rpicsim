  #include p10F322_and_config.inc
  udata
hot res 1
counter res 2
  code 0

cooldown:
  btfsc hot, 0
  call bigDelay
  call bigDelay
  return

bigDelay:
  movlw   255
  movwf   counter
  movlw   255
  movwf   counter + 1
delayLoop:
  decfsz  counter, F
  goto    delayLoop
  decfsz  counter+1, F
  goto    delayLoop
  return
  end