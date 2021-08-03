;
; main.asm
;
; Created: 02/08/2021 22:46:39
; Author : joaom
;

;--------------------------------------------------
;					SUMARIO
;--------------------------------------------------
;Setup
;main
;			MODOS
;run
;TIMER_H
;TIMER_M
;TIMER_WEEK
;ON_H
;ON_M
;WEEK_ON
;OFF_H
;OFF_M
;WEEK_OFF
;			FUNÇÕES
;rtc_write
;rtc_read
;Spi_Transmiter_Display
;convert_7Seg
;converte_semana
;__________________________________________________

.equ SS = 2
.equ MOSI = 3
.equ MISO = 4
.equ SCK = 5
.equ STCP = 6	; Pulso enable do Shift Register

.equ NA = 0		;flag de saida do NA
.equ NF = 1		;flag de saida do NF
.equ BITCH = 2	;chave da entrada IN, responsável por liberar a passagem do sinal IN, está conectado à base
.equ BR = 3		; Botao R
.equ BA = 4		; Botao A
.equ BINC = 5	; Botao INC
.equ BDEC = 6	; Botao DEC


.equ MT = 1		 ;00000001
.equ MW = 2		 ;00000010
.equ MO = 4		 ;00000100
.equ MF = 8		 ;00001000
.equ DISP1 = 16  ;00010000
.equ DISP2 = 32  ;00100000
.equ DISP3 = 64  ;01000000
.equ DISP4 = 128 ;10000000

.def TEMPO = R17	; VARIAVEL AUXILIAR (Usada em converte_7Seg apos receber o valor de horas ou minutos. Necessario, pois o valor dele eh alterado durante a conversao)
.def MINUTOS = R18	; Recebe o valor dos minutos do RTC no formato (X,dezena[6..4],unidade[3..0])
.def HORAS = R19	; Recebe o valor das horas do RTC no formato (0,X,dezena[5..4],unidade[3..0]), modo 24h
.def WEEK = R20		; Vai receber o dia da semana do RTC (0,0,0,0,0,bit2,bit1,bit0)
.def RMD = R21		; modos e saidas display (disp4,disp3,disp2,disp1,MF,MO,MW,MT) - use 'sbr' para setar um bit e 'cbr' para limpar
.def RAP = R22		; segmentos do display - invertidos (DP,g,f,e,d,c,b,a)
.def RDS = R23		; Leds dos dias de semana (0,sab,dom,sex,qui,qua,ter,seg)
.def UN = R24		; Em 'converte_7Seg' recebe a unidade e em seguida recebe o valor em 7seg.
.def DE = R25		; Em 'converte_7Seg' recebe a dezena e em seguida recebe o valor em 7seg.
.def MINUTE_BEGIN = R10		;-----------------------------------
.def HOUR_BEGIN = R11		; Inicio do intervalo de agendamento -- OBS.: Usar MOV para acessar estes registradores por meio do R16
.def WEEK_BEGIN = R12		;-----------------------------------
.def MINUTE_END = R13		;-----------------------------------
.def HOUR_END =	R14			; Fim do intervalo de agendamento	 -- OBS.: Usar MOV para acessar estes registradores por meio do R16
.def WEEK_END = R15			;-----------------------------------
; XH -> Registrador de status: Guarda um valor específico em cada Modo do relógio, identificando o Modo atual - Usado para piscar os leds
; XH = 0 NÃO PISCA
; XH = 1 PISCA T
; XH = 2 PISCA W
; XH = 3 PISCA O
; XH = 4 PISCA F

;.cseg				; Especifica que os comandos .ORG abaixo estao agindo dentro da memoria de programa (testei sem ele e funcionou)
.INCLUDE "m328Pdef.inc"
.org 0x0000
	rjmp Setup
.org 0x0016			; Endereco do vetor de interrupcao do Comparador A do Timer 1 no ATMega328P  -datasheet pag.66
	jmp TIM1_COMPA	; Esta direcionando a interrupcao para a sub-rotina que foi feita ao final do codigo


Setup:
	sbi DDRB, SS				; SS - Chip Selector
	sbi DDRB, MOSI				; MOSI - Master output Slave input
	cbi DDRB, MISO				; MISO - Master input Slave output
	sbi DDRB, SCK				; SCK  - Clock

	sbi DDRB, STCP				; Enable do 7HC

	cbi DDRD, BR				; Input Button
	cbi DDRD, BA				; Input Button
	cbi DDRD, BINC				; Input Button
	cbi DDRD, BDEC				; Input Button

	sbi DDRD, NA				; Output Flag
	sbi DDRD, NF				; Output Flag
	sbi DDRD, BITCH				; Output Flag

	sbi DDRC, 0		;SO ESTOU USANDO PARA TESTAR A INTERRUPCAO

	ldi r16, 0x50				; SPI CONTROL ->				
	out SPCR, r16				; 0x50 -> (SPE,MSTR)

	;INICIA SAIDAS
	cbi PORTD, NA
	sbi PORTD, NF
	sbi PORTD, BITCH
	;INICIALIZA REGISTRADORES
	ldi RMD, 0B0000_0000
	ldi RDS, 0B0000_0000
	ldi MINUTOS, 0B0000_0000
	ldi HORAS, 0B0000_0000
	ldi WEEK, 0B0000_0001

	ldi R16, 0B0000_0000
	mov MINUTE_BEGIN, R16
	mov HOUR_BEGIN, R16
	mov WEEK_BEGIN, R16
	mov MINUTE_END, R16
	mov HOUR_END, R16
	mov WEEK_END, R16


	;CONFIGURACAO DO TIMER 1
	cli									; Desabilita interrupcao global
	ldi r16, 0x07						; 1952 (HIGH)
	ldi r17, 0xA0						; 1952 (LOW)
	sts OCR1AH, r16						; OCR1A = 1952
	sts OCR1AL, r17
	ldi r16, (1 << OCIE1A)				;Habilita interrupcao pelo match com o comparador A
	sts TIMSK1, r16
	ldi r16, 0x0C						; Modo: 4 CTC , Prescale: 256
	sts TCCR1B, r16
	sei									; Habilita interrupcao global
	;OBS.: O comando 'sei' estava crachando no proteus, mas quando coloquei o 'cli', sem compromisso, funcionou perfeitamente.


;___________________________________________
;					MAIN
;-------------------------------------------
main:
	call run
jmp main

;___________________________________________
;					MODOS
;-------------------------------------------
;	RUN
;-------------------------------------------
run:
	ldi XH, 0x00						; Registrador de Status = 0
	;RECEBER DADOS DE TEMPO PELO SPI DO RTC
	call rtc_read
	ldi RMD, 0B1000_0000
	;ldi YH, 0x80
	;MOSTRAR UNIDADE DOS MINUTOS
	mov TEMPO, MINUTOS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	cbr RAP, 128						; Limpando o bit 7 - mostrar DP
	call troca_digito
	;MOSTRAR DEZENA DOS MINUTOS
	;Começa a conversão do tempo		; ESSE PROCESSO É REPETIDO COM O UNICO INTUITO DE ESPAÇAR O TEMPO DE EXIBICAO EM CADA DISPLAY
	MOV RAP, DE							;Passa a dezena pro display
	cbr RAP, 128						;Limpando o bit 7 - mostrar DP
	call troca_digito

	;MOSTRAR UNIDADE DAS HORAS
	mov TEMPO, HORAS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	cbr RAP, 128						; Limpando o bit 7 - mostrar DP
	call troca_digito
	;MOSTRAR DEZENA DOS HORAS
	;Começa a conversão do tempo
	MOV RAP, DE							; Passa a dezena pro display
	cbr RAP, 128						; Limpando o bit 7 - mostrar DP
	call troca_digito

	;MOSTRA A SEMANA
	call converte_semana

;_____________________________________________________________________________________________________
;			Verificar agendamento
;-----------------------------------------------------------------------------------------------------
	;VERIFICA INICIO DO AGENDAMENTO
	mov R16, WEEK_BEGIN
	cpi R16, 0x00
		breq Fim_Ver_Ag			; Se for != 0, há agendamento e o programa verifica se está dentro do intervalo.
	cpse R16, WEEK				; Se igual, compara a hora, se não, sai da verificação
		rjmp Fim_Ini_Ag

	mov R16, HOUR_BEGIN
	cpse R16, HORAS				; Se igual, compara o minuto, se não, sai da verificação
		rjmp Fim_Ini_Ag

	mov R16, MINUTE_BEGIN
	cpse R16, MINUTOS			; Se igual, ELE ENTRA NO INTERVALO, se não, sai da verificação
		rjmp Fim_Ini_Ag
	;Muda as saidas
	sbi PORTD, NA
	cbi PORTD, NF
	cbi PORTD, BITCH
	rjmp Fim_Ver_Ag
	Fim_Ini_Ag:

	;VERIFICA FIM DO AGENDAMENTO
	mov R16, WEEK_END
	cpse R16, WEEK				; Se igual, compara a hora, se não, sai da verificação
		rjmp Fim_Ver_Ag

	mov R16, HOUR_END
	cpse R16, HORAS				; Se igual, compara o minuto, se não, sai da verificação
		rjmp Fim_Ver_Ag

	mov R16, MINUTE_END
	cpse R16, MINUTOS			; Se igual, ELE ENTRA NO INTERVALO, se não, sai da verificação
		rjmp Fim_Ver_Ag
	cbi PORTD, NA
	sbi PORTD, NF
	sbi PORTD, BITCH
	Fim_Ver_Ag:
;_____________________________________________________________________________________________________

;-------------
;	BOTOES
;-------------
	sbic PIND, BR						; Verify Button_R press
    call TIMER_H						; Call function
    nop
    sbic PIND, BA						; Verify Button_A press
    call ON_H							; Call function
	nop
    ret ;FIM RUN

;________________________________________________
;  Manda os valores para os shifters registers
;------------------------------------------------

troca_digito:	
	;SPI - Transfere para os shift registers para exibir nos displays e leds
	mov r16, RDS
	call Spi_Transmiter_Display

	mov r16, RMD
	call Spi_Transmiter_Display

	mov r16, RAP
	call Spi_Transmiter_Display

	sbi PORTB, STCP						; Inicio Pulso do shift register
	cbi PORTB, STCP						; Fim Pulso do shift register

	mov r16, RMD
	andi r16, 0x0f
	sbrs RMD, 4
	lsr RMD
	andi RMD, 0xf0
	add RMD, r16
							
	ret

;-------------------------------------------
;	AJUSTE DE RELOGIO
;-------------------------------------------
TIMER_H:
	sbic PIND, BR						; Verify Button_R continue pressed
    rjmp TIMER_H
	ldi XH, 0x00						; Não pisca
	sbr RMD, MT							; MODO: T
	ldi RDS, 0B0000_0000				; Nao mostra as semanas ate chegar no Week
TIMER_H_loop:
	; Habilita a un. das horas

	cbr RMD, DISP1
	sbr RMD, DISP2
	;MOSTRA APENAS A ULTIMA HORA CRIADA NO DISPLAY
	mov TEMPO, HORAS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito

	MOV RAP, DE							; Passa a dezena pro display
	call troca_digito

	call Ajuste_Horas

	sbic PIND, BR						; Verify Button_R press
    rjmp TIMER_M						; Call function
    nop
	rjmp Timer_H_loop

TIMER_M:
	sbic PIND, BR						; Verify Button_R continue pressed
    rjmp TIMER_M
	ldi XH, 0x01						; Led T pisca
TIMER_M_loop:
	;MOSTRAR UNIDADE DOS MINUTOS
	;Habilita a un. dos minutos
	cbr RMD, 0xf0
	sbr RMD, DISP4
	mov TEMPO, MINUTOS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito

	;MOSTRAR DEZENA DOS MINUTOS
	MOV RAP, DE							;Passa a dezena pro display
	call troca_digito

	call Ajuste_Minutos

	sbic PIND, BR						; Verify Button_R press
    rjmp TIMER_WEEK						; Call function

rjmp Timer_M_loop

TIMER_WEEK:
	sbic PIND, BR						; Verify Button_R continue pressed
    rjmp TIMER_WEEK
	sbr RMD, MT							; MODO: T
	sbr RMD, MW							; MODO: W
	ldi XH, 0x02						; Led W pisca
TIMER_WEEK_loop:
	;MOSTRA A SEMANA
	call converte_semana
	cbr RMD, 0xf0
	sbr RMD, DISP4
	;MOSTRAR UNIDADE DOS MINUTOS
	mov TEMPO, MINUTOS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito
	
	MOV RAP, DE							;Passa a dezena pro display
	call troca_digito
	;cbr RAP, 128						;Limpando o bit 7 - mostrar DP

	;MOSTRA APENAS A ULTIMA HORA CRIADA NO DISPLAY
	mov TEMPO, HORAS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito

	MOV RAP, DE							; Passa a dezena pro display
	call troca_digito
	;cbr RAP, 128						; Limpando o bit 7 - mostrar DP

	call Ajuste_Week

	sbic PIND, BR						; Verify Button_R press
    rjmp send_data_rtc					; Call function
	rjmp TIMER_WEEK_loop

send_data_rtc:
	sbic PIND, BR						; Verify Button_R continue pressed
    rjmp send_data_rtc

;RTC_WRITE
	call rtc_write

ret ; FIM AJUSTE DE RELOGIO

;-------------------------------------------
;	AJUSTE DE AGENDAMENTO
;-------------------------------------------
ON_H:
	sbic PIND, BA						; Verify Button_A continue pressed
    rjmp ON_H
	ldi XH, 0x00						; Não pisca
	sbr RMD, MO							; MODO: O
	ldi RDS, 0B0000_0000				; Nao mostra as semanas ate chegar no Week
ON_H_loop:
	; Habilita a un. das horas

	cbr RMD, DISP1
	sbr RMD, DISP2
	;MOSTRA APENAS A ULTIMA HORA CRIADA NO DISPLAY
	mov TEMPO, HORAS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito

	MOV RAP, DE							; Passa a dezena pro display
	call troca_digito

	call Ajuste_Horas

	sbic PIND, BA						; Verify Button_A press
    rjmp ON_M							; Call function
    nop
	rjmp ON_H_loop

ON_M:
	sbic PIND, BA						; Verify Button_A continue pressed
    rjmp ON_M
	ldi XH, 0x03						; Led O pisca
ON_M_loop:
	;MOSTRAR UNIDADE DOS MINUTOS
	;Habilita a un. dos minutos
	cbr RMD, 0xf0
	sbr RMD, DISP4
	mov TEMPO, MINUTOS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito

	;MOSTRAR DEZENA DOS MINUTOS
	MOV RAP, DE							;Passa a dezena pro display
	call troca_digito

	call Ajuste_Minutos

	sbic PIND, BA						; Verify Button_R press
    rjmp WEEK_ON						; Call function

rjmp ON_M_loop

WEEK_ON:
	sbic PIND, BA						; Verify Button_A continue pressed
    rjmp WEEK_ON
	sbr RMD, MO							; MODO: O
	sbr RMD, MW							; MODO: W
	ldi XH, 0x02						; Led W pisca
ON_WEEK_loop:
	;MOSTRA A SEMANA
	call converte_semana
	cbr RMD, 0xf0
	sbr RMD, DISP4
	;MOSTRAR UNIDADE DOS MINUTOS
	mov TEMPO, MINUTOS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito
	
	MOV RAP, DE							;Passa a dezena pro display
	call troca_digito
	;cbr RAP, 128						;Limpando o bit 7 - mostrar DP

	;MOSTRA APENAS A ULTIMA HORA CRIADA NO DISPLAY
	mov TEMPO, HORAS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito

	MOV RAP, DE							; Passa a dezena pro display
	call troca_digito
	;cbr RAP, 128						; Limpando o bit 7 - mostrar DP

	call Ajuste_Week

	sbic PIND, BA						; Verify Button_A press
    rjmp grava_reg_ON					; Call function
	rjmp ON_WEEK_loop

grava_reg_ON:
	mov MINUTE_BEGIN, MINUTOS
	mov HOUR_BEGIN, HORAS
	mov WEEK_BEGIN, WEEK

OFF_H:
	sbic PIND, BA						; Verify Button_A continue pressed
    rjmp OFF_H
	ldi XH, 0x00						; Não pisca
	cbr RMD, MW							; Apaga LED W
	cbr RMD, MO							; Apaga LED O
	sbr RMD, MF							; MODO: F
	ldi RDS, 0B0000_0000				; Nao mostra as semanas ate chegar no Week
OFF_H_loop:
	; Habilita a un. das horas

	cbr RMD, DISP1
	sbr RMD, DISP2
	;MOSTRA APENAS A ULTIMA HORA CRIADA NO DISPLAY
	mov TEMPO, HORAS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito

	MOV RAP, DE							; Passa a dezena pro display
	call troca_digito

	call Ajuste_Horas

	sbic PIND, BA						; Verify Button_A press
    rjmp OFF_M							; Call function
    nop
	rjmp OFF_H_loop

OFF_M:
	sbic PIND, BA						; Verify Button_A continue pressed
    rjmp OFF_M
	ldi XH, 0x04						; Led F pisca
OFF_M_loop:
	;MOSTRAR UNIDADE DOS MINUTOS
	;Habilita a un. dos minutos
	cbr RMD, 0xf0
	sbr RMD, DISP4
	mov TEMPO, MINUTOS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito

	;MOSTRAR DEZENA DOS MINUTOS
	MOV RAP, DE							;Passa a dezena pro display
	call troca_digito

	call Ajuste_Minutos

	sbic PIND, BA						; Verify Button_R press
    rjmp WEEK_OFF						; Call function

rjmp OFF_M_loop

WEEK_OFF:
	sbic PIND, BA						; Verify Button_A continue pressed
    rjmp WEEK_OFF
	sbr RMD, MF							; MODO: F
	sbr RMD, MW							; MODO: W
	ldi XH, 0x02						; Led W pisca
OFF_WEEK_loop:
	;MOSTRA A SEMANA
	call converte_semana
	cbr RMD, 0xf0
	sbr RMD, DISP4
	;MOSTRAR UNIDADE DOS MINUTOS
	mov TEMPO, MINUTOS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito
	
	MOV RAP, DE							;Passa a dezena pro display
	call troca_digito
	;cbr RAP, 128						;Limpando o bit 7 - mostrar DP

	;MOSTRA APENAS A ULTIMA HORA CRIADA NO DISPLAY
	mov TEMPO, HORAS					; Transfere para TEMPO para manipular o valor
	;Começa a conversão do tempo
	call Convert_7Seg
	MOV RAP, UN							; Passa a unidade pro display
	call troca_digito

	MOV RAP, DE							; Passa a dezena pro display
	call troca_digito
	;cbr RAP, 128						; Limpando o bit 7 - mostrar DP

	call Ajuste_Week

	sbic PIND, BA						; Verify Button_A press
    rjmp grava_reg_OFF					; Call function

rjmp OFF_WEEK_loop

grava_reg_OFF:
	sbic PIND, BA						; Verify Button_A continue pressed
    rjmp grava_reg_OFF
	
	mov MINUTE_END, MINUTOS
	mov HOUR_END, HORAS
	mov WEEK_END, WEEK

ret ; FIM AJUSTE DE AGENDAMENTO

;___________________________________________
;							LISTA DE FUNCOES
;-------------------------------------------

;-------------------------------------------
;	SPI
;-------------------------------------------
rtc_write:
	; INIT WRITE DATA
	cbi PORTB, 2				; Start Transmission

	ldi r16, 0x3F				; Clock Burst Write
	out SPDR, r16				; Set comand
	call Wait_Transmit

	ldi r16, 0x00				; Value Seconds
	out SPDR, r16				; Set comand
	call Wait_Transmit

	mov r16, MINUTOS			; Value Minutis
	out SPDR, r16				; Set comand
	call Wait_Transmit
	
	mov r16, HORAS				; Value Hour
	out SPDR, r16				; Set comand
	call Wait_Transmit

	ldi r16, 0x01				; Value Data
	out SPDR, r16				; Set comand
	call Wait_Transmit

	ldi r16, 0x01				; Value Month
	out SPDR, r16				; Set comand
	call Wait_Transmit

	mov r16, WEEK				; Value Week Day
	out SPDR, r16				; Set comand
	call Wait_Transmit

	ldi r16, 0x21				; Value Year
	out SPDR, r16				; Set comand
	call Wait_Transmit

	ldi r16, 0x00				; Value Control
	out SPDR, r16				; Set bit Protect
	call Wait_Transmit

	sbi PORTB, 2				; End Transmission
	; END WRITE DATA
	ret


rtc_read:
	; INIT READ DATA
	cbi PORTB, 2				; Start Transmission

	ldi r16, 0xBF				; Clock Burst Read
	out SPDR, r16				; Set comand
	call Wait_Transmit

	clr r16						; Clear R16

	out SPDR, r16				; Value Seconds
	call Wait_Transmit
	
	lds r17, 0x4E				; Write value SPDR in R17
	
	out SPDR, r16				; Value Minutes
	call Wait_Transmit	
	lds MINUTOS, 0x4E			; Write value SPDR in MINUTOS

	out SPDR, r16				; Value Hour
	call Wait_Transmit
	lds HORAS, 0x4E				; Write value SPDR in HORAS

	out SPDR, r16				; Value Data
	call Wait_Transmit

	out SPDR, r16				; Value Month
	call Wait_Transmit

	out SPDR, r16				; Value Week Day
	call Wait_Transmit
	lds WEEK, 0x4E				; Write value SPDR in WEEK

	out SPDR, r16				; Value Year
	call Wait_Transmit

	out SPDR, r16				; Set Control
	call Wait_Transmit	

	sbi PORTB, 2				; End Transmission
	; END READ DATA
	ret

Spi_Transmiter_Display:
	out SPDR,r16

Wait_Transmit:
	in r16, SPSR	
	sbrs r16, SPIF			; Verify Flag interrupt
	rjmp Wait_Transmit
	ret
;__________________________________________________________


Convert_7Seg:
	;SEPARA DIGITOS
	MOV R16, TEMPO				; R16 vai tratar das dezenas e tempo das unidades
	ANDI TEMPO, 0B0000_1111		; Limpa os 4 bits MAIS significativos, restando apenas o valor das unidades
	MOV UN,TEMPO				; Transfere unidades para UN
	ANDI R16,0B0111_0000		; Lima os 4 bits MENOS significativos, restando o valor as dezenas (mas precisa ser deslocado ate o bit 0)
	LSR R16						; (00ddd000)
	LSR R16						; (000ddd00)
	LSR R16						; (0000ddd0)
	LSR R16						; (00000ddd)
	MOV DE, R16					; transfere dezenas para DE

	; COMPARA O VALOR DAS UNIDADES E TRANSFERE O VALOR EM 7SEG. (invertido) PARA 'UN'
	u0:
	cpi UN, 0b00000000
	brne u1
	ldi UN, 0b11000000
	u1:
	cpi UN, 0b00000001
	brne u2
	ldi UN, 0b11111001
	u2:
	cpi UN, 0b00000010
	brne u3
	ldi UN, 0b10100100
	u3:
	cpi UN, 0b00000011
	brne u4
	ldi UN, 0b10110000
	u4:
	cpi UN, 0b00000100
	brne u5
	ldi UN, 0b10011001
	u5:
	cpi UN, 0b00000101
	brne u6
	ldi UN, 0b10010010
	u6:
	cpi UN, 0b00000110
	brne u7
	ldi UN, 0b10000010
	u7:
	cpi UN, 0b00000111
	brne u8
	ldi UN, 0b11111000
	u8:
	cpi UN, 0b00001000
	brne u9
	ldi UN, 0b10000000
	u9:
	cpi UN, 0b00001001
	brne d0
	ldi UN, 0b10010000

	; COMPARA O VALOR DAS DEZENAS E TRANSFERE O VALOR EM 7SEG. (invertido) PARA 'DE'
	d0:
	cpi DE, 0b00000000
	brne d1
	ldi DE, 0b11000000
	d1:
	cpi DE, 0b00000001
	brne d2
	ldi DE, 0b11111001
	d2:
	cpi DE, 0b00000010
	brne d3
	ldi DE, 0b10100100
	d3:
	cpi DE, 0b00000011
	brne d4
	ldi DE, 0b10110000
	d4:
	cpi DE, 0b00000100
	brne d5
	ldi DE, 0b10011001
	d5:
	cpi DE, 0b00000101
	brne d6
	ldi DE, 0b10010010
	d6:
	cpi DE, 0b00000110
	brne d7
	ldi DE, 0b10000010
	d7:
	cpi DE, 0b00000111
	brne d8
	ldi DE, 0b11111000
	d8:
	cpi DE, 0b00001000
	brne d9
	ldi DE, 0b10000000
	d9:
	cpi DE, 0b00001001
	brne fim
	ldi DE, 0b10010000

	fim:
	nop
	ret


converte_semana:

	andi WEEK,0B00000111	;Limpa o que nao faz parte do valor da semana, por precaucao

	; COMPARA O VALOR DO DIA DE SEMANA E TRANSFERE A POSICAO DO LED A SER LIGADO PARA DIRETO 'RDS', O RESPONSAVEL PELOS LEDS DA SEMANA
	w1:
	cpi WEEK, 0b00000001
	brne w2
	ldi RDS, 0b00000001 ;SEGUNDA
	w2:
	cpi WEEK, 0b00000010
	brne w3
	ldi RDS, 0b00000010 ;TERCA
	w3:
	cpi WEEK, 0b00000011
	brne w4
	ldi RDS, 0b00000100 ;QUARTA
	w4:
	cpi WEEK, 0b00000100
	brne w5
	ldi RDS, 0b00001000 ;QUINTA
	w5:
	cpi WEEK, 0b00000101
	brne w6
	ldi RDS, 0b00010000 ;SEXTA
	w6:
	cpi WEEK, 0b00000110
	brne w7
	ldi RDS, 0b00100000 ;SABADO
	w7:
	cpi WEEK, 0b00000111
	brne fim_week
	ldi RDS, 0b01000000 ;DOMINGO

	fim_week:

	ret

Ajuste_Minutos:
    mov UN, MINUTOS                 ; Copy value input
    mov DE, MINUTOS                 ; Copy value input
    cbr UN,0XF0                     ; Clear value DE
    cbr DE,0X0F                     ; Clear value UN
    
    sbic PIND, BINC                 ; Verify Button_INC press
    call b_inc_min                  ; Call function
    nop
    sbic PIND, BDEC		            ; Verify Button_DEC press
    call b_dec_min                  ; Call function

	mov MINUTOS, DE
	add MINUTOS, UN
    ret

Ajuste_Horas:
	mov UN, HORAS                    ; Copy value input
    mov DE, HORAS                    ; Copy value input
    cbr UN,0XF0                      ; Clear value DE
    cbr DE,0X0F                      ; Clear value UN
    
    sbic PIND, BINC                  ; Verify Button_INC press
    call b_inc_h                     ; Call function
    nop
    sbic PIND, BDEC                  ; Verify Button_DEC press
    call b_dec_h                     ; Call function

	mov HORAS, DE
	add HORAS, UN
    ret

Ajuste_Week:
    
    sbic PIND, BINC                  ; Verify Button_INC press
    call b_inc_w                     ; Call function
    nop
    sbic PIND, BDEC                  ; Verify Button_DEC press
    call b_dec_w                     ; Call function

    ret
;__________________________________________
;    logica - inc/dec - MINUTOS
;------------------------------------------

b_inc_min:
	call delay						; Causa um delay de 0.5s
    inc UN                            ; Inc UN
    cpi DE, 0x50                    ; Verify DE = 50
    brsh limite_sup_de_min            ; Start upper limit
    cpi UN, 0x0A                    ; Verify UN >= 10
    brsh clear_un_min                ; Start Clear unit
    ret

b_dec_min:
	call delay						; Causa um delay de 0.5s
    dec UN                            ; Dec UN
    cpi DE, 0x00                    ; Verify DE = 00
    breq limite_inf_de_min            ; Start lower limit
    cpi UN, 0xFF                    ; Verify UN = 255
    breq set_un_min                    ; Start set unit
    ret

clear_un_min:
    ldi r16, 0x10                    ; Inc DE if UN > 9
    add DE, r16
    clr UN                            ; Clr UN if UN > 9
    ret

limite_sup_de_min:
    cpi UN, 0x0A                    ; When DE = 5, verify UN.
    brsh limite_sup_un_min            ; IF UN > 9 (limit is here)
    ret

limite_sup_un_min:                    
    clr UN                            ; Return to 00 when it reached the sup limit
    clr DE                            ; Return to 00 when it reached the sup limit
    ret
    
limite_inf_de_min:
    cpi UN, 0xFF                    ; When DE = 0, verity UN
    brsh limite_inf_un_min            ; IF UN < 0, (limit is here)
    ret

limite_inf_un_min:
    ldi UN, 0x09                    ; Return to 09 when it reached the inf limit
    ldi DE, 0x50                    ; Return to 50 when it reached the inf limit
    ret

set_un_min:
    ldi UN, 0x09                    ; when unit limit is reached set UN to 9 and 
    ldi r16, 0x10
    sub DE, r16
    ret

;__________________________________________
;    logica - inc/dec - Horas
;------------------------------------------

b_inc_h:
	call delay						; Causa um delay de 0.5s
    inc UN                            ; Inc UN
    cpi DE, 0x20                    ; Verify DE = 20
    brsh limite_sup_de_h            ; Start upper limit
    cpi UN, 0x0A                    ; Verify UN >= 0A
    brsh clear_un_h                    ; Start Clear unit
    ret

b_dec_h:
	call delay						; Causa um delay de 0.5s
    dec UN                            ; Dec UN
    cpi DE, 0x00                    ; Verify DE = 00
    breq limite_inf_de_h            ; Start lower limit
    cpi UN, 0xFF                    ; Verify UN = 255
    breq set_un_h                    ; Start set unit
    ret

clear_un_h:
    ldi r16, 0x10
    add DE, r16
    clr UN
    ret

limite_sup_de_h:
    cpi UN, 0x04
    brsh limite_sup_un_h
    ret

limite_sup_un_h:
    clr UN
    clr DE
    ret
    
limite_inf_de_h:
    cpi UN, 0xFF
    brsh limite_inf_un_h
    ret

limite_inf_un_h:
    ldi UN, 0x03
    ldi DE, 0x20
    ret

set_un_h:
    ldi UN, 0x09
    ldi r16, 0x10
    sub DE, r16
    ret

b_inc_w:
	call delay							; Causa um delay de 0.5s
    inc WEEK							; Inc WEEK
    cpi WEEK, 0x08						; Verify WEEK = 08
    brsh limite_sup_w					; Start upper limit
    ret

b_dec_w:
	call delay							; Causa um delay de 0.5s
    dec WEEK                            ; Dec WEEK
    cpi WEEK, 0x00					    ; Verify WEEK = 00
    breq limite_inf_w					; Start lower limit
	ret

limite_inf_w:
    ldi WEEK, 0x07
    ret

limite_sup_w:
    ldi WEEK, 0x01
    ret

; DELAY DE O.5s
delay:
        ldi r16, 0xFF
        ldi ZH, 0xFF
        ldi ZL, 0x03 ;;;recalcular
delay_loop0:
        dec ZL
        breq fim_delay
delay_loop1:
        dec r16                 ; +1 clock
        breq delay_loop0        ; +2 clock quando true
delay_loop2:

        dec ZH              ; +1 clock
        brne delay_loop2	; +2 clock
        jmp delay_loop1		; +3 clock
 fim_delay:
        ret
;---------------------------------------------------
;	INTERRUPCAO TIMER 1 PARA 0.5s
;---------------------------------------------------

; ESTA SENDO TESTADO AINDA
TIM1_COMPA:
;Pisca_T
	cpi XH, 0x01
	brne Pisca_W
	ldi R16,0B00000001
	EOR RMD, R16
	jmp Fim_int

Pisca_W:
	cpi XH, 0x02
	brne Pisca_O
	ldi R16,0B00000010
	EOR RMD, R16
	jmp Fim_int

Pisca_O:
	cpi XH, 0x03
	brne Pisca_R
	ldi R16,0B00000100
	EOR RMD, R16
	jmp Fim_int

Pisca_R:
	cpi XH, 0x04
	brne Fim_int
	ldi R16,0B00001000
	EOR RMD, R16
	jmp Fim_int

Fim_int:
reti