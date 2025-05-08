;nasm -felf64 -g zinseszins.asm && ld zinseszins.o -g -> for debugging with gdb -> regular run: gdb ./a.out
;nasm -felf64 -g zinseszins.asm && ld zinseszins.o && ./a.out -> for normal execution

section .data
    questionCapital db "Was ist Ihr Kapital in CHF? ",0
    questionInterest db "Wie hoch ist Ihr Zins? ",0
    questionYears db "Welche Laufzeit in Jahren soll berechnet werden? ",0
    answer db 10, "Ihr Vermögen: CHF ", 0
    total db "Total Zinseszins: CHF ", 0
    nl db 10,0

section .bss
    capital resb 7
    interest resb 3
    years resb 3
    result resd 1
    buffer resb 32

section .text
    global  _start

%define CAPITAL_BUFFER_SIZE 7
%define INTEREST_BUFFER_SIZE 3
%define YEARS_BUFFER_SIZE 3

_start:
    ; Ask for the user's capital
    mov rax, questionCapital
    call _print
    mov rsi, capital
    mov rdx, CAPITAL_BUFFER_SIZE
    call _getInput

    ; Convert capital to integer and safe it in r8
    xor rsi, rsi
    mov rsi, capital
    call _stringToInt
    xor r8, r8
    mov r8, [result]

    ; Ask for the user's interest
    mov rax, questionInterest
    call _print
    mov rsi, interest
    mov rdx, INTEREST_BUFFER_SIZE
    call _getInput

    ; Convert interest to integer and safe it in r9
    xor rsi, rsi
    mov rsi, interest
    call _stringToInt
    xor r9, r9
    mov r9, [result]

    ; Ask for the duration in years
    mov rax, questionYears
    call _print
    mov rsi, years
    mov rdx, YEARS_BUFFER_SIZE
    call _getInput

    ; Convert years to integer and safe it in r10
    xor rsi, rsi
    mov rsi, years
    call _stringToInt
    xor r10, r10
    mov r10, [result]

    ; Print the answer text
    mov rax, answer
    call _print

    ; End cycle counter
    xor rax, rax
    xor rdx, rdx
    rdtsc               ; Read time-stamp counter (result in EDX:EAX)
    shl rdx, 32         ; Shift high 32 bits to the left
    or rax, rdx         ; Combine EDX:EAX into RAX (64-bit timestamp)
    mov r14, rax 

    ; Move interest percentage back 2 decimal places
    xor rdx, rdx
    xor rax, rax
    cvtsi2sd xmm0, r9
    mov rax, 100
    cvtsi2sd xmm1, rax 
    divsd xmm0, xmm1

    ; Add 1.0 to the interest rate
    xor rax, rax
    mov rax, 1
    cvtsi2sd xmm1, rax
    addsd xmm0, xmm1

    ; Calculate the power of (1 + interest rate) ^ years
    movsd xmm2, xmm0
    mov rsi, r10
    call _getPower

    ; Multiply the capital with the power of (1 + interest rate) ^ years
    cvtsi2sd xmm0, r8
    mulsd xmm0, xmm2

    ; Calculate the actual monetary increase
    cvtsi2sd xmm5, r8
    movsd xmm6, xmm0
    subsd xmm6, xmm5

    ; Convert the results to integer
    xor rax, rax
    cvttsd2si rax, xmm0 ; Convert total
    cvttsd2si r12, xmm6 ; Convert interest

    ; Convert integer to string and print the answer
    mov rsi, buffer
    call _intToStr
    call _print

    ; End cycle counter
    xor rax, rax
    xor rdx, rdx
    rdtsc           ; Read time-stamp counter again
    shl rdx, 32     ; Shift high 32 bits
    or rax, rdx     ; Combine into 64-bit value in RAX
    mov r15, rax
    sub r15, r14    ; r15 holds the amount of cycles used for the calculations

    ; Print a newline
    xor rax, rax
    mov rax, nl
    call _print

    ; Print total
    xor rax, rax
    mov rax, total
    call _print

    ; Print total integer
    xor rax, rax
    mov rax, r12
    mov rsi, buffer
    call _intToStr
    call _print

    ; Print a newline
    xor rax, rax
    mov rax, nl
    call _print

    call _exit

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