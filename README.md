# Better C (BC)

**BC** is a system-level programming language inspired by C, but designed to be safer, more expressive, and more modernâ€”while staying true to the spirit of freestanding, low-level control.

It currently **transpiles to LLVM IR manually**, with plans to support C and assembly output as well. The runtime is optional and minimal, written in C or LLVM IR, and designed to work without libc (`-nostdlib`, `-ffreestanding`). You can build raw executables, call syscalls directly, and write low-level code without being boxed in.

---

## ¨ Why Better C?

C is powerful but clunky. BC keeps the power, drops the clunk.

- No preprocessor nonsense.
- No undefined behavior from ancient legacy.
- No standard library unless you want one.
- Explicit, readable syntax.
- Designed for **freestanding**, **bare-metal**, and **systems** programming.
- You write code BC turns it into clean LLVM IR you control the final binary.

---

##  Current Status

- Lexing  
- Parsing into AST  
- Manual LLVM IR Codegen  
- Variable bindings
- `let` definitions  
- Type annotations (`i32`, `void`, etc)  
- Function definitions  
- LLVM IR output that can be compiled with `llc + ld`

---

## Example

### Input (BC source):
```bc
extrn fn putint(i i32) void;

fn main() void {
    let v i32 = 39;
    putint(v);
}
```

### Output (LLVM IR):
```llvm
declare void @putint(i32)

define void @main() {
entry:
    %v = alloca i32
    store i32 39, ptr %v
    %tmp = load i32, ptr %v
    call void @putint(i32 %tmp)
    ret void
}
```

Compile with:
```sh
llc out.ll -o out.s
ld -o a.out out.s bc/runtime/start.o bc/runtime/runtime.o
./a.out
```

---

## Toolchain

- Language written in **D**.
- Compiler manually emits **LLVM IR**.
- Runtime is minimal and located in `bc/runtime/`.
- Only required dependencies: `runtime.o` and `start.o` for linking.

---

## Design Goals

BC aims to be:

- Freestanding-first: works without libc.
- Predictable: no hidden allocations, no magic behaviors.
- Modern: inspired by Rust, and Odin but compiles down to clean, raw output.
- Extensible: eventual plans for modules, generics, and user-defined memory management.

---

## File Extensions

BC source files use `.bc` (coincidentally also the LLVM bitcode extension).  
I may change this later if needed, but for now: `.bc` it is.

---

## Roadmap (short-term)

- Type checker
- Argument support for functions
- Runtime function declarations
- External function imports (`extrn fn ...`)
- String handling in IR
- Variadic arguments via slice-style packing
- Build system (no `make`, no `cmake`, just `bc build`)

---

## Contributing / Hacking

Right now this is mostly a solo project by me, and you're welcome to fork or follow progress.

To build:
```sh
dub run
```

To test:
```sh
./bc example.bc
llc out.ll -o out.s
ld -o a.out out.s bc/runtime/start.o bc/runtime/runtime.o
./a.out
```

