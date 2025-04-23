/* -------顶层模块-------- */

`include "defines.v"

module riscv (
    input   wire                                clk,
    input   wire                                rst_n,

    //总线接口
    output  wire [`CPU_WIDTH - 1:0]             sys_bus_addr_o ,       // 地址总线
    output  wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   sys_bus_access_type,   // 控制总线_访问类型
    input   wire [`CPU_WIDTH - 1:0]             sys_bus_rdata_i   ,    // 数据总线_读数据输入
    output  reg  [`CPU_WIDTH - 1:0]             sys_bus_wdata_o   ,    // 数据总线_写数据输出
    //测试led
    output  wire [1:0]                          led 
);

wire [`CPU_WIDTH-1:0]      test_reg1;
wire [`CPU_WIDTH-1:0]      test_reg2;

assign led={test_reg2[0],test_reg1[0]};

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
wire alu_pipestall;

wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   mem_access_type; //
wire                                mem_sign_ext;// memory sign extend
// wire [`CPU_WIDTH-1:0]               mem_raddr; // memory read address
wire [`CPU_WIDTH-1:0]               mem_rdata; // memory read data

// wire [`CPU_WIDTH-1:0]        mem_wdata;  // memory write data
// wire [`CPU_WIDTH-1:0]        mem_waddr;  // memory write address

/*------ 冒险变量定义--------*/
// reg rs1_forward_mem,rs2_forward_mem,rs1_forward_wb,rs2_forward_wb;//数据旁路标记,代表两个源寄存器是否需要数据旁路,需要连续看两条指令
wire control_hazard;//控制冒险标记,代表是否存在控制流冒险
wire pipe_flush;
/*--------五级流水线寄存---------*/

wire     pipeline_stall;    //全局流水线暂停信号
assign  pipeline_stall = alu_pipestall;

wire [`CPU_WIDTH-1:0]        if_id_inst;
wire [`CPU_WIDTH-1:0]        if_id_curr_pc;
wire [`CPU_WIDTH-1:0]        if_id_next_pc;
wire                         if_id_control_hazard;
if_id  u_if_id_0 (
    .clk(clk),
    .pipeline_flush(pipe_flush),
    .pipeline_stall(pipeline_stall),

    .inst(inst),
    .curr_pc(curr_pc),
    .next_pc(next_pc),
    .control_hazard(control_hazard),

    .if_id_inst(if_id_inst),
    .if_id_curr_pc(if_id_curr_pc),
    .if_id_next_pc(if_id_next_pc),
    .if_id_control_hazard(if_id_control_hazard)
);


wire [`CPU_WIDTH-1:0]               id_ex_inst;
wire [`CPU_WIDTH-1:0]               id_ex_curr_pc;
wire [`CPU_WIDTH-1:0]               id_ex_next_pc;
wire                                id_ex_branch;
wire                                id_ex_jump;
wire                                id_ex_reg_wen;
wire [`REG_ADDR_WIDTH-1:0]          id_ex_reg_waddr;
wire [`REGS_SRC_WIDTH-1:0]          id_ex_regs_src_sel;
wire [`REG_ADDR_WIDTH-1:0]          id_ex_reg1_raddr;
wire [`REG_ADDR_WIDTH-1:0]          id_ex_reg2_raddr;
wire [`CPU_WIDTH-1:0]               id_ex_reg1_rdata;
wire [`CPU_WIDTH-1:0]               id_ex_reg2_rdata;
wire [`ALU_OP_WIDTH-1:0]            id_ex_alu_op;
wire [`ALU_SRC_WIDTH-1:0]           id_ex_alu_src_sel;
wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   id_ex_mem_access_type;
wire                                id_ex_mem_sign_ext;
wire [`CPU_WIDTH-1:0]               id_ex_imm;
wire                                id_ex_control_hazard;


wire [1:0]  forward_to_alu;
wire [1:0]  id_ex_forward_to_alu;


id_ex  u_id_ex_0 (
    .clk(clk),
    .pipeline_flush(pipe_flush),
    .pipeline_stall(pipeline_stall),

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

wire [`CPU_WIDTH-1:0]               ex_mem_inst;
wire [`CPU_WIDTH-1:0]               ex_mem_curr_pc;
wire [`CPU_WIDTH-1:0]               ex_mem_next_pc;
wire [`CPU_WIDTH-1:0]               ex_mem_alu_res;
wire                                ex_mem_reg_wen;
wire [`REG_ADDR_WIDTH-1:0]          ex_mem_reg_waddr;
wire [`CPU_WIDTH-1:0]               ex_mem_reg2_rdata;
wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   ex_mem_mem_access_type;
wire                                ex_mem_mem_sign_ext;
wire [`REG_ADDR_WIDTH-1:0]          ex_mem_reg1_raddr;
wire [`REG_ADDR_WIDTH-1:0]          ex_mem_reg2_raddr;


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


wire [`CPU_WIDTH-1:0]               mem_wb_inst;
wire [`CPU_WIDTH-1:0]               mem_wb_curr_pc;
wire [`CPU_WIDTH-1:0]               mem_wb_next_pc;
wire [`CPU_WIDTH-1:0]               mem_wb_mem_rdata;
wire [`CPU_WIDTH-1:0]               mem_wb_alu_res;
wire                                mem_wb_reg_wen;
wire [`REG_ADDR_WIDTH-1:0]          mem_wb_reg_waddr;
wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   mem_wb_mem_access_type;
wire                                mem_wb_mem_sign_ext;
wire [`REG_ADDR_WIDTH-1:0]          mem_wb_reg1_raddr;
wire [`REG_ADDR_WIDTH-1:0]          mem_wb_reg2_raddr;

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
    .pipeline_stall                 ( pipeline_stall                ),
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
    .reg1_rdata                     ( id_ex_reg1_rdata              ),
    .forward_reg1_rdata             ( mem_rdata                     ),
    .forward_to_alu                 ( id_ex_forward_to_alu          ),
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
    .ex_reg_wen                     ( id_ex_reg_wen                 ),
    .mem_forward_addr               ( ex_mem_reg_waddr              ),
    .mem_reg_wen                    ( ex_mem_reg_wen                ),
    .wb_forward_addr                ( mem_wb_reg_waddr              ),
    .wb_reg_wen                     ( mem_wb_reg_wen                ),
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
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         ),
    .alu_op                         ( id_ex_alu_op                  ),
    .alu_src1                       ( alu_src1                      ),
    .alu_src2                       ( alu_src2                      ),
    .zero                           ( zero                          ),
    .alu_res                        ( alu_res                       ),
    .alu_pipestall                  ( alu_pipestall                 )
);

assign sys_bus_addr_o      = (id_ex_mem_access_type != `MEM_ACCESS_TYPE_NONE) ? alu_res : `CPU_WIDTH'h0;    
assign mem_rdata           = sys_bus_rdata_i;
// assign sys_bus_wdata_o     = (id_ex_mem_access_type == `MEM_ACCESS_TYPE_WRITE_BYTE || id_ex_mem_access_type == `MEM_ACCESS_TYPE_WRITE_HALF || id_ex_mem_access_type == `MEM_ACCESS_TYPE_WRITE_WORD) ? id_ex_reg2_rdata:`CPU_WIDTH'h0; //写数据
assign sys_bus_access_type = id_ex_mem_access_type;

always @(*) begin
    if (id_ex_mem_access_type == `MEM_ACCESS_TYPE_WRITE_BYTE || id_ex_mem_access_type == `MEM_ACCESS_TYPE_WRITE_HALF || id_ex_mem_access_type == `MEM_ACCESS_TYPE_WRITE_WORD) begin
        if (id_ex_forward_to_alu[1] == 1'b1) begin
            case (ex_mem_mem_access_type)
                `MEM_ACCESS_TYPE_READ_BYTE: begin
                    case (ex_mem_alu_res[1:0])
                        2'b00: sys_bus_wdata_o = ex_mem_mem_sign_ext ?{{24{mem_rdata[ 7]}},mem_rdata[ 7: 0]}:{{24{1'b0}},mem_rdata[ 7: 0]}; 
                        2'b01: sys_bus_wdata_o = ex_mem_mem_sign_ext ?{{24{mem_rdata[15]}},mem_rdata[15: 8]}:{{24{1'b0}},mem_rdata[15: 8]}; 
                        2'b10: sys_bus_wdata_o = ex_mem_mem_sign_ext ?{{24{mem_rdata[23]}},mem_rdata[23:16]}:{{24{1'b0}},mem_rdata[23:16]};  
                        2'b11: sys_bus_wdata_o = ex_mem_mem_sign_ext ?{{24{mem_rdata[31]}},mem_rdata[31:24]}:{{24{1'b0}},mem_rdata[31:24]};
                    endcase
                end
                `MEM_ACCESS_TYPE_READ_HALF: begin
                    case (ex_mem_alu_res[0])
                        1'b0: sys_bus_wdata_o = ex_mem_mem_sign_ext ?{{16{mem_rdata[15]}},mem_rdata[15: 0]}:{{16{1'b0}},mem_rdata[15: 0]}; 
                        1'b1: sys_bus_wdata_o = ex_mem_mem_sign_ext ?{{16{mem_rdata[31]}},mem_rdata[31:16]}:{{16{1'b0}},mem_rdata[31:16]};
                        endcase
                end
                `MEM_ACCESS_TYPE_READ_WORD: begin
                    sys_bus_wdata_o = mem_rdata;
                end
                // default: 
            endcase
            if (id_ex_reg2_rdata == ex_mem_reg_waddr) begin
                
            end
        end
        else begin
            sys_bus_wdata_o = id_ex_reg2_rdata;
        end
    end
    else  begin
        sys_bus_wdata_o = `CPU_WIDTH'hz; // 高阻态
    end
end



// data_mem  u_data_mem_0 (
//     .clk                            ( clk                           ),
//     .mem_raddr_i                    ( ex_mem_alu_res                ),
//     .mem_rdata_o                    ( mem_rdata                     ),

//     .mem_access_type                ( ex_mem_mem_access_type        ),
//     .mem_wdata_i                    ( ex_mem_reg2_rdata             ),
//     .mem_waddr_i                    ( ex_mem_alu_res                )   
// );

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
