; ModuleId = 'examples/hello'
source_filename = "examples/hello.bc"
define void @main() {
entry:
    %foo = alloca i32
    %0 = add i32 40, 2
    store i32 %0, ptr %foo
    %bar = alloca i32
    %1 = load i32, ptr %foo
    store i32  %1, ptr %bar
    %2 = load i32, ptr %bar
    call void @putint(i32  %2)
    ret void
}

declare void @putint(i32 %i)
