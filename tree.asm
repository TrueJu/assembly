;nasm -felf64 -g tree.asm && ld tree.o      -> -g for debugging with gdb
;gdb ./a.out
;break _start
;run
;step
;next for stepping over
;info registers for seeing the registers

global  _start
section .text

_start:
    mov rdx, output
    mov r8, 1
    mov r9, 0
    mov r10, 0
    mov r12, 0

init_space_count:
    xor rax, rax
    xor rbx, rbx

    mov rax, max_lines
    sub rax, r8
    shr rax, 1

    mov rbx, 2
    mul rbx
    mov r12, rax

    xor rax, rax
    xor rbx, rbx

space:
    lea rax, [output + data_size]
    cmp rdx, rax
    jae done
    xor rax, rax
    ; mov rdx, output

    mov byte [rdx], 95
    inc rdx
    inc r10
    dec r12
    cmp r12, r10
    jl space

hashtag:
    lea rax, [output + data_size]
    cmp rdx, rax
    jae done

    mov byte [rdx], 35
    inc rdx
    inc r9
    cmp r9, r8
    jne hashtag

line_done:
    lea rax, [output + data_size]
    cmp rdx, rax
    jae done

    mov byte [rdx], 10
    inc rdx
    inc r8
    xor r9, r9
    xor r10, r10
    xor r12, r12
    
    cmp r8, max_lines
    jng init_space_count

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

max_lines equ 6
data_size equ 96
output: resb data_size
