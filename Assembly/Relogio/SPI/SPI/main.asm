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

	ldi r16, 0xD0				; SPI CONTROL -> 
								; 0xDC -> (SPIE,SPE,MSTR,CPOL,CPHA)
								; 0x1C -> (MSTR,CPOL,CPHA)
	out SPCR, r16				; Configuration

Loop_write:
	; INIT WRITE DATA
	cbi PORTB, 2				; Start Transmission

	ldi r16, 0x3F				; Clock Burst Write
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x00				; Value Seconds
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x02				; Value Minutis
	out SPDR, r16				; Set comand
	call Wait_Transmit_send
	
	ldi r16, 0x12				; Value Hour
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x01				; Value Data
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x08				; Value Month
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x06				; Value Week Day
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x21				; Value Year
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x00				; Value Control
	out SPDR, r16				; Set bit Protecty
	call Wait_Transmit_send

	sbi PORTB, 2				; End Transmission
	; END WRITE DATA

loop_read:
	; INIT READ DATA
	cbi PORTB, 2				; Start Transmission

	ldi r16, 0xBF				; Clock Burst Read
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x00				; Value Seconds
	out SPDR, r16				; Set comand
	call Wait_Transmit_send
	
	lds r17, 0x4E				; Write value SPDR in R17
	
	ldi r16, 0x02				; Value Minutis
	out SPDR, r16				; Set comand
	call Wait_Transmit_send
	
	ldi r16, 0x12				; Value Hour
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x01				; Value Data
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x08				; Value Month
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x06				; Value Week Day
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x21				; Value Year
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x00				; Value Control
	out SPDR, r16				; Set bit Protecty
	call Wait_Transmit_send		; End Transmission

	sbi PORTB, 2				; End Transmission
	; END READ DATA
	rjmp Output


Wait_Transmit_send:				; Wait 8 pulses clock 
	in   r16, SPSR				;
	sbrs r16, SPIF				; Verify Flag interrupt
	rjmp Wait_Transmit_send		; Ao final grava o valor recebido no SPDR
	ret						

Output:
	;lds r16, 0x4E				; Write value SPDR in R16
	out PORTD, r17
	rjmp loop_read