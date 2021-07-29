;
; SPI.asm
;
; Created: 29/07/2021 12:17:05
; Author : joaom
;


; Replace with your application code
Setup:
	sbi DDRB, 3					; MOSI - Master output Slave input
	cbi DDRB, 4					; MISO - Master input Slave output
	sbi DDRB, 5					; SCK  - Clock

	ldi r16, 0x1C				; SPI CONTROL -> 
								; 0xDC -> (SPIE,SPE,MSTR,CPOL,CPHA)
								; 0x1C -> (MSTR,CPOL,CPHA)

	out SPCR, r16				

Spi_Transmiter:
	ldi r16, 0x2				; Request Minutes
	out SPDR,r16

Wait_Transmit:
	in r16, SPSR	
	sbrs r16, SPIF				; Verify Flag interrupt
	rjmp Wait_Transmit	
	ret