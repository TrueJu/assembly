;nasm -felf64 -g zinseszins.asm && ld zinseszins.o      -> -g for debugging with gdb
;nasm -felf64 -g zinseszins.asm && ld zinseszins.o && ./a.out
;gdb ./a.out
;break _start
;run
;step
;next for stepping over
;info registers for seeing the registers

section .data
    questionCapital db "Was ist Ihr Kapital in CHF? ",0
    questionInterest db "Wie hoch ist Ihr Zins? ",0
    questionYears db "Welche Laufzeit in Jahren soll berechnet werden? ",0
    answer db "Ihr Zinseszins beträgt: ",0
    nl db 10,0
    stri db "123456", 0

section .bss
    capital resb 7
    interest resb 2
    years resb 3
    result resd 1

section .text
    global  _start

%define CAPITAL_BUFFER_SIZE 7
%define INTEREST_BUFFER_SIZE 2
%define YEARS_BUFFER_SIZE 3

_start:
    ; Ask for the user's capital
    mov rax, questionCapital
    call _print
    mov rsi, capital
    mov rdx, CAPITAL_BUFFER_SIZE
    call _getInput

    ; Ask for the user's interest
    mov rax, questionInterest
    call _print
    mov rsi, interest
    mov rdx, INTEREST_BUFFER_SIZE
    call _getInput

    ; Ask for the duration in years
    mov rax, questionYears
    call _print
    mov rsi, years
    mov rdx, YEARS_BUFFER_SIZE
    call _getInput

    ;mov rbx, 3
    ;call _getPowerOfTen

    mov rsi, stri
    call _stringToInt
    mov rbx, 1000
    xor rdx, rdx
    div rbx


    call _exit

_exit:
    mov rax, 60
    mov rdi, 0
    syscall

    ret

; rbx: number
_getPowerOfTen:
    xor rax, rax
    mov rax, 1
    xor rdx, rdx
    
.loop: 
    cmp rdx, rbx
    jge powerOfTenDone
    imul rax, 10
    inc rdx
    jmp .loop

powerOfTenDone:
    ret  

; rsi: string
_stringToInt:
    xor rax, rax
    xor rcx, rcx

atoi_loop:
    movzx rdx, byte [rsi]
    test rdx, rdx
    jz atoi_done
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    jmp atoi_loop

atoi_done:
    mov [result], eax

    
    ret

; rdi: capital
; rsi: interest
; rdx: years
_calculateCompuntInterest:
    mov rax, 0
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