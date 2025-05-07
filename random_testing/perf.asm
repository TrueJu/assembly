;nasm -felf64 -g perf.asm && ld perf.o      -> -g for debugging with gdb
;nasm -felf64 -g perf.asm && ld perf.o && ./a.out
;gdb ./a.out
;break _start
;run
;step
;next for stepping over
;info registers for seeing the registers

section .data
    stri db "1", 10, 0

section .text
    global  _start

_start:
    xor r12, r12
    mov r12, 0
    call _countPrintLoop
    call _exit

_exit:
    mov rax, 60
    mov rdi, 0
    syscall

    ret

_countPrintLoop:
    inc r12
    mov rax, stri
    call _print
    cmp r12, 10000000
    jl _countPrintLoop

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