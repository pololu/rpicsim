  #include p10F322_and_config.inc
  udata
x res 2
  code 0

; Target word 0x100 of normal flash.
setupNormalFlash
  clrf PMADRL
  movlw 1
  movwf PMADRH
  bcf PMCON1, CFGS
  return

; Target the first User ID word.
setupUserId0
  clrf PMADRL
  clrf PMADRH
  bsf PMCON1, CFGS
  return
  
readX
  ; Put dummy data in to make sure the simulator actually performs the read.
  movlw 0xAA
  movwf PMDATL
  movlw 0x0A
  movwf PMDATH
  bsf PMCON1, RD   ; Set RD bit.
  nop              ; Two nops are required as shown in Figure 9-1 of the datasheet.
  nop
  movf PMDATL, W
  movwf x
  movf PMDATH, W
  movwf x + 1
  return
  
saveX
  bsf PMCON1, WREN  ; Enable erasing and writing.

  ; Erase
  bsf PMCON1, FREE
  call flashRequiredSequence

  ; Write.
  movf x, W
  movwf PMDATL
  movf x + 1, W
  movwf PMDATH
  bcf PMCON1, FREE
  call flashRequiredSequence
  return
  
flashRequiredSequence
  movlw   0x55
  movwf   PMCON2
  movlw   0xAA
  movwf   PMCON2
  bsf     PMCON1, WR    ; WR=1: Begin the write or erase.
  nop                   ; Ignored.
  nop                   ; Ignored.
  return
  
normalFlashBlock code 0x100
normalFlashVar
  dw 0x801
  dw 0x3FFF
flashu16
  retlw 0xCD
  retlw 0xAB
  
idSection code 0x2000
userId0
  dw 0x14B
  dw 0x14C
  dw 0x14D
  dw 0x14E
  end