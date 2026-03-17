%define WRITE_CALL 1
%define FD_STD_OUT 1
%define SOCKET_CALL 41
%define AF_INET 2
%define SOCK_STREAM 1
%define DEFAULT_PROTO 0
%define EXIT_CALL 60
%define ERR_EXIT_STAT 1

section .data
  err_msg: db "Encounter an error",10
  err_msg_len: equ $-err_msg

section .text
global _start
_start:
  call _create_sock
  jmp exit

_create_sock:
  mov rax, SOCKET_CALL
  mov rdi, AF_INET
  mov rsi, SOCK_STREAM
  mov rdx, DEFAULT_PROTO
  syscall
  test rax, rax
  js _exit_err
  ret

_exit_err:
  mov rax, WRITE_CALL
  mov rdi, FD_STD_OUT
  lea rsi, err_msg
  lea rdx, err_msg_len
  syscall
  mov rax, EXIT_CALL
  mov rdi, ERR_EXIT_STAT
  syscall

exit:
  mov rax, EXIT_CALL
  mov rdi, 0
  syscall
