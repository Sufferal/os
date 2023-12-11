org 4000h 
bits 16

jmp start

%include "print_string.asm"

start: 
    mov al, 0x3						
    mov ah, 0						
    int 0x10

    mov si, help
    call print_string_si

    mov bx, 0                         
    mov byte [counter], 0
    mov si, buffer					

read_key:
	mov ah, 0
	int 0x16                    ; Read keypress

	cmp ah, 0x0e				; Backspace 
	je input_bksp
	
	cmp ah, 0x1c				; Enter
	je input_enter
 
    cmp al, 0x2f                ; Slash '/'
    je go_back 

    cmp al, 0x20
    jge echo_char

	jmp read_key				; Always read for keyboard inputs


input_bksp:
	cmp si, buffer				; Check if buffer is empty
	je read_key					
	dec si
    dec bx
    dec byte [counter]
	mov byte [si], 0			; Delete last char in buffer

	mov ah, 0x03
	mov bh, 0
	int 0x10

	cmp dl, 0					; Check if cursor is at the start of the line
	jz prev_line				
	jmp prev_char				
	
prev_char:
	mov ah, 0x02
	dec dl
	int 0x10
	jmp overwrite_char

prev_line:
	mov ah, 0x02
	mov dl, 79
	dec dh
	int 0x10

overwrite_char:
	mov ah, 0xa					
	mov al, 0x20				
	mov cx, 1					
	int 0x10
	jmp read_key				

reverse_buffer:
    push si
    push di
    push ax
    push cx 

    dec bx
    lea si, [buffer + bx]
    mov di, buffer_rev
    mov cx, 0

    rev_loop:
        mov al, [si]
        mov [di], al

        dec si
        inc di
        inc cx

        cmp cx, 255
        jne rev_loop

        pop ax
        pop cx 
        pop di
        pop si
        jmp print_echo 

is_palindrome:
    push si
    push di
    push ax
    push cx
    push dx

    inc byte [result]
    mov si, buffer
    mov di, buffer_rev
    mov cx, 0

    comp:
        mov al, [si]
        mov dl, [di]
        cmp al, dl
        jne not_equal

        cmp cx, [counter]
        je equal

        inc si
        inc di
        inc cx

        cmp cx, [counter]
        jne comp

    equal:
        pop si
        pop di
        pop ax
        pop cx
        pop dx
        jmp print_result

    not_equal:
        pop si
        pop di
        pop ax
        pop cx
        pop dx
        dec byte [result]
        jmp print_result

input_enter:
	mov ah, 0x03
	mov bh, 0
	int 0x10					; x = DL, y = DH

	sub si, buffer				; Check if buffer is empty
	jz write_newline			

	mov ah, 0x03				; DL, DH store cursor (x,y) positions
	mov bh, 0
	int 0x10
    
    cmp dh, 24
    jge start
	
	cmp dh, 24
	jl reverse_buffer
	
	mov ah, 0x06				; Scroll down once to make space for the string
	mov al, 1
	mov bh, 0x07				; Draw new line as White on Black
	mov cx, 0					; (0,0): Top-left corner of the screen
	mov dx, 0x184f				; (79,24): Bottom-right corner of the screen
	int 0x10
	mov dh, 0x17				; Move cursor 1 line above target
	
print_echo:
	mov bh, 0 					; Video page number.
	mov ax, 0
	mov es, ax 					; ES:BP is the pointer to the buffer
	mov bp, buffer_rev 

	mov bl, 14				    ; Attribute: Yellow on Black
	mov cx, si					; String length
	inc dh						; y coordinate
	mov dl, 0					; x coordinate

	mov ax, 0x1301				; Write mode: character only, cursor moved
	int 0x10

write_newline:
	cmp dh, 24					; Last line of the screen
	je scroll_down				; Scroll screen down 1 line

	mov ah, 0x03				; DL, DH store cursor (x,y) positions
	mov bh, 0
	int 0x10

	jmp move_down 

scroll_down:
	mov ah, 0x06
	mov al, 1
	mov bh, 0x07				; Draw new line as White on Black
	mov cx, 0					; (0,0): Top-left corner of the screen
	mov dx, 0x184f				; (79,24): Bottom-right corner of the screen
	int 0x10
	mov dh, 0x17				; Move cursor 1 line above target

move_down:
	mov ah, 0x02				; Move the cursor at the start of the line below this one
	mov bh, 0
	inc dh
	mov dl, 0
	int 0x10

    jmp is_palindrome 

clear_buffer:
	mov byte [si], 0			; Replace every non 0 byte to 0 in the buffer
	inc si
	cmp si, 0
	jne clear_buffer

    ; Print new line
    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0a
    int 0x10
    mov al, 0x08
    int 0x10

    add si, buffer_rev
    jmp clean_buffer_rev

	mov si, buffer
	jmp read_key

print_result:
    cmp byte [result], 1
    je print_true

    ; Not palindrome
    mov ah, 0x0e
    mov al, '0'
    int 0x10
    
    add si, buffer
    jmp clear_buffer

print_true:
    mov ah, 0x0e
    mov al, '1'
    int 0x10
    
    add si, buffer
clean_buffer_rev:
    mov byte [si], 0			; Replace every non 0 byte to 0 in the buffer
    inc si
    cmp si, 0
    jne clean_buffer_rev

    mov bx, 0
    mov byte [counter], 0
    mov si, buffer
    jmp read_key

echo_char:
	cmp si, buffer + 255		; If buffer is at max size (255), ignore further inputs
	je read_key
	mov [si], al

	inc si
    inc bx
    inc byte [counter]

	mov ah, 0xe					; Echo any valid characters to screen
	int 10h

    jmp read_key

go_back: 
    mov al, 0x3						
    mov ah, 0						
    int 0x10

    mov ah, 00
    int 13h

    mov ax, 0000h
    mov es, ax
    mov bx, 7d00h 

    mov ah, 02h
    mov al, 5 
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0
    int 13h

    jmp 0000h:7d00h

help: db "Check if string is a palindrome (0 = false, 1 = true): ", 0xd, 0xa, 0 
help_len: equ $-help
buffer: times 256 db 0x0		; Empty 256 char buffer for our code
buffer_rev: times 256 db 0x0		; Empty 256 char buffer for our code
result: db 0
counter: db 0