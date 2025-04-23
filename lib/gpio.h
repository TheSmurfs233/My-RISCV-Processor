#ifndef __GPIO_H
#define __GPIO_H

#include "misc.h"

/* 寄存器结构体定义 -----------------------------------------------------------*/
typedef struct {
    volatile uint32_t CTRL;   // 控制寄存器 @0x10030000
    volatile uint32_t DATA;   // 数据寄存器 @0x10030004
} GPIO_TypeDef;

/* 外设地址映射 --------------------------------------------------------------*/
#define GPIO_BASE        ((volatile uint32_t)0x10030000)
#define GPIO            ((GPIO_TypeDef *)GPIO_BASE)

/* 模式枚举定义 --------------------------------------------------------------*/
typedef enum {
    GPIO_Mode_HIZ  = 0x0,   // 高阻模式（默认）
    GPIO_Mode_OUT  = 0x1,   // 输出模式
    GPIO_Mode_IN   = 0x2    // 输入模式
} GPIOMode_TypeDef;

/* 引脚定义宏 ----------------------------------------------------------------*/
#define GPIO_Pin_0      ((uint32_t)0x00000001)  // 引脚0
#define GPIO_Pin_1      ((uint32_t)0x00000002)  // 引脚1
// #define GPIO_Pin_2      0x0004  // 引脚2
// // ... 可扩展至更多引脚
// #define GPIO_Pin_15     0x8000  // 引脚15

/* 初始化结构体 --------------------------------------------------------------*/
typedef struct {
    uint32_t GPIO_Pin;            // 要配置的引脚（GPIO_Pin_x的或组合）
    GPIOMode_TypeDef GPIO_Mode;   // 工作模式（输入/输出/高阻）
    // 可扩展添加速度等参数
} GPIO_InitTypeDef;

/* 函数原型声明 ---------------------------------------------------------------*/
void GPIO_Init(GPIO_TypeDef* GPIOx, GPIO_InitTypeDef* GPIO_InitStruct);
void GPIO_SetBits(GPIO_TypeDef* GPIOx, uint32_t Pin);
void GPIO_ResetBits(GPIO_TypeDef* GPIOx, uint32_t Pin);
uint32_t GPIO_ReadInputDataBit(GPIO_TypeDef* GPIOx, uint32_t Pin);

void Delay(uint32_t nCount);

#endif /* __GPIO_H */