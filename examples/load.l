; ModuleId = 'examples/loa'
source_filename = "examples/load.bcs"
@0 = global [12 x i8] c"Hello World\00"
@1 = global [12 x i8] c"Hello World\00"

define void @main() {
entry:
    %x = alloca i32
    store i32 40, ptr %x
    %y = alloca ptr
    %0 = getelementptr [12 x i8], ptr @0, i32 0, i32 0
    store ptr %0, ptr %y
    %1 = getelementptr [12 x i8], ptr @1, i32 0, i32 0
    call void @puts(ptr %1)
    ret void
}

declare void @puts(ptr %0)


