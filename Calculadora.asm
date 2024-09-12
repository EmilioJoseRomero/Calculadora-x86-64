section .data
    mensaje_menu db "---------------------", 10, "|    Calculadora    |", 10, "|    1 - Sumar      |", 10, "|    2 - Restar     |", 10, "|    3 - Multiplicar|", 10, "|    4 - Dividir    |", 10, "|    5 - Apagar     |", 10, "---------------------", 10, "Seleccione una opcion: ", 10
    mensaje_menu_len equ $ - mensaje_menu

    mensaje_ingreso db "Ingrese el primer numero (entero): ", 0
    mensaje_ingreso_len equ $ - mensaje_ingreso

    mensaje_segundo db "Ingrese el segundo numero (entero): ", 0
    mensaje_segundo_len equ $ - mensaje_segundo

    mensaje_resultado db "Resultado: ", 0
    mensaje_resultado_len equ $ - mensaje_resultado

    mensaje_error db "Error: Division por cero no permitida.", 10
    mensaje_error_len equ $ - mensaje_error 

    mensaje_opcion_invalida db "Opcion invalida. Por favor, intente de nuevo.", 0x0A
    mensaje_opcion_invalida_len equ $ - mensaje_opcion_invalida

    mensaje_resultado_Hexa db "Resultado en Base Hexadecimal: ", 0
    mensaje_resultado__Hexa_len equ $ - mensaje_resultado_Hexa
    
    mensaje_resultado_Octal db "Resultado en Base Octal: ", 0
    mensaje_resultado_Octal_len equ $ - mensaje_resultado_Octal

    mensaje_resultado_Binario db "Resultado en Binario: ", 0
    mensaje_resultado_Binario_len equ $ - mensaje_resultado_Binario
    
    cambio_de_linea db 0x0A

section .bss
    num1 resb 11           ; Buffer para el primer número (espacio para 10 dígitos y el '\n')
    num2 resb 11           ; Buffer para el segundo número
    resultado resb 11      ; Buffer para el resultado en texto (espacio para números grandes y el '\n')
    resultado_hex resb 15 ; Buffer para el resultado en hexadecimal (espacio para "0x" + 8 dígitos + '\n')
    resultado_oct resb 15
    resultado_Bin resb 64

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
; Etiqueta para sumar dos números enteros
sumar:
    call pedir_primer_numero      ; Llamamos a la etiqueta que solicita el primer número al usuario
    mov r8, rax                  ; Guardamos el valor del primer número en el registro r8
    call pedir_segundo_numero     ; Llamamos a la etiqueta que solicita el segundo número al usuario
    mov r9, rax                  ; Guardamos el valor del segundo número en el registro r9
    add r8, r9                   ; Sumamos los valores de r8 y r9 y almacenamos el resultado en r8

    call limpiar_buffer_resultado ; Llamamos a la etiqueta que limpia el buffer de resultados
    mov rdi, r8                  ; Movemos el resultado de la suma al registro rdi para la conversión

    call int_to_string           ; Llamamos a la etiqueta que convierte el entero a cadena para imprimirlo en pantalla
    call int_to_hex_string       ; Llamamos a la etiqueta que convierte el entero a hexadecimal
    call int_to_octal            ; Llamamos a la etiqueta que convierte el entero a octal
    call int_to_binary           ; Llamamos a la etiqueta que convierte el entero a binario
    jmp mostrar_resultado        ; Saltamos a la etiqueta que imprime el resultado

; Etiqueta para restar dos números enteros
restar:
    call pedir_primer_numero      ; Llamamos a la etiqueta que solicita el primer número al usuario
    mov r8, rax                  ; Guardamos el valor del primer número en el registro r8
    call pedir_segundo_numero     ; Llamamos a la etiqueta que solicita el segundo número al usuario
    mov r9, rax                  ; Guardamos el valor del segundo número en el registro r9
    sub r8, r9                   ; Restamos el valor de r9 al valor de r8 y almacenamos el resultado en r8

    call limpiar_buffer_resultado ; Llamamos a la etiqueta que limpia el buffer de resultados
    mov rdi, r8                  ; Movemos el resultado de la resta al registro rdi para la conversión

    call int_to_string           ; Llamamos a la etiqueta que convierte el entero a cadena para imprimirlo en pantalla
    call int_to_hex_string       ; Llamamos a la etiqueta que convierte el entero a hexadecimal
    call int_to_octal            ; Llamamos a la etiqueta que convierte el entero a octal
    call int_to_binary           ; Llamamos a la etiqueta que convierte el entero a binario
    jmp mostrar_resultado        ; Saltamos a la etiqueta que imprime el resultado

; Etiqueta para multiplicar dos números enteros
multiplicar:
    call pedir_primer_numero      ; Llamamos a la etiqueta que solicita el primer número al usuario
    mov r8, rax                  ; Guardamos el valor del primer número en el registro r8
    call pedir_segundo_numero     ; Llamamos a la etiqueta que solicita el segundo número al usuario
    mov r9, rax                  ; Guardamos el valor del segundo número en el registro r9
    imul r8, r9                  ; Multiplicamos los valores de r8 y r9 y almacenamos el resultado en r8

    call limpiar_buffer_resultado ; Llamamos a la etiqueta que limpia el buffer de resultados
    mov rdi, r8                  ; Movemos el resultado de la multiplicación al registro rdi para la conversión

    call int_to_string           ; Llamamos a la etiqueta que convierte el entero a cadena para imprimirlo en pantalla
    call int_to_hex_string       ; Llamamos a la etiqueta que convierte el entero a hexadecimal
    call int_to_octal            ; Llamamos a la etiqueta que convierte el entero a octal
    call int_to_binary           ; Llamamos a la etiqueta que convierte el entero a binario
    jmp mostrar_resultado        ; Saltamos a la etiqueta que imprime el resultado

; Etiqueta para dividir dos números enteros   
dividir:
    call limpiar_buffer_resultado

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
    call int_to_hex_string
    call int_to_octal
    call int_to_binary
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

    ; Mostrar el mensaje de resultado
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_resultado_Hexa ; Mensaje a escribir
    mov rdx, mensaje_resultado__Hexa_len  ; Longitud del mensaje
    syscall

    mov rax, 1          ; sys_write
    mov rdi, 1          ; STDOUT
    mov rsi, resultado_hex ; Buffer para el resultado en hexadecimal
    mov rdx, 14         ; Longitud del resultado hexadecimal
    syscall

    ; Imprimir cambio de linea
    mov rax, 1          ; syscall número para sys_write
    mov rdi, 1          ; file descriptor 1 (stdout)
    mov rsi, cambio_de_linea    ; dirección del mensaje
    mov rdx, 1         ; longitud del mensaje (1 salto de línea)
    syscall

    ; Mostrar el mensaje de resultado
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_resultado_Octal ; Mensaje a escribir
    mov rdx, mensaje_resultado_Octal_len  ; Longitud del mensaje
    syscall

    mov rax, 1          ; sys_write
    mov rdi, 1          ; STDOUT
    mov rsi, resultado_oct ; Buffer para el resultado en hexadecimal
    mov rdx, 15         ; Longitud del resultado hexadecimal
    syscall

    ; Imprimir cambio de linea
    mov rax, 1          ; syscall número para sys_write
    mov rdi, 1          ; file descriptor 1 (stdout)
    mov rsi, cambio_de_linea    ; dirección del mensaje
    mov rdx, 1         ; longitud del mensaje (1 salto de línea)
    syscall

    ; Mostrar el mensaje de resultado
    mov rax, 1            ; sys_write
    mov rdi, 1            ; STDOUT
    mov rsi, mensaje_resultado_Binario ; Mensaje a escribir
    mov rdx, mensaje_resultado_Binario_len  ; Longitud del mensaje
    syscall

    mov rax, 1          ; sys_write
    mov rdi, 1          ; STDOUT
    mov rsi, resultado_Bin ; Buffer para el resultado en hexadecimal
    mov rdx, 64         ; Longitud del resultado hexadecimal
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


; Convertir entero a cadena hexadecimal
int_to_hex_string:
    ; rdi: entero a convertir
    ; rsi: buffer para la cadena hexadecimal

    ; Manejar caso de cero
    cmp rdi, 0
    je .zero_hex

    ; Configurar rax para la conversión
    mov rax, rdi          ; Copiar entero a rax
    mov rbx, 16           ; Base 16
    mov rcx, resultado_hex ; Buffer para el resultado hexadecimal
    add rcx, 15           ; Apuntar al final del buffer
    mov byte [rcx], 0     ; Null terminator para la cadena
    mov byte [rcx - 1], 'x'
    mov byte [rcx - 2], '0'
    sub rcx, 2            ; Mover el puntero al inicio del buffer hexadecimal

    ; Reservar espacio para el prefijo "0x" y el número hexadecimal
    mov rdx, rcx         ; Guardar el puntero para el prefijo "0x"
    mov byte [rdx], '0'
    mov byte [rdx + 1], 'x'
    add rdx, 2           ; Mover al final del prefijo

.reverse_hex_loop:
    xor rdx, rdx         ; Limpiar rdx antes de la división
    div rbx              ; Dividir rax entre 16
    cmp dl, 9
    jle .digit
    add dl, 'A' - 10     ; Convertir dígito 10-15 a 'a'-'f'
    jmp .store

.digit:
    add dl, '0'          ; Convertir dígito 0-9 a '0'-'9'

.store:
    mov [rcx], dl        ; Guardar el dígito en el buffer
    dec rcx              ; Mover al siguiente dígito
    test rax, rax        ; Verificar si queda más para procesar
    jnz .reverse_hex_loop ; Si no es cero, continuar

    ; Mover el puntero de la cadena al principio
    inc rcx              ; Ajustar el puntero de la cadena
    jmp .done_hex

.zero_hex:
    mov byte [rcx], '0'  ; Manejar el caso especial de cero
    mov byte [rcx + 1], 'x'
    mov byte [rcx + 2], '0'
    add rcx, 2           ; Ajustar el puntero para "0x0"

.done_hex:
    ; Calcular longitud del buffer hexadecimal
    mov rdx, 15
    sub rdx, rcx         ; Calcular longitud
    ret


; Convertir entero a cadena octal
int_to_octal:
    ; rdi: entero a convertir
    ; rsi: buffer para la cadena octal resultante

    ; Manejar caso de cero
    cmp rdi, 0
    je .zero

    ; Configurar rax para la conversión
    mov rax, rdi          ; Copiar entero a rax
    mov rbx, 8            ; Divisor 8 para octal
    mov rcx, resultado_oct    ; Buffer para el resultado
    add rcx, 15           ; Apuntar al final del buffer (espacio para 10 dígitos y el '\0')
    mov byte [rcx], 0     ; Null terminator para la cadena
    dec rcx               ; Mover al último dígito

.reverse_loop:
    xor rdx, rdx          ; Limpiar rdx antes de la división
    div rbx               ; Dividir rax entre 8
    add dl, '0'           ; Convertir el dígito a carácter ASCII
    cmp dl, '9'           ; Verificar si el dígito es mayor que 9
    jbe .store_digit      ; Si no es mayor que 9, almacenar dígito
    add dl, 7             ; Convertir dígitos de 10 a 15 a 'a' a 'f' en octal (solo útil si manejamos bases superiores)
.store_digit:
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


; Convertir entero a cadena binaria
int_to_binary:
    ; Convertir el número en RDI a una cadena binaria
    ; RDI (número a convertir)
    ; RSI (dirección del buffer para almacenar el resultado)

    mov rcx, 64         ; 64 bits para recorrer
    mov rbx, rdi        ; Copiar el número a un registro temporal
    mov rdx, resultado_Bin        ; Copiar la dirección del buffer a un registro temporal

    ; Inicializar el buffer para almacenar los bits
    mov byte [rdx + 64], 0 ; Establecer el terminador nulo en el final del buffer
    lea rsi, [rdx]       ; Apuntar al principio del buffer

convertir_binario_loop:
    shl rbx, 1          ; Desplazar el bit más significativo a la izquierda
    jc  bit_uno         ; Si el bit es 1, establecer '1'
    mov byte [rsi], '0' ; De lo contrario, establecer '0'
    jmp short bit_siguiente
bit_uno:
    mov byte [rsi], '1'
bit_siguiente:
    inc rsi             ; Mover al siguiente byte en el buffer
    loop convertir_binario_loop ; Repetir para los 64 bits

    ; Añadir el terminador nulo al final de la cadena
    mov byte [rsi], 0

    ret


; Limpia el buffer de resultados antes de cada conversión a cadena
limpiar_buffer_resultado:
    mov rcx, 11           ; Tamaño del buffer
    mov rsi, resultado     ; Apuntar al buffer de resultados
    xor rax, rax           ; Cargar 0 en rax (valor nulo)
.limpiar_loop:
    mov byte [rsi], 0      ; Establecer el byte a 0 (null terminator)
    inc rsi                ; Mover al siguiente byte
    loop .limpiar_loop     ; Repetir hasta que el buffer esté limpio
    ret
