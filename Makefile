all:
	nasm -g -f elf64 Calculadora.asm -o salida.o
	ld salida.o -o ejecutable
