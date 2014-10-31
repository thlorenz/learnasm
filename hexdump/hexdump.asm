; vim: ft=nasm
; Usage:
;   hexdump1 < (input file)

section .data

  HexStr: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00", 10
  HEXLEN equ $ - HexStr

  Digits: db "0123456789ABCDEF"

section .bss

  BUFFLEN equ 16      ; read file in 16 byte chunks
  Buff: resb BUFFLEN  ; buffer to hold these chunks

section .text

global _start

_start:
  nop

; Fill buffer from stdin
Read:
  mov eax, 3             ; sys_read
  mov ebx, 0             ; stdin fd
  mov ecx, Buff          ; offset to read to
  mov edx, BUFFLEN       ; number of bytes
  int 80h

  mov ebp, eax           ; save # of bytes we read (we'll need it later)
  cmp eax, 0             ; check for EOF
  je  Done

; Prep registers for process buffer step
  mov esi, Buff          ; point esi at buffer
  mov edi, HexStr        ; point edi at line string
  xor ecx, ecx           ; zero out ecx

; Go through buffer and convert binary to hex digits
Scan:
  xor eax, eax           ; zero out eax

; Calculate offset into HexStr which is ecx * 3
  mov edx, ecx           ; copy char counter
  shl edx, 1             ; multiply by 2
  add edx, ecx           ; add ecx

; Get char from buffer and put into eax and ebx
  mov al, byte [esi + ecx] ; put byte from current position in input buffer into al
  mov ebx, eax             ; duplicate it into bl

; Look up low nybble char and insert it into the string
  and al, 0Fh                       ; mask out all but the low nybble
  mov al, byte [Digits + eax]       ; lookup char equivalent of nybble
  mov byte [HexStr + edx + 2], al   ; write LSB char digit to line string

; Look up high nybble char and insert it into the string
  shr bl, 4                         ; shift high 4 bits of char to 4 low bits
  mov bl, byte [Digits + ebx]       ; lookup char equivalent of nybble
  mov byte [HexStr + edx + 1], bl   ; Write MSB char digit to line string

; Bump buffer pointer to next char and check if we are done
  inc ecx
  cmp ecx, ebp    ; compare to number of bytes in buffer (we saved it earlier)
  jna Scan        ; while (ecx <= ebp)

; Write the line of hex values to stdout
  mov eax, 4      ; sys_write
  mov ebx, 1      ; stdout fd
  mov ecx, HexStr ; line string address
  mov edx, HEXLEN ; line string size
  int 80h
  jmp Read        ; Keep reading from buffer

Done:
  mov eax, 1      ; exit with code zero
  mov ebx, 0
  int 80H
