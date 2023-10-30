start:
  mov AH, 09h ; Function 09h = Write Character and Attribute at Cursor Position
  mov AL, 'O' ; Character to write
  mov BL, 14  ; Attribute/Color
  mov CX, 1   ; Number of characters to write
  int 10h     ; Call BIOS video interrupt