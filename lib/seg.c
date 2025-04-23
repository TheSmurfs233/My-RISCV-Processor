#include "seg.h"

/**​
  * @brief  初始化数码管控制器
  * @param  initStruct: 初始化配置结构体指针
  */
void SEG_Init(SEG_InitTypeDef *initStruct) {
    // 关闭数码管显示
    SEG->CTRL = 0x00;
    
    // 清空所有段数据
    SEG_ClearAll();
    
    // 配置扫描使能
    if (initStruct->scanEnable) {
        SEG->CTRL |= 0x01;
    }
}

/**​
  * @brief  向指定数码管写入数据
  * @param  segIndex: 数码管索引 (0~5)
  * @param  num: 显示的数字 (SEG_NUM_0~SEG_NUM_F)
  * @param  dotEnable: 小数点使能 (SEG_DOT_ENABLE/SEG_DOT_DISABLE)
  */
void SEG_WriteData(uint8_t segIndex, SEG_NumTypeDef num, uint8_t dotEnable) {
    if (segIndex > 5) return;  // 索引范围检查
    
    uint8_t regValue = (dotEnable << 7) | (num & 0x0F);
    SEG->DATA[segIndex] = regValue;
}

/**​
  * @brief  清空所有数码管显示
  */
void SEG_ClearAll(void) {
    for (uint8_t i = 0; i < 6; i++) {
        SEG->DATA[i] = 0x00;
    }
}

/**
  * @brief  使能/禁用数码管显示
  * @param  enable: 使能控制 (true/false)
  */
void SEG_Enable(bool enable) {
    if (enable) {
        SEG->CTRL |= 0x01;   // 使能扫描
    } else {
        SEG->CTRL &= ~0x01;  // 关闭扫描
    }
}
