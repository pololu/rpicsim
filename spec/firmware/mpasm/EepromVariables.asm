  #include p18f25k50_and_config.inc
  code 0
  
eepromRead:
    clrf     EECON1
    bsf      EECON1, RD
    movf     EEDATA, W
    return

eepromWrite:
    movwf    EEDATA
    clrf     EECON1
    bsf      EECON1, WREN

    movlw    0x55
    movwf    EECON2
    movlw    0xAA
    movwf    EECON2
    bsf      EECON1, WR

writeCompletionLoop:
    btfsc    EECON1, WR
    bra      writeCompletionLoop
    return
  
eepromBlock code 0xF00010
eepromVar1
  db 0x84
  
  end