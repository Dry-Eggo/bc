; ModuleId = 'examples/hello'
source_filename = "examples/hello.bc"
@0 = global [12 x i8] c"Hello World\00"

define void @main() {
entry:
    %0 = getelementptr [12 x i8], ptr @0, i32 0, i32 0
    call void @puts(ptr %0)
    ret void
}

declare void @putint(i32 %i)
declare void @puts(ptr %m)


