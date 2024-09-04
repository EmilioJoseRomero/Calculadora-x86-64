section .data
    mensaje_menu db "---------------------", 10, "|    Calculadora    |", 10, "|    1 - Sumar      |", 10, "|    2 - Restar     |", 10, "|    3 - Multiplicar|", 10, "|    4 - Dividir    |", 10, "|    5 - Salir      |", 10, "---------------------", 10, "Seleccione una opcion: ", 10, 0
    mensaje_ingreso db "Ingrese el primer numero (entero): ", 0
    mensaje_segundo db "Ingrese el segundo numero (entero): ", 0
    mensaje_resultado db "Resultado: ", 0
    mensaje_error db "Error: Division por cero no permitida.", 10, 0 
    mensaje_opcion_invalida db "Opcion invalida. Por favor, intente de nuevo.", 10, 0

section .bss
    num1 resb 11           ; Buffer para el primer número (espacio para 10 dígitos y el '\n')
    num2 resb 11           ; Buffer para el segundo número
    resultado resb 12      ; Buffer para el resultado en texto (espacio para números grandes y el '\n')
    opcion resb 2          ; Buffer para la opción del menú 

section .text
    global _start

_start:
    ; Mostrar el menú
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_menu ; Mensaje a escribir
    mov rdx, 199          ; Longitud del mensaje
    syscall

    ; Leer la opción del usuario
    mov rax, 0            ; sys_read
    mov rdi, 0            ; STDIN
    mov rsi, opcion       ; Buffer para leer
    mov rdx, 2            ; Leer 2 bytes (incluye el salto de línea)
    syscall

    ; Convertir opción de carácter a número
    sub byte [opcion], '0' ; Convertir de ASCII a entero
    movzx rbx, byte [opcion] ; Mover y extender el valor a rbx

    ; Validar la opción
    cmp rbx, 1
    je realizar_operacion
    cmp rbx, 2
    je realizar_operacion
    cmp rbx, 3
    je realizar_operacion
    cmp rbx, 4
    je realizar_operacion
    cmp rbx, 5
    je _exit

    ; Opción inválida
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_opcion_invalida ; Mensaje a escribir
    mov rdx, 50           ; Longitud del mensaje
    syscall
    jmp _exit

; Realizar la operación
realizar_operacion:
    ; Mostrar mensaje para primer número
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_ingreso ; Mensaje a escribir
    mov rdx, 35           ; Longitud del mensaje
    syscall

    ; Leer primer número (entrada en texto)
    mov rax, 0            ; sys_read
    mov rdi, 0            ; STDIN
    mov rsi, num1         ; Buffer para leer
    mov rdx, 11           ; Leer hasta 11 bytes (espacio para número y '\n')
    syscall

    ; Eliminar el salto de línea si está presente
    mov byte [num1 + rax - 1], 0  ; Reemplaza el '\n' al final con null terminator

    ; Mostrar mensaje para segundo número
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_segundo ; Mensaje a escribir
    mov rdx, 37           ; Longitud del mensaje
    syscall

    ; Leer segundo número (entrada en texto)
    mov rax, 0            ; sys_read
    mov rdi, 0            ; STDIN
    mov rsi, num2         ; Buffer para leer
    mov rdx, 11           ; Leer hasta 11 bytes (espacio para número y '\n')
    syscall

    ; Eliminar el salto de línea si está presente
    mov byte [num2 + rax - 1], 0  ; Reemplaza el '\n' al final con null terminator

    ; Convertir las cadenas a enteros
    call str_to_int       ; Convertir num1
    mov r8, rax           ; Guardar el primer número en r8

    call str_to_int       ; Convertir num2
    mov r9, rax           ; Guardar el segundo número en r9

    ; Ejecutar la operación seleccionada
    cmp rbx, 1
    je sumar
    cmp rbx, 2
    je restar
    cmp rbx, 3
    je multiplicar
    cmp rbx, 4
    je dividir

    ; Salir si no se seleccionó una opción válida
    jmp _exit

sumar:
    add r8, r9            ; Sumar
    mov rdi, r8           ; Guardar el resultado en rdi
    call int_to_str       ; Convertir a cadena
    jmp mostrar_resultado

restar:
    sub r8, r9            ; Restar
    mov rdi, r8           ; Guardar el resultado en rdi
    call int_to_str       ; Convertir a cadena
    jmp mostrar_resultado

multiplicar:
    imul r8, r9           ; Multiplicar
    mov rdi, r8           ; Guardar el resultado en rdi
    call int_to_str       ; Convertir a cadena
    jmp mostrar_resultado

dividir:
    test r9, r9           ; Verificar si el divisor es 0
    jz   division_error   ; Si es 0, ir a division_error
    xor rdx, rdx          ; Limpiar rdx antes de la división         
    div r9                ; Dividir r8 entre r9
    mov rdi, rax          ; Guardar el resultado en rdi
    call int_to_str       ; Convertir a cadena
    jmp mostrar_resultado

division_error:
    ; Mostrar mensaje de error
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_error ; Mensaje a escribir
    mov rdx, 35           ; Longitud del mensaje
    syscall
    jmp _exit

mostrar_resultado:
    ; Mostrar el mensaje de resultado
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_resultado ; Mensaje a escribir
    mov rdx, 12           ; Longitud del mensaje
    syscall

    ; Mostrar el resultado (convertido a cadena)
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, resultado    ; Buffer para el resultado
    mov rdx, 12           ; Longitud del resultado
    syscall

    jmp _exit

_exit:
    mov rax, 60           ; sys_exit
    xor rdi, rdi          ; Código de salida 0
    syscall

; Convertir cadena ASCII a entero
str_to_int:
    xor rax, rax          ; Limpiar rax para el resultado
    xor rcx, rcx          ; Limpiar rcx para el índice
.next_digit:
    movzx rdx, byte [num1 + rcx] ; Leer un carácter
    test  rdx, rdx        ; Verificar si es el final de la cadena
    jz    .done           ; Si es 0 (nulo), terminar
    sub   rdx, '0'        ; Convertir de ASCII a valor numérico
    imul  rax, rax, 10    ; Multiplicar el resultado actual por 10
    add   rax, rdx        ; Sumar el nuevo dígito
    inc   rcx             ; Avanzar al siguiente carácter
    jmp   .next_digit     ; Repetir
.done:
    ret

; Convertir entero a cadena ASCII
int_to_str:
    mov     rsi, rdi      ; Guardar dirección del buffer en rsi
    add     rdi, 10       ; Apuntar al final del buffer
    mov     byte [rdi], 0x0  ; Null terminador
    mov     rbx, 10       ; Divisor
.reverse_loop:
    dec     rdi           ; Mover hacia atrás en el buffer
    xor     rdx, rdx      ; Limpiar rdx
    div     rbx           ; Dividir rdi por 10
    add     dl, '0'       ; Convertir residuo a carácter ASCII
    mov     [rdi], dl     ; Guardar carácter en el buffer
    test    rax, rax      ; Verificar si el cociente es 0
    jnz     .reverse_loop ; Si no es 0, continuar
    mov     rdx, rsi      ; Longitud del resultado
    sub     rdx, rdi      ; Calcular longitud real del número
    ret
