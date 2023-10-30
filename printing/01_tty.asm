start:
  mov AH, 0Eh ; Teletype output(TTY)
  mov AL, 58h ; Character to print (X)
  int 10h     ; Call BIOS interrupt