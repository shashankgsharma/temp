section .data
    n_value dq 10 ; Set the value of n here

section .bss
    fib_number resq 1 ; Reserve 8 bytes (64 bits) to store the Fibonacci number
    output_buffer resb 101 ; Reserve 101 bytes for output (100 digits + sign + null terminator)

section .rodata
    result_prompt db "Fibonacci(", 0 ; Prompt message

section .text
    global _start

_start:
    ; Move the value of 'n' from the data section to rdi (n)
    mov rdi, qword [n_value]

    ; Calculate the Fibonacci number for n
    call fibonacci

    ; Store the final Fibonacci number (in rax) into the memory location fib_number
    mov [fib_number], rax

    ; Print the Fibonacci number
    call print_newline
    mov rsi, result_prompt
    call print_string
    mov rdi, [fib_number]
    call print_integer
    mov rsi, close_bracket
    call print_string
    call print_newline

    ; Exit the program
    call exit_program

fibonacci:
    ; Calculate the nth Fibonacci number and return it in rax
    ; n is passed in rdi

    ; Check if n is less than or equal to 0
    cmp rdi, 0
    jle .fib_done
    mov rax, 0 ; Fibonacci number for n=0
    mov rbx, 1 ; Fibonacci number for n=1

    .fib_loop:
        dec rdi    ; Decrement n
        jz .fib_done ; If n=1, then the Fibonacci number is already in rax

        ; Calculate the next Fibonacci number (rax + rbx) and store it in rax
        add rax, rbx

        ; Swap values: rax (current) -> rbx (prev_1) -> rdx (prev_2) -> rax (current)
        mov rdx, rbx
        mov rbx, rax
        mov rax, rdx

        jmp .fib_loop ; Repeat the loop to calculate the next Fibonacci number

    .fib_done:
    ret

print_string:
    ; Function to print a null-terminated string pointed to by rsi
    ; Using syscall 1 for sys_write
    mov rax, 1      ; syscall number 1 for sys_write
    mov rdi, 1      ; file descriptor 1 (stdout)
    xor rdx, rdx    ; zero out rdx (as length is 0 for null-terminated strings)
    .print_loop:
        lodsb       ; load the next byte from rsi into al and increment rsi
        test al, al ; check if we reached the end of the string (null terminator)
        jz .print_done
        inc rdx      ; number of bytes to write (1 byte for each character)
        syscall
        jmp .print_loop
    .print_done:
        ret

print_integer:
    ; Function to print the signed integer in rdi
    ; Using syscall 1 for sys_write
    mov rsi, output_buffer + 100 ; Set rsi to the end of the output buffer (reserve 100 bytes for digits)
    mov rcx, 100     ; Set the maximum number of digits to print
    xor rdx, rdx    ; Clear rdx for handling negative numbers

    ; Check if the number is zero
    test rdi, rdi
    jz .print_zero

    ; Check if the number is negative
    test rdi, rdi
    js .handle_negative

    ; Convert the positive number
    .convert_digit_loop:
        dec rsi      ; Move the pointer to the left
        xor rax, rax ; Clear rax for division
        mov rbx, 10  ; Set rbx to 10 for dividing the number by 10
        div rbx      ; Divide rdi by 10, quotient in rax, remainder in rdx
        add dl, '0'  ; Convert the remainder (0-9) to ASCII character ('0'-'9')
        mov [rsi], dl ; Store the ASCII character in the output buffer

        test rax, rax ; Check if quotient is zero
        jnz .convert_digit_loop ; If not zero, continue converting the next digit

    ; Calculate the actual position of the last character to print
    sub rsi, rcx    ; rsi now points to the start of the output

    ; Print the positive integer
    jmp .print_done

.handle_negative:
    neg rdi         ; Negate the negative number to make it positive
    mov byte [rsi], '-' ; Place the minus sign in the output buffer
    inc rsi         ; Move the pointer to the left for the digits
    dec rcx         ; Decrease the maximum number of digits to print

    ; Convert the positive number (same as before)
    .convert_digit_loop_negative:
        dec rsi
        xor rax, rax
        mov rbx, 10
        div rbx
        add dl, '0'
        mov [rsi], dl

        test rax, rax
        jnz .convert_digit_loop_negative

    ; Calculate the actual position of the last character to print
    sub rsi, rcx    ; rsi now points to the start of the output

.print_done:
    ; Print the number
    mov rdx, 101     ; Set the number of bytes to write (including null terminator)
    mov rax, 1      ; syscall number 1 for sys_write
    mov rdi, 1      ; file descriptor 1 (stdout)
    syscall
    ret

.print_zero:
    ; Print "0" for zero
    mov byte [rsi], '0'
    inc rsi
    mov byte [rsi], 0
    jmp .print_done

print_newline:
    ; Function to print a newline character
    ; Using syscall 1 for sys_write
    mov rax, 1      ; syscall number 1 for sys_write
    mov rdi, 1      ; file descriptor 1 (stdout)
    mov rsi, newline
    mov rdx, 1      ; number of bytes to write (1 byte for the newline character)
    syscall

    ret

exit_program:
    ; Function to exit the program
    ; Using syscall 60 for sys_exit
    mov rax, 60     ; syscall number 60 for sys_exit
    xor rdi, rdi    ; Clear rdi (exit code 0)
    syscall

section .data
    newline db 10   ; Newline character (LF)
    close_bracket db ")", 0 ; Closing bracket for prompt message
