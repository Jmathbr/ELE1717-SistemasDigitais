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
void delay_2(){
	for(int i = 0;i<1000;i++){}
}
void lcd_cmd(unsigned char cmd){
	
	PORTB &= 0xF0;								// Mask preservation 4 LSBs
	PORTB |= cmd;								// Add data command
	
	PORTB &= ~(1<<PORTB5);						// Set RS = 0
	PORTB |= (1<<PORTB4);						// Set E = 1
	delay_1();				
	PORTB &= ~(1<<PORTB4);						// Set E = 0 

}

void lcd_data(unsigned char data){
	
	PORTB |= (1<<PORTB5);						// Set RS = 1
	
	for(int i=0; i<2 ;i++){						// Send two data (2x 4 bits)
		if(i==0){
			
			char MSB_data = data >> 4;			// Shift right 4 Bits MSB >> LSB
			PORTB &= 0xF0;						// Mask preservation 4 MSBs
			PORTB |= MSB_data;					// Add data		
			
			PORTB |= (1<<PORTB4);				// Set E = 1
			delay_1();
			PORTB &= ~(1<<PORTB4);				// Set E = 0
		}
		
		else{
			PORTB &= 0xF0;						// Mask preservation 4 LSBs
			PORTB |= data;						// Add data
			
			PORTB |= (1<<PORTB4);				// Set E = 1
			delay_1();
			PORTB &= ~(1<<PORTB4);				// Set E = 0
		}
	}
	PORTB &= ~(1<<PORTB5);						// Set RS = 0 

}
void lcd_adress(unsigned char adress){
	
	PORTB &= ~(1<<PORTB5);						// Set RS = 0
	
	for(int i=0; i<2 ;i++){						// Send two data (2x 4 bits)
		if(i==0){
			
			char MSB_adress = adress >> 4;		// Shift right 4 Bits MSB >> LSB
			PORTB &= 0xF0;						// Mask preservation 4 MSBs
			PORTB |= MSB_adress;				// Add data
			
			PORTB |= (1<<PORTB4);				// Set E = 1
			delay_1();
			PORTB &= ~(1<<PORTB4);				// Set E = 0
		}
		
		else{
			PORTB &= 0xF0;						// Mask preservation 4 LSBs
			PORTB |= adress;						// Add data
			
			PORTB |= (1<<PORTB4);				// Set E = 1
			delay_1();
			PORTB &= ~(1<<PORTB4);				// Set E = 0
		}
	}
	PORTB &= ~(1<<PORTB5);					// Set RS = 0 
}
void lcd_init(){
	
	lcd_cmd(0x02);							//RS = 0 D7:D4 = 0010
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

void lcd_default(){
	
	lcd_adress(0x80);
	lcd_data(0x4D);							//M
	lcd_adress(0x81);
	lcd_data(0x6F);							//o
	lcd_adress(0x82);
	lcd_data(0x64);							//d
	lcd_adress(0x83);
	lcd_data(0x3A);							//:
	
	lcd_adress(0xC0);
	lcd_data(0x4D);							//M
	lcd_adress(0xC1);
	lcd_data(0x73);							//s
	lcd_adress(0xC2);
	lcd_data(0x67);							//g
	lcd_adress(0xC3);
	lcd_data(0x3A);							//:
}

void lcd_mod(int mod){
	switch(mod){
		case 1:								//AM
			lcd_adress(0x85);
			lcd_data(0x4D);
			
			lcd_adress(0x86);
			lcd_data(0x4D);
			
			lcd_adress(0x87);
			lcd_data(0x01);
			
			lcd_adress(0x89);
			lcd_data(0x46);					//F
			lcd_adress(0x8A);
			lcd_data(0x3A);					//:
			
			lcd_adress(0X8D);
			lcd_data(0xB0);					//-
			lcd_adress(0X8C);
			lcd_data(0xB0);					//-
			lcd_adress(0X8B);
			lcd_data(0xB0);					//-
			
			lcd_adress(0x8E);
			lcd_data(0x48);					//H
			lcd_adress(0x8F);
			lcd_data(0x7A);					//z
			
			lcd_adress(0XC5);
			lcd_data(0xB0);					//-
			lcd_adress(0XC6);
			lcd_data(0xB0);					//-
			lcd_adress(0XC7);
			lcd_data(0xB0);					//-
			break;
			
		case 2:								//FM
			lcd_adress(0x85);
			lcd_data(0x46);
			
			lcd_adress(0x86);
			lcd_data(0x4D);
			
			lcd_adress(0x87);
			lcd_data(0x01);
			lcd_adress(0x89);
			
			lcd_adress(0x89);
			lcd_data(0x46);					//F
			lcd_adress(0x8A);
			lcd_data(0x3A);					//:
			
			lcd_adress(0X8D);
			lcd_data(0xB0);					//-
			lcd_adress(0X8C);
			lcd_data(0xB0);					//-
			lcd_adress(0X8B);
			lcd_data(0xB0);					//-
			
			lcd_adress(0x8E);
			lcd_data(0x48);					//H
			lcd_adress(0x8F);
			lcd_data(0x7A);					//z
			
			lcd_adress(0XC5);
			lcd_data(0xB0);					//-
			lcd_adress(0XC6);
			lcd_data(0xB0);					//-
			lcd_adress(0XC7);
			lcd_data(0xB0);					//-
			break;
			
		case 3:								//ASK
			lcd_adress(0x85);
			lcd_data(0x41);
			
			lcd_adress(0x86);
			lcd_data(0x53);
			
			lcd_adress(0x87);
			lcd_data(0x4B);
			
			lcd_adress(0x89);
			lcd_data(0x54);					//T
			lcd_adress(0x8A);
			lcd_data(0x3A);					//:
			
			lcd_adress(0X8D);
			lcd_data(0xB0);					//-
			lcd_adress(0X8C);
			lcd_data(0xB0);					//-
			lcd_adress(0X8B);
			lcd_data(0xB0);					//-
			
			lcd_adress(0x8E);
			lcd_data(0x62);					//b
			lcd_adress(0x8F);
			lcd_data(0x73);					//s
		
			lcd_adress(0XC5);
			lcd_data(0xB0);					//-
			lcd_adress(0XC6);
			lcd_data(0xB0);					//-
			lcd_adress(0XC7);
			lcd_data(0x2E);					//.
			lcd_adress(0XC8);
			lcd_data(0xB0);					//-
			lcd_adress(0XC9);
			lcd_data(0xB0);					//-
			lcd_adress(0XCA);
			lcd_data(0x2E);					//.
			lcd_adress(0XCB);
			lcd_data(0xB0);					//-
			lcd_adress(0XCC);
			lcd_data(0xB0);					//-
			lcd_adress(0XCD);
			lcd_data(0x2E);					//.
			lcd_adress(0XCE);
			lcd_data(0xB0);					//-
			lcd_adress(0XCF);
			lcd_data(0xB0);					//-
			break;
			
		case 4:								//FSK
			lcd_adress(0x85);
			lcd_data(0x46);
			
			lcd_adress(0x86);
			lcd_data(0x53);
					
			lcd_adress(0x87);
			lcd_data(0x4B);
			
			lcd_adress(0x89);
			lcd_data(0x54);					//T
			lcd_adress(0x8A);
			lcd_data(0x3A);					//:
			
			lcd_adress(0X8D);
			lcd_data(0xB0);					//-
			lcd_adress(0X8C);
			lcd_data(0xB0);					//-
			lcd_adress(0X8B);
			lcd_data(0xB0);					//-
			
			lcd_adress(0x8E);
			lcd_data(0x62);					//b
			lcd_adress(0x8F);
			lcd_data(0x73);					//s
			
			lcd_adress(0XC5);
			lcd_data(0xB0);					//-
			lcd_adress(0XC6);
			lcd_data(0xB0);					//-
			lcd_adress(0XC7);
			lcd_data(0x2E);					//.
			lcd_adress(0XC8);
			lcd_data(0xB0);					//-
			lcd_adress(0XC9);
			lcd_data(0xB0);					//-
			lcd_adress(0XCA);
			lcd_data(0x2E);					//.
			lcd_adress(0XCB);
			lcd_data(0xB0);					//-
			lcd_adress(0XCC);
			lcd_data(0xB0);					//-
			lcd_adress(0XCD);
			lcd_data(0x2E);					//.
			lcd_adress(0XCE);
			lcd_data(0xB0);					//-
			lcd_adress(0XCF);
			lcd_data(0xB0);					//-
			break;
	}
	
}

/*
	lcd_adress(0x89)
	lcd_data(0x54)			//T
	lcd_adress(0x8A)
	lcd_data(0x3A)			//:
	
	lcd_adress(0x89)
	lcd_data(0x46)			//F
	lcd_adress(0x8A)
	lcd_data(0x3A)			//:
	
	lcd_adress(0x89)
	lcd_data(0x50)			//P
	lcd_adress(0x8A)
	lcd_data(0x3A)			//:
		
	lcd_adress(0x8E)			
	lcd_data(0x62)			//b
	lcd_adress(0x8F)
	lcd_data(0x39)			//s
	
	lcd_adress(0x8E)	
	lcd_data(0x48)			//H
	lcd_adress(0x8F)
	lcd_data(0x7A)			//z
	
	
	//linha 1
	lcd_adress(0X8D);
	lcd_data(0xB0);					//-
	lcd_adress(0X8C);
	lcd_data(0xB0);					//-
	lcd_adress(0X8B);
	lcd_data(0xB0);					//-
	
	//linha 2
	lcd_adress(0XC5);
	lcd_data(0xB0);					//-
	lcd_adress(0XC6);
	lcd_data(0xB0);					//-
	lcd_adress(0XC7);
	lcd_data(0xB0);					//-
	
	//linha 2
	lcd_adress(0XC5);
	lcd_data(0xB0);					//-
	lcd_adress(0XC6);
	lcd_data(0xB0);					//-
	lcd_adress(0XC7);
	lcd_data(0x2E);					//.
	lcd_adress(0XC8);
	lcd_data(0xB0);					//-
	lcd_adress(0XC9);
	lcd_data(0xB0);					//-
	lcd_adress(0XCA);
	lcd_data(0x2E);					//.
	lcd_adress(0XCB);
	lcd_data(0xB0);					//-
	lcd_adress(0XCC);
	lcd_data(0xB0);					//-
	lcd_adress(0XCD);
	lcd_data(0x2E);					//.
	lcd_adress(0XCE);
	lcd_data(0xB0);					//-
	lcd_adress(0XCF);
	lcd_data(0xB0);					//-
*/

int main(void){
	
	DDRB = 0xff;
	DDRC = 0xff;
	PORTB = 0xF0;
	PORTC = 0xAF;
	
	lcd_init();								//Init LCD
	lcd_off_cursor();
	lcd_on_cursor();
	lcd_default();
	int i = 0;
	while(1){
		i++;
		lcd_mod(i);
		delay_2();
		delay_2();
		if(i == 4){
			i=0;
		}
	}
		
    
}