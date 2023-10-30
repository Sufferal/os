org 0x7c00 ; Set origin to 0x7c00

jmp start ; Jump to start of program

section .data
  msg db "Welcome to Assembly Club"     ; db = define byte
  msg_len equ $-msg                     ; $ = current address, $-msg = length of message

start:
  mov SP, 0x7c00  ; Set stack pointer to 0x7c00
  mov AX, 1300h   ; Function 13h, Write String
  mov AL, 1       ; Subservice 0
  mov BL, 14      ; Attribute/Color of text (14 = yellow)
  mov DH, 1       ; Row position where string is to be written
  mov DL, 25      ; Column position where string is to be written	
  mov CX, msg_len ; Length of message
  mov BP, msg     ; Pointer to message
  int 10h         ; Call BIOS video interrupt