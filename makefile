

build:
	dub build
	./bc examples/if_else.bc -o examples/if_else.ll
	llc examples/if_else.ll -o examples/if_else.s
	as examples/if_else.s -o examples/if_else.o
	nasm -felf64 runtime/syscall.s -o runtime/syscall.o
	gcc -c runtime/runtime.c -o runtime/runtime.o -w
	ld examples/if_else.o runtime/runtime.o runtime/syscall.o -o examples/if_else

run: build
	examples/hello

dry:
	clang examples/hello.ll runtime/runtime.o runtime/syscall.o -o examples/hello -ffreestanding -nostdlib
	# as hello.s -o hello.o
	# ld hello.o runtime/runtime.o -o hello

clean:
	rm -rf */*.ll
	rm -rf examples/*.s
