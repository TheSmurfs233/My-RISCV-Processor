/* ------- PC多路选择器模块 -------- */
//用于根据不同的控制信号（分支、跳转等）决定下一条指令的地址（next_pc_o）
`include "defines.v"

module mux_pc (
    // input  wire                     rst_n       ,   //异步复位信号
    input  wire                     ena         ,   //模块使能信号。ena=1 时更新 PC，否则保持当前 PC
    input  wire                     branch      ,   //分支指令标志（如 beq, bne）
    input  wire                     zero        ,   //ALU 比较结果（通常用于分支条件判断，如 rs1 == rs2）
    input  wire                     jump        ,   //无条件跳转指令标志（如 jal, jalr）
    input  wire [`CPU_WIDTH - 1:0]  imm         ,   //符号扩展后的立即数偏移量（通常为指令中的偏移字段）
    input  wire [`CPU_WIDTH - 1:0]  curr_pc_i   ,   //当前指令地址（即当前 PC 值）
    output reg  [`CPU_WIDTH - 1:0]  next_pc_o   ,   //计算出的下一条指令地址

    input  wire [`CPU_WIDTH - 1:0]  inst_i,
    
    output reg                      control_hazard,  
    output reg                      pipe_flush  , 
    input  wire                     id_ex_control_hazard  // 控制冒险标志
);


// always @(*) begin
//     if (!ena) begin
//         next_pc_o = curr_pc_i;
//     end
//     else if(branch && !zero) begin  // bne分支指令,zero为0时跳转
//         next_pc_o = curr_pc_i + imm;
//     end
//     else if(jump) begin     // jal跳转指令
//         next_pc_o = curr_pc_i + imm;
//     end
//     else begin
//         next_pc_o = curr_pc_i + `CPU_WIDTH'h4; // 默认情况，下一条指令地址为当前指令地址加4
//     end
// end

`define INST_TYPE_B  `OPCODE_WIDTH'b1100011 // beq/bne/blt/bge/bltu/bgeu
`define INST_JAL     `OPCODE_WIDTH'b1101111 // jal
`define INST_JALR    `OPCODE_WIDTH'b1100111 // jalr
// reg                              control_hazard;      // 控制冒险标志
reg                              fetch_stop;           // 取指停止标志
always @(*) begin
    if (inst_i[6:0] == `INST_TYPE_B) begin
        // 分支跳转指令，进行静态预测， 向后统一预测为跳转，向前统一预测为不跳转
        fetch_stop = inst_i[31];
        // 如果预测不跳转，则设置冒险标记
        control_hazard = ~(inst_i[31]);
    end
    else if(inst_i[6:0] == `INST_JAL || inst_i[6:0] == `INST_JALR) begin
        fetch_stop = 1'b1; // 等待跳转
        control_hazard = 1'b0;
    end
    else begin
        fetch_stop = 1'b0;
        control_hazard = 1'b0;
    end
end
always @(*) begin
    if (!ena) begin
        next_pc_o = curr_pc_i;
    end
    else if(branch && !zero && id_ex_control_hazard) begin  // bne分支指令,预测失败，zero为0时跳转
        next_pc_o = curr_pc_i + imm - `CPU_WIDTH'h8;
        pipe_flush = 1'b1;
    end
    else if(jump) begin     // jal跳转指令
        next_pc_o = curr_pc_i + imm - `CPU_WIDTH'h8;
        pipe_flush = 1'b1;
    end
    else begin
        next_pc_o = curr_pc_i + `CPU_WIDTH'h4; // 默认情况，下一条指令地址为当前指令地址加4
        pipe_flush = 1'b0;
    end
end
endmodule
