; vim: ft=nasm

section .data

section .bss
  BUFFLEN equ 1024
  Buff    resb BUFFLEN

section .text

global _start

_start:
                nop

read:           mov eax, 3                ; sys_read
                mov ebx, 0                ; from stdio
                mov ecx, Buff             ; into Buff
                mov edx, BUFFLEN          ; multiple chars
                int 80H

                cmp eax, 0                ; EOF?
                je  exit

                mov esi, eax              ; sys_read returns number of bytes read, store them to use in process_buf and write

process_buff:   mov ecx, esi              ; number of bytes read

                mov ebp, Buff             ; set ebp to address right before buffer
                dec ebp


process_char:   cmp byte [ebp + ecx], 61h ; don't change chars before 'a'
                jb  next

                cmp byte [ebp + ecx], 7ah ; don't change chars after 'z'
                ja  next

                sub byte [ebp + ecx], 20h ; substracting 20h from lowercase makes it uppercase

next:           dec ecx                   ; repeat until we processed the entire buffer (from back to front)
                jnz process_char

write:          mov eax, 4                ; sys_write
                mov ebx, 1                ; to stdout
                mov ecx, Buff             ; from Buff
                mov edx, esi              ; number of bytes read 
                int 80h

loop:           jmp read                  ; read, process and write next buffer

exit:           mov eax, 1                ; exit with code zero
                mov ebx, 0
                int 80H
