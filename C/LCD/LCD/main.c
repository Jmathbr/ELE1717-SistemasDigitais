/*
 * main.c
 *
 * Created: 8/13/2021 7:15:26 PM
 *  Author: joaom
 */ 
#define AUXPORTB PORTB

#include <xc.h>
void lcd_cmd(unsigned char cmd){
	
	PORTB &= 0xF0;
	PORTB |= cmd;
	
	PORTC &= 0xFC;
	PORTC |= 0x01;
	for(int i = 0;i<255;i++){}//Delay
	PORTC &=~ 0x01;

}

void lcd_data(unsigned char data){
	
	PORTB &= 0xF0;
	PORTB |= data;
	
	PORTC &= 0xFC;
	PORTC |= 0x01;
	for(int i = 0;i<255;i++){}//Delay
	PORTC &=~ 0x01;

}

void lcd_init(){
	//RS = 0 D7:D4 = 0010
	//RS = 0 D7:D4 = 1000
	lcd_cmd(0x02);
	lcd_cmd(0x08);
}

void lcd_off_cursor(){
	//RS = 0 D7:D4 = 0000
	//RS = 0 D7:D4 = 1100
	lcd_cmd(0x00);
	lcd_cmd(0x0C);
}

void lcd_on_cursor(){
	//RS = 0 D7:D4 = 0000
	//RS = 0 D7:D4 = 1100
	lcd_cmd(0x00);
	lcd_cmd(0x0F);
}


int main(void)
{
	DDRB = 0xff;
	DDRC = 0xff;
	PORTB = 0xF8;
	PORTC = 0xAF;
	lcd_init();
	lcd_off_cursor();
    while(1){
		lcd_on_cursor();
	}
}