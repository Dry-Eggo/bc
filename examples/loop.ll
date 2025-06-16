; ModuleId = 'examples/loop'
source_filename = "examples/loop.bcs"
@0 = global [12 x i8] c"Hello World\00"
@1 = global [6 x i8] c"hello\00"

define void @main() {
entry:
    br label %.loop0
.loop0:
    %0 = getelementptr [12 x i8], ptr @0, i32 0, i32 0
    call void @puts(ptr %0)
    br label %.loop0
.loop0.done:
    %2 = getelementptr [6 x i8], ptr @1, i32 0, i32 0
    call void @puts(ptr %2)
    ret void
}

declare void @puts(ptr %0)


