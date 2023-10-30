start:
  mov AH, 09h ; Function 09h = Write Character and Attribute at Cursor Position
  mov AL, 'F' ; Character to write
  mov BL, 2   ; Attribute/Color
  mov CX, 20  ; Number of characters to write
  int 10h     ; Call BIOS video interrupt