/*
 * main.c
 *
 * Created: 8/13/2021 7:15:26 PM
 *  Author: joaom
 */ 

#include <xc.h>
#define F_CPU 8000000UL
#include <avr/io.h>

void delay_1(){
	for(int i = 0;i<200;i++){}
}
void lcd_cmd(unsigned char cmd){
	
	PORTB &= 0xF0;							// Mask preservation 4 LSBs
	PORTB |= cmd;							// Add data command

	PORTB |= (1<<PORTB4);					// Set E = 1
	PORTB &= ~(1<<PORTB5);					// Set RS = 0
	delay_1();				
	PORTB &= ~(1<<PORTB4);					// Set E = 0 

}

void lcd_data(unsigned char data){
	
	PORTB |= (1<<PORTB5);					// Set RS = 1
	
	for(int i=0; i<2 ;i++){					// Send two data (2x 4 bits)
		PORTB &= 0xF0;						// Mask preservation 4 LSBs
		PORTB |= data;						// Add data
		
		PORTB |= (1<<PORTB4);				// Set E = 1
		delay_1();
		PORTB &= ~(1<<PORTB4);				// Set E = 0
	}
	PORTB &= ~(1<<PORTB5);					// Set RS = 0 

}
void lcd_adress(unsigned char adress){
	
	PORTB &= ~(1<<PORTB5);					// Set RS = 0
	
	for(int i=0; i<2 ;i++){					// Send two data (2x 4 bits)
		PORTB &= 0xF0;						// Mask preservation 4 LSBs
		PORTB |= adress;						// Add data
		
		PORTB |= (1<<PORTB4);				// Set E = 1
		delay_1();
		PORTB &= ~(1<<PORTB4);				// Set E = 0
	}

}
void lcd_init(){
	
	lcd_cmd(0x02);							//RS = 0 D7:D4 = 0010
	lcd_cmd(0x08);							//RS = 0 D7:D4 = 1000
	
}

void lcd_off_cursor(){

	lcd_cmd(0x00);							//RS = 0 D7:D4 = 0000
	lcd_cmd(0x0C);							//RS = 0 D7:D4 = 1100
}

void lcd_on_cursor(){
	
	lcd_cmd(0x00);							//RS = 0 D7:D4 = 0000
	lcd_cmd(0x0F);							//RS = 0 D7:D4 = 1100
}

int main(void){
	
	DDRB = 0xff;
	DDRC = 0xff;
	PORTB = 0xF8;
	PORTC = 0xAF;
	
	lcd_init();								//Init LCD
	lcd_off_cursor();
	lcd_on_cursor();
	lcd_adress(0x8F)
	lcd_data(0x35);
    
}