section .text
global _start

_start:
  mov ah, 0x0E ; Function to print a character
  mov al, 'C'  ; Character to print
  int 0x10

  ; Halt
  hlt
