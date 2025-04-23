/* -------ALU多路选择器模块-------- */
// 选择ALU的输入数据，包括寄存器数据、立即数、PC+4、或其他
// ALU模块进行运算，mux_alu模块选择ALU的输入数据源

`include "defines.v"

module mux_alu ( 
    input      [`ALU_SRC_WIDTH-1:0] alu_src_sel,// ALU 输入数据源选择信号

    input      [`CPU_WIDTH-1:0]     reg1_rdata, // 寄存器1读出数据
    input      [`CPU_WIDTH-1:0]     reg2_rdata, // 寄存器2读出数据
    input      [`CPU_WIDTH-1:0]     imm,        // 立即数
    input      [`CPU_WIDTH-1:0]     curr_pc,    // 当前pc地址

    output reg [`CPU_WIDTH-1:0]     alu_src1,   // ALU 源1
    output reg [`CPU_WIDTH-1:0]     alu_src2    // ALU 源2
);

always @(*) begin
    alu_src1 = reg1_rdata;     // 默认选择reg1数据
    alu_src2 = reg2_rdata;     // 默认选择reg2数据
    case (alu_src_sel)
        `ALU_SRC_REG: begin
            alu_src2 = reg2_rdata; // 来自于寄存器，选择reg2数据
        end
        `ALU_SRC_IMM: begin
            alu_src2 = imm;        // 来自于立即数，选择立即数
        end
        `ALU_SRC_FOUR_PC: begin
            alu_src1 = `CPU_WIDTH'h4; // pc + 4 
            alu_src2 = curr_pc;       //
        end
        `ALU_SRC_IMM_PC: begin  
            alu_src1 = imm;
            alu_src2 = curr_pc;
        end
    endcase
end
endmodule
