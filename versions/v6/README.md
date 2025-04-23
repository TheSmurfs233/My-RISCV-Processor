# v6版本主要做了以下修改

1.修复分支指令和jalr指令等部分指令的BUG。

2.扩展GPIO模块，使其支持16个引脚。

3.编写模块的库函数，之前的代码是直接操作寄存器的地址使用，改成库函数风格，定义结构体来表示外设的寄存器组。比如`GPIO_InitTypeDef`，里面包含引脚号、模式等参数。初始化函数GPIO_Init会接收这个结构体，并根据其中的参数配置相应的寄存器。例如，设置GPIO1为输出模式，需要将CTRL寄存器的某些位设置为特定值。

4.增加八段数码管外设



### 踩坑

1. 程序下载进去发现与预期现象不符，经测试分析，发现代码跳转到 地址0x400228，但是最后一个指令的地址也才0x400224，查阅资料才发现是因为c语言代码中使用了case语句，case语句会被编译成跳转表，而跳转表不在 `.text` 段，而指令 `riscv64-unknown-elf-objdump -d x.elf` 只会反汇编 `.text` 段的内容，需要使用指令 `riscv64-unknown-elf-objdump -s -d x.elf` 才能查看全部的反汇编内容，运行后可以发现如下段，就是跳转表的内容，

   ```
   Contents of section .rodata:
    400228 7c004000 90004000 a4004000 b8004000  |.@...@...@...@.
    400238 cc004000 e0004000                    ..@...@.        
   ```

   - **`objdump -d`** 默认只反汇编 `.text` 段（代码段）中的指令。
   - **跳转表位于 `.rodata` 段**（只读数据段），因此不会被 `-d` 参数反汇编为指令。
   - 需使用 **`-s`** 参数查看 `.rodata` 段的原始数据。

   跳转表的作用

   - 实现 `switch-case` 逻辑，根据数码管位置（0-5）跳转到对应的处理分支。
   - 每个表项存储分支入口地址，通过索引直接跳转，复杂度为 `O(1)`。

   示例

   1. **输入参数**：`a0 = 2`。
   2. **偏移量计算**：`2 × 4 = 8`。
   3. **跳转表项地址**：`0x400228 + 8 = 0x400230`。
   4. **读取目标地址**：`0x4000a4`。
   5. **跳转执行**：`jr 0x4000a4`，进入数码管位置 2 的处理逻辑。



# 后续计划



### 1.扩展外设（GPIO、UART、DDR3 RAM、数码管、定时器、PWM）

### 2.采用AXI+分层总线架构

```
+----------------+     +-----------------+     +---------------+
| RISC-V CPU     |     | AXI Interconnect|     | DDR3 Controller|
| (AXI Master)   |---->|                 |---->| (AXI Slave)    |
+----------------+     +-----------------+     +---------------+
                        |           |
                        |           |  AXI-to-Legacy Bridge
                        |           v
                        |     +-----------------+
                        |     | Legacy Devices  |
                        |     | (RAM/GPIO/Timer)|
                        |     +-----------------+
                        |
                        v（预留DMA接口）
                  +-----------------+
                  | Future AXI Master|
                  | (e.g., DMA)     |
                  +-----------------+
```

### 3.实现CSR寄存器和相关系统指令，支持中断系统

### 4.扩展指令集（M、F、D指令集），支持乘法除法取模求余单双精度浮点数指令

### 5.对SOC时序进行分析





# **数码管外设设计方案**

### 一、寄存器定义

外设基地址为 `0x1003_0100`，定义如下寄存器：

| 地址偏移（字节） | 寄存器名称 | 位域  |              功能描述              |
| :--------------: | :--------: | :---: | :--------------------------------: |
|       0x00       | SEG_DATA_0 | [7:0] |   数码管0显示数据（格式：D7~D0）   |
|       0x01       | SEG_DATA_1 | [7:0] |   数码管1显示数据（格式：D7~D0）   |
|       0x02       | SEG_DATA_2 | [7:0] |   数码管2显示数据（格式：D7~D0）   |
|       0x03       | SEG_DATA_3 | [7:0] |   数码管3显示数据（格式：D7~D0）   |
|       0x04       | SEG_DATA_4 | [7:0] |   数码管4显示数据（格式：D7~D0）   |
|       0x05       | SEG_DATA_5 | [7:0] |   数码管5显示数据（格式：D7~D0）   |
|       0x06       |  SEG_CTRL  | [7:0] | 控制寄存器（仅D0有效，其他位保留） |

**寄存器详细说明：**

1. **SEG_DATA_0 ~ SEG_DATA_5**
   - 位定义：
     - **D3-D0**：显示字符编码（0x0~0xF），对应数字0~9及字母A~F。
     - **D7**：小数点控制位，1=点亮小数点，0=关闭小数点。
     - **D6-D4**：保留位，默认置0。
   - **示例**：`0x87`表示显示数字7并点亮小数点。
2. **SEG_CTRL**
   - 位定义：
     - **D0**：扫描使能位，1=开启动态扫描，0=关闭所有数码管。
     - **D7-D1**：保留位，默认置0。

### 二、设计说明

##### 1. 功能概述

本模块实现6位共阳极数码管的动态扫描驱动，支持以下功能：

- **动态扫描**：以1kHz频率轮询显示，降低功耗并避免静态显示残影。
- **段码译码**：自动将4位二进制数（0x0~0xF）转换为7段数码管编码。
- **小数点控制**：支持独立控制每位数码管的小数点显示。
- **APB接口**：通过APB总线读写寄存器，实现显示内容更新与控制。

##### 2. 寄存器配置流程

1. **写入显示数据**：
   - 向`SEG_DATA_0~SEG_DATA_5`写入目标值（格式见寄存器定义）。
   - 示例：`SEG_DATA_0 = 8'h92`表示数码管0显示数字5，不点亮小数点。
2. **控制扫描使能**：
   - 向`SEG_CTRL`写入`0x01`开启动态扫描，写入`0x00`关闭所有显示。

##### 3. 动态扫描原理

- **扫描频率**：1kHz（每位数码管刷新频率≈167Hz）。
- **计数器分频**：基于50MHz系统时钟，每位数码管显示周期为`50_000_000 / (1000 * 6) = 8333`个时钟周期。
- **防残影设计**：在切换数码管前，短暂关闭所有位选信号（`seg_sel_n=6'b111111`）。

##### 4. 段码译码规则

- 译码表：内置16种字符编码（0~F），共阳极段码如下：

  ```verilog
  0-F(不带小数点) : 0xc0,0xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90,0x88,0x83,0xc6,0xa1,0x86,0x8e
  ```

- **小数点处理**：段码最高位（`seg_data[7]`）直接由寄存器`D7`控制，逻辑取反后与译码结果进行位与操作。

##### 5. 总线接口操作

- 写操作：
  - 当`psel=1`、`penable=1`且`pwrite=1`时，根据`paddr`写入对应寄存器。
- 读操作：
  - 当`psel=1`、`penable=1`且`pwrite=0`时，返回`paddr`对应寄存器的值（低8位有效）。

##### 6. 注意事项

1. 复位状态：
   - 默认开启扫描（`SEG_CTRL=0x01`），所有数码管显示字符0且关闭小数点。
2. 数据更新时机：
   - 建议在扫描使能状态下更新数据，以实时反映变化。
3. 硬件连接：
   - 位选信号（`seg_sel_n`）需外接PNP三极管驱动，低电平有效。
   - 段选信号（`seg_data`）直接连接共阳极数码管。

### 三、Verilog 模块代码

```
module seg_led (
    input  wire         clk,          // 系统时钟（如50MHz）
    input  wire         rst_n,        // 异步复位（低有效）
    
    // 寄存器读写接口（假设为APB总线）
    input  wire         psel,         // 外设选择
    input  wire         penable,      // 使能信号
    input  wire [3:0]   paddr,        // 字节地址
    input  wire         pwrite,       // 写使能
    input  wire [31:0]  pwdata,       // 写数据
    output reg  [31:0]  prdata,       // 读数据
    
    // 数码管硬件接口
    output reg  [5:0]   seg_sel_n,    // 位选信号（低有效，驱动PNP三极管）
    output wire [7:0]   seg_data      // 段选信号（a~g + 小数点，共阳极）
);

// ---- 寄存器定义 ----
reg [7:0] seg_data_reg [0:5];  // 6个段选数据寄存器
reg [7:0] seg_ctrl_reg;        // 控制寄存器 第0位控制扫描使能


// ---- 动态扫描参数 ----
localparam SCAN_FREQ  = 1000;   // 扫描频率1kHz
localparam CLK_FREQ   = 50_000_000; // 系统时钟50MHz
localparam SCAN_CYCLES = CLK_FREQ / (SCAN_FREQ * 6); // 每个数码管显示周期

reg [31:0] scan_counter;       // 扫描计数器
reg [2:0]  scan_index;         // 当前扫描的数码管索引（0~5）

// ---- 段选译码表（共阳数码管） ----
reg [7:0] seg_decoder [0:15];  // 0~F的段码（含小数点）
initial begin
    seg_decoder[0]  = 8'hC0; // 0
    seg_decoder[1]  = 8'hF9; // 1
    seg_decoder[2]  = 8'hA4; // 2
    seg_decoder[3]  = 8'hB0; // 3
    seg_decoder[4]  = 8'h99; // 4
    seg_decoder[5]  = 8'h92; // 5
    seg_decoder[6]  = 8'h82; // 6
    seg_decoder[7]  = 8'hF8; // 7
    seg_decoder[8]  = 8'h80; // 8
    seg_decoder[9]  = 8'h90; // 9
    seg_decoder[10] = 8'h88; // A
    seg_decoder[11] = 8'h83; // B
    seg_decoder[12] = 8'hC6; // C
    seg_decoder[13] = 8'hA1; // D
    seg_decoder[14] = 8'h86; // E
    seg_decoder[15] = 8'h8E; // F
end

// ---- 总线读写逻辑 ----
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seg_ctrl_reg <= 8'h01; // 默认使能扫描
        for (integer i=0; i<6; i=i+1) begin
            seg_data_reg[i] <= 8'h00;
        end
        prdata <= 32'h0;
    end else if (psel && penable) begin
        if (pwrite) begin // 写操作
            case (paddr)
                4'h0: seg_data_reg[0] <= pwdata[7:0];
                4'h1: seg_data_reg[1] <= pwdata[7:0];
                4'h2: seg_data_reg[2] <= pwdata[7:0];
                4'h3: seg_data_reg[3] <= pwdata[7:0];
                4'h4: seg_data_reg[4] <= pwdata[7:0];
                4'h5: seg_data_reg[5] <= pwdata[7:0];
                4'h6: seg_ctrl_reg    <= pwdata[7:0];
            endcase
        end else begin // 读操作
            case (paddr)
                4'h0: prdata <= {24'h0, seg_data_reg[0]};
                4'h1: prdata <= {24'h0, seg_data_reg[1]};
                4'h2: prdata <= {24'h0, seg_data_reg[2]};
                4'h3: prdata <= {24'h0, seg_data_reg[3]};
                4'h4: prdata <= {24'h0, seg_data_reg[4]};
                4'h5: prdata <= {24'h0, seg_data_reg[5]};
                4'h6: prdata <= {24'h0, seg_ctrl_reg};
                default: prdata <= 32'h0;
            endcase
        end
    end
end

// ---- 动态扫描逻辑 ----
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        scan_counter <= 0;
        scan_index   <= 0;
        seg_sel_n    <= 6'b111111; // 默认关闭所有位选
    end else begin
        if (seg_ctrl_reg[0]) begin // 扫描使能
            if (scan_counter >= SCAN_CYCLES) begin
                scan_counter <= 0;
                seg_sel_n <= 6'b111111; // 短暂关闭显示，避免残影
                
                // 切换到下一个数码管
                scan_index <= (scan_index == 5) ? 0 : scan_index + 1;

                
            end else begin
                scan_counter <= scan_counter + 1;
                seg_sel_n[scan_index] <= 1'b0; // 低电平选中当前数码管
            end
        end else begin
            seg_sel_n <= 6'b111111; // 关闭所有数码管
        end
    end
end

// ---- 段选输出逻辑 ----
assign seg_data = seg_decoder[seg_data_reg[scan_index][3:0]]  // 数字译码
                & {~seg_data_reg[scan_index][7], 7'hFF};        // 小数点控制

endmodule
```

### 四、软件操作示例

```c
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

```

