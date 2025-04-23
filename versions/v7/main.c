#include "sys_timer.h"
#include "seg.h"

// 定时器实例
SysTimer_TypeDef *sys_timer = SYS_TIMER;

// 定时器配置
SysTimer_InitTypeDef timer_config = {
    .period = 50000000,   // 1秒周期（50MHz时钟）
    .auto_reload = 1      // 自动重载
};

int main(void) {
    // 初始化数码管
    SEG_InitTypeDef seg_init = {.scanEnable = 1};
    SEG_Init(&seg_init);
    
    // 初始化系统定时器
    SysTimer_Init(sys_timer, &timer_config);
    SysTimer_Start(sys_timer);
    
    SEG_WriteData(5, SEG_NUM_F, SEG_DOT_DISABLE);
    SEG_WriteData(4, SEG_NUM_E, SEG_DOT_DISABLE);
    uint32_t counter = 0;
    while(1) {
        
        if(SysTimer_CheckOverflow(sys_timer)) {
            SysTimer_ClearFlag(sys_timer);
            
            // 更新数码管显示
            SEG_WriteData(0, (counter % 10), SEG_DOT_DISABLE);
            SEG_WriteData(1, (counter / 10) % 10, SEG_DOT_DISABLE);
            SEG_WriteData(2, (counter / 100) % 10, SEG_DOT_ENABLE);
            
            counter++;
            if(counter >= 999) counter = 0;
        }
    }
    
    return 0;
}