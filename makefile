

build:
	dub build
	./bc examples/fibonacci.bc -o examples/fibonacci.ll
	llc examples/fibonacci.ll -o examples/fibonacci.s
	as examples/fibonacci.s -o examples/fibonacci.o
	nasm -felf64 runtime/syscall.s -o runtime/syscall.o
	gcc -c runtime/runtime.c -o runtime/runtime.o -w
	ld examples/fibonacci.o runtime/runtime.o runtime/syscall.o -o examples/fibonacci

run: build
	examples/hello

dry:
	clang examples/hello.ll runtime/runtime.o runtime/syscall.o -o examples/hello -ffreestanding -nostdlib
	# as hello.s -o hello.o
	# ld hello.o runtime/runtime.o -o hello

clean:
	rm -rf */*.ll
	rm -rf examples/*.s
