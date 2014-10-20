; vim: ft=nasm
;
; Build using these commands (works on 32-bit Linux)
;    nasm -f elf -g -F stabs eatsyscall.asm
;    ld -o eatsyscall eatsyscall.o
;
; Build on 64-bit Linux: (Linux 3.13.7-1-ARCH #1 x86_64 GNU/Linux)
;    nasm -f elf64 -g -F stabs eatsyscall.asm
;    ld -o eatsyscall eatsyscall.o
;
; Build on OSX (although the instructions are not valid for its architecture)
;    nasm -f macho eatsyscall.asm 
;    ld -arch i386 -macosx_version_min 10.5 -no_pie -e _start -o eatsyscall eatsyscall.o
;

section .data                 ; contains initialized data

EatMsg: db "Eat at Joe's!",10
EatLen  equ $ - EatMsg

section .bss                  ; contains uninitialized data

section .text                 ; contains code

global _start                 ; entry point found by linker (default is _start)

_start:
  nop                         ; needed to allow debugging with gdb - lldb not properly working ATM
  mov eax,4                   ; Specify sys_write syscall
  mov ebx,1                   ; specify file descriptor: stdout
  mov ecx,EatMsg              ; pass message offset
  mov edx,EatLen              ; pass message length
  int 80H                     ; make syscall to output text to stdout

  mov eax,1                   ; specify exit syscall
  mov ebx,0                   ; return code of zero
  int 80H                     ; make syscall to terminate program
