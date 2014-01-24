  #include p10F322_and_config.inc
  udata
xu8 res 1
xs8 res 1
xu16 res 2
yu16 res 2
zu16 res 2
xs16 res 2
xu24 res 3
xs24 res 3
xu32 res 4
xs32 res 4
  code 0
addition  ; 16-bit addition routine:  zu16 = yu16 + xu16
  movf    xu16, W
  addwf   yu16, W
  movwf   zu16
  movf    xu16 + 1, W
  btfsc   STATUS, C
  addlw   1
  addwf   yu16 + 1, W
  movwf   zu16 + 1
  return
  
  end