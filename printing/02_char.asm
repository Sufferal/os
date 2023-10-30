start:
  mov AH, 0Ah ; Function 0Ah - Write character
  mov AL, 'K' ; Character to write
  mov CX, 1   ; Number of characters to write
  int 10h     ; Call BIOS video interrupt