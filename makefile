

build:
	dub build
	./bc examples/hello.bc
	llc hello.ll -o hello.s
	as hello.s -o hello.o
	nasm -felf64 runtime/syscall.s -o runtime/syscall.o
	gcc -c runtime/runtime.c -o runtime/runtime.o
	ld hello.o runtime/runtime.o runtime/syscall.o -o hello

run: build
	./hello

dry:
	clang hello.ll runtime/runtime.o runtime/syscall.o -o hello -ffreestanding -nostdlib
	# as hello.s -o hello.o
	# ld hello.o runtime/runtime.o -o hello

clean:
	rm hello.*
	rm hello
