/* -------指令/数据存储器模块-------- */

`include "defines.v"
//0~1023存储指令，1024~2047存储数据
module data_mem (
    input   wire                                clk         , // 时钟信号
    input   wire                                rst_n       , // 复位信号
    input   wire                                mem_sel     , // 选择信号
    input   wire                                mem_wen     ,     // 写使能信号
    input   wire [`CPU_WIDTH - 1:0]             mem_addr_i  ,   // 地址输入
    output  reg  [`CPU_WIDTH - 1:0]             mem_rdata_o ,   // 数据输出
    input   wire [`CPU_WIDTH - 1:0]             mem_wdata_i     // 数据输入
);
// reg [`CPU_WIDTH - 1:0] data_mem [0:`DATA_MEM_ADDR_DEPTH - 1]; // 存储器
reg [`CPU_WIDTH - 1:0] data_mem [0:32 - 1]; // 存储器
wire [`CPU_WIDTH - 1:0] word_addr;
assign word_addr = mem_addr_i >> 2; // 读地址输入,转换为字地址，32位对应4个地址，所以右移2位

//存储器读
always @(posedge clk ,negedge rst_n) begin
    if (rst_n == 1'b0) begin
        mem_rdata_o = `CPU_WIDTH'h0;
    end
    else if(mem_sel == 1'b1) begin
        mem_rdata_o = data_mem[word_addr]; 
    end
    else begin
        mem_rdata_o = `CPU_WIDTH'h0;
    end
end

//存储器写入
always @(posedge clk ,negedge rst_n) begin
    if (rst_n == 1'b0) begin
        data_mem[0] = 32'hff0000ff;
        data_mem[1] = 32'hf00f0ff0;
        data_mem[2] = 32'h00000000;
        data_mem[3] = 32'h00000000;
        data_mem[4] = 32'h00000000;
        data_mem[5] = 32'h00000000;
        data_mem[6] = 32'h00000000;
        data_mem[7] = 32'h00000000;
        data_mem[8] = 32'h00000000;
        data_mem[9] = 32'h00000000;
    end
    else if (mem_sel == 1'b1 && mem_wen == 1'b1) begin
        data_mem[word_addr] <= mem_wdata_i;
    end
end

// initial begin
// data_mem[0] = 32'hbeefbeef;
// data_mem[1] = 32'hbeefbeef;
// data_mem[2] = 32'hbeefbeef;
// data_mem[3] = 32'hbeefbeef;
// data_mem[4] = 32'hbeefbeef;
// data_mem[5] = 32'h00000000;
// data_mem[6] = 32'h00000000;
// data_mem[7] = 32'h00000000;
// data_mem[8] = 32'h00000000;
// data_mem[9] = 32'h00000000;
// end
// initial begin
//     $readmemh ("D:/RISCV/myriscv_v3/sim/inst/SH", data_mem); // 从文件中读取指令
// end

endmodule
