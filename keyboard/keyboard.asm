section .data
  row db 0                 ; x 
  column db 0              ; y
  buffer times 256 db 0    ; 256 bytes buffer

section .text
  global _start

_start:
  ; Set up the stack
  mov ax, 0x0000     
  mov ss, ax          
  mov sp, 0x7C00

  ; Call BIOS to clear the screen
  call clear_screen

  ; Initialize the cursor position (row and column)
  mov si, buffer
  mov byte [row], 0
  mov byte [column], 0

main: 
  call read_char 

  ; Backspace
  cmp al, 0x08
  je backspace

  ; Enter
  cmp al, 0x0D
  je enter

  call print_char
  jmp main

backspace:
  ; Check if we are at the beginning of the current line
  cmp byte [column], 0
  je prev_line

  ; Backspace, Print a space, Backspace again
  mov ah, 0x0E
  mov al, 0x08
  int 0x10
  mov al, 0x20
  int 0x10
  mov al, 0x08
  int 0x10

  ; Update the current column
  dec byte [column]

  ; Buffer is empty
  cmp si, buffer
  je main

  ; Remove the last character from the buffer
  dec si
  mov byte [si], 0

  jmp main

prev_line:
  ; Check if we are at the beginning of the screen
  cmp byte [row], 0 
  je main

  ; Move the cursor to the beginning of the previous line
  dec byte [row]
  mov byte [column], 79
  mov ah, 0x02
  mov dh, byte [row]
  mov dl, byte [column]
  int 0x10

  jmp main

; Copy a string from SI to the screen
copy_string_loop:
  lodsb
  cmp al, 0
  je copy_string_exit
  int 0x10
  jmp copy_string_loop

copy_string_exit:
  ret ; return to the caller 

enter:
  ; Check if we are at the end of the screen
  cmp byte [row], 24
  je main

  call new_line

  ; check if the buffer is empty
  mov si, buffer
  cmp byte [si], 0
  je main

  ; Print the buffer
  mov ah, 0x0E
  mov si, buffer
  call copy_string_loop

  ; Clear the buffer, reset the buffer pointer
  mov si, buffer
  xor cx, cx
  fill_buffer_loop:
    mov byte [si], 0
    inc si
    inc cx
    cmp cx, 256
    jl fill_buffer_loop

  ; Move the cursor to the beginning of the next line
  call new_line
  call new_line

  ; Reset the buffer pointer, reset the current column
  mov si, buffer
  mov byte [column], 0
  
  jmp main

new_line:
  inc byte [row]
  mov byte [column], 0
  mov ah, 02h           ; update cursor position
  mov bh, 0             ; page number
  mov dh, byte[row]     ; row
  mov dl, byte[column]  ; column
  int 0x10              ; call BIOS
  ret ; return to the caller

read_char:
  mov ah, 0x00 ; read char from keyboard
  int 0x16     ; call BIOS
  ret ; return to the caller

print_char:
  inc byte [column]     ; Update the current column
  
  cmp byte [column], 80 ; Check if we are at the end of the screen
  je enter

  mov [si], al    ; Store the character in the buffer
  inc si          ; Update the buffer pointer

  mov ah, 0x0E  ; print char
  int 0x10      ; call BIOS
  ret ; return to the caller

clear_screen:
  mov ah, 06h   ; scroll window up
  mov al, 0     ; clear entire screen
  mov cx, 0     ; upper left corner (0, 0)
  mov dx, 184fh ; lower right corner (24, 79)
  mov bh, 1Eh   ; yellow on blue
  int 0x10
  ret ; return to the caller