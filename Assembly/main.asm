.include "m328pdef.inc"
.org 0x0000   

.def cont = r17
.def ADCL_aux = r20
.def ADCH_aux = r21 
.def PWM_value = r22
.def soma = r23
.def subt = r24

.def pass = r25

;.def r26 = XL
;.def r27 = XH

;.def r28 = YL
;.def r29 = YH
	 
;.def r30 = ZL
;.def r31 = ZH

rjmp setup

;------------------------- SETUP ---------------------------------

Setup:
	;---> CONFIGURANDO PORTAS DE SAIDA
	ldi XL, 0x00 
	ldi XH, 0x00 
		
	ldi YL, 0x00
	ldi YH, 0x00 
		
	ldi ZL, 0x00 
	ldi ZH, 0x00 
	
	;---> CONFIGURANDO PORTAS DE SAIDA

	ldi r16 , 0xff				; Defina todos os bits como 1
	out DDRD, r16				; Defina todas as portas D como saida

	ldi r16, 0xb8				; Defina os bits 3,4,5,7 como 1 
	out DDRB, r16				; Defina as portas 3,4,5,7 como saida
	
	sbi DDRC, 5					; Porta para acionamento do mux
	sbi DDRC, 6					; Porta para acionamento do mux

	;---> CONFIGURANDO PORTAS DE ENTRADA
	
	ldi r16, 0x06				; Defina os bits 1 e 2 como 0
	out DDRC, r16				; Defina como portas de entrada
	
	;---> CONFIGURANDO ADC
		;PC0

	ldi r16,0x40				; 0100 - AVC, 0000 - ADC0 PC0 
	sts ADMUX, r16				; ADMUX - referencia e porta
	
	ldi r16, 0xE7				; 1110 - 0N, 0111 - ADPS(3 bits) 
	sts ADCSRA, r16				; ADCSRA - Habilitador e prescale 

	;---> CONFIGURANDO PWM

	ldi r16, 0x83				; guarde 1000 0011 
	sts 0xB0, r16				; TCCR2A- TIMER 2 - Fast PWM 
	
	ldi r16, 0x03				; guarde 1010 0011 
	sts 0xB1, r16				; TCCR2B - TIMER 2
    
	ldi PWM_value, 0x7f			; 32 - 50, 7F - 127, FF - 255

	;---> CONFIGURANDO TIMER

    ldi r16, 0x05				; Ligar o timer, 0x05 Desativar
    sts TCCR1B, r16				; Configurar o timer
	cbi TIFR1, 1

	rjmp Close

;------------------------- LOOP ---------------------------------
Close:
	sbi PORTB, 5				; Liga led Vermelho
	cbi PORTB, 4				; Desliga led azul
	cbi PORTB, 3				; Desliga led verde
	cbi	PORTB, 7				; Tranca fechada
	
	cbi PORTC, 5				; Padrao do display apagado
	sbi PORTC, 6
	
	sbis PINC, 1				; Verifique se o pino ta em alto, true = salto
	rjmp Close
	rjmp Read_BP_ajuste
	
ajuste:
	ldi soma, 0x00
	ldi subt, 0x00

	;ldi r16, 0x0D				; Ligar o timer, 0x05 Desativar, 0x0D LIGAR
    ;sts TCCR1B, r16				; Configurar o timer
	clr r16
	sts TCNT1H, r16 
	sts TCNT1L, r16 
	sts TIFR1, r16
	;ldi r16, (1 << TOV2) | (1 << OCF2A) | (1 << OCF2B)

	cbi PORTB, 5				; Desliga led Vermelho
	sbi PORTB, 4				; Liga led azul
	cbi PORTB, 3				; Desliga led verde
	cbi	PORTB, 7				; Tranca fechada

	cbi PORTC, 5				; Padrao do display lendo o valor do potenciometro
	cbi PORTC, 6

	;lendo adc
	lds ADCL_aux ,ADCL			; Salve copias dos valores lidos
	lds r16 ,ADCH
	lsl r16
	lsl r16
	mov ADCH_aux, r16
	
	cpi	ADCH_aux, 0x0C
	breq Map

	out PORTD, ADCL_aux			; saida de 8 bits BCD (8 bits)
	out PORTC, ADCH_aux			; saida de 8 bits BCD (2 bits) 

	sbic PINC, 2				; ADD Verifique se o pino ta em alto, true = salto
	rjmp Read_BA_ajuste
	nop
	nop
	nop

	sbis PINC, 1				; Power Verifique se o pino ta em alto, true = salto
	rjmp ajuste
	rjmp Close

verificar:
	inc cont					; Incrementa no contador
    ldi r16, 0x05				; Ligar o timer, 0x05 Desativar
    sts TCCR1B, r16				; Configurar o timer

	cpi cont, 0x01				; compara se esta na primeira senha
	breq VP1

	cpi cont, 0x02				; compara se esta na segunda senha
	breq VP2

	cpi cont, 0x03				; compara se esta na terceira senha
	breq VP3

timer:
	sbi PORTB, 3				; Liga led Verde
	cbi PORTB, 4				; Liga led azul
	sbi PORTB, 5				; Desliga led Vermelho

	;out OCR2A, PWM_value		;controla o duty cicle 50% 127 0x7F
	
	ldi r16, 0x0D				; Ligar o timer, 0x05 Desativar, 0x0D LIGAR
    sts TCCR1B, r16				; Configurar o timer

    ldi r16, 0x1E        
    sts OCR1AH, r16				; definindo o valor de TOP - HIGH
	
	ldi r16, 0x84
	sts OCR1AL, r16				; definindo o valor de TOP - LOW
	
	sbis TIFR1, 2				; TIFR1 - Quando o contador estourar, bit 1 = 1 
	rjmp timer
	
	cpi cont, 0x03				; compara se ja esta na terceira senha
	brsh compare
	rjmp ajuste

open:
	cbi PORTB, 5				; Desliga led Vermelho
	cbi PORTB, 4				; Desliga led azul
	sbi PORTB, 3				; liga led verde
	sbi	PORTB, 7				; Tranca aberta
	
	sbi PORTC, 5				; Padrao dos --- no display
	cbi PORTC, 6

	ldi r16, 0x05				; Ligar o timer, 0x05 Desativar
    sts TCCR1B, r16				; Configurar o timer
	cbi TIFR1, 1

	sbis PINC, 1				;Verifique se o pino ta em alto, true = salto
	rjmp open
	rjmp Read_BP_Close

Read_BP_Ajuste:
	sbis PINC, 1				; Verifique se Continua em alto, true = salto
	rjmp ajuste
	rjmp Read_BP_ajuste

Read_BP_Close:
	sbis PINC, 1				; Verifique se Continua em alto, true = salto
	rjmp Close
	rjmp Read_BP_Close

Read_BA_ajuste:
	sbic PINC, 2				; Verifique se Continua em alto, true = salto
	rjmp verificar
	rjmp Read_BA_ajuste

Map:							; Forçar que qualquer valor maior que 999 seja 999
	cpi ADCL_aux, 0xE7			; Compara para ver se é maior que 1000
	brsh Force					; Caso o valor seja >=
	rjmp ajuste					; Caso o valor seja <

Force:
	ldi ADCL_aux, 0xE7			; Forçe o valor 999 no Registrador
	out PORTD, ADCL_aux			; Saida de 8 bits BCD (8 bits)
	out PORTC, ADCH_aux			; Saida de 8 bits BCD (2 bits) 
	rjmp ajuste					; Volte para ajuste

errou:
	ldi pass, 0x01				; Seta qualquer bit para 1
	rjmp timer
	
compare:
	tst pass
	breq open
	rjmp Close

VP1:
	cpse ADCH_aux, XH			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua
	cpse ADCL_aux, XL			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua

	nop
	rjmp timer

VP2:
	cpse ADCH_aux, YH			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua
	cpse ADCL_aux, YL			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua

	nop
	rjmp timer

VP3:
	cpse ADCH_aux, ZH			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua
	cpse ADCL_aux, ZL			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua

	nop
	rjmp timer