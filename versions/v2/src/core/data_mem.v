/* -------指令/数据存储器模块-------- */

`include "defines.v"
//0~1023存储指令，1024~2047存储数据
module data_mem (
    input   wire                                clk         , // 时钟信号
    input   wire [`CPU_WIDTH - 1:0]             mem_raddr_i ,   // 地址输入
    output  reg  [`CPU_WIDTH - 1:0]             mem_rdata_o ,   // 数据输出

    input   wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   mem_access_type, // 内存访问类型
    input   wire [`CPU_WIDTH - 1:0]             mem_wdata_i ,    // 数据输入
    input   wire [`CPU_WIDTH - 1:0]             mem_waddr_i      // 地址输入
);
// reg [`CPU_WIDTH - 1:0] data_mem [0:`DATA_MEM_ADDR_DEPTH - 1]; // 存储器
reg [`CPU_WIDTH - 1:0] data_mem [0:32 - 1]; // 存储器

wire mem_wen; // 写使能信号
assign mem_wen = (mem_access_type == `MEM_ACCESS_TYPE_WRITE_WORD) | (mem_access_type == `MEM_ACCESS_TYPE_WRITE_HALF) | (mem_access_type == `MEM_ACCESS_TYPE_WRITE_BYTE); // 写使能信号

wire [`CPU_WIDTH - 1:0] mem_waddr; // 读地址输入
assign mem_waddr = mem_waddr_i - 4096; // 指令地址从1024开始

//存储器读
always @(*) begin
    if (mem_access_type == `MEM_ACCESS_TYPE_READ_WORD | mem_access_type == `MEM_ACCESS_TYPE_READ_HALF | mem_access_type == `MEM_ACCESS_TYPE_READ_BYTE) begin
        mem_rdata_o = data_mem[mem_raddr_i[`DATA_MEM_ADDR_WIDTH + 2 - 1:2] - 1024]; // 取指令，因为指令是32位的，所以需要一次取一个字32位bit，所以最低两位是没有意义的，或者说相当于除4， 例如 pc_addr_i = 10'b00_0000_0100, 对应十进制为4，应该取第五个地址，一个指令32位对应4个地址，所以取地址应该取第二个32位的指令
    end
    else begin
        mem_rdata_o = 0;
    end
end
initial begin
data_mem[0] = 32'h0ff000ff;
data_mem[1] = 32'h00000000;
data_mem[2] = 32'h00000000;
data_mem[3] = 32'h00000000;
data_mem[4] = 32'h00000000;
data_mem[5] = 32'h00000000;
data_mem[6] = 32'h00000000;
data_mem[7] = 32'h00000000;
data_mem[8] = 32'h00000000;
data_mem[9] = 32'h00000000;
end
// initial begin
//     $readmemh ("D:/RISCV/myriscv_v2/sim/inst/LB", data_mem); // 从文件中读取指令
// end
//存储器写入
always @(posedge clk ) begin
    if (mem_wen) begin
    case (mem_access_type)
        `MEM_ACCESS_TYPE_WRITE_BYTE: begin
            case (mem_waddr[1:0])
                2'b00: data_mem[mem_waddr[`CPU_WIDTH -1:2]][7:0] = mem_wdata_i[7:0];
                2'b01: data_mem[mem_waddr[`CPU_WIDTH -1:2]][15:8] = mem_wdata_i[7:0];
                2'b10: data_mem[mem_waddr[`CPU_WIDTH -1:2]][23:16] = mem_wdata_i[7:0];
                2'b11: begin
                    data_mem[mem_waddr[`CPU_WIDTH -1:2]][31:24] = mem_wdata_i[7:0];
                end
            endcase
        end
        `MEM_ACCESS_TYPE_WRITE_HALF: begin
            case (mem_waddr[1:0])
                2'b00: data_mem[mem_waddr[`CPU_WIDTH -1:2]][15:0] = mem_wdata_i[15:0];
                2'b01: data_mem[mem_waddr[`CPU_WIDTH -1:2]][23:8] = mem_wdata_i[15:0];
                2'b10: data_mem[mem_waddr[`CPU_WIDTH -1:2]][31:16] = mem_wdata_i[15:0];
                2'b11: begin
                    data_mem[mem_waddr[`CPU_WIDTH -1:2]][31:24] = mem_wdata_i[7:0];
                    data_mem[mem_waddr[`CPU_WIDTH -1:2]][7:0] = mem_wdata_i[15:8];
                end
            endcase
        end
        `MEM_ACCESS_TYPE_WRITE_WORD: begin
            data_mem[mem_waddr[`CPU_WIDTH -1:2]] = mem_wdata_i;
        end
    endcase
end
end
endmodule
