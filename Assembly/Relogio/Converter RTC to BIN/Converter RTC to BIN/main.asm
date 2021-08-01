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

	ldi HORAS, 0x59					; Value Input
    mov UN, HORAS					; Copy value input
	mov DE, HORAS					; Copy value input
	cbr UN,0XF0						; Clear value DE
	cbr DE,0X0F						; Clear value UN
	
	sbic PIND, BINC					; Verify Button_INC press
	call b_inc						; Call function
	nop
	sbic PIND, BDEC					; Verify Button_DEC press
	call b_dec						; Call function
	nop

	; Introduce time delay
	; Corresponding to the frequency of 2hz

	ret

b_inc:
	inc UN							; Inc UN
	cpi DE, 0x50					; Verify DE = 50
	brsh limite_sup_de				; Start upper limit
	cpi UN, 0x0A					; Verify UN >= 10
	brsh clear_un					; Start Clear unit
	rjmp RTC_TO_BIN

b_dec:
	dec UN							; Dec UN
	cpi DE, 0x00					; Verify DE = 00
	breq limite_inf_de				; Start lower limit
	cpi UN, 0xFF					; Verify UN = 255
	breq set_un						; Start set unit
	rjmp RTC_TO_BIN

clear_un:
	ldi r16, 0x10
	add DE, r16
	clr UN
	rjmp RTC_TO_BIN

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