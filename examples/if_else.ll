; ModuleId = 'examples/if_else'
source_filename = "examples/if_else.bc"
@0 = global [6 x i8] c"true\0A\00"
@1 = global [7 x i8] c"Close\0A\00"
@2 = global [26 x i8] c"Man u got God on ur side\0A\00"
@3 = global [11 x i8] c"GodDamnit\0A\00"

define void @main() {
entry:
    %x = alloca i32
    store i32 0, ptr %x
    %y = alloca i32
    store i32 7, ptr %y
    %1 = load i32, ptr %x
    %2 = load i32, ptr %y
    %3 = add i32  %1,  %2
    %4 = icmp eq i32 %3, 4
    %5 = zext i1 %4 to i32
    %6 = icmp ne i32 %5, 0
    br i1 %6, label %.if0, label %.if0.else
.if0:
    %7 = getelementptr [6 x i8], ptr @0, i32 0, i32 0
    call void @puts(ptr %7)
    br label %.if0.done
.if0.else:
    %10 = load i32, ptr %x
    %11 = load i32, ptr %y
    %12 = add i32  %10,  %11
    %13 = icmp eq i32 %12, 5
    %14 = zext i1 %13 to i32
    %15 = icmp ne i32 %14, 0
    br i1 %15, label %.if9, label %.if9.else
.if9:
    %16 = getelementptr [7 x i8], ptr @1, i32 0, i32 0
    call void @puts(ptr %16)
    br label %.if9.done
.if9.else:
    %19 = icmp ne i32 1, 0
    br i1 %19, label %.if18, label %.if18.else
.if18:
    %20 = getelementptr [26 x i8], ptr @2, i32 0, i32 0
    call void @puts(ptr %20)
    br label %.if18.done
.if18.else:
    %22 = getelementptr [11 x i8], ptr @3, i32 0, i32 0
    call void @puts(ptr %22)
    br label %.if18.done
.if18.done:
    br label %.if9.done
.if9.done:
    br label %.if0.done
.if0.done:
    ret void
}

declare void @puts(ptr %0)


