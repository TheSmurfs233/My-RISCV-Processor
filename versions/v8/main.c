//通过main.dump得到的c语言代码，未验证是否与汇编对应
#include <stdint.h>

// 定义GPIO寄存器地址
#define GPIO_CTRL  ((volatile uint32_t *)0x10030000)
#define GPIO_DATA  ((volatile uint32_t *)(0x10030000 + 0x04))

void main() {
    // 配置GPIO控制寄存器
    *GPIO_CTRL = 0x06;  // GPIO0输入模式，GPIO1输出模式
    
    // 初始化延时计数器
    volatile uint32_t delay_counter;
    
    while(1) {
        // 读取GPIO数据寄存器
        uint32_t gpio_val = (*GPIO_DATA) & 0x01;
        
        // 判断按键状态（假设GPIO0连接按键）
        if (gpio_val) {   // 按键未按下（假设高电平表示未按下）
            // 关闭LED（GPIO1输出0）
            // *GPIO_DATA =  0x00;
            *GPIO_DATA = (*GPIO_DATA & 0xFFFD);
        } else {                // 按键按下
            // 点亮LED（GPIO1输出1）
            // *GPIO_DATA =  0x02;
            *GPIO_DATA = (*GPIO_DATA | 0x02);
        }
        // *GPIO_DATA =  0x02;
        // 简单延时
        delay_counter = 100000;
        while(delay_counter--);
    }
}