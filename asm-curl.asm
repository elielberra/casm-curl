%define WRITE_CALL 1
%define FD_STD_OUT 1
%define FD_STD_ERR 2
%define SOCKET_CALL 41
%define AF_INET 2
%define SOCK_STREAM 1
%define DEFAULT_PROTO 0
%define CONN_CALL 42
%define CLOSE_CALL 3
%define READ_CALL 0
%define RES_BUFF_SIZE 4096
%define NEW_LINE 10
%define CARRIAGE_RET 13
%define EXIT_CALL 60
%define ERR_EXIT_STAT 1
%define NO_ERR_EXIT_STAT 0

section .data
  sock_err_msg: db "Error while creating a socket", NEW_LINE
  sock_err_msg_len: equ $-sock_err_msg
  conn_err_msg: db "Error while attempting to establish a connection", NEW_LINE
  conn_err_msg_len: equ $-conn_err_msg
  send_req_err_msg: db "Error while sending the request", NEW_LINE
  send_req_err_msg_len: equ $-send_req_err_msg
  read_res_err_msg: db "Errow while reading the response", NEW_LINE
  read_res_err_msg_len: equ $-read_res_err_msg
  addr:
    dw AF_INET
    dw 0x401F    ; sin_port: 8000 (little endian 0x1F40-> big endian)
    db 127,0,0,1 ; sin_addr 127.0.0.1
    dq 0         ; sin_zero: 8 bytes of padding
  addr_len: equ $-addr
  req:
    db "GET / HTTP/1.1",CARRIAGE_RET,NEW_LINE
    db "Host: 127.0.0.1",CARRIAGE_RET,NEW_LINE
    db "User-Agent: asm-curl",CARRIAGE_RET,NEW_LINE
    db "Connection: close",CARRIAGE_RET,NEW_LINE,CARRIAGE_RET,NEW_LINE
  req_len: equ $-req

section .text
global _start
_start:
  call _create_sock
  mov r12, rax      ; prevent FD from getting clobbered
  mov rdi, r12      ; set FD as param for syscall inside next function
  call _connect
  mov rdi, r12
  call _send_req
  mov rdi, r12
  call _read_res
  mov rdi, r12
  call _close_sock
  jmp exit

_create_sock:
  mov rax, SOCKET_CALL
  mov rdi, AF_INET
  mov rsi, SOCK_STREAM
  mov rdx, DEFAULT_PROTO
  syscall
  test rax, rax
  js sock_err
  ret

_connect:
  mov rax, CONN_CALL
  lea rsi, addr
  mov rdx, addr_len
  syscall
  test rax, rax
  js connect_err
  ret

_send_req:
  mov rax, WRITE_CALL
  lea rsi, req
  mov rdx, req_len
  syscall
  test rax, rax
  js send_req_err
  ret

_read_res:
  sub rsp, RES_BUFF_SIZE ; create buffer for res text on stack
  mov rax, READ_CALL
  mov rsi, rsp
  mov rdx, RES_BUFF_SIZE
  syscall
  test rax, rax
  js read_res_err
  print_res:
    mov rdx, rax         ; num of bytes to read 
    mov rax, WRITE_CALL
    mov rdi, FD_STD_OUT
    mov rsi, rsp
    syscall
  add rsp, RES_BUFF_SIZE ; clean up stack
  ret

_close_sock:
  mov rax, CLOSE_CALL
  syscall
  ret

sock_err:
  lea rsi, sock_err_msg
  lea rdx, sock_err_msg_len
  jmp handle_err

connect_err:
  lea rsi, conn_err_msg
  lea rdx, conn_err_msg_len
  jmp handle_err

send_req_err:
  lea rsi, send_req_err_msg
  lea rdx, send_req_err_msg_len
  jmp handle_err

read_res_err:
  lea rsi, read_res_err_msg
  lea rdx, read_res_err_msg_len
  jmp handle_err

handle_err:
  mov rax, WRITE_CALL
  mov rdi, FD_STD_ERR
  syscall
  jmp err_cleanup

err_cleanup:
  mov rdi, r12
  call _close_sock
  jmp exit_err

exit_err:
  mov rax, EXIT_CALL
  mov rdi, ERR_EXIT_STAT
  syscall

exit:
  mov rax, EXIT_CALL
  mov rdi, NO_ERR_EXIT_STAT
  syscall
