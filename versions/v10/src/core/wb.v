/* -------写回模块-------- */
//将数据写回寄存器

`include "defines.v"

module wb (
    input   wire [`CPU_WIDTH-1:0]               alu_res,   // ALU结果

    //内存访问控制信号
    input   wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   mem_access_type, // 内存访问类型
    input   wire                                mem_sign_ext, // 内存加载符号扩展
    //存储器读地址数据信号  
    output  reg  [`CPU_WIDTH-1:0]               mem_raddr_o,   // 存储器地址
    input   wire [`CPU_WIDTH-1:0]               mem_rdata_i ,  // 存储器数据
    //写回寄存器堆  
    output  reg  [`CPU_WIDTH-1:0]               reg_wdata  // 寄存器写数据
    
);

//alu_res[1:0] =0 [7:0] =1 [15:8] =2 [23:16] =3 [31:24] =4
always @(*) begin
    reg_wdata = alu_res;
    mem_raddr_o = 0;
    case (mem_access_type)
        `MEM_ACCESS_TYPE_READ_BYTE: begin
            mem_raddr_o = alu_res;//将ALU运算结果作为存储器地址
            case (alu_res[1:0])
                2'b00: reg_wdata = mem_sign_ext ?{{24{mem_rdata_i[ 7]}},mem_rdata_i[ 7: 0]}:{{24{1'b0}},mem_rdata_i[ 7: 0]}; 
                2'b01: reg_wdata = mem_sign_ext ?{{24{mem_rdata_i[15]}},mem_rdata_i[15: 8]}:{{24{1'b0}},mem_rdata_i[15: 8]}; 
                2'b10: reg_wdata = mem_sign_ext ?{{24{mem_rdata_i[23]}},mem_rdata_i[23:16]}:{{24{1'b0}},mem_rdata_i[23:16]};  
                2'b11: reg_wdata = mem_sign_ext ?{{24{mem_rdata_i[31]}},mem_rdata_i[31:24]}:{{24{1'b0}},mem_rdata_i[31:24]};
            endcase
        end
        `MEM_ACCESS_TYPE_READ_HALF: begin
            mem_raddr_o = alu_res;//将ALU运算结果作为存储器地址
            case (alu_res[1])
                1'b0: reg_wdata = mem_sign_ext ?{{16{mem_rdata_i[15]}},mem_rdata_i[15: 0]}:{{16{1'b0}},mem_rdata_i[15: 0]}; 
                1'b1: reg_wdata = mem_sign_ext ?{{16{mem_rdata_i[31]}},mem_rdata_i[31:16]}:{{16{1'b0}},mem_rdata_i[31:16]};
            endcase
        end
        `MEM_ACCESS_TYPE_READ_WORD: begin
            mem_raddr_o = alu_res;//将ALU运算结果作为存储器地址
            reg_wdata = mem_rdata_i;
        end
    endcase
end




    
endmodule