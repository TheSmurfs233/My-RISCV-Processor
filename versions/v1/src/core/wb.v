/* -------写回模块-------- */
//将数据写回寄存器

`include "defines.v"

module wb (
    input  wire  [`CPU_WIDTH-1:0]    alu_res,   // ALU结果

    //内存访问控制信号
    input wire [`MEM_ACCESS_TYPE_WIDTH-1:0] mem_access_type, // 内存访问类型
    input wire [`MEM_ACCESS_SIZE_WIDTH-1:0] mem_access_size, // 内存访问大小
    input wire                              mem_sign_ext, // 内存加载符号扩展

    //寄存器堆
    // output reg [`REG_ADDR_WIDTH-1:0] reg_waddr,  // 寄存器写地址
    output reg [`CPU_WIDTH-1:0]      reg_wdata,  // 寄存器写数据

    //存储器地址数据信号
    output reg [`CPU_WIDTH-1:0]       mem_raddr_o,   // 存储器地址
    output reg [`CPU_WIDTH-1:0]       mem_waddr_o,   // 存储器地址
    //output  wire [`CPU_WIDTH-1:0]       mem_data_o,   // 存储器写入数据

    input   wire [`CPU_WIDTH-1:0]       mem_data_i
    
);

//alu_res[1:0] =0 [7:0] =1 [15:8] =2 [23:16] =3 [31:24] =4
always @(*) begin
    case (mem_access_type)
        `MEM_ACCESS_TYPE_NONE: begin
            mem_raddr_o = 0;
            mem_waddr_o = 0;
            reg_wdata = alu_res; //根据ALU运算结果写回数据
        end
        `MEM_ACCESS_TYPE_READ:begin
            //从存储器读出数据
            mem_raddr_o = alu_res;//将ALU运算结果作为存储器地址
            case (mem_access_size)
                `MEM_ACCESS_SIZE_BYTE: begin
                    case (alu_res[1:0])
                        2'b00: reg_wdata = mem_sign_ext ?{{24{mem_data_i[7]}},mem_data_i[7:0]}:{{24{1'b0}},mem_data_i[7:0]}; 
                        2'b01: reg_wdata = mem_sign_ext ?{{24{mem_data_i[15]}},mem_data_i[15:8]}:{{24{1'b0}},mem_data_i[15:8]}; 
                        2'b10: reg_wdata = mem_sign_ext ?{{24{mem_data_i[23]}},mem_data_i[23:16]}:{{24{1'b0}},mem_data_i[23:16]};  
                        2'b11: reg_wdata = mem_sign_ext ?{{24{mem_data_i[31]}},mem_data_i[31:24]}:{{24{1'b0}},mem_data_i[31:24]};
                    endcase
                end
                `MEM_ACCESS_SIZE_HALF: begin
                    case (alu_res[1])
                        1'b0: reg_wdata = mem_sign_ext ?{{16{mem_data_i[15]}},mem_data_i[15:0]}:{{16{1'b0}},mem_data_i[15:0]}; 
                        1'b1: reg_wdata = mem_sign_ext ?{{16{mem_data_i[31]}},mem_data_i[31:16]}:{{16{1'b0}},mem_data_i[31:16]};
                    endcase
                end
                `MEM_ACCESS_SIZE_WORD: begin
                    reg_wdata = mem_data_i;
                end

            endcase
        end
        `MEM_ACCESS_TYPE_WRITE:begin
            //将数据写入存储器
            mem_waddr_o = alu_res; //将ALU运算结果作为存储器地址
        end
    endcase
end


    
endmodule