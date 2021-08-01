;
; Converter RTC to BIN.asm
;
; Created: 31/07/2021 22:15:40
; Author : joaom
;


; Replace with your application code
.equ SS = 2
.equ MOSI = 3
.equ MISO = 4
.equ SCK = 5
.equ STCP = 6

.equ BR = 3
.equ BA = 4
.equ BINC = 5
.equ BDEC = 6


.equ DISP1 = 16  ;00010000
.equ DISP2 = 32  ;00100000
.equ DISP3 = 64  ;01000000
.equ DISP4 = 128 ;10000000

.def TEMPO = R17 ;VARIAVEL AUXILIAR
.def MINUTOS = R18
.def HORAS = R19
.def WEEK = R20
.def RMD = R21 ;modos e saidas display
.def RAP = R22 ;segmentos display
.def RDS = R23 ;dias de semana
.def UN = R24
.def DE = R25

Setup:
    call RTC_TO_BIN

RTC_TO_BIN:

	ldi HORAS, 0x00					; Value Input
    mov UN, HORAS
	mov DE, HORAS
	cbr UN,0XF0
	cbr DE,0X0F
	
	sbic PIND, BINC
	call b_inc
	nop
	sbic PIND, BDEC
	call b_dec
	nop
	ret

b_inc:
	inc UN
	cpi DE, 0x50
	brsh limite_sup_de
	cpi UN, 0x0A
	brsh clear_un
	rjmp RTC_TO_BIN

b_dec:
	dec UN
	cpi DE, 0x00
	breq limite_inf_de
	cpi UN, 0xFF
	breq set_un
	rjmp RTC_TO_BIN

clear_un:
	ldi r16, 0x10
	add DE, r16
	clr UN
	ret

limite_sup_de:
	cpi UN, 0x0A
	brsh limite_sup_un
	rjmp RTC_TO_BIN

limite_sup_un:
	clr UN
	clr DE
	rjmp RTC_TO_BIN
	
limite_inf_de:
	cpi UN, 0xFF
	brsh limite_inf_un
	rjmp RTC_TO_BIN	

limite_inf_un:
	ldi UN, 0x09
	ldi DE, 0x50
	rjmp RTC_TO_BIN

set_un:
	ldi UN, 0x09
	ldi r16, 0x10
	sub DE, r16
	rjmp RTC_TO_BIN