;
; SPI.asm
;
; Created: 29/07/2021 12:17:05
; Author : joaom
;


; Replace with your application code
Setup:
	ldi r16, 0x80
	out SREG, r16

	sbi DDRB, 2					; SS   - Slave select
	sbi DDRB, 3					; MOSI - Master output Slave input
	cbi DDRB, 4					; MISO - Master input Slave output
	sbi DDRB, 5					; SCK  - Clock

	ldi r16, 0xDC				; SPI CONTROL -> 
								; 0xDC -> (SPIE,SPE,MSTR,CPOL,CPHA)
								; 0x1C -> (MSTR,CPOL,CPHA)
	out SPCR, r16				
	ldi r19,SPDR

Spi_Transmiter:
	ldi r16, 0x3				; Request Minutes
	out SPDR, r16

Wait_Transmit:
	in r16, SPSR	
	sbrs r16, SPIF				; Verify Flag interrupt
	rjmp Wait_Transmit	
	ret

