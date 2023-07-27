section .bss
    fib_number resq 1 ; Reserve 8 bytes (64 bits) to store the Fibonacci number

section .text
    global _start

_start:
    ; Check if there is at least one command-line argument (argument count >= 2)
    cmp rdi, 2
    jl invalid_args

    ; Extract the first command-line argument (argument at index 1) into rsi
    ; The command-line arguments are stored as pointers to strings in memory.
    ; The first argument (program name) is at [rsi + 8], and the second argument (n) is at [rsi + 16].
    mov rsi, [rsi + 16] ; Pointer to the second argument (value of n)

    ; Convert the input string to an integer and store it in rdi (n)
    call parse_integer

    ; Check if n is less than 0, if yes, then set the Fibonacci number to 0 and exit
    cmp rdi, 0
    jl done
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

invalid_args:
    ; Print an error message for invalid command-line arguments
    mov rsi, invalid_args_msg
    call print_string

    ; Exit the program
    call exit_program

parse_integer:
    ; Function to convert a null-terminated string to an integer
    ; The input string should be in rsi, and the result will be in rax
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
    ; Function to print the integer in rdi
    ; Using syscall 1 for sys_write
    mov rbx, 10     ; Set rbx to 10 for dividing the number by 10
    mov rsi, output_buffer + output_buffer_size - 1 ; Set rsi to the end of the output buffer

    .convert_digit_loop:
        dec rsi      ; Move the pointer to the left
        xor rdx, rdx
