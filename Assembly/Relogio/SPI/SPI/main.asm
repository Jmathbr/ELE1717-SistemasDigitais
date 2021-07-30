;
; SPI.asm
;
; Created: 29/07/2021 12:17:05
; Author : joaom
;
.def read = r18

; Replace with your application code
Setup:
	
	ldi r16, 0xFF			
	out DDRD, r16				; Configurando todas as portas como saida

	sbi DDRB, 2					; SS   - Slave select
	sbi DDRB, 3					; MOSI - Master output Slave input
	cbi DDRB, 4					; MISO - Master input Slave output
	sbi DDRB, 5					; SCK  - Clock

	ldi r16, 0xDC				; SPI CONTROL -> 
								; 0xDC -> (SPIE,SPE,MSTR,CPOL,CPHA)
								; 0x1C -> (MSTR,CPOL,CPHA)
	out SPCR, r16				; Configuration

Loop:
	ldi r16, 0x81
	out SPDR, r16				; Request Seconds

Wait_Transmit:					; Wait 8 pulses clock 
	in   r16, SPSR				;
	sbrs r16, SPIF				; Verify Flag interrupt
	rjmp Wait_Transmit			; Ao final grava o valor recebido no SPDR
	rjmp Output							

Output:
	lds r16, 0X4E				; Write value SPDR in R16
	out PORTD, r16
	rjmp loop

;	Spi_Transmiter:
;	ldi r16, 0x03				; Request Minutes
;	out SPDR, r16
