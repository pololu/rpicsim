  #include p10F322_and_config.inc
  ; This is supposed to be a test for the call stack analyzer, so we should
  ; include all the special cases that it handles.
  
  udata
var1 res 1
var2 res 2
  
rst code 0
  goto start
  
isr code 4
isr
  call joo
  retfie
  
main code 0x20
start
  btfsc LATA, 0
  goto start2
  call goo
  call hoo
start2
  call foo
  goto start

foo code 0x40
foo
  call goo
goo
  call hoo
  return

hoo code 0x60
hoo
  call ioo
  return

ioo code 0x80
ioo
  call joo
  return

joo code 0x100
joo
  clrf LATA
  clrf TRISA
  return

  end