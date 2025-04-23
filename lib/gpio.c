#include "misc.h"
#include "gpio.h"


/********************* 函数实现 **********************/

/**
  * @brief  GPIO初始化函数
  * @param  GPIOx: GPIO端口（当前仅支持GPIO）
  * @param  GPIO_InitStruct: 初始化参数结构体指针
  */
void GPIO_Init(GPIO_TypeDef* GPIOx, GPIO_InitTypeDef* GPIO_InitStruct)
{
    // GPIOx->CTRL = 0x06;
    uint32_t pinpos;
    // 遍历所有可能的引脚（0-15）
    for (pinpos = 0; pinpos < 16; pinpos++) {
        // 检查当前引脚是否需要配置
        
        if ((GPIO_InitStruct->GPIO_Pin & (1 << pinpos)) != 0) {
            // 计算控制寄存器位偏移（每个引脚占2bit）
            uint32_t pos = pinpos * 2;

            // 清空原有模式（掩码：0b11）
            GPIOx->CTRL &= ~(0x03 << pos);
            
            // 设置新模式
            GPIOx->CTRL |= (GPIO_InitStruct->GPIO_Mode << pos);
        }
    }
}

/**
   * @brief  设置指定引脚为高电平（仅对输出模式有效）
   * @param  GPIOx: GPIO端口
   * @param  Pin: 要设置的引脚（GPIO_Pin_x的或组合）
   */
void GPIO_SetBits(GPIO_TypeDef* GPIOx, uint32_t Pin)
 {
     GPIOx->DATA |= Pin;
 }

/**
   * @brief  设置指定引脚为低电平（仅对输出模式有效）
   * @param  GPIOx: GPIO端口
   * @param  Pin: 要清除的引脚（GPIO_Pin_x的或组合）
   */
void GPIO_ResetBits(GPIO_TypeDef* GPIOx, uint32_t Pin)
 {
     GPIOx->DATA &= ~Pin;
 }

/**
  * @brief  读取指定输入引脚状态
  * @param  GPIOx: GPIO端口
  * @param  Pin: 要读取的引脚（只能单选）
  * @retval 引脚状态：0（低电平）或1（高电平）
  */
uint32_t GPIO_ReadInputDataBit(GPIO_TypeDef* GPIOx, uint32_t Pin)
{
    return (GPIOx->DATA & Pin) ? 1 : 0;
}

/**
  * @brief  简单延时函数
  * @param  nCount: 延时计数器值
  */

void Delay(uint32_t nCount) {
    // 实现延时逻辑，例如：
    while(nCount--) {
        __asm__ volatile ("nop"); // 空操作指令
    }
}
