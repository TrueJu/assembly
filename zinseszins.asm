;nasm -felf64 -g zinseszins.asm && ld zinseszins.o      -> -g for debugging with gdb
;nasm -felf64 -g zinseszins.asm && ld zinseszins.o && ./a.out
;gdb ./a.out
;break _start
;run
;step
;next for stepping over
;info registers for seeing the registers
;p &<bss> for printing the content of a variable
;x/16xb 0x40209 OR p *(long *) 0x402098 to print contents

section .data
    questionCapital db "Was ist Ihr Kapital in CHF? ",0
    questionInterest db "Wie hoch ist Ihr Zins? ",0
    questionYears db "Welche Laufzeit in Jahren soll berechnet werden? ",0
    answer db 10, "Ihr Zinseszins in CHF beträgt: "
    nl db 10,0
    ;stri db "123456", 10, 0
    stri db 0x31, 0x30, 0x30, 0x30, 0x0a, 0x00

section .bss
    capital resb 7
    interest resb 2
    years resb 3
    result resd 1
    buffer resb 32

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

    ;rax
    ;xor r8, r8
    ;mov rbx, 3
    ;call _getPowerOfTen
    ;mov r8, rax

    ;mov rsi, buffer
    ;call _intToStr

    ;call _print

    ; 100 franken, 2 prozent, 3 jahre

    ;rbx
    ;mov rsi, stri
    ;call _stringToInt

    ;mov rax, r8
    ;mov rcx, r9
    ;mul rcx

    ;xor rax, rax
    ;mov rax, r9
    ;xor rdx, rdx
    ;mov rcx, 100
    ;div rcx  


    mov rax, answer
    call _print

    xor rdx, rdx
    xor rax, rax
    cvtsi2sd xmm0, r9
    mov rax, 100
    cvtsi2sd xmm1, rax 
    divsd xmm0, xmm1

    xor rax, rax
    mov rax, 1
    cvtsi2sd xmm1, rax
    addsd xmm0, xmm1

    ;movq [result], xmm0

    movsd xmm2, xmm0
    mov rsi, r10
    call _getPower

    cvtsi2sd xmm0, r8
    mulsd xmm0, xmm2

    ;movq [result], xmm0

    xor rax, rax
    cvttsd2si rax, xmm0

    ;xor rdi, rdi
    ;mov rdi, rax
    ;xor rax, rax
;
    ;mov rax, answer
    ;call _print
    ;xor rax, rax
    ;mov rax, rdi

    mov rsi, buffer
    call _intToStr
    call _print

    xor rax, rax
    mov rax, nl
    call _print

    ;movq rax, xmm0

    nop

    ;mov rbx, r8
    ;xor rdx, rdx
    ;div rbx
;
    ;cvtsi2sd xmm0, rax
    ;cvtsi2sd xmm1, rbx
    ;mov rdi, 1000
    ;cvtsi2sd xmm2, rdi
    ;divsd xmm1, xmm2
    ;addsd xmm0, xmm1
    ;;movq mm0, xmm0

    

    call _exit

_exit:
    mov rax, 60
    mov rdi, 0
    syscall

    ret

; xmm2: base
; rsi; exponent
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

; rbx: number
_getPowerOfTen:
    xor rax, rax
    mov rax, 1
    xor rdx, rdx
    
.getPowerOfTenLoop: 
    cmp rdx, rbx
    jge powerOfTenDone
    imul rax, 10
    inc rdx
    jmp .getPowerOfTenLoop

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

    cmp rdx, '0'             ; Check if it's a digit ('0')
    jl atoi_done
    cmp rdx, '9'             ; Check if it's a digit ('9')
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
    mov rcx, 10             ; base 10
    mov rbx, rsi            ; save original buffer pointer
    add rsi, 30             ; go to end of buffer
    mov byte [rsi], 0       ; null terminator

.convertLoop:
    dec rsi
    xor rdx, rdx
    div rcx                 ; rax /= 10, rdx = remainder
    add dl, '0'
    mov [rsi], dl
    test rax, rax
    jnz .convertLoop

    mov rax, rsi            ; result pointer in rax
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