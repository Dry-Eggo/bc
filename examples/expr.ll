; ModuleId = 'examples/expr'
source_filename = "examples/expr.bc"
@0 = global [2 x i8] c"\0A\00"

define i32 @printint(i32 %0,i32 %1,i32 %2) {
entry:
    %n = alloca i32
    store i32 %0, ptr %n
    %f = alloca i32
    store i32 %1, ptr %f
    %n = alloca i32
    store i32 %2, ptr %n
    %3 = load i32, ptr %n
    call void @putint(i32  %3)
    %5 = getelementptr [2 x i8], ptr @0, i32 0, i32 0
    call void @puts(ptr %5)
    ret i32 0
}
define void @main() {
entry:
    ret void
}

declare void @putint(i32 %0)
declare void @puts(ptr %0)


