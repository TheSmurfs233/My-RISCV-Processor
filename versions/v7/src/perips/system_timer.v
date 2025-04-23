/*
操作流程
// 初始化定时器（C伪代码）
volatile uint32_t *CTRL  = (uint32_t*)0x1000; // 假设基地址0x1000
volatile uint32_t *LOAD  = (uint32_t*)0x1004;
volatile uint32_t *VAL   = (uint32_t*)0x1008;

*LOAD = 999;          // 设置1ms周期（假设时钟1MHz）
*VAL  = 0;            // 触发重载并清除COUNTFLAG
*CTRL = 0x3;          // 使能定时器和中断
*/

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
