# 乘除法扩展指令集M

M类型扩展指令集提供了一系列整数乘除指令，包括单周期乘除指令、乘累加指令、带余数除法指令等。这些指令可以用于执行高效的整数乘除运算，从而提高系统的性能和效率：

- 乘法指令集：包括单周期乘法指令、乘累加指令和伪随机数生成指令。这些指令可以用来执行高速乘法、乘累加和随机数生成等操作；
- 除法指令集：包括单周期除法指令和带余数除法指令。这些指令可以用来执行高精度除法操作，从而提高了系统的运算速度和精度；
- 加速指令集：包括一系列指令，可以用于执行高效的算术运算、移位操作、位操作和逻辑运算。这些指令可以实现快速、高效的数据处理操作。
  以RV32M为例，其所有指令均为R型指令，具体格式如下（2018年发布的v2.1版本）：

以RV32M为例，其所有指令均为R型指令，具体格式如下

![image-20250415154633657](../../RISCV/doc/img/rv-img-7.png)

### RV32M指令详细介绍

#### 1.乘法操作

![image-20250415155106635](../../RISCV/doc/img/rv-img-8.png)

1. **MUL指令（mul rd,rs1,rs2）**

   乘（Multiply），寄存器x[rs2]乘以寄存器x[rs1]，并将乘积写入x[rd]，忽略算数溢出。

2. **MULH指令（mul rd,rs1,rs2）**

   高位乘（Multiply High），把寄存器x[rs2]乘以寄存器x[rs1]，都视为2的补码，将乘积的高位写入x[rd]。

3. **MULHSU指令（mulhsu rd,rs1,rs2）**

   高位有符号-无符号乘（Multiply High Signed-Unsigned），把寄存器x[rs2]乘以寄存器x[rs1]，其中x[rs1]为补码，x[rs2]为无符号数，将乘积的高位写入x[rd]。

4. **MULHU指令（mulhu rd,rs1,rs2）**

   高位无符号乘（Multiply High Unsigned），把寄存器x[rs2]乘以寄存器x[rs1]，两者均为无符号数，计算结果的高位写入x[rd]。

#### 2.除法操作

![image-20250415155354212](../../RISCV/doc/img/rv-img-9.png)

1. **DIV指令（div rd,rs1,rs2）**

   除法（Divide），用寄存器x[rs1]的值除以寄存器x[rs2]的值，向零舍入，将这些数视为二进制补码，把商写入x[rd]。

2. **DIVU指令（div rd,rs1,rs2）**

   无符号除法（Divide，Unsigned），用寄存器x[rs1]的值除以寄存器x[rs2]的值，向零舍入，将这些数据视为无符号数，把商写入x[rd]。

3. **REM指令（rem rd,rs1,rs2）**

   求余数（Remainder），x[rs1]除以x[rs2]向0舍入，都视为2的补码，余数写入x[rd]。

4. **REMU指令（rem rd,rs1,rs2）**

   求无符号数的余数（Remainder，Unsigned），x[rs1]除以x[rs2]，向0舍入，都视为无符号数，余数写入x[rd]。



# 流水线暂停原理

- **取指阶段（IF）**：

  **冻结PC值**：暂停期间保持PC不变，阻止新指令进入流水线。

- **译码阶段（ID）**：

  **冻结指令寄存器**：保持当前指令和操作数不变。

- **执行阶段（EX）**：

  **保持操作数不变**：确保除法输入的 `dividend` 和 `divisor` 在暂停期间稳定（波形中70ns~150ns期间数值未变化）。

- **访存（MEM）和写回（WB）阶段**：

  **可正常流动或冻结**：若MEM/WB阶段无长延迟操作，可继续执行（但需确保前序阶段暂停时无新数据传入）。若需完全暂停，将寄存器更新条件与 `stall` 绑定。

- **数据前递与冒险处理**：

  **前递逻辑调整**：暂停期间忽略EX阶段产生的前递数据（避免无效数据污染流水线）

  **控制冒险处理**：暂停期间PC不变，无需处理分支预测错误。



# 除法指令实现

- **除法单元仿真波形图**

  ![除法单元仿真波形图](../../RISCV/doc/img/除法单元仿真波形图.png)

  当ALU输入操作为除法操作时，`div_inst`信号为高，同时采用时序逻辑电路对其打一拍得到信号`div_inst_r` , 然后对其进行边沿检测，生成单周期的数据有效信号 `data_rdy` 通知除法单元模块进行无符号除法操作，在此期间拉高 `alu_pipestall` 信号执行暂停流水线操作，直到除法单元返回计算完成信号 `res_rdy` 信号，同时拉低`alu_pipestall` 信号解除流水线暂停操作。

- 有符号除法和无符号除法如何复用除法单元

  **补码转换为原码**

  1. 提取符号位

     判断被除数（`dividend`）和除数（`divisor`）的符号位（最高位）。

     ```
     wire sign_dividend = dividend[WIDTH-1];
     wire sign_divisor  = divisor[WIDTH-1];
     ```

  2. 计算绝对值

     将负数转换为正数（若为负数，取补码的绝对值）。

     ```
     wire [WIDTH-1:0] abs_dividend = sign_dividend ? (-dividend) : dividend;
     wire [WIDTH-1:0] abs_divisor  = sign_divisor  ? (-divisor)  : divisor;
     ```


  **调用无符号除法器**

  ```
  // 实例化无符号除法器
  wire [WIDTH:0] abs_quotient, abs_remainder;
  unsigned_divider u_div (
    .dividend(abs_dividend),
    .divisor(abs_divisor),
    .quotient(abs_quotient),
    .remainder(abs_remainder)
  );
  ```

  **结果转换回补码**

  1. 计算符号

     商的符号：被除数与除数符号异或。

     余数的符号：与被除数符号一致。

     ```
     wire sign_quotient = sign_dividend ^ sign_divisor;
     wire sign_remainder = sign_dividend;
     ```

  2. 符号转换

     ```
     // 商：根据符号转换为补码
     wire [WIDTH-1:0] quotient = sign_quotient ? 
                               -abs_quotient[WIDTH-1:0] : 
                               abs_quotient[WIDTH-1:0];
     
     // 余数：根据符号转换为补码
     wire [WIDTH-1:0] remainder = sign_remainder ? 
                                -abs_remainder[WIDTH-1:0] : 
                                abs_remainder[WIDTH-1:0];
     ```

     




## Multiplier IP核

![image-20250415144843480](../../RISCV/doc/img/rv-img-6.png)

### 一、IP核基本特性

- **支持乘法类型**：并行乘法（无符号/有符号）、常系数乘法（固定系数）
- **输入范围**：A/B端口最大支持18位（A[17:0], B[17:0]）
- **输出范围**：P端口最大36位（P[35:0]）
- **优化选项**：速度优先（DSP块）或面积优先（逻辑资源）

### 二、核心配置步骤

#### 1. 调用IP核

- 在Block Design中右键 > Add IP > 搜索"Multiplier"
- 默认生成组件名称为`mult_gen_0`

#### 2. Basic标签页配置

- 乘法器类型：
  - *Parallel*：通用并行乘法（A×B）
  - *Constant Coefficients*：固定系数乘法（仅B端口为常数）
- 输入类型：
  - 勾选"Signed"时为有符号数乘法
  - 默认无符号数（Unsigned）
- 位宽设置：
  - 通过"A Width"和"B Width"调整输入位宽
  - 输出位宽自动计算（InputA_width + InputB_width）

#### 3. Output and Control标签页

- 控制信号：
  - 可启用CE（时钟使能）、SCLR（同步清零）等控制端口
  - 通过"Show disabled ports"显示/隐藏未启用的端口
- 流水线级数：
  - 可配置Latency提升时序性能（增加寄存器层级）

#### 4. 实现优化

- 构建方式：
  - *Use DSP48*：使用FPGA的专用DSP单元（Xilinx DSP48E1）
  - *Use LUTs*：使用逻辑资源（CLB）实现
- 优化策略：
  - 速度优化：优先时序性能（默认3级流水）
  - 面积优化：减少资源消耗（可能降低最大频率）

### 三、使用注意事项

1. **数据溢出**：

   - 确保输出位宽 ≥ 输入位宽之和（如18位×18位需36位输出）
   - 可通过截断或饱和处理管理溢出

2. **时序约束**：

   - 使用DSP48时需注意时钟域约束
   - 高频率设计建议启用流水线（Latency≥2）

3. **资源选择建议**：

   ```
   // 资源选择伪代码示例
   if (输入位宽 > 18位) 
       必须使用LUTs实现；
   else if (需要高性能) 
       选择DSP48 + 速度优化；
   else 
       选择LUTs + 面积优化；
   ```

