/* -------顶层模块-------- */

`include "defines.v"

module riscv (
    input                               clk,
    input                               rst_n
);

wire                         ena;
wire [`CPU_WIDTH-1:0]        curr_pc;    // current pc addr
wire [`CPU_WIDTH-1:0]        next_pc;    // next pc addr

wire                         branch;     // branch flag
wire                         zero;       // alu result is zero
wire                         jump;       // jump flag

wire [`CPU_WIDTH-1:0]        inst;       // instruction

wire                         reg_wen;    // register write enable
wire [`REG_ADDR_WIDTH-1:0]   reg_waddr;  // register write address
wire [`CPU_WIDTH-1:0]        reg_wdata;  // register write data
wire [`REGS_SRC_WIDTH-1:0]   regs_src_sel;
wire [`REG_ADDR_WIDTH-1:0]   reg1_raddr; // register 1 read address
wire [`REG_ADDR_WIDTH-1:0]   reg2_raddr; // register 2 read address
wire [`CPU_WIDTH-1:0]        reg1_rdata; // register 1 read data
wire [`CPU_WIDTH-1:0]        reg2_rdata; // register 2 read data

wire [`IMM_GEN_OP_WIDTH-1:0] imm_gen_op; // immediate extend opcode
wire [`CPU_WIDTH-1:0]        imm;        // immediate

wire [`ALU_OP_WIDTH-1:0]     alu_op;     // alu opcode
wire [`ALU_SRC_WIDTH-1:0]    alu_src_sel;// alu source select flag
wire [`CPU_WIDTH-1:0]        alu_src1;   // alu source 1
wire [`CPU_WIDTH-1:0]        alu_src2;   // alu source 2
wire [`CPU_WIDTH-1:0]        alu_res;    // alu result

wire [`MEM_ACCESS_SIZE_WIDTH-1:0]   mem_access_size; // 
wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   mem_access_type; //
wire                                mem_sign_ext;// memory sign extend
wire [`CPU_WIDTH-1:0]               mem_raddr;
wire [`CPU_WIDTH-1:0]               mem_waddr;
wire [`CPU_WIDTH-1:0]               mem_rdata;


pc_reg u_pc_reg_0(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .ena                            ( ena                           ),
    .next_pc_i                      ( next_pc                       ),
    .curr_pc_o                      ( curr_pc                       )
);

mux_pc u_mux_pc_0(
    .ena                            ( ena                           ),
    .branch                         ( branch                        ),
    .zero                           ( zero                          ),
    .jump                           ( jump                          ),
    .imm                            ( imm                           ),
    .curr_pc_i                      ( curr_pc                       ),
    .next_pc_o                      ( next_pc                       )
);


inst_mem u_inst_mem_0(
    .pc_addr_i                      ( curr_pc                       ),
    .inst_o                         ( inst                          ),
    .mem_raddr_i                    ( mem_raddr                     ),
    .mem_rdata_o                    ( mem_rdata                     ),
    .mem_access_size                ( mem_access_size               ),
    .mem_access_type                ( mem_access_type               ),
    .mem_wdata_i                    ( reg2_rdata                    ),
    .mem_waddr_i                    ( mem_waddr                     )
);


ctrl u_ctrl_0(
    .inst                           ( inst                          ),
    .branch                         ( branch                        ),
    .jump                           ( jump                          ),
    .reg_wen                        ( reg_wen                       ),
    .reg1_raddr                     ( reg1_raddr                    ),
    .reg2_raddr                     ( reg2_raddr                    ),
    .reg_waddr                      ( reg_waddr                     ),
    .regs_src_sel                   ( regs_src_sel                  ),
    .imm_gen_op                     ( imm_gen_op                    ),
    .alu_op                         ( alu_op                        ),
    .alu_src_sel                    ( alu_src_sel                   ),
    .mem_access_type                ( mem_access_type               ),
    .mem_access_size                ( mem_access_size               ),
    .mem_sign_ext                   ( mem_sign_ext                  )
);


regs u_regs_0(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .reg_wen                        ( reg_wen                       ),
    .reg_waddr                      ( reg_waddr                     ),
    .reg_wdata                      ( reg_wdata                     ),
    .reg1_raddr                     ( reg1_raddr                    ),
    .reg2_raddr                     ( reg2_raddr                    ),
    .reg1_rdata                     ( reg1_rdata                    ),
    .reg2_rdata                     ( reg2_rdata                    )
);

imm_gen u_imm_gen_0(
    .inst                           ( inst                          ),
    .imm_gen_op                     ( imm_gen_op                    ),
    .imm                            ( imm                           )
);

mux_alu u_mux_alu_0(
    .alu_src_sel                    ( alu_src_sel                   ),
    .reg1_rdata                     ( reg1_rdata                    ),
    .reg2_rdata                     ( reg2_rdata                    ),
    .imm                            ( imm                           ),
    .curr_pc                        ( curr_pc                       ),
    .alu_src1                       ( alu_src1                      ),
    .alu_src2                       ( alu_src2                      )
);

alu u_alu_0(
    .alu_op                         ( alu_op                        ),
    .alu_src1                       ( alu_src1                      ),
    .alu_src2                       ( alu_src2                      ),
    .zero                           ( zero                          ),
    .alu_res                        ( alu_res                       )
);

wb  u_wb_0 (
    .alu_res                        ( alu_res                       ),
    .mem_access_type                ( mem_access_type               ),
    .mem_access_size                ( mem_access_size               ),
    .mem_sign_ext                   ( mem_sign_ext                  ),
    .reg_wdata                      ( reg_wdata                     ),
    .mem_raddr_o                    ( mem_raddr                     ),
    .mem_waddr_o                    ( mem_waddr                     ),
    .mem_data_i                     ( mem_rdata                     )
  );

endmodule
