

build:
	dub build
	./bc examples/loop.bcs -o examples/loop.ll
	llc examples/loop.ll -o examples/loop.s
	as examples/loop.s -o examples/loop.o
	nasm -felf64 runtime/syscall.s -o runtime/syscall.o
	gcc -c runtime/runtime.c -o runtime/runtime.o -w
	ld examples/loop.o runtime/runtime.o runtime/syscall.o -o examples/loop

compile:
	dub build
	nasm -felf64 runtime/syscall.s -o runtime/syscall.o
	gcc -c runtime/runtime.c -o runtime/runtime.o -w

run: build
	examples/hello

dry:
	clang examples/factorial.ll runtime/runtime.o runtime/syscall.o -o examples/fibonacci -ffreestanding -nostdlib
	# as fibonacci.s -o hello.o
	# ld fibonacci.o runtime/runtime.o -o hello

clean:
	rm -rf */*.ll
	rm -rf examples/*.s
