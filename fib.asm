print_integer:
    ; Function to print the signed integer in rdi
    ; Using syscall 1 for sys_write
    mov rsi, output_buffer + 20 ; Set rsi to the end of the output buffer (reserve 20 bytes for digits)
    mov rcx, 20     ; Set the maximum number of digits to print
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
    mov rdx, 21     ; Set the number of bytes to write (including null terminator)
    mov rax, 1      ; syscall number 1 for sys_write
    mov rdi, 1      ; file descriptor 1 (stdout)
    syscall
    ret

.print_zero:
