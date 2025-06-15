

build:
	dub build
	./bc examples/factorial.bc -o examples/factorial.ll
	llc examples/factorial.ll -o examples/factorial.s
	as examples/factorial.s -o examples/factorial.o
	nasm -felf64 runtime/syscall.s -o runtime/syscall.o
	gcc -c runtime/runtime.c -o runtime/runtime.o -w
	ld examples/factorial.o runtime/runtime.o runtime/syscall.o -o examples/factorial
run: build
	examples/hello

dry:
	clang examples/factorial.ll runtime/runtime.o runtime/syscall.o -o examples/fibonacci -ffreestanding -nostdlib
	# as fibonacci.s -o hello.o
	# ld fibonacci.o runtime/runtime.o -o hello

clean:
	rm -rf */*.ll
	rm -rf examples/*.s
