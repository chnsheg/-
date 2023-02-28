#include "CortexM3.h"
#include "CortexM3_driver.h"
#include "spi_gpio.h"

// 1 led亮 0 led灭
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

void LED_Init(void)
{
 GPIO_InitTypeDef  GPIO_InitStructure;
	
 GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3;				
 GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT; 		 

 GPIO_Init(GPIOA, &GPIO_InitStructure);					
 GPIO_ResetBits(GPIOA,GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3);						 
	
//验证输入函数
 GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;
 GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4;
 GPIO_Init(GPIOA, &GPIO_InitStructure);
	//GPIO_SetBits(GPIOA,GPIO_Pin_4);
 //GPIOA->DATA &= ~((uint32_t)GPIOA);
}

void my_delay(uint32_t time){
	time*=5000;
	while(time--){
	}
}

int main(){
	//SysTick_Config(SystemCoreClock / 1000);//1ms
	char *a = "ARM-CM3";
	uint8_t ReadBuffer[20];
	SystemInit();
	
	//LED_Init();
	SPI_GPIO_Init();
	
	//GPIO_SetBits(GPIOA, GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3);
	
	while(1) 
	{		
		
//			GPIO_ResetBits(GPIOA,GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3);
//			delay_1ms(2000);
//			GPIO_SetBits(GPIOA,GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3);
//			delay_1ms(2000);
//		if(!GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_4)){
//			delay_1ms(20);
//			if(!GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_4)){
//				GPIO_WriteBit(GPIOA,GPIO_Pin_0,~(GPIO_ReadOutputDataBit(GPIOA,GPIO_Pin_0)));
//				while(!GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_4));
//			}
//		}
		Master_SPI_WR_String(ReadBuffer,(uint8_t*)a,7);
		delay_1ms(100);
	}
}

