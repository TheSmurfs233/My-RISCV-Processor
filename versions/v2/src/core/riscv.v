/* -------顶层模块-------- */

`include "defines.v"

module riscv (
    input                               clk,
    input                               rst_n,
    output wire [1:0]                   led 
);

wire [`CPU_WIDTH-1:0]      test_reg1;
wire [`CPU_WIDTH-1:0]      test_reg2;

assign led={test_reg2[0],test_reg1[0]};

wire                         ena;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        curr_pc;    // current pc addr
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        next_pc;    // next pc addr
(*mark_debug="true"*)wire                         branch;     // branch flag
(*mark_debug="true"*)wire                         zero;       // alu result is zero
(*mark_debug="true"*)wire                         jump;       // jump flag
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        inst;       // instruction
(*mark_debug="true"*)wire                         reg_wen;    // register write enable
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]   reg_waddr;  // register write address
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        reg_wdata;  // register write data
(*mark_debug="true"*)wire [`REGS_SRC_WIDTH-1:0]   regs_src_sel;
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]   reg1_raddr; // register 1 read address
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]   reg2_raddr; // register 2 read address
wire [`CPU_WIDTH-1:0]        reg1_rdata; // register 1 read data
wire [`CPU_WIDTH-1:0]        reg2_rdata; // register 2 read data
(*mark_debug="true"*)
(*mark_debug="true"*)wire [`IMM_GEN_OP_WIDTH-1:0] imm_gen_op; // immediate extend opcode
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        imm;        // immediate

(*mark_debug="true"*)wire [`ALU_OP_WIDTH-1:0]     alu_op;     // alu opcode
wire [`ALU_SRC_WIDTH-1:0]    alu_src_sel;// alu source select flag
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        alu_src1;   // alu source 1
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        alu_src2;   // alu source 2
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        alu_res;    // alu result


wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   mem_access_type; //
wire                                mem_sign_ext;// memory sign extend
// wire [`CPU_WIDTH-1:0]               mem_raddr; // memory read address
wire [`CPU_WIDTH-1:0]               mem_rdata; // memory read data

// wire [`CPU_WIDTH-1:0]        mem_wdata;  // memory write data
// wire [`CPU_WIDTH-1:0]        mem_waddr;  // memory write address

/*------ 冒险变量定义--------*/
// reg rs1_forward_mem,rs2_forward_mem,rs1_forward_wb,rs2_forward_wb;//数据旁路标记,代表两个源寄存器是否需要数据旁路,需要连续看两条指令
(*mark_debug="true"*)wire control_hazard;//控制冒险标记,代表是否存在控制流冒险
(*mark_debug="true"*)wire pipe_flush;
/*--------五级流水线寄存---------*/

(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        if_id_inst;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        if_id_curr_pc;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]        if_id_next_pc;
(*mark_debug="true"*)wire                         if_id_control_hazard;
if_id  u_if_id_0 (
    .clk(clk),
    .pipeline_flush(pipe_flush),
    .inst(inst),
    .curr_pc(curr_pc),
    .next_pc(next_pc),
    .control_hazard(control_hazard),

    .if_id_inst(if_id_inst),
    .if_id_curr_pc(if_id_curr_pc),
    .if_id_next_pc(if_id_next_pc),
    .if_id_control_hazard(if_id_control_hazard)
);


(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               id_ex_inst;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               id_ex_curr_pc;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               id_ex_next_pc;
(*mark_debug="true"*)wire                                id_ex_branch;
(*mark_debug="true"*)wire                                id_ex_jump;
(*mark_debug="true"*)wire                                id_ex_reg_wen;
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]          id_ex_reg_waddr;
(*mark_debug="true"*)wire [`REGS_SRC_WIDTH-1:0]          id_ex_regs_src_sel;
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]          id_ex_reg1_raddr;
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]          id_ex_reg2_raddr;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               id_ex_reg1_rdata;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               id_ex_reg2_rdata;
(*mark_debug="true"*)wire [`ALU_OP_WIDTH-1:0]            id_ex_alu_op;
(*mark_debug="true"*)wire [`ALU_SRC_WIDTH-1:0]           id_ex_alu_src_sel;
(*mark_debug="true"*)wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   id_ex_mem_access_type;
(*mark_debug="true"*)wire                                id_ex_mem_sign_ext;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               id_ex_imm;
(*mark_debug="true"*)wire                                id_ex_control_hazard;


(*mark_debug="true"*)wire [1:0]  forward_to_alu;
(*mark_debug="true"*)wire [1:0]  id_ex_forward_to_alu;


id_ex  u_id_ex_0 (
    .clk(clk),
    .pipeline_flush(pipe_flush),

    .if_id_curr_pc(if_id_curr_pc),
    .if_id_next_pc(if_id_next_pc),
    .if_id_inst(if_id_inst),
    .branch(branch),
    .jump(jump),
    .reg_wen(reg_wen),
    .reg_waddr(reg_waddr),
    .regs_src_sel(regs_src_sel),
    .reg1_raddr(reg1_raddr),
    .reg2_raddr(reg2_raddr),
    .reg1_rdata(reg1_rdata),
    .reg2_rdata(reg2_rdata),
    .alu_op(alu_op),
    .alu_src_sel(alu_src_sel),
    .mem_access_type(mem_access_type),
    .mem_sign_ext(mem_sign_ext),
    .imm(imm),
    .if_id_control_hazard(if_id_control_hazard),
    .forward_to_alu(forward_to_alu),

    .id_ex_curr_pc(id_ex_curr_pc),
    .id_ex_next_pc(id_ex_next_pc),
    .id_ex_inst(id_ex_inst),
    .id_ex_branch(id_ex_branch),
    .id_ex_jump(id_ex_jump),
    .id_ex_reg_wen(id_ex_reg_wen),
    .id_ex_reg_waddr(id_ex_reg_waddr),
    .id_ex_regs_src_sel(id_ex_regs_src_sel),
    .id_ex_reg1_raddr(id_ex_reg1_raddr),
    .id_ex_reg2_raddr(id_ex_reg2_raddr),
    .id_ex_reg1_rdata(id_ex_reg1_rdata),
    .id_ex_reg2_rdata(id_ex_reg2_rdata),
    .id_ex_alu_op(id_ex_alu_op),
    .id_ex_alu_src_sel(id_ex_alu_src_sel),
    .id_ex_mem_access_type(id_ex_mem_access_type),
    .id_ex_mem_sign_ext(id_ex_mem_sign_ext),
    .id_ex_imm(id_ex_imm),
    .id_ex_control_hazard(id_ex_control_hazard),
    .id_ex_forward_to_alu(id_ex_forward_to_alu)

);

(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               ex_mem_inst;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               ex_mem_curr_pc;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               ex_mem_next_pc;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               ex_mem_alu_res;
(*mark_debug="true"*)wire                                ex_mem_reg_wen;
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]          ex_mem_reg_waddr;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               ex_mem_reg2_rdata;
(*mark_debug="true"*)wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   ex_mem_mem_access_type;
(*mark_debug="true"*)wire                                ex_mem_mem_sign_ext;
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]          ex_mem_reg1_raddr;
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]          ex_mem_reg2_raddr;


ex_mem  u_ex_mem_0 (
    .clk(clk),
    .id_ex_inst(id_ex_inst),
    .id_ex_curr_pc(id_ex_curr_pc),
    .id_ex_next_pc(id_ex_next_pc),
    .alu_res(alu_res),
    .id_ex_reg_wen(id_ex_reg_wen),
    .id_ex_reg_waddr(id_ex_reg_waddr),
    .id_ex_reg2_rdata(id_ex_reg2_rdata),
    .id_ex_mem_access_type(id_ex_mem_access_type),
    .id_ex_mem_sign_ext(id_ex_mem_sign_ext),
    .id_ex_reg1_raddr(id_ex_reg1_raddr),
    .id_ex_reg2_raddr(id_ex_reg2_raddr),
    
    .ex_mem_inst(ex_mem_inst),
    .ex_mem_curr_pc(ex_mem_curr_pc),
    .ex_mem_next_pc(ex_mem_next_pc),
    .ex_mem_alu_res(ex_mem_alu_res),
    .ex_mem_reg_wen(ex_mem_reg_wen),
    .ex_mem_reg_waddr(ex_mem_reg_waddr),
    .ex_mem_reg2_rdata(ex_mem_reg2_rdata),
    .ex_mem_mem_access_type(ex_mem_mem_access_type),
    .ex_mem_mem_sign_ext(ex_mem_mem_sign_ext),
    .ex_mem_reg1_raddr(ex_mem_reg1_raddr),
    .ex_mem_reg2_raddr(ex_mem_reg2_raddr)
);


(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               mem_wb_inst;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               mem_wb_curr_pc;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               mem_wb_next_pc;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               mem_wb_mem_rdata;
(*mark_debug="true"*)wire [`CPU_WIDTH-1:0]               mem_wb_alu_res;
(*mark_debug="true"*)wire                                mem_wb_reg_wen;
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]          mem_wb_reg_waddr;
(*mark_debug="true"*)wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   mem_wb_mem_access_type;
(*mark_debug="true"*)wire                                mem_wb_mem_sign_ext;
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]          mem_wb_reg1_raddr;
(*mark_debug="true"*)wire [`REG_ADDR_WIDTH-1:0]          mem_wb_reg2_raddr;

mem_wb  u_mem_wb_0 (
    .clk(clk),
    .ex_mem_inst(ex_mem_inst),
    .ex_mem_curr_pc(ex_mem_curr_pc),
    .ex_mem_next_pc(ex_mem_next_pc),
    .ex_mem_alu_res(ex_mem_alu_res),
    .mem_rdata(mem_rdata),
    .ex_mem_reg_wen(ex_mem_reg_wen),
    .ex_mem_reg_waddr(ex_mem_reg_waddr),
    .ex_mem_mem_access_type(ex_mem_mem_access_type),
    .ex_mem_mem_sign_ext(ex_mem_mem_sign_ext),
    .ex_mem_reg1_raddr(ex_mem_reg1_raddr),
    .ex_mem_reg2_raddr(ex_mem_reg2_raddr),

    .mem_wb_inst(mem_wb_inst),
    .mem_wb_curr_pc(mem_wb_curr_pc),
    .mem_wb_next_pc(mem_wb_next_pc),
    .mem_wb_mem_rdata(mem_wb_mem_rdata),
    .mem_wb_alu_res(mem_wb_alu_res),
    .mem_wb_reg_wen(mem_wb_reg_wen),
    .mem_wb_reg_waddr(mem_wb_reg_waddr),
    .mem_wb_mem_access_type(mem_wb_mem_access_type),
    .mem_wb_mem_sign_ext(mem_wb_mem_sign_ext),
    .mem_wb_reg1_raddr(mem_wb_reg1_raddr),
    .mem_wb_reg2_raddr(mem_wb_reg2_raddr)
);
/*-----------------*/

/*-------PC寄存器-------*/
pc_reg u_pc_reg_0(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .rst_pc                         ( `RESET_PC_VALUE               ),
    .ena                            ( ena                           ),
    .next_pc_i                      ( next_pc                       ),
    .curr_pc_o                      ( curr_pc                       )
);



mux_pc u_mux_pc_0(
    .ena                            ( ena                           ),
    .branch                         ( id_ex_branch                  ),
    .zero                           ( zero                          ),
    .jump                           ( id_ex_jump                    ),
    .imm                            ( id_ex_imm                     ),
    .curr_pc_i                      ( curr_pc                       ),
    .next_pc_o                      ( next_pc                       ),

    .inst_i                         ( inst                          ),
    .control_hazard                 ( control_hazard                ),
    .pipe_flush                     ( pipe_flush                    ),
    .id_ex_control_hazard           ( id_ex_control_hazard          )
);

inst_mem u_inst_mem_0(
    .pc_addr_i                      ( curr_pc                       ),
    .inst_o                         ( inst                          )
);


ctrl u_ctrl_0(
    .inst                           ( if_id_inst                    ),
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
    .mem_sign_ext                   ( mem_sign_ext                  )
);


regs u_regs_0(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .reg_wen                        ( mem_wb_reg_wen                ),
    .reg_waddr                      ( mem_wb_reg_waddr              ),
    .reg_wdata                      ( reg_wdata                     ),
    .reg1_raddr                     ( reg1_raddr                    ),
    .reg2_raddr                     ( reg2_raddr                    ),
    .reg1_rdata                     ( reg1_rdata                    ),
    .reg2_rdata                     ( reg2_rdata                    ),

    .ex_forward_addr                ( id_ex_reg_waddr               ),
    .mem_forward_addr               ( ex_mem_reg_waddr              ),
    .wb_forward_addr                ( mem_wb_reg_waddr              ),
    //这三个接口处理非LOAD指令的写前冲突，将alu运算结果前递到寄存器堆
    .ex_forward_data                ( alu_res                       ),//SH指令后紧接着LH指令，前递数据未必是正确的，如果上一条指令是SH指令，则前递数据不是alu结果，因为计算的是地址，需要判断是否寄存器写使能
    .mem_forward_data               ( ex_mem_alu_res                ),
    .wb_forward_data                ( mem_wb_alu_res                ),

    //这两个接口处理LOAD指令后紧接着的读寄存器的写前冲突，将mem_rdata前递到alu
    .id_ex_mem_access_type          ( id_ex_mem_access_type         ),
    .forward_to_alu                 ( forward_to_alu                ),

    //这四个接口处理LOAD指令的写前冲突，将mem_rdata前递到寄存器堆读数据
    .ex_mem_mem_access_type         ( ex_mem_mem_access_type        ),//来自访存阶段
    .ex_mem_mem_sign_ext            ( ex_mem_mem_sign_ext           ),
    .mem_forward_data_mem_rdata     ( mem_rdata                     ),//访存_前递_数据_存储器读数据
    .mem_wb_mem_access_type         ( mem_wb_mem_access_type        ),//来自写回阶段
    .mem_wb_mem_sign_ext            ( mem_wb_mem_sign_ext           ),
    .wb_forward_data_mem_rdata      ( mem_wb_mem_rdata              ),//来自写回阶段

    //测试用
    .test_reg1                      ( test_reg1                     ),
    .test_reg2                      ( test_reg2                     )
);

imm_gen u_imm_gen_0(
    .inst                           ( if_id_inst                    ),
    .imm_gen_op                     ( imm_gen_op                    ),
    .imm                            ( imm                           )
);

mux_alu u_mux_alu_0(
    .alu_src_sel                    ( id_ex_alu_src_sel             ),
    .reg1_rdata                     ( id_ex_reg1_rdata              ),
    .reg2_rdata                     ( id_ex_reg2_rdata              ),
    .imm                            ( id_ex_imm                     ),
    .curr_pc                        ( id_ex_curr_pc                 ),
    .alu_src1                       ( alu_src1                      ),
    .alu_src2                       ( alu_src2                      ),
    .forward_to_alu                 ( id_ex_forward_to_alu          ),
    .mem_forward_data               ( mem_rdata                     ),
    .ex_mem_mem_sign_ext            ( ex_mem_mem_sign_ext           ),
    .ex_mem_mem_access_type         ( ex_mem_mem_access_type        ),
    .ex_mem_alu_res                 ( ex_mem_alu_res                )
);

alu u_alu_0(
    .alu_op                         ( id_ex_alu_op                  ),
    .alu_src1                       ( alu_src1                      ),
    .alu_src2                       ( alu_src2                      ),
    .zero                           ( zero                          ),
    .alu_res                        ( alu_res                       )
);


data_mem  u_data_mem_0 (
    .clk                            ( clk                           ),
    .mem_raddr_i                    ( ex_mem_alu_res                ),
    .mem_rdata_o                    ( mem_rdata                     ),

    .mem_access_type                ( ex_mem_mem_access_type        ),
    .mem_wdata_i                    ( ex_mem_reg2_rdata             ),
    .mem_waddr_i                    ( ex_mem_alu_res                )   
);

wb u_wb_0(
    .alu_res                        ( mem_wb_alu_res                ),
    .mem_access_type                ( mem_wb_mem_access_type        ),
    .mem_sign_ext                   ( mem_wb_mem_sign_ext           ),
    .mem_raddr_o                    (                               ),
    .mem_rdata_i                    ( mem_wb_mem_rdata              ),
    .reg_wdata                      ( reg_wdata                     )
);

/*------数据冒险-----*/
//数据前递


endmodule
