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

    test    rax, rax
    mov     rsi, rax
    js      _exit_failure_s

    ; ---- Bind ----

    mov     rdi, r12
    mov     rsi, address
    mov     rdx, 16
    mov     rax, 49             
    syscall                         ; bind

    test    rax, rax
    mov     rsi, rax
    js      _exit_failure_b

    ; ---- Listen ----

    mov     rdi, r12                ; int file_descriptor
    mov     rsi, 10                  ; int backlog
    mov     rax, 50                 ; sys_listen
    syscall

    test    rax, rax
    mov     rsi, rax
    js      _exit_failure_l

loop:

    ; ---- Accept ----

    mov     rdi, r12
    mov     rsi, 0
    mov     rdx, 0
    mov     rax, 43                 ; sys_accept
    syscall

    mov     r13, rax                ; r13 = int client_fd

    test    rax, rax
    mov     rsi, rax
    js      _exit_failure_a

    ; ---- Open ----
    
    mov     rax, 2
    mov     rdi, filename
    mov     rsi, 0
    mov     rdx, 0
    syscall

    mov     r14, rax

    test    rax, rax
    mov     rsi, rax
    js      _exit_failure_o

    ; ---- Sendfile ----

    mov     rax, 40
    mov     rsi, r14
    mov     rdi, r13
    mov     rdx, 0
    mov     r10, 400
    syscall

    lea     rdi, [rel msg]
    xor     rax, rax
    call    printf

    ; ---- close(f_fd) ----

    mov     rdi, r14
    mov     rax, 3
    syscall

    ; ---- close(c_fd) ----

    mov     rdi, r13
    mov     rax, 3
    syscall

    ;jmp loop                       ; Uncomment to allow for continues uses, im getting connection reset most of the time when loop is uncommented

_exit_success:
    mov     rdi, 0x0
    mov     rax, 60
    syscall      


_exit_failure_s:
    lea   rdi, [rel error_s]
    jmp _exit_failure

_exit_failure_b:
    lea   rdi, [rel error_b]
    jmp   _exit_failure

_exit_failure_l:
    lea   rdi, [rel error_l]
    jmp   _exit_failure

_exit_failure_a:
    lea   rdi, [rel error_a]
    jmp   _exit_failure

_exit_failure_o:
    lea   rdi, [rel error_o]
    jmp   _exit_failure

_exit_failure:

    xor   rax, rax           ; AL=0  no FP args in XMM regs
    call  printf

    mov     rdi, 0x1
    mov     rax, 60
    syscall

section .data

    msg db "Sending file to client", 10, 0
    error_s db "Error socket: %d", 10, 0   
    error_b db "Error bind: %d", 10, 0   
    error_l db "Error listen: %d", 10, 0   
    error_a db "Error accept: %d", 10, 0    
    error_o db "Error open: %d", 10, 0   

    

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
