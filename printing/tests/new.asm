go:
  mov AH, 0Eh
  mov AL, 57h
  int 10h

;;; nasm -f bin -o new.com new.asm
