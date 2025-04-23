# v7版本主要做了以下修改

1. 增加系统定时器模块



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





### **系统定时器设计方案**

### 一、寄存器定义

外设基地址由系统分配，定义如下寄存器：

| 地址偏移（字节） | 寄存器名称 |  位域  |            功能描述            |
| :--------------: | :--------: | :----: | :----------------------------: |
|       0x00       |    CTRL    |  [0]   |     使能位（1=启动定时器）     |
|                  |            |  [1]   |    中断使能位（1=允许中断）    |
|                  |            |  [16]  | COUNTFLAG 状态（只读，1=超时） |
|       0x04       |   LOAD_L   | [31:0] |          重载值低32位          |
|       0x08       |   LOAD_H   | [31:0] |          重载值高32位          |
|       0x0C       |   VAL_L    | [31:0] |      当前值低32位（只读）      |
|       0x10       |   VAL_H    | [31:0] |      当前值高32位（只读）      |

# **系统定时器模块设计方案**

### 一、寄存器定义

外设基地址由系统分配，定义如下寄存器：

| 地址偏移（字节） | 寄存器名称 |  位域  |            功能描述            |
| :--------------: | :--------: | :----: | :----------------------------: |
|       0x00       |    CTRL    |  [0]   |     使能位（1=启动定时器）     |
|                  |            |  [1]   |    中断使能位（1=允许中断）    |
|                  |            |  [16]  | COUNTFLAG 状态（只读，1=超时） |
|       0x04       |   LOAD_L   | [31:0] |          重载值低32位          |
|       0x08       |   LOAD_H   | [31:0] |          重载值高32位          |
|       0x0C       |   VAL_L    | [31:0] |      当前值低32位（只读）      |
|       0x10       |   VAL_H    | [31:0] |      当前值高32位（只读）      |

**寄存器详细说明：**

1. **CTRL（控制寄存器）**
   - **D0**：定时器使能位，写1启动定时器，写0停止
   - **D1**：中断使能位，写1允许超时中断
   - **D16**：COUNTFLAG 状态位（只读），超时后自动置1
   - 其他位：保留位，默认置0
2. **LOAD_L/LOAD_H（重载值寄存器）**
   - 组成64位重载初值（LOAD_H为高32位）
3. **VAL_L/VAL_H（当前值寄存器）**
   - 组成64位当前计数值（VAL_H为高32位，只读）
   - 写操作会触发计数器重载（将LOAD值载入VAL）

### 二、设计说明

##### 1. 功能概述

本模块实现64位系统级定时器，支持以下功能：

- **递减计数**：以系统时钟频率递减计数
- **自动重载**：计数到0时自动加载预设值
- **状态监控**：通过COUNTFLAG标志查询超时状态
- **总线接口**：支持32位寄存器读写操作

##### 2. 寄存器配置流程

1. **设置重载值**：

   ```c
   LOAD_L = 0x0000FFFF;  // 低32位初值
   LOAD_H = 0x00000001;  // 高32位初值
   ```

2. **启动定时器**：

   ```c
   CTRL = (1 << 0) | (1 << 1);  // 使能定时器+中断
   ```

3. **查询状态**：

   ```
   if (CTRL & (1 << 16)) {  // 检查COUNTFLAG
       // 处理超时事件
   }
   ```

##### 3. 计数器工作模式

- **递减逻辑**：
  - 当CTRL[0]=1时，每个时钟周期计数器减1
  - 计数到0时自动加载LOAD寄存器的值
  - 加载时自动置位COUNTFLAG标志
- **手动重载**：
  - 写入VAL_L或VAL_H寄存器时立即重载
  - 重载操作自动清除COUNTFLAG标志

##### 4. 中断逻辑

- **中断条件**：

  ```
  irq = ctrl_reg[1] & ctrl_reg[16];  // 中断使能且超时
  ```

- **标志清除**：

  - 读取CTRL寄存器后自动清除COUNTFLAG
  - 写入VAL寄存器或定时器重载时清除

##### 5. 总线接口操作

- 写操作：
  - 写LOAD寄存器：更新重载值
  - 写VAL寄存器：触发立即重载
  - 写CTRL[0]：控制定时器启停
- 读操作：
  - 读VAL寄存器：获取当前计数值
  - 读CTRL寄存器：获取控制状态（自动清除标志）

##### 6. 注意事项

1. **复位状态**：
   - 所有寄存器复位值为0，定时器处于停止状态
2. **写时序**：
   - 建议先配置LOAD寄存器再启动定时器
   - 写VAL寄存器会中断当前计数周期
3. **中断处理**：
   - 应在中断服务例程中读取CTRL寄存器清除标志
   - 连续超时会产生周期中断
4. **64位处理**：
   - 访问VAL寄存器时建议关闭中断，防止高低位读取不一致

### 三、Verilog 模块代码

```
module system_timer (
    input  wire        clk,          // 系统时钟
    input  wire        rst_n,        // 异步低电平复位
    input  wire        sel,
    // 寄存器读写接口
    input  wire [2:0]  addr,         // 3位地址 000=CTRL, 001=LOAD_L, 011=LOAD_H, 010=VAL_L, 100=VAL_H
    input  wire [31:0] wdata,        // 写入数据
    input  wire        wen,          // 写使能
    output reg  [31:0] rdata,        // 读取数据
    output wire        irq           // 中断输出
);

// 寄存器定义
reg  [31:0] ctrl_reg;   // 控制寄存器   // [0wr:ENABLE, 1wr:INTERRUPT_EN, 16r:COUNTFLAG]
reg  [31:0] load_reg_h; // 高32位重装值
reg  [31:0] load_reg_l; // 低32位重装值
reg  [31:0] val_reg_h;  // 高32位当前值
reg  [31:0] val_reg_l;  // 低32位当前值
wire [63:0] counter = {val_reg_h, val_reg_l};
wire [63:0] load_val = {load_reg_h, load_reg_l};
// 位16 COUNTFLAG 读后清除标志信号
reg clear_flag;

// 中断信号       
assign irq = ctrl_reg[1] & ctrl_reg[16]; // 当COUNTFLAG=1且中断使能时触发

// 寄存器写逻辑
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ctrl_reg   <= 32'h0;
        load_reg_h <= 32'h0;
        load_reg_l <= 32'h0;
        val_reg_h  <= 32'h0;
        val_reg_l  <= 32'h0;
        clear_flag <= 0;
    end else begin
        // 寄存器写入
        if (wen && sel) begin
            case(addr)
                3'b000: ctrl_reg <= {wdata[31:17], 1'b0, wdata[15:0]};//保留位17和位1
                3'b001: load_reg_l <= wdata;
                3'b011: load_reg_h <= wdata;
                3'b010: begin  // 写VAL_L触发重载
                    {val_reg_h, val_reg_l} <= load_val;
                    ctrl_reg[16] <= 1'b0;   // 清除COUNTFLAG
                end
                3'b100: begin  // 写VAL_H触发重载
                    {val_reg_h, val_reg_l} <= load_val;
                    ctrl_reg[16] <= 1'b0;   // 清除COUNTFLAG
                end
                default: ; // 其他地址忽略
            endcase
        end
        
        // 64位递减逻辑
        if (ctrl_reg[0]) begin
            if (counter == 64'h0) begin
                {val_reg_h, val_reg_l} <= load_val;
                ctrl_reg[16] <= 1'b1;   // 置位COUNTFLAG
            end
            else begin
                {val_reg_h, val_reg_l} <= counter - 64'h1;
            end
        end

        //读后清除
        // 检测到读CTRL且COUNTFLAG=1时标记清除
        clear_flag <= (addr == 3'b000) && sel && ctrl_reg[16];
        // 执行实际清除
        if (clear_flag ) begin
            ctrl_reg[16] <= 1'b0;
            clear_flag <= 0;
        end
    end


end

// 寄存器读逻辑
always @(posedge clk) begin
    case(addr)
        3'b000: rdata = ctrl_reg; // 读CTRL（包含COUNTFLAG状态）
        3'b001: rdata = load_reg_l; // 读LOAD
        3'b010: rdata = load_reg_h;
        3'b011: rdata = val_reg_l; // 读VAL
        3'b100: rdata = val_reg_h;
        default: rdata = 32'h0;
    endcase
end


endmodule

```

### 四、软件操作示例

```c
#include <stdint.h>
#include "seg.h"  // 包含数码管驱动头文件

/*------------------------- 寄存器地址宏定义 -----------------------*/
#define SYS_TIMER_BASE 0x10030200

// 寄存器偏移定义（每个寄存器4字节间隔）
#define TIMER_CTRL   (*(volatile uint32_t*)(SYS_TIMER_BASE + 0x00))
#define TIMER_LOAD_L (*(volatile uint32_t*)(SYS_TIMER_BASE + 0x04))
#define TIMER_LOAD_H (*(volatile uint32_t*)(SYS_TIMER_BASE + 0x08))
#define TIMER_VAL_L  (*(volatile uint32_t*)(SYS_TIMER_BASE + 0x0C))
#define TIMER_VAL_H  (*(volatile uint32_t*)(SYS_TIMER_BASE + 0x10))


/*------------------------- 主程序 --------------------------------*/
int main(void) {
    // 初始化数码管
    // 初始化配置
    SEG_InitTypeDef segInit = {
        .scanEnable = true  // 使能扫描
    };
    
    // 初始化数码管
    SEG_Init(&segInit);
    // 显示
    SEG_WriteData(4, 0xE, SEG_DOT_DISABLE);
    SEG_WriteData(5, 0xF, SEG_DOT_DISABLE);    

    // 1. 配置1秒定时（假设时钟50MHz）
    TIMER_LOAD_L = 50000000;  // 低32位：50,000,000
    TIMER_LOAD_H = 0;        // 高32位：0
    TIMER_VAL_L = 0;         // 触发重载

    // 2. 启动定时器（设置ENABLE位）
    TIMER_CTRL = 0x1;

    // 初始显示值
    uint32_t count = 0;  // 30秒倒计时
    
    while(1) {
        // 3. 检查超时标志（位16）
        if(TIMER_CTRL & (1 << 16)) {
            // 清除标志（读CTRL寄存器）
            volatile uint32_t flag = TIMER_CTRL;
            SEG_WriteData(0, count, SEG_DOT_DISABLE);    

            count++;
            // // 重载定时器
            // TIMER_VAL_L = 0;  // 任意写VAL触发重载
        }
    }
    return 0;
}

```

