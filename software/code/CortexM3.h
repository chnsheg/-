
#ifndef CORTEXM3_H
#define CORTEXM3_H
 
#include <stdint.h>
#include <stdio.h>

#if defined ( __CC_ARM   )
#pragma anon_unions
#endif

/*
 * ==========================================================================
 * ---------- Interrupt Number Definition -----------------------------------
 * ==========================================================================
 */

typedef enum IRQn
{
/******  Cortex-M3 Processor Exceptions Numbers ***************************************************/
  NonMaskableInt_IRQn           = -14,    /*!<  2 Cortex-M3 Non Maskable Interrupt                        */
  HardFault_IRQn                = -13,    /*!<  3 Cortex-M3 Hard Fault Interrupt                          */
  MemoryManagement_IRQn         = -12,    /*!<  4 Cortex-M3 Memory Management Interrupt            */
  BusFault_IRQn                 = -11,    /*!<  5 Cortex-M3 Bus Fault Interrupt                    */
  UsageFault_IRQn               = -10,    /*!<  6 Cortex-M3 Usage Fault Interrupt                  */
  SVCall_IRQn                   = -5,     /*!< 11 Cortex-M3 SV Call Interrupt                      */
  DebugMonitor_IRQn             = -4,     /*!< 12 Cortex-M3 Debug Monitor Interrupt                */
  PendSV_IRQn                   = -2,     /*!< 14 Cortex-M3 Pend SV Interrupt                      */
  SysTick_IRQn                  = -1,     /*!< 15 Cortex-M3 System Tick Interrupt                  */

/******  CM3DS_MPS2 Specific Interrupt Numbers *******************************************************/
  UARTTX_IRQn                   = 0,       /* UART 0 RX and TX Combined Interrupt   */
  UARTRX_IRQn                   = 1,       /* Undefined                             */
  UARTOVR_IRQn                  = 2,       /* UART 1 RX and TX Combined Interrupt   */
	KEY_IRQn                      = 3,       /* KEY Interrupt                         */
} IRQn_Type;

/*
 * ==========================================================================
 * ----------- Processor and Core Peripheral Section ------------------------
 * ==========================================================================
 */

/* Configuration of the Cortex-M3 Processor and Core Peripherals */
#define __CM3_REV                 0x0201    /*!< Core Revision r2p1                             */
#define __NVIC_PRIO_BITS          3         /*!< Number of Bits used for Priority Levels        */
#define __Vendor_SysTickConfig    0         /*!< Set to 1 if different SysTick Config is used   */
#define __MPU_PRESENT             1         /*!< MPU present or not                             */

#include "core_cm3.h"

/*------------- Universal Asynchronous Receiver Transmitter (UART) -----------*/
typedef struct
{
  __IO   uint32_t  DATA;          /*!< Offset: 0x000 Data Register    (R/W) */
  __IO   uint32_t  STATE;         /*!< Offset: 0x004 Status Register  (R/W) */
  __IO   uint32_t  CTRL;          /*!< Offset: 0x008 Control Register (R/W) */
  union {
    __I    uint32_t  INTSTATUS;   /*!< Offset: 0x00C Interrupt Status Register (R/ ) */
    __O    uint32_t  INTCLEAR;    /*!< Offset: 0x00C Interrupt Clear Register ( /W) */
    };
  __IO   uint32_t  BAUDDIV;       /*!< Offset: 0x010 Baudrate Divider Register (R/W) */

}  UART_TypeDef;

/*  UART DATA Register Definitions */

#define  UART_DATA_Pos               0                                            /*!<  UART_DATA_Pos: DATA Position */
#define  UART_DATA_Msk              (0xFFul <<  UART_DATA_Pos)               /*!<  UART DATA: DATA Mask */

#define  UART_STATE_RXOR_Pos         3                                            /*!<  UART STATE: RXOR Position */
#define  UART_STATE_RXOR_Msk         (0x1ul <<  UART_STATE_RXOR_Pos)         /*!<  UART STATE: RXOR Mask */

#define  UART_STATE_TXOR_Pos         2                                            /*!<  UART STATE: TXOR Position */
#define  UART_STATE_TXOR_Msk         (0x1ul <<  UART_STATE_TXOR_Pos)         /*!<  UART STATE: TXOR Mask */

#define  UART_STATE_RXBF_Pos         1                                            /*!<  UART STATE: RXBF Position */
#define  UART_STATE_RXBF_Msk         (0x1ul <<  UART_STATE_RXBF_Pos)         /*!<  UART STATE: RXBF Mask */

#define  UART_STATE_TXBF_Pos         0                                            /*!<  UART STATE: TXBF Position */
#define  UART_STATE_TXBF_Msk         (0x1ul <<  UART_STATE_TXBF_Pos )        /*!<  UART STATE: TXBF Mask */

#define  UART_CTRL_HSTM_Pos          6                                            /*!<  UART CTRL: HSTM Position */
#define  UART_CTRL_HSTM_Msk          (0x01ul <<  UART_CTRL_HSTM_Pos)         /*!<  UART CTRL: HSTM Mask */

#define  UART_CTRL_RXORIRQEN_Pos     5                                            /*!<  UART CTRL: RXORIRQEN Position */
#define  UART_CTRL_RXORIRQEN_Msk     (0x01ul <<  UART_CTRL_RXORIRQEN_Pos)    /*!<  UART CTRL: RXORIRQEN Mask */

#define  UART_CTRL_TXORIRQEN_Pos     4                                            /*!<  UART CTRL: TXORIRQEN Position */
#define  UART_CTRL_TXORIRQEN_Msk     (0x01ul <<  UART_CTRL_TXORIRQEN_Pos)    /*!<  UART CTRL: TXORIRQEN Mask */

#define  UART_CTRL_RXIRQEN_Pos       3                                            /*!<  UART CTRL: RXIRQEN Position */
#define  UART_CTRL_RXIRQEN_Msk       (0x01ul <<  UART_CTRL_RXIRQEN_Pos)      /*!<  UART CTRL: RXIRQEN Mask */

#define  UART_CTRL_TXIRQEN_Pos       2                                            /*!<  UART CTRL: TXIRQEN Position */
#define  UART_CTRL_TXIRQEN_Msk       (0x01ul <<  UART_CTRL_TXIRQEN_Pos)      /*!<  UART CTRL: TXIRQEN Mask */

#define  UART_CTRL_RXEN_Pos          1                                            /*!<  UART CTRL: RXEN Position */
#define  UART_CTRL_RXEN_Msk          (0x01ul <<  UART_CTRL_RXEN_Pos)         /*!<  UART CTRL: RXEN Mask */

#define  UART_CTRL_TXEN_Pos          0                                            /*!<  UART CTRL: TXEN Position */
#define  UART_CTRL_TXEN_Msk          (0x01ul <<  UART_CTRL_TXEN_Pos)         /*!<  UART CTRL: TXEN Mask */

#define  UART_INTSTATUS_RXORIRQ_Pos  3                                            /*!<  UART CTRL: RXORIRQ Position */
#define  UART_CTRL_RXORIRQ_Msk       (0x01ul <<  UART_INTSTATUS_RXORIRQ_Pos) /*!<  UART CTRL: RXORIRQ Mask */

#define  UART_CTRL_TXORIRQ_Pos       2                                            /*!<  UART CTRL: TXORIRQ Position */
#define  UART_CTRL_TXORIRQ_Msk       (0x01ul <<  UART_CTRL_TXORIRQ_Pos)      /*!<  UART CTRL: TXORIRQ Mask */

#define  UART_CTRL_RXIRQ_Pos         1                                            /*!<  UART CTRL: RXIRQ Position */
#define  UART_CTRL_RXIRQ_Msk         (0x01ul <<  UART_CTRL_RXIRQ_Pos)        /*!<  UART CTRL: RXIRQ Mask */

#define  UART_CTRL_TXIRQ_Pos         0                                            /*!<  UART CTRL: TXIRQ Position */
#define  UART_CTRL_TXIRQ_Msk         (0x01ul <<  UART_CTRL_TXIRQ_Pos)        /*!<  UART CTRL: TXIRQ Mask */

#define  UART_BAUDDIV_Pos            0                                            /*!<  UART BAUDDIV: BAUDDIV Position */
#define  UART_BAUDDIV_Msk            (0xFFFFFul <<  UART_BAUDDIV_Pos)        /*!<  UART BAUDDIV: BAUDDIV Mask */


/**************************************GPIO*******************************************/

/** @defgroup GPIO_pins_define 
  * @{
  */

#define GPIO_Pin_0                 ((uint16_t)0x0001)  /*!< Pin 0 selected */
#define GPIO_Pin_1                 ((uint16_t)0x0002)  /*!< Pin 1 selected */
#define GPIO_Pin_2                 ((uint16_t)0x0004)  /*!< Pin 2 selected */
#define GPIO_Pin_3                 ((uint16_t)0x0008)  /*!< Pin 3 selected */
#define GPIO_Pin_4                 ((uint16_t)0x0010)  /*!< Pin 4 selected */
#define GPIO_Pin_5                 ((uint16_t)0x0020)  /*!< Pin 5 selected */
#define GPIO_Pin_6                 ((uint16_t)0x0040)  /*!< Pin 6 selected */
#define GPIO_Pin_7                 ((uint16_t)0x0080)  /*!< Pin 7 selected */
#define GPIO_Pin_8                 ((uint16_t)0x0100)  /*!< Pin 8 selected */
#define GPIO_Pin_9                 ((uint16_t)0x0200)  /*!< Pin 9 selected */
#define GPIO_Pin_10                ((uint16_t)0x0400)  /*!< Pin 10 selected */
#define GPIO_Pin_11                ((uint16_t)0x0800)  /*!< Pin 11 selected */
#define GPIO_Pin_12                ((uint16_t)0x1000)  /*!< Pin 12 selected */
#define GPIO_Pin_13                ((uint16_t)0x2000)  /*!< Pin 13 selected */
#define GPIO_Pin_14                ((uint16_t)0x4000)  /*!< Pin 14 selected */
#define GPIO_Pin_15                ((uint16_t)0x8000)  /*!< Pin 15 selected */
#define GPIO_Pin_All               ((uint16_t)0xFFFF)  /*!< All pins selected */


typedef struct
{
  __IO   uint32_t  DATA;                     /* Offset: 0x000 (R/W) DATA Register */
  __IO   uint32_t  DATAOUT;                  /* Offset: 0x004 (R/W) Data Output Latch Register */
         uint32_t  RESERVED0[2];
  __IO   uint32_t  OUTENSET;             /* Offset: 0x010 (R/W) Output Enable Set Register */
  __IO   uint32_t  OUTENCLR;             /* Offset: 0x014 (R/W) Output Enable Clear Register */
  __IO   uint32_t  ALTFUNCSET;               /* Offset: 0x018 (R/W) Alternate Function Set Register */
  __IO   uint32_t  ALTFUNCCLR;               /* Offset: 0x01C (R/W) Alternate Function Clear Register */
  __IO   uint32_t  INTENSET;                 /* Offset: 0x020 (R/W) Interrupt Enable Set Register */
  __IO   uint32_t  INTENCLR;                 /* Offset: 0x024 (R/W) Interrupt Enable Clear Register */
  __IO   uint32_t  INTTYPESET;               /* Offset: 0x028 (R/W) Interrupt Type Set Register */
  __IO   uint32_t  INTTYPECLR;               /* Offset: 0x02C (R/W) Interrupt Type Clear Register */
  __IO   uint32_t  INTPOLSET;                /* Offset: 0x030 (R/W) Interrupt Polarity Set Register */
  __IO   uint32_t  INTPOLCLR;                /* Offset: 0x034 (R/W) Interrupt Polarity Clear Register */
  union {
    __I    uint32_t  INTSTATUS;              /* Offset: 0x038 (R/ ) Interrupt Status Register */
    __O    uint32_t  INTCLEAR;               /* Offset: 0x038 ( /W) Interrupt Clear Register */
    };
         uint32_t RESERVED1[241];
  __IO   uint32_t LB_MASKED[256];            /* Offset: 0x400 - 0x7FC Lower byte Masked Access Register (R/W) */
  __IO   uint32_t UB_MASKED[256];            /* Offset: 0x800 - 0xBFC Upper byte Masked Access Register (R/W) */
}  GPIO_TypeDef;

typedef enum
{ 
  GPIO_Mode_IN = 0x01,
  GPIO_Mode_OUT = 0x02,
  GPIO_Mode_AF = 0x04
}GPIOMode_TypeDef;

typedef enum
{ Bit_RESET = 0,
  Bit_SET
}BitAction;


typedef struct
{
  uint16_t GPIO_Pin;             /*!< Specifies the GPIO pins to be configured.
                                      This parameter can be any value of @ref GPIO_pins_define */

  GPIOMode_TypeDef GPIO_Mode;    /*!< Specifies the operating mode for the selected pins.
                                      This parameter can be a value of @ref GPIOMode_TypeDef */
}GPIO_InitTypeDef;

/**************************************LED*******************************************/
typedef struct
{
  volatile uint32_t LEDS;
} APB_LED_TypeDef;

///**************************************KEY*******************************************/
typedef struct 
{
  volatile uint32_t KEYState;
} APB_KEY_TypeDef;


///**************************************ACCELERATOR**************************************/
//typedef struct 
//{
//  volatile uint32_t threshold; //  二值化阈值
//	volatile uint32_t disp_type; //  显示类型
//} APB_ACC_TypeDef;

/**************************************GPIO模拟SPI*******************************************/


/******************************************************************************/
/*                         Peripheral memory map                              */
/******************************************************************************/
/* Peripheral and SRAM base address */
#define APB_BASE         (0x40000000UL)
#define AHB_BASE         (0x50000000UL)

#define GPIOA_BASE			 (AHB_BASE + 0x0000UL)

#define APB_UART_BASE    (APB_BASE)
#define APB_LED_BASE     (APB_BASE + 0x1000UL)
#define APB_KEY_BASE     (APB_BASE + 0x2000UL)
//#define APB_ACC_BASE     (APB_BASE + 0x3000UL)
/******************************************************************************/
/*                         Peripheral declaration                             */
/******************************************************************************/
#define UART             ((UART_TypeDef   *) APB_UART_BASE   )

#define GPIOA						 ((GPIO_TypeDef    *) GPIOA_BASE)

#define APB_LED          ((APB_LED_TypeDef 		*) APB_LED_BASE    )
#define APB_KEY          ((APB_KEY_TypeDef 		*) APB_KEY_BASE    )
//#define APB_ACC          ((APB_ACC_TypeDef *) APB_ACC_BASE    )

#endif


