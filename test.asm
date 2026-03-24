_read_res:
  sub rsp, RES_BUFF_SIZE ; Create buffer on stack
.read_loop:
  mov rax, READ_CALL
  mov rdi, r12           ; Socket FD
  mov rsi, rsp           ; Buffer starts at RSP
  mov rdx, RES_BUFF_SIZE
  syscall

  test rax, rax
  jle .done              ; If rax <= 0 (error or EOF), stop reading

  ; Print the chunk we just received
  mov rdx, rax           ; Bytes returned by read
  mov rax, WRITE_CALL
  mov rdi, FD_STD_OUT
  mov rsi, rsp           ; Buffer starts at RSP
  syscall

  jmp .read_loop         ; Go back to read more data

.done:
  add rsp, RES_BUFF_SIZE ; Clean up stack
  ret