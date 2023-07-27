section .data
    ; Define variables here if needed

section .bss
    fib_number resq 1 ; Reserve 8 bytes (64 bits) to store the Fibonacci number

section .text
    global _start

_start:
    ; Get the value of n from the user and store it in rdi register
    mov rsi, prompt
    call print_string
    call read_integer

    ; Check if n is less than 0, if yes, then set the Fibonacci number to 0 and exit
    cmp rax, 0
    jl done
    mov rdi, 0 ; n
    mov rax, 0 ; Fibonacci number for n=0
    mov rbx, 1 ; Fibonacci number for n=1

fib_loop:
    cmp rdi, 1 ; Check if n is 1 or more
    jle done   ; If n<=1, then the Fibonacci number is already in rax

    ; Calculate the next Fibonacci number (rax + rbx) and store it in rax
    add rax, rbx

    ; Swap values: rax (current) -> rbx (prev_1) -> rdx (prev_2) -> rax (current)
    mov rdx, rbx
    mov rbx, rax
    mov rax, rdx

    dec rdi    ; Decrement n
    jmp fib_loop ; Repeat the loop to calculate the next Fibonacci number

done:
    ; Store the final Fibonacci number (in rax) into the memory location fib_number
    mov [fib_number], rax

    ; Print the Fibonacci number
    call print_newline
    mov rsi, result_prompt
    call print_string
    mov rdi, [fib_number]
    call print_integer
    call print_newline

    ; Exit the program
    call exit_program

print_string:
    ; Function to print a null-terminated string pointed to by rsi
    ; Using syscall 1 for sys_write
    xor rax, rax    ; syscall number 1 for sys_write
    mov rdi, 1      ; file descriptor 1 (stdout)
    mov rdx, 0      ; zero out rdx (as length is 0 for null-terminated strings)
    .print_loop:
        lodsb       ; load the next byte from rsi into al and increment rsi
        test al, al ; check if we reached the end of the string (null terminator)
        jz .print_done
        mov rdx, 1  ; number of bytes to write (1 byte for each character)
        syscall
        jmp .print_loop
    .print_done:
        ret

read_integer:
    ; Function to read an integer from the user and store it in rax
    ; Using syscall 0 for sys_read
    xor rax, rax    ; syscall number 0 for sys_read
    mov rdi, 0      ; file descriptor 0 (stdin)
    mov rsi, input_buffer
    mov rdx, input_buffer_size
    syscall

    ; Convert the string to an integer
    xor rax, rax    ; Clear rax to store the result
    xor rcx, rcx    ; Clear rcx to use as a counter
    .convert_loop:
        movzx rbx, byte [rsi + rcx] ; Load the next byte into rbx
        cmp rbx, 0   ; Check if we reached the end of the string (null terminator)
        je .conversion_done
        sub rbx, '0' ; Convert ASCII character to its integer value
        imul rax, 10 ; Multiply current result by 10
        add rax, rbx ; Add the new digit to the result
        inc rcx      ; Move to the next character
        jmp .convert_loop
    .conversion_done:
        ret

print_integer:
    ; Function to print the integer in rdi
    ; Using syscall 1 for sys_write
    xor rcx, rcx    ; Initialize a counter to keep track of the number of digits
    mov rbx, 10     ; Set rbx to 10 for dividing the number by 10
    mov rsi, output_buffer + output_buffer_size - 1 ; Set rsi to the end of the output buffer

    .convert_digit_loop:
        dec rsi      ; Move the pointer to the left
        xor rdx, rdx ; Clear rdx for division
        div rbx      ; Divide rdi by 10, quotient in rax, remainder in rdx
        add dl, '0'  ; Convert the remainder (0-9) to ASCII character ('0'-'9')
        mov [rsi], dl ; Store the ASCII character in the output buffer
        inc rcx      ; Increment the digit counter

        test rax, rax ; Check if quotient is zero
        jnz .convert_digit_loop ; If not zero, continue converting the next digit

    ; Print the integer
    mov rdx, rcx    ; Set the number of digits to print
    mov rax, 1      ; syscall number 1 for sys_write
    mov rdi, 1      ; file descriptor 1 (stdout)
    mov rax, 1      ; syscall number 1 for sys_write
    mov rdi, 1      ; file descriptor 1 (stdout)
    mov rax, 1      ; syscall number 1 for sys_write
    mov rdi, 1      ; file descriptor 1 (stdout)
    mov rsi, rsi    ; pointer to the output buffer
    syscall
    ret

print_newline:
    ; Function to print a newline character
    ; Using syscall 1 for sys_write
    xor rax, rax    ; syscall number 1 for sys_write
    mov rdi, 1      ; file descriptor 1 (stdout)
    mov rsi, newline
    mov rdx, 1      ; number of bytes to write (1 byte for the newline character)
    syscall
    ret

exit_program:
    ; Function to exit the program
    ; Using syscall 60 for sys_exit
    xor rax, rax    ; syscall number 60 for sys_exit
    syscall

section .rodata
    prompt db "Enter the value of n: ", 0
    result_prompt db "The Fibonacci number is: ", 0
    newline db 10, 0

section .bss
    input_buffer resb 20 ; Reserve 20 bytes for user input
    output_buffer resb 21 ; Reserve 21 bytes for output (20 digits + null terminator)
    input_buffer_size equ $ - input_buffer
    output_buffer_size equ $ - output_buffer
