  #include p10F322_and_config.inc
  udata
x res 1
  code 0
ReadPMADRL
  movf  PMADRL, W
  movwf x
  return
  end