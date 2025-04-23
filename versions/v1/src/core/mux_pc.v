/* ------- PC多路选择器模块 -------- */
//用于根据不同的控制信号（分支、跳转等）决定下一条指令的地址（next_pc_o）
`include "defines.v"

module mux_pc (
    input  wire                     ena         ,   //模块使能信号。ena=1 时更新 PC，否则保持当前 PC
    input  wire                     branch      ,   //分支指令标志（如 beq, bne）
    input  wire                     zero        ,   //ALU 比较结果（通常用于分支条件判断，如 rs1 == rs2）
    input  wire                     jump        ,   //无条件跳转指令标志（如 jal, jalr）
    input  wire [`CPU_WIDTH - 1:0]  imm         ,   //符号扩展后的立即数偏移量（通常为指令中的偏移字段）
    input  wire [`CPU_WIDTH - 1:0]  curr_pc_i   ,   //当前指令地址（即当前 PC 值）
    output reg  [`CPU_WIDTH - 1:0]  next_pc_o       //计算出的下一条指令地址
);
    
always @(*) begin
    if (!ena) begin
        next_pc_o = curr_pc_i;
    end
    else if(branch && !zero) begin  // bne分支指令,zero为0时跳转
        next_pc_o = curr_pc_i + imm;
    end
    else if(jump) begin     // jal跳转指令
        next_pc_o = curr_pc_i + imm;
    end
    else begin
        next_pc_o = curr_pc_i + `CPU_WIDTH'h4; // 默认情况，下一条指令地址为当前指令地址加4
    end
end
endmodule
