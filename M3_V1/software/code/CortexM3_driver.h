#ifndef CORTEXM3_DRIVER_H
#define CORTEXM3_DRIVER_H

#include "CortexM3.h"

/****************************UART*******************************/

extern uint32_t  uart_init( UART_TypeDef * uart, uint32_t divider, uint32_t tx_en,
                           uint32_t rx_en, uint32_t tx_irq_en, uint32_t rx_irq_en, uint32_t tx_ovrirq_en, uint32_t rx_ovrirq_en);

  /**
   * @brief Returns whether the UART RX Buffer is Full.
   */

 extern uint32_t  uart_GetRxBufferFull( UART_TypeDef * uart);

  /**
   * @brief Returns whether the UART TX Buffer is Full.
   */

 extern uint32_t  uart_GetTxBufferFull( UART_TypeDef * uart);

  /**
   * @brief Sends a character to the UART TX Buffer.
   */


 extern void  uart_SendChar( UART_TypeDef * uart, char txchar);

  /**
   * @brief Receives a character from the UART RX Buffer.
   */

 extern char  uart_ReceiveChar( UART_TypeDef * uart);

  /**
   * @brief Returns UART Overrun status.
   */

 extern uint32_t  uart_GetOverrunStatus( UART_TypeDef * uart);

  /**
   * @brief Clears UART Overrun status Returns new UART Overrun status.
   */

 extern uint32_t  uart_ClearOverrunStatus( UART_TypeDef * uart);

  /**
   * @brief Returns UART Baud rate Divider value.
   */

 extern uint32_t  uart_GetBaudDivider( UART_TypeDef * uart);

  /**
   * @brief Return UART TX Interrupt Status.
   */

 extern uint32_t  uart_GetTxIRQStatus( UART_TypeDef * uart);

  /**
   * @brief Return UART RX Interrupt Status.
   */

 extern uint32_t  uart_GetRxIRQStatus( UART_TypeDef * uart);

  /**
   * @brief Clear UART TX Interrupt request.
   */

 extern void  uart_ClearTxIRQ( UART_TypeDef * uart);

  /**
   * @brief Clear UART RX Interrupt request.
   */

 extern void  uart_ClearRxIRQ( UART_TypeDef * uart);

  /**
   * @brief Set CM3DS_MPS2 Timer for multi-shoot mode with internal clock
   */
 extern void  uart_SendString(char *string);
 /**************************************SYSTICK*******************************************/

extern void delay(uint32_t time);
extern void Set_SysTick_CTRL(uint32_t ctrl);
extern void Set_SysTick_LOAD(uint32_t load);
extern uint32_t Read_SysTick_VALUE(void);
extern void Set_SysTick_VALUE(uint32_t value);
extern void Set_SysTick_CALIB(uint32_t calib);
extern uint32_t Timer_Ini(void);
extern uint8_t Timer_Stop(uint32_t *duration_t,uint32_t start_t);

extern void delay_1ms(void);

 /**************************************LED*******************************************/
extern void send2LED( uint32_t cnt);

 /**************************************KEY*******************************************/
//#define KEY_DOWN  0x01 // 按键按下
//#define KEY_UP    0x00 // 按键抬起
//extern int getKEY();

/**************************************ACCELERATOR**************************************/
extern char disp_flag;
extern void change_threshold(uint32_t threshold);//修改二值化阈值 0-255
extern void disp_choice(uint32_t disp_type); // 修改显示图像 0->原始图像 1->灰度图 2->二值化图


#endif




