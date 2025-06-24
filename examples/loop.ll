; ModuleId = 'examples/loop'
source_filename = "examples/loop.bcs"
@0 = global [2 x i8] c"\0A\00"

define void @main() {
entry:
    %x = alloca i32
    store i32 0, ptr %x
    br label %.loop0
.loop0:
    %0 = load i32, ptr %x
    %1 = icmp sge i32  %0, 10
    %2 = zext i1 %1 to i32
    %3 = icmp ne i32 %2, 0
    br i1 %3, label %.if0, label %.if0.done
.if0:
    br label %.if0.done
.if0.done:
    %4 = load i32, ptr %x
    call void @putint(i32  %4)
    %6 = getelementptr [2 x i8], ptr @0, i32 0, i32 0
    call void @puts(ptr %6)
    %8 = load i32, ptr %x
    %9 = add i32  %8, 1
    store i32 %9, ptr %x
    br label %.loop0
.loop0.done:
    ret void
}

declare void @puts(ptr %0)
declare void @putint(i32 %0)


