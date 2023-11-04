org 0x7c00 ; Load program at address 0x7c00

start:
  mov AH, 13h     ; Function 13h, Write String
  mov AL, 0       ; Do not update cursor
  mov BL, 14      ; Attribute/Color of text (14 = yellow)
  mov DH, 1       ; Row position where string is to be written
  mov DL, 25      ; Column position where string is to be written	
  mov CX, msg_len ; Length of message
  mov BP, msg     ; Pointer to message
  int 10h         ; Call BIOS video interrupt

section .data
  msg db "Hello to Assembly Club", 0  ; db = define byte, 0 = null terminator
  msg_len equ $-msg        