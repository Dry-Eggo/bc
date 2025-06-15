

build:
	dub build
	./bc examples/hello.bc -o examples/hello.ll
	llc examples/hello.ll -o examples/hello.s
	as examples/hello.s -o examples/hello.o
	nasm -felf64 runtime/syscall.s -o runtime/syscall.o
	gcc -c runtime/runtime.c -o runtime/runtime.o -w
	ld examples/hello.o runtime/runtime.o runtime/syscall.o -o examples/hello

run: build
	examples/hello

dry:
	clang examples/hello.ll runtime/runtime.o runtime/syscall.o -o examples/hello -ffreestanding -nostdlib
	# as hello.s -o hello.o
	# ld hello.o runtime/runtime.o -o hello

clean:
	rm hello.*
	rm hello
