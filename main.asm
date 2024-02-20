default rel
extern printf

section .text
global main
main:

    ; ---- Socket ----

    mov     rdi, AF_INET
    mov     rsi, SOCK_STREAM
    mov     rdx, 0
    mov     rax, 41
    syscall

    mov     r12, rax                ; r12 = int s_fd = socket(AF_INET, SOCK_STREAM, 0);

    mov   rsi, rax   ; "%x" takes a 32-bit unsigned int
    lea   rdi, [rel format]
    xor   rax, rax           ; AL=0  no FP args in XMM regs
    call  printf
    
    ; ---- Bind ----

    mov     rdi, r12
    mov     rsi, address
    mov     rdx, 16
    mov     rax, 49             
    syscall                         ; bind

    mov   rsi, rax   ; "%x" takes a 32-bit unsigned int
    lea   rdi, [rel format]
    xor   rax, rax           ; AL=0  no FP args in XMM regs
    call  printf

    ; ---- Listen ----

    mov     rdi, r12                ; int file_descriptor
    mov     rsi, 2                  ; int backlog
    mov     rax, 50                 ; sys_listen
    syscall

    mov   rsi, rax   ; "%x" takes a 32-bit unsigned int
    lea   rdi, [rel format]
    xor   rax, rax           ; AL=0  no FP args in XMM regs
    call  printf

    ; ---- Accept ----

    mov     rdi, r12
    mov     rsi, 0
    mov     rdx, 0
    mov     rax, 43                 ; sys_accept
    syscall

    mov     r13, rax                ; r13 = int client_fd

    mov   rsi, rax   ; "%x" takes a 32-bit unsigned int
    lea   rdi, [rel format2]
    xor   rax, rax           ; AL=0  no FP args in XMM regs
    call  printf

    ; ---- Open ----
    
    mov     rax, 2
    mov     rdi, filename
    mov     rsi, 0
    mov     rdx, 0
    syscall

    mov     r14, rax

    mov   rsi, rax   ; "%x" takes a 32-bit unsigned int
    lea   rdi, [rel format3]
    xor   rax, rax           ; AL=0  no FP args in XMM regs
    call  printf


    ; ---- Sendfile ----

    mov     rax, 40
    mov     rsi, r14
    mov     rdi, r13
    mov     rdx, 0
    mov     r10, 256
    syscall

    ; ---- close(f_fd) ----

    mov     rdi, r14
    mov     rax, 3
    syscall

    ; ---- close(c_fd) ----

    mov     rdi, r13
    mov     rax, 3
    syscall

_exit_success:
    mov     rdi, 0x0
    mov     rax, 60
    syscall         

section .data

    format db "%d", 10, 0   ; C 0-terminated string: "%#x\n" 
    format2 db "Accept: %d", 10, 0   ; C 0-terminated string: "%#x\n" 
    format3 db "Open: %d", 10, 0   ; C 0-terminated string: "%#x\n" 

    filename db "response.txt", 0  

    SOCK_STREAM: equ 1
    AF_INET: equ 2
    INADDR_ANY: equ 0
    


    address:
        dw 0x02                   ; sin_family = AF_INET (in little-endian)
        dw 0x901f              ; sin_port = htons(8080)
        dd 0x00000000          ; sin_addr.s_addr = INADDR_ANY
        times 8 db 0           ; Padding to match the size of struct sockaddr_in




;           Code to print N in dec to terminal

;    mov   rsi, N    ; "%x" takes a 32-bit unsigned int
;    lea   rdi, [rel format]
;    xor   rax, rax           ; AL=0  no FP args in XMM regs
;    call  printf
