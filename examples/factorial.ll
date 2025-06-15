; ModuleId = 'examples/factorial'
source_filename = "examples/factorial.bc"

define i32 @factorial(i32 %0) {
entry:
    %n = alloca i32
    store i32 %0, ptr %n
    %1 = load i32, ptr %n
    %2 = icmp sle i32  %1, 1
    %3 = zext i1 %2 to i32
    %4 = icmp ne i32 %3, 0
    br i1 %4, label %.if0, label %.if0.else
.if0:
    ret i32 1
.if0.else:
    %5 = load i32, ptr %n
    %6 = load i32, ptr %n
    %7 = sub nsw i32  %6, 1
    %8 = call i32 @factorial(i32 %7)
    %9 = mul i32  %5, %8
    ret i32 %9
.if0.done:
    ret i32 0
}
define void @main() {
entry:
    %result = alloca i32
    %0 = call i32 @factorial(i32 10)
    store i32 %0, ptr %result
    %1 = load i32, ptr %result
    call void @putint(i32  %1)
    ret void
}

declare void @putint(i32 %0)


