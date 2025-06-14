

global __bc_sys0
__bc_sys0:
        syscall
        ret


        
global __bc_sys1
__bc_sys1:
        mov rax, rdi
        syscall
        ret

        
global __bc_sys2
__bc_sys2:
        mov rax, rdi
        mov rdi, rsi
        syscall
        ret
global __bc_sys3
__bc_sys3:
        mov rax, rdi
        mov rdi, rsi
        mov rsi, rdx
        syscall
        ret
global __bc_sys4
__bc_sys4:
        mov rax, rdi
        mov rdi, rsi
        mov rsi, rdx
        mov rdx, rcx
        syscall
        ret
global __bc_sys5
__bc_sys5:
        mov rax, rdi
        mov rdi, rsi
        mov rsi, rdx
        mov rdx, rcx
        mov r10, r8
        syscall
        ret
global __bc_sys6
__bc_sys6:
        mov rax, rdi
        mov rdi, rsi
        mov rsi, rdx
        mov rdx, rcx
        mov r10, r8
        mov r8, r9
        mov r9, [rsp + 8]
        syscall
        ret
section .note.GNU-stack
