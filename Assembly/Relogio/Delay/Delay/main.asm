;
; Delay.asm
;
; Created: 29/07/2021 14:24:05
; Author : joaom
;


; Replace with your application code
rjmp start
Delay:
    ldi r16, 0x00
	ldi r17, 0xA
Delay_loop:
	inc r16
	cpse r16, r17
	rjmp Delay_loop
	ret
start:
    ldi r16, 0x00
	nop
	nop
	nop
	nop
	rcall Delay
	nop
	nop
	nop
	nop

