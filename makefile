

build:
	dub build
	./bc examples/expr.bc -o examples/expr.ll
	llc examples/expr.ll -o examples/expr.s
	as examples/expr.s -o examples/expr.o
	nasm -felf64 runtime/syscall.s -o runtime/syscall.o
	gcc -c runtime/runtime.c -o runtime/runtime.o -w
	ld examples/expr.o runtime/runtime.o runtime/syscall.o -o examples/expr

run: build
	examples/hello

dry:
	clang examples/hello.ll runtime/runtime.o runtime/syscall.o -o examples/hello -ffreestanding -nostdlib
	# as hello.s -o hello.o
	# ld hello.o runtime/runtime.o -o hello

clean:
	rm -rf */*.ll
	rm -rf examples/*.s
