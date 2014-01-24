  #include p10F322_and_config.inc
  udata
x res 2
y res 2
z res 2
  code 0
addition  ; 16-bit addition routine:  z = x + y
  movf    x, W
  addwf   y, W
  movwf   z
  movf    x + 1, W
  btfsc   STATUS, C
  addlw   1
  addwf   y + 1, W
  movwf   z + 1
  return
  end