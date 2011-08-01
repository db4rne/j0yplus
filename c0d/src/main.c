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
	DDRC = 0xFF; 	//Port C all outputs
	
	while(1) {
		PORTC = 0b00000000;
		wait(5);
		PORTC = 0x11;
		wait(5);
	}
	
	/* never reach this line */
	return 0;
}
