
`define SIM_CLK_PERIOD          20      //时钟周期20ns

// Prosessor     
`define CPU_WIDTH               32      //CPU数据总线宽度

// pc复位值
`define RESET_PC_VALUE          32'h00000000 //重置地址

// register 
`define REG_DATA_DEPTH          32      //寄存器堆的深度
`define REG_ADDR_WIDTH          5       //寄存器堆的地址宽度 2^5 = 32

// instruction/data memory
`define INST_MEM_ADDR_WIDTH     12      //指令存储器地址宽度
`define DATA_MEM_ADDR_WIDTH     12      //指令存储器地址宽度
`define INST_MEM_ADDR_DEPTH     1024    //指令存储器地址深度
`define DATA_MEM_ADDR_DEPTH     1024    //数据存储器地址深度 
  
// immediate generate
`define INST_I_IMM_WIDTH 12
`define INST_S_IMM_WIDTH 12
`define INST_B_IMM_WIDTH 13
`define INST_U_IMM_WIDTH 32
`define INST_J_IMM_WIDTH 21

// instruction bits select
`define FUNCT3_BASE 12
`define FUNCT7_BASE 25
`define RD_BASE     7
`define RS1_BASE    15
`define RS2_BASE    20

// opcode
`define OPCODE_WIDTH 7
`define INST_TYPE_R  `OPCODE_WIDTH'b0110011 // add/sub/xor/or/and/sll/srl/sra/slt/sltu
`define INST_TYPE_I  `OPCODE_WIDTH'b0010011 // addi/xori/ori/andi/slli/srli/srai/slti/sltiu
`define INST_TYPE_IL `OPCODE_WIDTH'b0000011 // lb/lh/lw/lbu/lhu
`define INST_TYPE_S  `OPCODE_WIDTH'b0100011 // sb/sh/sw
`define INST_TYPE_B  `OPCODE_WIDTH'b1100011 // beq/bne/blt/bge/bltu/bgeu
`define INST_JAL     `OPCODE_WIDTH'b1101111 // jal
`define INST_JALR    `OPCODE_WIDTH'b1100111 // jalr
`define INST_LUI     `OPCODE_WIDTH'b0110111 // lui
`define INST_AUIPC   `OPCODE_WIDTH'b0010111 // auipc
`define INST_TYPE_IE `OPCODE_WIDTH'b1110011 // ecall/ebreak

// funct3
// R-type
`define FUNCT3_WIDTH 3
`define INST_ADD_SUB   `FUNCT3_WIDTH'h0 
`define INST_XOR       `FUNCT3_WIDTH'h4
`define INST_OR        `FUNCT3_WIDTH'h6
`define INST_AND       `FUNCT3_WIDTH'h7
`define INST_SLL       `FUNCT3_WIDTH'h1
`define INST_SRL_SRA   `FUNCT3_WIDTH'h5
`define INST_SLT       `FUNCT3_WIDTH'h2
`define INST_SLTU      `FUNCT3_WIDTH'h3
// I-type 
`define INST_ADDI      `FUNCT3_WIDTH'h0
`define INST_XORI      `FUNCT3_WIDTH'h4
`define INST_ORI       `FUNCT3_WIDTH'h6
`define INST_ANDI      `FUNCT3_WIDTH'h7
`define INST_SLLI      `FUNCT3_WIDTH'h1
`define INST_SRLI_SRAI `FUNCT3_WIDTH'h5 
`define INST_SLTI      `FUNCT3_WIDTH'h2
`define INST_SLTIU     `FUNCT3_WIDTH'h3
// I-type load
`define INST_LB        `FUNCT3_WIDTH'h0
`define INST_LH        `FUNCT3_WIDTH'h1
`define INST_LW        `FUNCT3_WIDTH'h2
`define INST_LBU       `FUNCT3_WIDTH'h4
`define INST_LHU       `FUNCT3_WIDTH'h5
// S-type
`define INST_SB        `FUNCT3_WIDTH'h0
`define INST_SH        `FUNCT3_WIDTH'h1
`define INST_SW        `FUNCT3_WIDTH'h2
// B-type
`define INST_BEQ       `FUNCT3_WIDTH'h0
`define INST_BNE       `FUNCT3_WIDTH'h1
`define INST_BLT       `FUNCT3_WIDTH'h4
`define INST_BGE       `FUNCT3_WIDTH'h5
`define INST_BLTU      `FUNCT3_WIDTH'h6
`define INST_BGEU      `FUNCT3_WIDTH'h7
// I-type environment
`define INST_ECALL     `FUNCT3_WIDTH'h0
`define INST_EBREAK    `FUNCT3_WIDTH'h0

// funct7
`define FUNCT7_WIDTH 7
`define FUNCT7_INST_A  `FUNCT7_WIDTH'h00
`define FUNCT7_INST_B  `FUNCT7_WIDTH'h20


// ALU opcode
`define ALU_OP_WIDTH 5
`define ALU_AND  `ALU_OP_WIDTH'b00000
`define ALU_OR   `ALU_OP_WIDTH'b00001
`define ALU_XOR  `ALU_OP_WIDTH'b00010
`define ALU_ADD  `ALU_OP_WIDTH'b00011
`define ALU_SUB  `ALU_OP_WIDTH'b00100
`define ALU_SLL  `ALU_OP_WIDTH'b00101 // shift left logical
`define ALU_SRL  `ALU_OP_WIDTH'b00110 // shift right logical
`define ALU_SRA  `ALU_OP_WIDTH'b00111 // shift right arith 
`define ALU_SLT  `ALU_OP_WIDTH'b01000 // set less than  
`define ALU_SLTU `ALU_OP_WIDTH'b01001 // set less than (unsigned) 
`define ALU_BLT  `ALU_OP_WIDTH'b01010 // branch less than
`define ALU_BLTU `ALU_OP_WIDTH'b01011 // branch less than (unsigned)
`define ALU_JAL  `ALU_OP_WIDTH'b01100  
`define ALU_JALR `ALU_OP_WIDTH'b01101  
`define ALU_SUB_NE  `ALU_OP_WIDTH'b01110 // sub not equal
`define ALU_SLT_GTE  `ALU_OP_WIDTH'b01111 // 
`define ALU_SLTU_GTE  `ALU_OP_WIDTH'b10000 // 

// ALU select soure
`define ALU_SRC_WIDTH 2
`define ALU_SRC_REG     `ALU_SRC_WIDTH'b00 // src1 = reg1, src2 = reg2
`define ALU_SRC_IMM     `ALU_SRC_WIDTH'b01 // src1 = reg1, src2 = imm
`define ALU_SRC_FOUR_PC `ALU_SRC_WIDTH'b10 // src1 = 4,    src2 = pc
`define ALU_SRC_IMM_PC  `ALU_SRC_WIDTH'b11 // src1 = imm,  src2 = pc

// IMM GEN opcode
`define IMM_GEN_OP_WIDTH 3
`define IMM_GEN_I `IMM_GEN_OP_WIDTH'b000 
`define IMM_GEN_S `IMM_GEN_OP_WIDTH'b001
`define IMM_GEN_B `IMM_GEN_OP_WIDTH'b010
`define IMM_GEN_J `IMM_GEN_OP_WIDTH'b011
`define IMM_GEN_U `IMM_GEN_OP_WIDTH'b100

//REGS_SRC opcode
`define REGS_SRC_WIDTH 2
`define REGS_SRC_LS `REGS_SRC_WIDTH'b00
`define REGS_SRC_ALU `REGS_SRC_WIDTH'b01


//MEM ACCESS opcode
`define MEM_ACCESS_TYPE_WIDTH 3
`define MEM_ACCESS_TYPE_NONE        `MEM_ACCESS_TYPE_WIDTH'b000
`define MEM_ACCESS_TYPE_READ_BYTE   `MEM_ACCESS_TYPE_WIDTH'b001
`define MEM_ACCESS_TYPE_READ_HALF   `MEM_ACCESS_TYPE_WIDTH'b010
`define MEM_ACCESS_TYPE_READ_WORD   `MEM_ACCESS_TYPE_WIDTH'b011

`define MEM_ACCESS_TYPE_WRITE_BYTE  `MEM_ACCESS_TYPE_WIDTH'b100
`define MEM_ACCESS_TYPE_WRITE_HALF  `MEM_ACCESS_TYPE_WIDTH'b101
`define MEM_ACCESS_TYPE_WRITE_WORD  `MEM_ACCESS_TYPE_WIDTH'b110