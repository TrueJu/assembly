;nasm -felf64 -g bubblesort.asm && ld bubblesort.o -g -> for debugging with gdb -> regular run: gdb ./a.out
;nasm -felf64 -g bubblesort.asm && ld bubblesort.o && ./a.out -> for normal execution

section .data

section .bss
    result resd 1
    buffer resb 32

section .text
    global  _start

_start:
    mov r8, 5   ; i
    mov r9, 5   ; j

    call _bubblesort

    call _exit


_bubblesort:
    nop
.outerLoop:     ; i
    cmp r8, 0
    je bubblesortDone

    sub r8, 1

.innerLoop:     ; j
    cmp r9, 0
    je .outerLoop

    sub r9, 1

    mov rax, r9
    mov rsi, buffer
    call _intToStr
    call _print

    ret


bubblesortDone:
    ret

_exit:
    mov rax, 60
    mov rdi, 0
    syscall

    ret

; xmm2: base
; rsi:  exponent
_getPower:
    xor rax, rax
    mov rax, 1
    cvtsi2sd xmm3, rax

.getPowerLoop:
    cmp rsi, 0
    jle powerDone
    
    mulsd xmm3, xmm2

    dec rsi
    jmp .getPowerLoop
    
powerDone:
    movsd xmm2, xmm3
    ret

; rsi: string
_stringToInt:
    xor rax, rax
    xor rcx, rcx

atoi_loop:
    movzx rdx, byte [rsi]
    test rdx, rdx
    jz atoi_done

    cmp rdx, '0'
    jl atoi_done
    cmp rdx, '9'
    jg atoi_done

    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    jmp atoi_loop

atoi_done:
    mov [result], eax

    ret

; rax: number to convert - result pointer
; rsi: pointer to buffer (must be large enough, e.g. 32 bytes)
_intToStr:
    mov rcx, 10         ; base 10
    mov rbx, rsi        ; save original buffer pointer
    add rsi, 30         ; go to end of buffer
    mov byte [rsi], 0   ; null terminator

.convertLoop:
    dec rsi
    xor rdx, rdx
    div rcx             ; rax /= 10, rdx = remainder
    add dl, '0'
    mov [rsi], dl
    test rax, rax
    jnz .convertLoop

    mov rax, rsi
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
    syscall         ; messes with r11, TODO: restore r11

    ret