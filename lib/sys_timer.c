/* sys_timer.c */
#include "sys_timer.h"

// 定时器初始化
// void SysTimer_Init(SysTimer_TypeDef *timer, SysTimer_InitTypeDef *init) {
//     // 计算实际周期 = (prescaler + 1) * period
//     // uint64_t actual_period = (init->prescaler + 1) * get_period64(init);
    
//     // 写入硬件寄存器（分两次32位写入）
//     timer->LOAD_L = (uint32_t)(init->period_low );
//     timer->LOAD_H = (uint32_t)(init->period_high);
    
//     // 设置自动重载
//     if(init->auto_reload) {
//         timer->CTRL |= SYS_TIMER_CTRL_AUTORELOAD;
//     }
//     // 触发初始重载
//     timer->VAL_L = 0;
// }
void SysTimer_Init(SysTimer_TypeDef *timer, SysTimer_InitTypeDef *init) {
    // 禁用定时器
    timer->CTRL = 0;
    
    // 设置重载值
    timer->LOAD_L = (uint32_t)(init->period & 0xFFFFFFFF);
    timer->LOAD_H = (uint32_t)(init->period >> 32);
    
    // 设置自动重载
    if(init->auto_reload) {
        timer->CTRL |= SYS_TIMER_CTRL_AUTORELOAD;
    }
    
    // 触发初始重载
    timer->VAL_L = 0;
}

// 启动定时器
void SysTimer_Start(SysTimer_TypeDef *timer) {
    timer->CTRL |= SYS_TIMER_CTRL_ENABLE;
}

// 停止定时器
void SysTimer_Stop(SysTimer_TypeDef *timer) {
    timer->CTRL &= ~SYS_TIMER_CTRL_ENABLE;
}

// 获取当前计数值
uint64_t SysTimer_GetCurrentValue(SysTimer_TypeDef *timer) {
    uint32_t high, low;
    do {
        high = timer->VAL_H;
        low = timer->VAL_L;
    } while (high != timer->VAL_H);
    return ((uint64_t)high << 32) | low;
}

// 检查溢出标志
uint8_t SysTimer_CheckOverflow(SysTimer_TypeDef *timer) {
    return (timer->CTRL & SYS_TIMER_CTRL_OVF_FLAG) ? 1 : 0;
}

// 清除溢出标志
void SysTimer_ClearFlag(SysTimer_TypeDef *timer) {
    volatile uint32_t temp = timer->CTRL;
    (void)temp; // 抑制编译器警告
}

// 延时函数（单位：ms）
void SysTimer_DelayMs(SysTimer_TypeDef *timer, uint32_t ms) {
    const uint64_t cycles = ms * 50000; // 假设系统时钟50MHz
    // const uint64_t cycles = 50000000; // 假设系统时钟50MHz
    SysTimer_InitTypeDef init = {
        .period = cycles,
        .auto_reload = 0
    };
    
    SysTimer_Init(timer, &init);
    SysTimer_Start(timer);
    
    while(!SysTimer_CheckOverflow(timer)) {
        // 等待溢出
    }
    
    SysTimer_Stop(timer);
}