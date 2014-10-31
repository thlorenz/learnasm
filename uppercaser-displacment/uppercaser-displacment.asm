; vim: ft=nasm

section .data
  SYSREAD_ERROR     db "An error occurred during sys_read", 10
  SYSREAD_ERROR_LEN equ $ - SYSREAD_ERROR

  SYSWRITE_ERROR     db "An error occurred during sys_write", 10
  SYSWRITE_ERROR_LEN equ $ - SYSWRITE_ERROR

section .bss
  BUFFLEN equ 1024
  Buff    resb BUFFLEN

section .text

global _start

; error handling functions
; none of them print error codes at this point
sysread_error:  mov ecx, SYSREAD_ERROR
                mov edx, SYSREAD_ERROR_LEN
                jmp dump_and_exit

syswrite_error: mov ecx, SYSWRITE_ERROR
                mov edx, SYSWRITE_ERROR_LEN
                jmp dump_and_exit

dump_and_exit:  mov eax, 4                           ; write error msg to stderr
                mov ebx, 2
                int 80h
                jmp exit                             ; if we encounter an error while writing one we are screwed anyways, so just exit either way

; entry point
_start:
                nop

read:           mov eax, 3                           ; sys_read
                mov ebx, 0                           ; from stdio
                mov ecx, Buff                        ; into Buff
                mov edx, BUFFLEN                     ; multiple chars
                int 80H

                cmp eax, 0                           ; EOF?
                je  exit
                jb  sysread_error

                mov esi, eax                         ; sys_read returns number of bytes read, store them to use in process_buf and write

process_buff:   mov ecx, esi                         ; number of bytes read

                mov ebp, Buff                        ; set ebp to buffer address


process_char:   cmp byte [Buff - 1 + ecx], 61h       ; don't change chars before 'a'
                jb  next

                cmp byte [Buff - 1 + ecx], 7ah       ; don't change chars after 'z'
                ja  next

                sub byte [Buff - 1 + ecx], 20h       ; substracting 20h from lowercase makes it uppercase

next:           dec ecx                              ; repeat until we processed the entire buffer (from back to front)
                jnz process_char

write:          mov eax, 4                           ; sys_write
                mov ebx, 1                           ; to stdout
                mov ecx, Buff                        ; from Buff
                mov edx, esi                         ; number of bytes read
                int 80h

                cmp eax, 0
                jb  syswrite_error

loop:           jmp read                             ; read, process and write next buffer

exit:           mov eax, 1                           ; exit with code zero
                mov ebx, 0
                int 80H
