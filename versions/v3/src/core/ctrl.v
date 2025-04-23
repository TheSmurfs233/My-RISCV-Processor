/* -------译码控制模块-------- */
//负责根据当前指令（inst）解析并生成 控制信号，协调处理器各部件（如寄存器堆、ALU、立即数生成器等）的工作。

`include "defines.v"
module ctrl(
    input      [`CPU_WIDTH-1:0]        inst,       // 指令输入

    output reg                         branch,     // 分支标志
    output reg                         jump,       // 跳转标志

    output reg                         reg_wen,    // 寄存器写使能
    output reg [`REG_ADDR_WIDTH-1:0]   reg_waddr,  // 寄存器写地址
    output reg [`REGS_SRC_WIDTH-1:0]   regs_src_sel,// 寄存器写入源选择
    output reg [`REG_ADDR_WIDTH-1:0]   reg1_raddr, // 寄存器1读地址
    output reg [`REG_ADDR_WIDTH-1:0]   reg2_raddr, // 寄存器2读地址
    
    output reg [`IMM_GEN_OP_WIDTH-1:0] imm_gen_op, // 立即数扩展操作码

    output reg [`ALU_OP_WIDTH-1:0]     alu_op,     // alu操作码
    output reg [`ALU_SRC_WIDTH-1:0]    alu_src_sel,// alu操作源选择

    //内存访问控制信号
    output reg [`MEM_ACCESS_TYPE_WIDTH-1:0] mem_access_type,    // 内存访问类型
    output reg                              mem_sign_ext       // 内存加载符号扩展
);

// 指令解析
wire [`OPCODE_WIDTH-1:0] opcode = inst[`OPCODE_WIDTH-1:0];                          // 位置固定
wire [`FUNCT3_WIDTH-1:0] funct3 = inst[`FUNCT3_WIDTH+`FUNCT3_BASE-1:`FUNCT3_BASE];  // 位置固定            
wire [`FUNCT7_WIDTH-1:0] funct7 = inst[`FUNCT7_WIDTH+`FUNCT7_BASE-1:`FUNCT7_BASE];  // 位置固定            
wire [`REG_ADDR_WIDTH-1:0] rd   = inst[`REG_ADDR_WIDTH+`RD_BASE-1:`RD_BASE];        // 位置固定        
wire [`REG_ADDR_WIDTH-1:0] rs1  = inst[`REG_ADDR_WIDTH+`RS1_BASE-1:`RS1_BASE];      // 位置固定        
wire [`REG_ADDR_WIDTH-1:0] rs2  = inst[`REG_ADDR_WIDTH+`RS2_BASE-1:`RS2_BASE];      // 位置固定        


always @(*) begin
    //进行一个初始化操作，避免因为case语句覆盖不完全而产生的未赋值引起的问题
    branch      = 1'b0;
    jump        = 1'b0;
    reg_wen     = 1'b0;
    reg1_raddr  = `REG_ADDR_WIDTH'b0;
    reg2_raddr  = `REG_ADDR_WIDTH'b0;
    reg_waddr   = `REG_ADDR_WIDTH'b0;
    imm_gen_op  = `IMM_GEN_I;
    alu_op      = `ALU_AND;
    alu_src_sel = `ALU_SRC_REG;
    mem_access_type = `MEM_ACCESS_TYPE_NONE;
    mem_sign_ext = 1'b0;
    regs_src_sel = `REGS_SRC_ALU;
    case (opcode)
        `INST_TYPE_R: begin // R-type
            reg_wen     = 1'b1;
            reg1_raddr  = rs1;
            reg2_raddr  = rs2;
            reg_waddr   = rd;
            alu_src_sel = `ALU_SRC_REG;
            case (funct3)
                `INST_ADD_SUB: begin
                    alu_op = (funct7 == `FUNCT7_INST_A) ? `ALU_ADD : `ALU_SUB; // A:add B:sub 
                end
                `INST_AND: begin
                    alu_op = `ALU_AND;
                end
                `INST_OR: begin
                    alu_op = `ALU_OR;
                end
                `INST_XOR: begin
                    alu_op = `ALU_XOR;
                end
                `INST_SLL: begin
                    alu_op = `ALU_SLL;
                end
                `INST_SRL_SRA: begin
                    alu_op = (funct7 == `FUNCT7_INST_B) ? `ALU_SRA : `ALU_SRL;
                end
                `INST_SLT: begin
                    alu_op = `ALU_SLT;
                end
                `INST_SLTU: begin
                    alu_op = `ALU_SLTU;
                end
            endcase
        end
        `INST_TYPE_I: begin // I-type
            reg_wen     = 1'b1;
            reg1_raddr  = rs1;
            reg_waddr   = rd;
            alu_src_sel = `ALU_SRC_IMM;
            case (funct3)
                `INST_ADDI: begin
                    alu_op = `ALU_ADD; 
                end
                `INST_ANDI: begin
                    alu_op = `ALU_AND;
                end
                `INST_XORI: begin
                    alu_op = `ALU_XOR;
                end
                `INST_ORI: begin
                    alu_op = `ALU_OR;
                end
                `INST_SLLI: begin
                    alu_op = `ALU_SLL;
                end
                `INST_SRLI_SRAI: begin
                    alu_op = (funct7 == `FUNCT7_INST_B) ? `ALU_SRA : `ALU_SRL;
                end
                `INST_SLTI: begin
                    alu_op = `ALU_SLT;
                end
                `INST_SLTIU: begin
                    alu_op = `ALU_SLTU;
                end
            endcase
        end
        `INST_TYPE_IL: begin // I-type load（LB/LH/LW/LBU/LHU） op:0000011
            reg_wen     = 1'b1;
            reg1_raddr  = rs1;
            reg_waddr   = rd;
            imm_gen_op  = `IMM_GEN_I;
            alu_src_sel = `ALU_SRC_IMM;
            alu_op      = `ALU_ADD;
            regs_src_sel = `REGS_SRC_LS;//寄存器堆写入数据来自内存访问
            case (funct3)
                `INST_LB: begin // LB（funct3=3'b000）
                    mem_access_type = `MEM_ACCESS_TYPE_READ_BYTE;
                    mem_sign_ext = 1'b1;   // 符号扩展
                end
                `INST_LBU: begin // LBU（funct3=3'b100）
                    mem_access_type = `MEM_ACCESS_TYPE_READ_BYTE;
                    mem_sign_ext = 1'b0;   // 无符号扩展
                end
                `INST_LH: begin // LH（funct3=3'b001）
                    mem_access_type = `MEM_ACCESS_TYPE_READ_HALF;
                    mem_sign_ext = 1'b1;   // 符号扩展
                end
                `INST_LHU: begin // LHU（funct3=3'b101）
                    mem_access_type = `MEM_ACCESS_TYPE_READ_HALF;
                    mem_sign_ext = 1'b0;   // 无符号扩展
                end
                `INST_LW: begin // LW（funct3=3'b010）
                    mem_access_type = `MEM_ACCESS_TYPE_READ_WORD;
                    mem_sign_ext = 1'b1;   // 符号扩展
                end
        
                default: begin
                    // 非法指令处理（可选）
                end
            endcase
        end
        `INST_TYPE_S: begin // S-type   op:0100011  sb/sw/sh
            reg_wen     = 1'b0;
            reg1_raddr  = rs1;
            reg2_raddr  = rs2;
            reg_waddr   = rd;
            imm_gen_op  = `IMM_GEN_S;
            alu_src_sel = `ALU_SRC_IMM;
            alu_op      = `ALU_ADD;
            case (funct3)
                `INST_SB: begin
                    mem_access_type = `MEM_ACCESS_TYPE_WRITE_BYTE;
                end
                `INST_SH: begin
                    mem_access_type = `MEM_ACCESS_TYPE_WRITE_HALF;
                end
                `INST_SW: begin
                    mem_access_type = `MEM_ACCESS_TYPE_WRITE_WORD;
                end
            endcase
        end
        `INST_TYPE_B: begin // B-type
            reg1_raddr  = rs1;
            reg2_raddr  = rs2;
            imm_gen_op  = `IMM_GEN_B;
            alu_src_sel = `ALU_SRC_REG;
            case (funct3)
                `INST_BNE: begin
                    branch     = 1'b1;
                    alu_op     = `ALU_SUB;
                end
                `INST_BEQ: begin
                    branch     = 1'b1;
                    alu_op     = `ALU_SUB_NE;
                end
                `INST_BLT: begin
                    branch     = 1'b1;
                    alu_op     = `ALU_SLT;
                end
                `INST_BGE: begin
                    branch     = 1'b1;
                    alu_op     = `ALU_SLT_GTE;
                end
                `INST_BLTU: begin
                    branch     = 1'b1;
                    alu_op     = `ALU_SLTU;
                end
                `INST_BGEU: begin
                    branch     = 1'b1;
                    alu_op     = `ALU_SLTU_GTE;
                end
            endcase
        end
        `INST_JAL: begin // only jal
            jump        = 1'b1;
            reg_wen     = 1'b1;
            reg_waddr   = rd;
            imm_gen_op  = `IMM_GEN_J;
            alu_op      = `ALU_ADD;
            alu_src_sel = `ALU_SRC_FOUR_PC; //pc + 4
        end
        `INST_LUI: begin // only lui
            reg_wen     = 1'b1;
            reg1_raddr  = `REG_ADDR_WIDTH'b0; // x0 = 0
            reg_waddr   = rd;
            imm_gen_op  = `IMM_GEN_U;
            alu_op      = `ALU_ADD;
            alu_src_sel = `ALU_SRC_IMM; // x0 + imm
        end
        `INST_AUIPC: begin // only auipc
            reg_wen     = 1'b1;
            reg1_raddr  = `REG_ADDR_WIDTH'b0; // x0 = 0
            reg_waddr   = rd;
            imm_gen_op  = `IMM_GEN_U;
            alu_op      = `ALU_ADD;
            alu_src_sel = `ALU_SRC_IMM_PC; // imm + pc
        end
    endcase 
end

endmodule
