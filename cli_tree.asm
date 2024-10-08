global  _start
section .text

_start:
    mov rdx, output
    mov r8, 1
    mov r9, 0

hashtag:
    mov byte [rdx], 35
    inc rdx
    inc r9
    cmp r9, r8
    jne hashtag

line_done:
    mov byte [rdx], 10
    inc rdx
    inc r8
    mov r9, 0
    cmp r8, max_lines
    jng hashtag

done:
    mov rax, 1
    mov rdi, 1
    mov rsi, output
    mov rdx, data_size
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

section .bss

max_lines equ 8
data_size equ 44
output: resb data_size
