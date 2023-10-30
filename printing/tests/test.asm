go:
  mov AH, 0Eh
  mov AL, 1Dh
  int 10h

;;; nasm -f bin -o test.com test.asm