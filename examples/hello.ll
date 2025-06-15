; ModuleId = 'examples/hello'
source_filename = "examples/hello.bc"

@0 = global [4 x i8] c"Foo\00"

@1 = global [12 x i8] c"Hello World\00"

define void @main() {
entry:
    %foo = alloca i32
    %0 = add i32 40, 2
    store i32 %0, ptr %foo
    %bar = alloca i32
    %1 = load i32, ptr %foo
    store i32  %1, ptr %bar
    %msg = alloca ptr
%2 = getelementptr [4 x i8], ptr @0, i32 0, i32 0    store ptr %2, ptr %msg
    %3 = load i32, ptr %bar
    call void @putint(i32  %3)
%4 = getelementptr [12 x i8], ptr @1, i32 0, i32 0    call void @puts(ptr %4)
    ret void
}

declare void @putint(i32 %i)declare void @puts(ptr %m)

