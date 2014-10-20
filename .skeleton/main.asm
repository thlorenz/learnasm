; vim: ft=nasm

section .data

section .bss

section .text

global _start

_start:
  nop

  mov eax,1                   ; exit with code zero
  mov ebx,0
  int 80H
