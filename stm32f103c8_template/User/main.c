#include "stm32f10x.h"

// ??? LED(???? PA5)
void LED_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStructure;
    // 1. ?? GPIOA ??
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

    // 2. ?? PA5 ?????
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_5;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);
    
    // 3. ??????(??LED??????,?????)
    GPIO_SetBits(GPIOA, GPIO_Pin_5); 
}

// ???????(???? PA0)
void KEY_EXTI_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStructure;
    EXTI_InitTypeDef EXTI_InitStructure;
    NVIC_InitTypeDef NVIC_InitStructure;

    // 1. ?? GPIOA ? AFIO ??(???????AFIO!)
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_AFIO, ENABLE);

    // 2. ?? PA0 ???(?????????GND,???PA0,???????)
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU; // ????
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    // 3. ? PA0 ????? EXTI ??? 0
    GPIO_EXTILineConfig(GPIO_PortSourceGPIOA, GPIO_PinSource0);

    // 4. ?? EXTI ????
    EXTI_InitStructure.EXTI_Line = EXTI_Line0;           // ?????0
    EXTI_InitStructure.EXTI_Mode = EXTI_Mode_Interrupt;  // ??????
    EXTI_InitStructure.EXTI_Trigger = EXTI_Trigger_Falling; // ?????(??????)
    EXTI_InitStructure.EXTI_LineCmd = ENABLE;            // ????
    EXTI_Init(&EXTI_InitStructure);

    // 5. ?? NVIC(?????)
    NVIC_InitStructure.NVIC_IRQChannel = EXTI0_IRQn;     // ????0
    NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1; // ?????
    NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;        // ????
    NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;      // ??????
    NVIC_Init(&NVIC_InitStructure);
}

int main(void)
{
    // ?????
    LED_Init();
    KEY_EXTI_Init();

    while (1)
    {
        // ???:?????????!
        // ?????????????,?????
    }
}