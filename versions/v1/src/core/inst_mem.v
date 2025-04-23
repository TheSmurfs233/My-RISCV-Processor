/* -------指令/数据存储器模块-------- */

`include "defines.v"
//0~1023存储指令，1024~2047存储数据
module inst_mem (
    input   wire [`CPU_WIDTH - 1:0]   pc_addr_i ,   // 程序计数器地址
    output  reg  [`CPU_WIDTH - 1:0]   inst_o    ,   // 指令输出


    input  wire [`CPU_WIDTH - 1:0]   mem_raddr_i,
    output reg  [`CPU_WIDTH - 1:0]   mem_rdata_o,
    
    input wire [`MEM_ACCESS_SIZE_WIDTH-1:0] mem_access_size, // 内存访问大小
    input wire [`MEM_ACCESS_TYPE_WIDTH-1:0] mem_access_type, // 内存访问类型
    input wire [`CPU_WIDTH-1:0]       mem_waddr_i,
    input wire [`CPU_WIDTH-1:0]       mem_wdata_i   // 存储器写数据输入



);
reg [`CPU_WIDTH - 1:0] inst_mem [0:`MEM_ADDR_DEPTH - 1]; // 存储器

always @(*) begin
    inst_o = inst_mem[pc_addr_i[`INST_MEM_ADDR_WIDTH + 2 - 1:2]]; // 取指令，因为指令是32位的，所以需要一次取一个字32位bit，所以最低两位是没有意义的，或者说相当于除4， 例如 pc_addr_i = 10'b00_0000_0100, 对应十进制为4，应该取第五个地址，一个指令32位对应4个地址，所以取地址应该取第二个32位的指令
end

wire [`CPU_WIDTH - 1:0] temp;
assign temp = mem_waddr_i[1:0];
always @(*) begin
    case (mem_access_type)
        `MEM_ACCESS_TYPE_NONE: begin
            // reg_wdata = alu_res; //根据ALU运算结果写回数据
        end
        `MEM_ACCESS_TYPE_READ: begin
            mem_rdata_o = inst_mem[mem_raddr_i[`CPU_WIDTH -1:2]];
        end
    
        `MEM_ACCESS_TYPE_WRITE:begin
            if (mem_waddr_i >= `INST_MEM_ADDR_DEPTH) begin
                case (mem_access_size)
                `MEM_ACCESS_SIZE_NONE: begin

                end
                `MEM_ACCESS_SIZE_BYTE: begin
                    case (mem_waddr_i[1:0])
                        2'b00: inst_mem[mem_waddr_i[`CPU_WIDTH -1:2]][7:0] = mem_wdata_i[7:0];
                        2'b01: inst_mem[mem_waddr_i[`CPU_WIDTH -1:2]][15:8] = mem_wdata_i[7:0];
                        2'b10: inst_mem[mem_waddr_i[`CPU_WIDTH -1:2]][23:16] = mem_wdata_i[7:0];
                        2'b11: begin
                            inst_mem[mem_waddr_i[`CPU_WIDTH -1:2]][31:24] = mem_wdata_i[7:0];
                        end
                    endcase
                end
                `MEM_ACCESS_SIZE_HALF: begin
                    case (mem_waddr_i[1:0])
                        2'b00: inst_mem[mem_waddr_i[`CPU_WIDTH -1:2]][15:0] = mem_wdata_i[15:0];
                        2'b01: inst_mem[mem_waddr_i[`CPU_WIDTH -1:2]][23:8] = mem_wdata_i[15:0];
                        2'b10: inst_mem[mem_waddr_i[`CPU_WIDTH -1:2]][31:16] = mem_wdata_i[15:0];
                        2'b11: begin
                            inst_mem[mem_waddr_i[`CPU_WIDTH -1:2]][31:24] = mem_wdata_i[7:0];
                            inst_mem[mem_waddr_i[`CPU_WIDTH -1:2]][7:0] = mem_wdata_i[15:8];
                        end

                    endcase
                end
                `MEM_ACCESS_SIZE_WORD: begin
                    inst_mem[mem_waddr_i[`CPU_WIDTH -1:2]] = mem_wdata_i;
                end
                endcase
            end
        end
    endcase
    
end



endmodule
