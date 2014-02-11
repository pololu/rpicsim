  #include p18F25K50_and_config.inc

  udata
var1 res 1
var2 res 2
  
rst code 0
  goto start
  
isr code 4
isr
  call emptyRoutine
  retfie
  
main code 0x20
start
  call disasmSkipTest
  call disasmBranchTest
  bra $

emptyRoutine:
  return
  
disasmSkipTest code 0x0040
disasmSkipTest

  ; Test every skipping instruction with a two-word goto.
  ; If any of these are misinterpreted as not a skip, then
  ; the analyzer cannot get to the end and it will detect the wrong
  ; call stack depth.

  cpfseq var1, ACCESS
  return

  cpfsgt var1, ACCESS
  return

  cpfslt var1, ACCESS
  return

  decfsz var1, ACCESS
  return

  dcfsnz var1, ACCESS
  return

  incfsz var1, ACCESS
  return

  infsnz var1, ACCESS
  return
  
  tstfsz var1, ACCESS
  return
  
  btfsc LATA, 0
  return

  btfss LATA, 1
  return
  
  call emptyRoutine
  return
  
  
disasmGotoTest code 0x0100
disasmGotoTest
  btfsc LATA, 0
  bra emptyRoutine
  goto emptyRoutine 

disasmBranchTest code 0x0080
disasmBranchTest
  ; Test condition branches.  If our code doesn't allow for the possibility that the branch
  ; can be taken or not taken, then it will not think the end of this routine is reachable.
  
  bc emptyRoutine
  bc $ + 2
  goto emptyRoutine 

  bn emptyRoutine
  bn $ + 2
  goto emptyRoutine 

  bnc emptyRoutine
  bnc $ + 2
  goto emptyRoutine 

  bnn emptyRoutine
  bnn $ + 2
  goto emptyRoutine 

  bnov emptyRoutine
  bnov $ + 2
  goto emptyRoutine 

  bnz emptyRoutine
  bnz $ + 2
  goto emptyRoutine 

  bov emptyRoutine
  bov $ + 2
  goto emptyRoutine 

  bz emptyRoutine
  bz $ + 2
  goto emptyRoutine  
  
  call emptyRoutine
  return
  
  end