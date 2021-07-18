.include "m328pdef.inc"
.org 0x0000   

.def cont = r17
.def ADCL_aux = r20
.def ADCH_aux = r21 
.def PWM_value = r22
.def PWM_valueL = r23
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
	;---> CONFIGURANDO SENHAS
	ldi XL, 0x00 
	ldi XH, 0x00 
		
	ldi YL, 0x00
	ldi YH, 0x00 
		
	ldi ZL, 0x00 
	ldi ZH, 0x00 
	
	;---> CONFIGURANDO PORTAS DE SAIDA

	ldi r16 , 0xff				; Defina todos os bits como 1
	out DDRD, r16				; Defina todas as portas D como saida

	Sbi DDRB, 3					; Defina como porta de saida
	Sbi DDRB, 4					; Defina como porta de saida
	Sbi DDRB, 5					; Defina como porta de saida
	Sbi DDRB, 7					; Defina como porta de saida
	
	sbi DDRC, 5					; Porta para acionamento do mux
	sbi DDRC, 6					; Porta para acionamento do mux

	;---> CONFIGURANDO PORTAS DE ENTRADA
	
	cbi DDRC, 2
	cbi DDRC, 1

	;---> CONFIGURANDO ADC
		;PC0

	ldi r16,0x40				; 0100 - AVC, 0000 - ADC0 PC0 
	sts ADMUX, r16				; ADMUX - referencia e porta
	
	ldi r16, 0xE7				; 1110 - 0N, 0111 - ADPS(3 bits) 
	sts ADCSRA, r16				; ADCSRA - Habilitador e prescale 

	;---> CONFIGURANDO PWM

	ldi r16, 0x83				; guarde 1000 0011 
	sts 0xB0, r16				; TCCR2A- TIMER 2 - Fast PWM 
	
	ldi r16, 0x03				; guarde 0000 0011 
	sts 0xB1, r16				; TCCR2B - TIMER 2
    
	ldi PWM_value, 0x7f			; 32 - 50, 7F - 127, FF - 255
	ldi PWM_valueL, 0x00

	;---> CONFIGURANDO TIMER

    ldi r16, 0x0D				; Ligar o timer, 0x05 Desativar
    sts TCCR1B, r16				; Configurar o timer
	
	ldi r16, 0x00;0x1E        
    sts OCR1AH, r16				; definindo o valor de TOP - HIGH
	
	ldi r16, 0x0A;0x84
	sts OCR1AL, r16				; definindo o valor de TOP - LOW

	;sbi TIFR1, 1				; Limpar Flag do timer
	
	rjmp Close

;------------------------- LOOP ---------------------------------
Close:
	sbi PORTB, 5				; Liga led Vermelho
	cbi PORTB, 4				; Desliga led azul
	cbi PORTB, 3				; Desliga led verde
	sts OCR2A, PWM_valueL
	cbi	PORTB, 7				; Tranca fechada
	
	cbi PORTC, 5				; Padrao do display apagado
	sbi PORTC, 6				; Seletor do MUX
	clr cont					; Zera o contador

	sbis PINC, 1				; Verifique se o pino ta em alto, true = salto
	rjmp Close
	rjmp Read_BP_ajuste
	
ajuste:
	
	cbi PORTB, 5				; Desliga led Vermelho
	sbi PORTB, 4				; Liga led azul
	cbi PORTB, 3				; Desliga led verde
	sts OCR2A, PWM_valueL
	cbi	PORTB, 7				; Tranca fechada

	cbi PORTC, 5				; Padrao do display lendo o valor do potenciometro
	cbi PORTC, 6				; Seletor do MUX

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
	nop
	nop

	sbic PINC, 2				; ADD Verifique se o pino ta em alto, true = salto
	rjmp Read_BA_ajuste
	nop
	nop

	sbis PINC, 1				; Power Verifique se o pino ta em alto, true = salto
	rjmp ajuste
	rjmp Read_BP_Close

verificar:
	inc cont					; Incrementa no contador

	cpi cont, 0x01				; compara se esta na primeira senha
	breq VP1

	cpi cont, 0x02				; compara se esta na segunda senha
	breq VP2

	cpi cont, 0x03				; compara se esta na terceira senha
	breq VP3

VP1:
	cpse ADCH_aux, XH			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua
	cpse ADCL_aux, XL			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua

	nop
	sbi TIFR1, 1				; Limpar Flag do timer
	rjmp timer

VP2:
	cpse ADCH_aux, YH			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua
	cpse ADCL_aux, YL			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua

	nop
	sbi TIFR1, 1				; Limpar Flag do timer
	rjmp timer

VP3:
	cpse ADCH_aux, ZH			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua
	cpse ADCL_aux, ZL			; se == skip, pois tem que ficar 0
	rjmp errou					; se != continua

	nop
	sbi TIFR1, 1				; Limpar Flag do timer
	rjmp timer

Map:							; Forçar que qualquer valor maior que 999 seja 999
	cpi ADCL_aux, 0xE7			; Compara para ver se é maior que 1000
	brsh Force					; Caso o valor seja >=

	out PORTD, ADCL_aux			; saida de 8 bits BCD (8 bits)
	out PORTC, ADCH_aux			; saida de 8 bits BCD (2 bits) 
	nop
	nop

	sbic PINC, 2				; ADD Verifique se o pino ta em alto, true = salto
	rjmp Read_BA_ajuste
	nop
	nop

	sbis PINC, 1				; Power Verifique se o pino ta em alto, true = salto
	rjmp ajuste
	rjmp Read_BP_Close			

timer:
	;sbi PORTB, 3				; Liga led Verde
	sts OCR2A, PWM_value		;controla o duty cicle 50% 127 0x7F
	cbi PORTB, 4				; Liga led azul
	sbi PORTB, 5				; Desliga led Vermelho

	
	
	sbis TIFR1, 1				; TIFR1 - Quando o contador estourar, bit 1 = 1 
	rjmp timer
	
	cpi cont, 0x03				; compara se ja esta na terceira senha
	brsh compare
	rjmp ajuste

open:
	cbi PORTB, 5				; Desliga led Vermelho
	cbi PORTB, 4				; Desliga led azul
	sbi PORTB, 3				; liga led verde
	sts OCR2A, PWM_value
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
	sbis PINC, 2				; Verifique se Continua em alto, true = salto
	rjmp verificar
	rjmp Read_BA_ajuste



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