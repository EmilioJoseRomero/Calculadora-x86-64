section .data
    mensaje_menu db "---------------------", 10, "|    Calculadora    |", 10, "|    1 - Sumar      |", 10, "|    2 - Restar     |", 10, "|    3 - Multiplicar|", 10, "|    4 - Dividir    |", 10, "|    5 - Apagar     |", 10, "---------------------", 10, "Seleccione una opcion: ", 10, 0
    mensaje_menu_len equ $ - mensaje_menu

    mensaje_ingreso db "Ingrese el primer numero (entero): ", 0
    mensaje_ingreso_len equ $ - mensaje_ingreso

    mensaje_segundo db "Ingrese el segundo numero (entero): ", 0
    mensaje_segundo_len equ $ - mensaje_segundo

    mensaje_resultado db "Resultado: ", 0
    mensaje_resultado_len equ $ - mensaje_resultado

    mensaje_error db "Error: Division por cero no permitida.", 10, 0 
    mensaje_error_len equ $ - mensaje_error 

    mensaje_opcion_invalida db "Opcion invalida. Por favor, intente de nuevo.", 0
    mensaje_opcion_invalida_len equ $ - mensaje_opcion_invalida
    
    cambio_de_linea db 0x0A

section .bss
    num1 resb 11           ; Buffer para el primer número (espacio para 10 dígitos y el '\n')
    num2 resb 11           ; Buffer para el segundo número
    resultado resb 11      ; Buffer para el resultado en texto (espacio para números grandes y el '\n')
    opcion resb 2          ; Buffer para la opción del menú 

section .text
    global _start

_start:
    ; Mostrar el menú
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_menu ; Mensaje a escribir
    mov rdx, mensaje_menu_len   ; Longitud del mensaje
    syscall

    ; Leer la opción del usuario
    mov rax, 0            ; sys_read
    mov rdi, 0            ; STDIN
    mov rsi, opcion       ; Buffer para leer
    mov rdx, 2            ; Leer 2 bytes (incluye el salto de línea)
    syscall

    ; Convertir opción de carácter a número
    sub byte [rsi], '0'  ; Convertir de ASCII a entero
    movzx rbx, byte [rsi] ; Mover y extender el valor a rbx 

    ; Validar la opción
    cmp rbx, 1
    je sumar
    cmp rbx, 2
    je restar
    cmp rbx, 3
    je multiplicar
    cmp rbx, 4
    je dividir
    cmp rbx, 5
    je _exit

    ; Opción inválida
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_opcion_invalida ; Mensaje a escribir
    mov rdx, mensaje_opcion_invalida_len ; Longitud del mensaje
    syscall
    jmp _start

; Realizar las operaciones
sumar:
    call pedir_primer_numero
    mov r8, rax
    call pedir_segundo_numero
    mov r9, rax
    add r8, r9
    mov rdi, r8
    call int_to_string
    jmp mostrar_resultado

restar:
    call pedir_primer_numero
    mov r8, rax
    call pedir_segundo_numero
    mov r9, rax
    sub r8, r9
    mov rdi, r8
    call int_to_string
    jmp mostrar_resultado

multiplicar:
    call pedir_primer_numero
    mov r8, rax
    call pedir_segundo_numero
    mov r9, rax
    imul r8, r9
    mov rdi, r8
    call int_to_string
    jmp mostrar_resultado

dividir:
    call pedir_primer_numero
    mov r8, rax
    call pedir_segundo_numero
    mov r9, rax
    test r9, r9           ; Verificar si el divisor es 0
    jz   division_error   ; Si es 0, ir a division_error
    mov rax, r8           ; Cargar dividendo en rax
    xor rdx, rdx          ; Limpiar rdx antes de la división         
    div r9                ; Dividir rax entre r9
    mov rdi, rax          ; Guardar el resultado en rdi
    call int_to_string
    jmp mostrar_resultado

division_error:
    ; Mostrar mensaje de error
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_error ; Mensaje a escribir
    mov rdx, mensaje_error_len; Longitud del mensaje
    syscall
    jmp _start

mostrar_resultado:
    ; Mostrar el mensaje de resultado
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_resultado ; Mensaje a escribir
    mov rdx, mensaje_resultado_len   ; Longitud del mensaje
    syscall

    ; Mostrar el resultado (convertido a cadena)
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, resultado    ; Buffer para el resultado
    mov rdx, 11           ; Longitud del resultado
    syscall

    ; Imprimir cambio de linea
    mov rax, 1          ; syscall número para sys_write
    mov rdi, 1          ; file descriptor 1 (stdout)
    mov rsi, cambio_de_linea    ; dirección del mensaje
    mov rdx, 1         ; longitud del mensaje (1 salto de línea)
    syscall

    jmp _start

_exit:
    mov rax, 60           ; sys_exit
    xor rdi, rdi          ; Código de salida 0
    syscall

pedir_primer_numero:
    ; Mostrar mensaje para primer número
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_ingreso ; Mensaje a escribir
    mov rdx, mensaje_ingreso_len   ; Longitud del mensaje
    syscall

    ; Leer primer número (entrada en texto)
    mov rax, 0            ; sys_read
    mov rdi, 0            ; STDIN
    mov rsi, num1         ; Buffer para leer
    mov rdx, 11           ; Leer hasta 11 bytes (espacio para número y '\n') 
    syscall

    ; Convertir las cadenas a enteros
    call string_to_int
    
    ret

pedir_segundo_numero:
    ; Mostrar mensaje para segundo número
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_segundo ; Mensaje a escribir
    mov rdx, mensaje_segundo_len  ; Longitud del mensaje
    syscall

    ; Leer segundo número (entrada en texto)
    mov rax, 0            ; sys_read
    mov rdi, 0            ; STDIN
    mov rsi, num2         ; Buffer para leer
    mov rdx, 11           ; Leer hasta 11 bytes (espacio para número y '\n')
    syscall
    
    ; Convertir las cadenas a enteros
    call string_to_int

    ret

; Convertir cadena ASCII a entero
string_to_int:
    xor rax, rax          ; Limpiar rax para el resultado (número entero)
    xor rcx, rcx          ; Limpiar rcx para el índice
.next_digit:
    movzx rdx, byte [rsi + rcx] ; Leer un carácter
    test  rdx, rdx        ; Verificar si es el final de la cadena (null terminator)
    jz    .done           ; Si es 0 (nulo), terminar
    sub   rdx, '0'        ; Convertir de ASCII a valor numérico
    cmp   rdx, 9          ; Verificar si el dígito está en el rango 0-9
    ja    .done           ; Si no está en el rango, terminar (podría ser un error en el input)
    imul  rax, rax, 10    ; Multiplicar el resultado actual por 10
    add   rax, rdx        ; Sumar el nuevo dígito
    inc   rcx             ; Avanzar al siguiente carácter
    jmp   .next_digit     ; Repetir
.done:
    ret

; Convertir entero a cadena ASCII
int_to_string:
    ; rdi: entero a convertir
    ; rsi: buffer para la cadena resultante

    ; Manejar caso de cero
    cmp rdi, 0
    je .zero

    ; Configurar rax para la conversión
    mov rax, rdi          ; Copiar entero a rax
    mov rbx, 10           ; Divisor 10
    mov rcx, resultado    ; Buffer para el resultado
    add rcx, 10           ; Apuntar al final del buffer
    mov byte [rcx], 0     ; Null terminator para la cadena
    dec rcx               ; Mover al último dígito

.reverse_loop:
    xor rdx, rdx          ; Limpiar rdx antes de la división
    div rbx               ; Dividir rax entre 10
    add dl, '0'           ; Convertir el dígito a carácter ASCII
    mov [rcx], dl         ; Guardar el dígito en el buffer
    dec rcx               ; Mover al siguiente dígito
    test rax, rax         ; Verificar si queda más para procesar
    jnz .reverse_loop     ; Si no es cero, continuar

    ; Mover el puntero de la cadena al principio
    inc rcx               ; Ajustar el puntero de la cadena
    jmp .done

.zero:
    mov byte [rcx], '0'   ; Manejar el caso especial de cero

.done:
    ret
