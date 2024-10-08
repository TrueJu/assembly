;nasm -felf64 -g inputs.asm && ld inputs.o      -> -g for debugging with gdb
;nasm -felf64 -g inputs.asm && ld inputs.o && ./a.out
;gdb ./a.out
;break _start
;run
;step
;next for stepping over
;info registers for seeing the registers

section .data
    question db "What is your name? ",0
    greeting db "Hello, ",0
    nl db 10,0

section .bss
    name resb 16

section .text
    global  _start

%define USER_INPUT_BUFFER_SIZE 16

_start:
    ; Ask for the user's name
    mov rax, question
    call _print

    ; Get the user's name
    mov rsi, name
    mov rdx, USER_INPUT_BUFFER_SIZE
    call _getInput

    ; Print the greeting
    mov rax, greeting
    call _print
    mov rax, name
    call _print
    mov rax, nl
    call _print

    call _exit

_exit:
    mov rax, 60
    mov rdi, 0
    syscall

    ret

; rsi: buffer
; rdx: buffer size
_getInput:
    mov rax, 0
    mov rdi, 0
    syscall

    ret

; rax: string
_print:
    push rax
    mov rbx, 0
_printLoop:
    inc rax
    inc rbx
    mov cl, [rax]
    cmp cl, 0
    jne _printLoop

    mov rax, 1
    mov rdi, 1
    pop rsi
    mov rdx, rbx
    syscall

    ret