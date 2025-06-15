; ModuleId = 'examples/if_else'
source_filename = "examples/fibonacci.bc"

define i32 @fib(i32 %0) {
entry:
    %n = alloca i32
    store i32 %0, ptr %n
    %1 = load i32, ptr %n
    call void @putint(i32  %1)
    ret i32 0
}
define void @main() {
entry:
    %result = alloca i32
    %0 = call i32 @fib(i32 10)
    store i32 %0, ptr %result
    %1 = load i32, ptr %result
    call void @putint(i32  %1)
    ret void
}

declare void @putint(i32 %0)


