; ----------------------------------------------------------------------------------------
; Writes "Hello, World" to the console using only system calls. Runs on 64-bit Linux only.
; To assemble and run:
;
;     nasm -felf64 hello.asm && ld hello.o && ./a.out
; ----------------------------------------------------------------------------------------

global    _start
section   .text

_start:   
    mov rax, 1                  
    mov rdi, 1                
    mov rsi, message            
    mov rdx, 13                
    syscall                    
    mov rax, 60                
    xor rdi, rdi               
    syscall                    

    section .data
message:  
    db  "Hello, World", 10     