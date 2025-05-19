;nasm -felf64 -g bubblesort.asm && ld bubblesort.o -g -> for debugging with gdb -> regular run: gdb ./a.out
;nasm -felf64 -g bubblesort.asm && ld bubblesort.o && ./a.out -> for normal execution

section .data
    askForInteger db "Bitte geben Sie eine Zahlenreihe ein (max 8 Nummern lang): ",0
    sortedAnswer db "Die sortierte Zahlenreihe ist: ",0

section .bss
    input resb 9
    result resd 1
    buffer resb 32

section .text
    global  _start

%define INPUT_BUFFER_SIZE 9

_start:
    mov rax, askForInteger
    call _print

    mov rsi, input
    mov rdx, INPUT_BUFFER_SIZE
    call _getInput

    mov rsi, input
    call _stringToInt
    mov rax, [result]

    call _bubblesort

    push rax
    mov rax, sortedAnswer
    call _print
    pop rax

    mov rsi, buffer
    call _intToStr
    call _print

    call _nL

    call _exit


; rax: list of integers to sort
_bubblesort:
    mov r10, 0
    mov r14, 0
    mov r15, 0

    push rax
    call _getIntLength
    mov r8, rax
    pop rax

    call .outerLoop

.incrementOuter:
    add r10, 1

.outerLoop:     ; i
    cmp r10, r8
    jg bubblesortDone

    mov r12, 0

.innerLoop:     ; j
    mov r13, r8
    sub r13, r10
    sub r13, 1

    cmp r12, r13
    jg .incrementOuter

    push rax
    mov rbx, r12
    call _getNthInteger
    mov r14, rax
    pop rax

    push rax
    mov rbx, r12
    add rbx, 1
    call _getNthInteger
    mov r15, rax
    pop rax

    add r12, 1

    cmp r15, r14
    jg .innerLoop

    sub r12, 1

    ; switch the two numbers inside the list
    mov rbx, r12
    mov rsi, r15
    call _replaceNthInteger

    mov rbx, r12
    add rbx, 1
    mov rsi, r14
    call _replaceNthInteger

    add r12, 1

    call .innerLoop

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
    jle .powerDone
    
    mulsd xmm3, xmm2

    dec rsi
    jmp .getPowerLoop
    
.powerDone:
    movsd xmm2, xmm3
    ret

; rsi: string
_stringToInt:
    xor rax, rax
    xor rcx, rcx

.atoi_loop:
    movzx rdx, byte [rsi]
    test rdx, rdx
    jz .atoi_done

    cmp rdx, '0'
    jl .atoi_done
    cmp rdx, '9'
    jg .atoi_done

    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    jmp .atoi_loop

.atoi_done:
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

_nL:
    xor rax, rax
    sub rsp, 16
    mov word [rsp], 0x0A00
    mov rax, rsp
    call _print
    add rsp, 16
    ret

; rax: string
_print:
    push rax

    mov rbx, 0
.printLoop:
    inc rax
    inc rbx
    mov cl, [rax]
    cmp cl, 0
    jne .printLoop

    mov rax, 1
    mov rdi, 1
    pop rsi
    mov rdx, rbx
    syscall         ; messes with r11, TODO: restore r11

    ret

; rax: int to reverse
_reverseInteger:
    push rbx
    push rcx
    push rdx
    mov rbx, 0

    mov rcx, 10
.rvIntLoop:
    xor rdx, rdx
    div rcx

    imul rbx, 10
    add rbx, rdx
    
    cmp rax, 0
    jne .rvIntLoop

    mov rax, rbx
    pop rdx
    pop rcx
    pop rbx
    ret

; rax: int to index
; rbx: index
_getNthInteger:
    call _reverseInteger

    push r8
    push rdx
    push rcx
    push rbx

    xor r8, r8
    mov r8, 10

    add rbx, 1
    mov rcx, 0

.intIndexLoop:
    xor rdx, rdx
    div r8

    add rcx, 1
    cmp rbx, rcx
    je .getNthIntegerDone

    cmp rax, 0
    jne .intIndexLoop

.getNthIntegerDone:
    mov rax, rdx
    
    pop rbx
    pop rcx
    pop rdx
    pop r8

    ret


; rax: int
; rbx: index to replace
; rsi: int to replace with
_replaceNthInteger:
    call _reverseInteger

    push r9
    push r8
    push rdx
    push rcx
    push rbx
    push rsi

    xor r8, r8
    mov r8, 10
    mov r9, 0

    add rbx, 1
    mov rcx, 0

.intReplaceIndexLoop:
    xor rdx, rdx
    div r8

    add rcx, 1
    cmp rbx, rcx
    jne .dontReplace

.replace:
    imul r9, 10
    add r9, rsi

    cmp rax, 0
    jne .intReplaceIndexLoop
    je .replaceNthIntegerDone

.dontReplace:
    imul r9, 10
    add r9, rdx

    cmp rax, 0
    jne .intReplaceIndexLoop

.replaceNthIntegerDone:
    mov rax, r9
    
    pop rsi
    pop rbx
    pop rcx
    pop rdx
    pop r8
    pop r9

    ret

; rax: int to get the length of
_getIntLength:
    push rcx
    push rdx
    push r8

    mov r8, 0
    mov rcx, 10
.rvIntLoop:
    xor rdx, rdx
    div rcx

    add r8, 1
    
    cmp rax, 0
    jne .rvIntLoop

    mov rax, r8

    pop r8
    pop rdx
    pop rcx
    ret