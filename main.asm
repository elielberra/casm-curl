%define NUM_REQ_ARGS 2
%define WRITE_CALL 1
%define FD_STD_OUT 1
%define FD_STD_ERR 2
%define SOCKET_CALL 41
%define AF_INET 2
%define SOCK_STREAM 1
%define DEFAULT_PROTO 0
%define SOCKADDR_SIZE 16
%define CONN_CALL 42
%define CLOSE_CALL 3
%define READ_CALL 0
%define RES_BUFF_SIZE 4096
%define NEW_LINE 10
%define CARRIAGE_RET 13
%define EXIT_CALL 60
%define ERR_EXIT_STAT 1
%define NO_ERR_EXIT_STAT 0

extern get_sockaddr
extern free

section .data
  args_err_msg: db "Error: Wrong number of arguments. Usage: asm-curl <URL>", NEW_LINE
  args_err_msg_len: equ $ - args_err_msg
  sock_err_msg: db "Error while creating a socket", NEW_LINE
  sock_err_msg_len: equ $ - sock_err_msg
  conn_err_msg: db "Error while attempting to establish a connection", NEW_LINE
  conn_err_msg_len: equ $ - conn_err_msg
  send_req_err_msg: db "Error while sending the request", NEW_LINE
  send_req_err_msg_len: equ $ - send_req_err_msg
  read_res_err_msg: db "Errow while reading the response", NEW_LINE
  read_res_err_msg_len: equ $ - read_res_err_msg
  req:
    db "GET / HTTP/1.1",CARRIAGE_RET,NEW_LINE
    db "User-Agent: asm-curl",CARRIAGE_RET,NEW_LINE
    db "Connection: close",CARRIAGE_RET,NEW_LINE,CARRIAGE_RET,NEW_LINE
  req_len: equ $ - req

section .text

global main
main:
  call parse_args
  call create_sock
  mov r13, rax             ; prevent FD from getting clobbered
  mov rdi, r12             ; pass URL as param
  call resolve_url
  mov rdi, r13             ; set FD as param for syscall inside next function
  mov rsi, rax             ; pass sockaddr as param
  call connect
  mov rdi, r13
  call send_req
  mov rdi, r13
  call read_res
  mov rdi, r13
  call close_sock
  xor rax, rax
  ret                      ; exit program following CRT convention

parse_args:
  cmp rdi, NUM_REQ_ARGS
  jne args_err
  mov r12, [rsi + 8]       ; prevent second item in argv array from getting clobbered
  ret

create_sock:
  mov rax, SOCKET_CALL
  mov rdi, AF_INET
  mov rsi, SOCK_STREAM
  mov rdx, DEFAULT_PROTO
  syscall
  test rax, rax           ; check if syscall returned err with status code -1
  js sock_err
  ret

resolve_url:
  call get_sockaddr
  test rax, rax
  js exit_err
  ret

connect:
  mov rax, CONN_CALL
  mov rdx, SOCKADDR_SIZE
  syscall
  mov rdi, rsi
  call free
  test rax, rax
  js connect_err
  ret

send_req:
  mov rax, WRITE_CALL
  lea rsi, req
  mov rdx, req_len
  syscall
  test rax, rax
  js send_req_err
  ret

read_res:
  sub rsp, RES_BUFF_SIZE   ; create buffer
  .loop:
    mov rax, READ_CALL
    mov rdi, r13           ; prevent socket FD from getting clobbered
    mov rsi, rsp           ; set buffer as arg
    mov rdx, RES_BUFF_SIZE
    syscall
    test rax, rax
    jle .done               ; if 0 (EOF) or negative (Error), exit loop
    .print_res_chunk:
      mov rdx, rax           
      mov rax, WRITE_CALL
      mov rdi, FD_STD_OUT
      mov rsi, rsp
      syscall
    jmp .read_loop
  .done:
    add rsp, RES_BUFF_SIZE ; clean up stack
    ret

close_sock:
  mov rax, CLOSE_CALL
  syscall
  ret

args_err:
  lea rsi, args_err_msg
  lea rdx, args_err_msg_len
  jmp print_and_exit

sock_err:
  lea rsi, sock_err_msg
  lea rdx, sock_err_msg_len
  jmp print_and_exit

connect_err:
  lea rsi, conn_err_msg
  lea rdx, conn_err_msg_len
  jmp handle_err_cleanup

send_req_err:
  lea rsi, send_req_err_msg
  lea rdx, send_req_err_msg_len
  jmp handle_err_cleanup

read_res_err:
  lea rsi, read_res_err_msg
  lea rdx, read_res_err_msg_len
  jmp handle_err_cleanup

print_and_exit:
  mov rax, WRITE_CALL
  mov rdi, FD_STD_ERR
  syscall
  jmp exit_err

handle_err_cleanup:
  mov rax, WRITE_CALL
  mov rdi, FD_STD_ERR
  syscall
  jmp err_cleanup

err_cleanup:
  mov rdi, r13
  call close_sock
  jmp exit_err

exit_err:
  mov rax, EXIT_CALL
  mov rdi, ERR_EXIT_STAT
  syscall

section .note.GNU-stack noalloc noexec nowrite progbits
