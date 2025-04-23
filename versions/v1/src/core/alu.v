/* -------运算逻辑单元模块-------- */
// 对输入的两个数进行运算，并输出运算结果


`include "defines.v"

module alu(
    input      [`ALU_OP_WIDTH-1:0] alu_op,   // ALU操作码
    input      [`CPU_WIDTH-1:0]    alu_src1, // ALU源1
    input      [`CPU_WIDTH-1:0]    alu_src2, // ALU源2
    output reg                     zero,     // ALU结果是否为0
    output reg [`CPU_WIDTH-1:0]    alu_res   // ALU结果
);



always @(*) begin
    zero = 1'b0;
    alu_res = `CPU_WIDTH'b0;
    case (alu_op)
        `ALU_ADD: begin // 加法运算
            alu_res = alu_src1 + alu_src2;
        end
        `ALU_SUB:begin // 减法运算,相等时zero返回1,mux_pc模块不进行跳转
            alu_res = alu_src1 - alu_src2;
            zero = (alu_res == `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_SUB_NE:begin // 减法运算,不相等时返回1,mux_pc模块里进行跳转
            alu_res = alu_src1 - alu_src2;
            zero = (alu_res != `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_AND:begin // 与运算
            alu_res = alu_src1 & alu_src2;
        end
        `ALU_OR:begin // 或运算
            alu_res = alu_src1 | alu_src2;
        end
        `ALU_XOR:begin // 异或运算
            alu_res = alu_src1 ^ alu_src2;
        end
        `ALU_SLL:begin // 逻辑左移
            alu_res = alu_src1 << alu_src2[4:0];
        end
        `ALU_SRL:begin // 逻辑右移
            alu_res = alu_src1 >> alu_src2[4:0];
        end
        `ALU_SRA:begin // 算术右移
            alu_res = $signed(alu_src1) >>> alu_src2[4:0];
        end
        `ALU_SLT:begin // 带符号比较，若alu_src1 < alu_src2,则结果为1,否则为0
            alu_res = $signed(alu_src1) < $signed(alu_src2) ? `CPU_WIDTH'b1 : `CPU_WIDTH'b0;
            zero = (alu_res == `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_SLT_GTE:begin // 带符号比较，若alu_src1 >= alu_src2,则结果为1,否则为0
            alu_res = $signed(alu_src1) >= $signed(alu_src2) ? `CPU_WIDTH'b1 : `CPU_WIDTH'b0;
            zero = (alu_res == `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_SLTU:begin // 不带符号比较，若alu_src1 < alu_src2,则结果为1,否则为0
            alu_res = alu_src1 < alu_src2 ? `CPU_WIDTH'b1 : `CPU_WIDTH'b0;
            zero = (alu_res == `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_SLTU_GTE:begin // 不带符号比较，若alu_src1 >= alu_src2,则结果为1,否则为0
            alu_res = alu_src1 >= alu_src2 ? `CPU_WIDTH'b1 : `CPU_WIDTH'b0;
            zero = (alu_res == `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
    endcase
end
endmodule
