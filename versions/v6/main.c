#include <stdint.h>

// 数码管外设寄存器地址定义
#define SEG_BASE_ADDR  0x10030100

// 段数据寄存器偏移量（每个数码管1字节）
#define SEG_DATA0      (*((volatile uint8_t*)(SEG_BASE_ADDR + 0x00)))
#define SEG_DATA1      (*((volatile uint8_t*)(SEG_BASE_ADDR + 0x01)))
#define SEG_DATA2      (*((volatile uint8_t*)(SEG_BASE_ADDR + 0x02)))
#define SEG_DATA3      (*((volatile uint8_t*)(SEG_BASE_ADDR + 0x03)))
#define SEG_DATA4      (*((volatile uint8_t*)(SEG_BASE_ADDR + 0x04)))
#define SEG_DATA5      (*((volatile uint8_t*)(SEG_BASE_ADDR + 0x05)))

// 控制寄存器（1字节）
#define SEG_CTRL       (*((volatile uint8_t*)(SEG_BASE_ADDR + 0x06)))

// 数码管显示数字定义（共阳数码管）
typedef enum {
    SEG_0 = 0x0,    // 显示0
    SEG_1 = 0x1,    // 显示1
    SEG_2 = 0x2,    // 显示2
    SEG_3 = 0x3,    // 显示3
    SEG_4 = 0x4,    // 显示4
    SEG_5 = 0x5,    // 显示5
    SEG_6 = 0x6,    // 显示6
    SEG_7 = 0x7,    // 显示7
    SEG_8 = 0x8,    // 显示8
    SEG_9 = 0x9,    // 显示9
    SEG_A = 0xA,    // 显示A
    SEG_B = 0xB,    // 显示B
    SEG_C = 0xC,    // 显示C
    SEG_D = 0xD,    // 显示D
    SEG_E = 0xE,    // 显示E
    SEG_F = 0xF     // 显示F
} SegNumber;

// 设置单个数码管显示内容
void seg_set_data(uint8_t seg_index, SegNumber num, uint8_t dot_enable) {
    uint8_t reg_value = (dot_enable << 7) | (num & 0x0F);
    switch(seg_index) {
        case 0: SEG_DATA0 = reg_value;break;
        case 1: SEG_DATA1 = reg_value;break;
        case 2: SEG_DATA2 = reg_value;break;
        case 3: SEG_DATA3 = reg_value;break;
        case 4: SEG_DATA4 = reg_value;break;
        case 5: SEG_DATA5 = reg_value;break;
        default: break;
    }
}

// 初始化数码管控制器
void seg_init(void) {
    // 关闭所有数码管显示
    SEG_CTRL = 0x00;
    
    // 清空所有段数据
    SEG_DATA0 = 0x00;
    SEG_DATA1 = 0x00;
    SEG_DATA2 = 0x00;
    SEG_DATA3 = 0x00;
    SEG_DATA4 = 0x00;
    SEG_DATA5 = 0x00;
    
    // 使能扫描
    SEG_CTRL = 0x01;
}

// 示例：显示"123.456"
void demo_show_number(void) {

    seg_set_data(0, SEG_1, 0);  // 第0位显示1，无小数点
    seg_set_data(1, SEG_2, 0);  // 第1位显示2
    seg_set_data(2, SEG_3, 1);  // 第2位显示3，带小数点
    seg_set_data(3, SEG_4, 0);  // 第3位显示4
    seg_set_data(4, SEG_5, 0);  // 第4位显示5
    seg_set_data(5, SEG_6, 0);  // 第5位显示6
}

int main(void) {

    // 初始化数码管外设
    seg_init();
    
    // 显示示例内容
    demo_show_number();
    
    // 保持显示
    while(1);
    
    return 0;
}
