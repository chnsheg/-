#include "CortexM3.h"
#include "CortexM3_driver.h"
void NMIHandler(void) {
    ;
}

void HardFaultHandler(void) {
    ;
}

void MemManageHandler(void) {
    ;
}

void BusFaultHandler(void) {
    ;
}

void UsageFaultHandler(void) {
    ;
}

void SVCHandler(void) {
    ;
}

void DebugMonHandler(void) {
    ;
}

void PendSVHandler(void) {
    ;
}

void SysTickHandler(void) {
    Set_SysTick_CTRL(0);
    SCB->ICSR = SCB->ICSR | (1 << 25);
}


void UARTRXHandler(void) {
//		uart_ClearTxIRQ(UART);
//    send2LED(0x0001);
//		Delay(1000);
	int data;
    data = uart_ReceiveChar(UART);
	send2LED(data);
	uart_SendString("M3:");
    uart_SendChar(UART,data);
    uart_SendChar(UART,'\n');
}	

void UARTTXHandler(void) {
    ;
}

void UARTOVRHandler(void) {
    ;
}

void KEYHandler(void) {
     send2LED(0x0001);
}
