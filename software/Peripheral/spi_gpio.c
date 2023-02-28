#include "spi_gpio.h"

void SPI_GPIO_Init(void){
	GPIO_InitTypeDef GPIO_InitStructure;			//����ṹ�����͵ı���
	
	
	GPIO_InitStructure.GPIO_Pin  = CS_Pin|CLK_Pin|MOSI_Pin;	
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;					//�������
	GPIO_Init(SPI_Port,&GPIO_InitStructure);
	
	GPIO_InitStructure.GPIO_Pin  = MISO_Pin;	
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;					 
	GPIO_Init(SPI_Port,&GPIO_InitStructure);
	
	GPIO_SetBits(SPI_Port,CS_Pin);	//CS����
	GPIO_ResetBits(SPI_Port,CLK_Pin);//CLK����
	//GPIO_ResetBits(SPI_Port,MISO_Pin);	
}

/*
*********************************************************************************************************
*	�� �� ��: SPI_WRByte
*	��    ��: spi; wdat:д�������
*	�� �� ֵ: spi��һ���ֽ�
*	����˵��: ����spiͬʱ��дһ���ֽڵ�ʱ��		MSB
*********************************************************************************************************
*/
uint8_t Master_SPI_WR_Byte(uint8_t wdat)
{
	uint8_t i=0,rdat=0;
	SPI_CS_LOW;
	for(i=0;i<8;i++)
	{
		if(wdat&0x80)
			SPI_MOSI_HIGH;
		else
			SPI_MOSI_LOW;
		wdat<<=1;
		delay_us(3);	
				
		SPI_CLK_HIGH;
				
		delay_us(2);
		rdat<<=1;
//		if(SPI_MISO_READ)
//			rdat |= 0x01;
		delay_us(1);
		
		SPI_CLK_LOW;
		
	}
	SPI_CS_HIGH;
	return rdat;	
}

/**
  * @brief :SPI�շ��ַ���
  * @param :
  *			@ReadBuffer: �������ݻ�������ַ
  *			@WriteBuffer:�����ֽڻ�������ַ
  *			@Length:�ֽڳ���
  * @note  :�Ƕ���ʽ��һ���ȴ���ʱ���������Զ��˳�
  * @retval:��
  */
void Master_SPI_WR_String( uint8_t* ReadBuffer, uint8_t* WriteBuffer, uint16_t Length )
{
	SPI_CS_LOW;			//Ƭѡ����
	
	while( Length-- )
	{
		*ReadBuffer = Master_SPI_WR_Byte( *WriteBuffer );		//�շ�����
		ReadBuffer++;
		WriteBuffer++;			//��д��ַ��1
	}
	
	SPI_CS_HIGH;		//Ƭѡ����
}