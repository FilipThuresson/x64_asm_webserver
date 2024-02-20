all: obj
	gcc -no-pie -o webserver main.o

obj:
	nasm -f elf64 -o main.o main.asm

clean:
	rm *.o webserver