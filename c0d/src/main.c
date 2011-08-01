/* helloworldled.c
   my first own program */ 

#include <avr/io.h>

void wait(int mt){
	for(;mt>0;mt--){
		unsigned int t;
		for(t=65535; t>0; t--) {
			asm volatile("nop");
		}
	}
}


/* DDRC =  0    //Switchs
   DDRC =  0xFF //LEDs */

int main (void)
{	
	DDRB = 0xFF; 	//Port C all outputs
	
	while(1) {
		PORTB = 0b00000000;
		wait(5);
		PORTB = 0xC0;
		wait(5);
	}
	
	/* never reach this line */
	return 0;
}
