#include "CortexM3.h"
#include "CortexM3_driver.h"
// 1 led¡¡ 0 led√
volatile uint32_t SystemTicks=0;
extern uint32_t SystemCoreClock;
void SystemInit (void);

void SysTick_Handler(void){
	SystemTicks++;
}

void Delay(uint32_t time_ms){
	uint32_t now = SystemTicks;
	while((SystemTicks - now ) < time_ms);
}


int main(){
	//SysTick_Config(SystemCoreClock / 1000);//1ms
	SystemInit();
	send2LED(8);
	char *a="hello\n";
	uart_SendString(a);

	while(1) 
	{
//			if(APB_KEY->KEYState){
//				send2LED(1);
//			}
//		//Delay(1000);
//		send2LED(0x0002);
//		Delay(1000);	
//		send2LED(0x0004);		
//		Delay(1000);	
//		send2LED(0x0008);
//		Delay(1000);		
	}
}

