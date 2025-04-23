#ifndef __SEG_H
#define __SEG_H

#include <stdint.h>
#include <stdbool.h>

// 数码管寄存器结构体定义（内存映射）
typedef struct {
    volatile uint8_t DATA[6];  // 段数据寄存器 (偏移 0x00~0x05)
    volatile uint8_t CTRL;     // 控制寄存器   (偏移 0x06)
} SEG_TypeDef;

// 数码管基地址
#define SEG_BASE          0x10030100
#define SEG               ((SEG_TypeDef *)SEG_BASE)

// 数码管显示数字定义（共阳）
typedef enum {
    SEG_NUM_0 = 0x0,
    SEG_NUM_1 = 0x1,
    SEG_NUM_2 = 0x2,
    SEG_NUM_3 = 0x3,
    SEG_NUM_4 = 0x4,
    SEG_NUM_5 = 0x5,
    SEG_NUM_6 = 0x6,
    SEG_NUM_7 = 0x7,
    SEG_NUM_8 = 0x8,
    SEG_NUM_9 = 0x9,
    SEG_NUM_A = 0xA,
    SEG_NUM_B = 0xB,
    SEG_NUM_C = 0xC,
    SEG_NUM_D = 0xD,
    SEG_NUM_E = 0xE,
    SEG_NUM_F = 0xF
} SEG_NumTypeDef;

// 小数点控制
#define SEG_DOT_DISABLE   0
#define SEG_DOT_ENABLE    1

// 初始化配置结构体
typedef struct {
    bool scanEnable;      // 扫描使能
} SEG_InitTypeDef;

/* 函数原型 */
void SEG_Init(SEG_InitTypeDef *initStruct);
void SEG_WriteData(uint8_t segIndex, SEG_NumTypeDef num, uint8_t dotEnable);
void SEG_ClearAll(void);
void SEG_Enable(bool enable);

#endif // __SEG_H