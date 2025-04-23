/* sys_timer.h */
#ifndef __SYS_TIMER_H
#define __SYS_TIMER_H

#include <stdint.h>

// 定时器基本地址
#define SYS_TIMER_BASE 0x10030200

// 定时器寄存器结构体
typedef struct {
    volatile uint32_t CTRL;    // 控制寄存器
    volatile uint32_t LOAD_L;  // 低32位重装值
    volatile uint32_t LOAD_H;  // 高32位重装值
    volatile uint32_t VAL_L;   // 低32位当前值
    volatile uint32_t VAL_H;   // 高32位当前值
} SysTimer_TypeDef;

// 定时器实例
#define SYS_TIMER ((SysTimer_TypeDef *)SYS_TIMER_BASE)

// 控制寄存器位定义
#define SYS_TIMER_CTRL_ENABLE    (0x00000001)  // 使能位
#define SYS_TIMER_CTRL_AUTORELOAD (0x00000002) // 自动重载位
#define SYS_TIMER_CTRL_OVF_FLAG  (0x00010000)  // 溢出标志位

// 定时器配置结构体
typedef struct {
    uint64_t prescaler;      // 预分频系数
    uint64_t period;         // 定时周期（计数值）
    uint8_t auto_reload;     // 自动重载使能
} SysTimer_InitTypeDef;
// typedef struct {
//     uint32_t prescaler;    // 预分频系数（0~N）
//     uint32_t period_low;   // 周期低32位
//     uint32_t period_high;  // 周期高32位
//     uint8_t auto_reload;   // 自动重载使能
//     uint8_t reserved[3];   // 对齐填充
// } SysTimer_InitTypeDef;

// 函数原型
void SysTimer_Init(SysTimer_TypeDef *timer, SysTimer_InitTypeDef *init);
void SysTimer_Start(SysTimer_TypeDef *timer);
void SysTimer_Stop(SysTimer_TypeDef *timer);
uint64_t SysTimer_GetCurrentValue(SysTimer_TypeDef *timer);
uint8_t SysTimer_CheckOverflow(SysTimer_TypeDef *timer);
void SysTimer_ClearFlag(SysTimer_TypeDef *timer);
void SysTimer_DelayMs(SysTimer_TypeDef *timer, uint32_t ms);

#endif /* __SYS_TIMER_H */