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

Loop:
	; INIT WRITE DATA
	cbi PORTB, 2				; Start Transmission
	ldi r16, 0x3F				; Clock Burst Write
	out SPDR, r16				; Set comand
	call Wait_Transmit_send

	ldi r16, 0x0B				; Adress Day
	out SPDR, r16				; Set Adress
	call Wait_Transmit_send

	ldi r16, 0x03				; Value Day
	out SPDR, r16				; Set Day
	call Wait_Transmit_send
	
	ldi r16, 0x03				; Adress Minutis
	out SPDR, r16				; Set Adress
	call Wait_Transmit_send

	ldi r16, 0x07				; Value Minutis
	out SPDR, r16				; Set Minutis
	call Wait_Transmit_send

	ldi r16, 0x00				; Bit Protecty
	out SPDR, r16				; Set Protecty
	call Wait_Transmit_send
	sbi PORTB, 2				; End Transmission
	; END WRITE DATA
	
	; INIT READ DATA
	cbi PORTB, 2				; Start Transmission
	ldi r16, 0x8B				; Request Day
	out SPDR, r16
	call Wait_Transmit_recive
	
	clr r16						; Trash Value
	out SPDR, r16
	call Wait_Transmit_recive	; Return Value Day	
	sbi PORTB, 2				; End Transmission
	; END READ DATA
	rjmp Output


Wait_Transmit_send:				; Wait 8 pulses clock 
	in   r16, SPSR				;
	sbrs r16, SPIF				; Verify Flag interrupt
	rjmp Wait_Transmit_send		; Ao final grava o valor recebido no SPDR
	ret						

; Necessita que o SPIF seja limpo
Wait_Transmit_recive:			; Wait 8 pulses clock 
	in   r16, SPSR				;
	sbrs r16, SPIF				; Verify Flag interrupt
	rjmp Wait_Transmit_recive
	rjmp Output					; Ao final grava o valor recebido no SPDR

Output:
	cbi PORTB, 2
	lds r16, 0x4E				; Write value SPDR in R16
	out PORTD, r16
	rjmp Output

;	Spi_Transmiter:
;	ldi r16, 0x03				; Request Minutes
;	out SPDR, r16
