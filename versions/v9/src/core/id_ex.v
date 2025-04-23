/*----- 译码执行流水线寄存 -----*/
`include "defines.v"

module id_ex(
    input   wire                                clk                     ,
    input   wire                                pipeline_flush          ,
    input   wire                                pipeline_stall          ,

    input   wire [`CPU_WIDTH-1:0]               if_id_inst              ,
    input   wire [`CPU_WIDTH-1:0]               if_id_curr_pc           ,
    input   wire [`CPU_WIDTH-1:0]               if_id_next_pc           ,
    input   wire                                branch                  ,
    input   wire                                jump                    ,
    input   wire                                reg_wen                 ,
    input   wire [`REG_ADDR_WIDTH-1:0]          reg_waddr               ,
    input   wire [`REGS_SRC_WIDTH-1:0]          regs_src_sel            ,
    input   wire [`REG_ADDR_WIDTH-1:0]          reg1_raddr              ,
    input   wire [`REG_ADDR_WIDTH-1:0]          reg2_raddr              ,
    input   wire [`CPU_WIDTH-1:0]               reg1_rdata              ,
    input   wire [`CPU_WIDTH-1:0]               reg2_rdata              ,
    input   wire [`ALU_OP_WIDTH-1:0]            alu_op                  ,     
    input   wire [`ALU_SRC_WIDTH-1:0]           alu_src_sel             ,  
    input   wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   mem_access_type         ,
    input   wire                                mem_sign_ext            , // 
    input   wire [`CPU_WIDTH-1:0]               imm                     ,
    input   wire                                if_id_control_hazard    ,
    input   wire [1:0]                          forward_to_alu          ,

    output   reg [`CPU_WIDTH-1:0]               id_ex_curr_pc           , 
    output   reg [`CPU_WIDTH-1:0]               id_ex_next_pc           ,
    output   reg [`CPU_WIDTH-1:0]               id_ex_inst              ,
    output   reg                                id_ex_branch            ,
    output   reg                                id_ex_jump              ,
    output   reg                                id_ex_reg_wen           ,
    output   reg [`REG_ADDR_WIDTH-1:0]          id_ex_reg_waddr         ,
    output   reg [`REGS_SRC_WIDTH-1:0]          id_ex_regs_src_sel      ,
    output   reg [`REG_ADDR_WIDTH-1:0]          id_ex_reg1_raddr        ,
    output   reg [`REG_ADDR_WIDTH-1:0]          id_ex_reg2_raddr        ,
    output   reg [`CPU_WIDTH-1:0]               id_ex_reg1_rdata        ,
    output   reg [`CPU_WIDTH-1:0]               id_ex_reg2_rdata        ,
    output   reg [`ALU_OP_WIDTH-1:0]            id_ex_alu_op            ,     
    output   reg [`ALU_SRC_WIDTH-1:0]           id_ex_alu_src_sel       ,  
    output   reg [`MEM_ACCESS_TYPE_WIDTH-1:0]   id_ex_mem_access_type   ,
    output   reg                                id_ex_mem_sign_ext      , // 
    output   reg [`CPU_WIDTH-1:0]               id_ex_imm               ,
    output   reg                                id_ex_control_hazard    ,
    output   reg [1:0]                          id_ex_forward_to_alu

);

    always @(posedge clk ) begin
        if (pipeline_stall == 1'b1) begin
            id_ex_curr_pc           <= id_ex_curr_pc        ;
            id_ex_next_pc           <= id_ex_next_pc        ;
            id_ex_inst              <= id_ex_inst           ;
            id_ex_branch            <= id_ex_branch         ;
            id_ex_jump              <= id_ex_jump           ;
            id_ex_reg_wen           <= id_ex_reg_wen        ;
            id_ex_reg_waddr         <= id_ex_reg_waddr      ;
            id_ex_regs_src_sel      <= id_ex_regs_src_sel   ;
            id_ex_reg1_raddr        <= id_ex_reg1_raddr     ;
            id_ex_reg2_raddr        <= id_ex_reg2_raddr     ;
            id_ex_reg1_rdata        <= id_ex_reg1_rdata     ;
            id_ex_reg2_rdata        <= id_ex_reg2_rdata     ;
            id_ex_alu_op            <= id_ex_alu_op         ;
            id_ex_alu_src_sel       <= id_ex_alu_src_sel    ;
            id_ex_mem_access_type   <= id_ex_mem_access_type;
            id_ex_mem_sign_ext      <= id_ex_mem_sign_ext   ;
            id_ex_imm               <= id_ex_imm            ;
            id_ex_control_hazard    <= id_ex_control_hazard ;
            id_ex_forward_to_alu    <= id_ex_forward_to_alu ;
        end
        else if (pipeline_flush == 1'b1) begin
            id_ex_curr_pc           <=  `CPU_WIDTH'b0 ;
            id_ex_next_pc           <=  `CPU_WIDTH'b0 ;
            id_ex_inst              <=  `CPU_WIDTH'b0 ;
            id_ex_branch            <=  1'b0 ;
            id_ex_jump              <=  1'b0 ;
            id_ex_reg_wen           <=  1'b0 ;
            id_ex_reg_waddr         <=  `REG_ADDR_WIDTH'b0 ;
            id_ex_regs_src_sel      <=  `REGS_SRC_WIDTH'b0 ;
            id_ex_reg1_raddr        <=  `REG_ADDR_WIDTH'b0 ;
            id_ex_reg2_raddr        <=  `REG_ADDR_WIDTH'b0 ;
            id_ex_reg1_rdata        <=  `CPU_WIDTH'b0 ;
            id_ex_reg2_rdata        <=  `CPU_WIDTH'b0 ;
            id_ex_alu_op            <=  `ALU_OP_WIDTH'b0 ;
            id_ex_alu_src_sel       <=  `ALU_SRC_WIDTH'b0 ;
            id_ex_mem_access_type   <=  `MEM_ACCESS_TYPE_WIDTH'b0 ;
            id_ex_mem_sign_ext      <=  1'b0 ;
            id_ex_imm               <=  `CPU_WIDTH'b0 ;
            id_ex_control_hazard    <=  1'b0 ;
            id_ex_forward_to_alu    <=  2'b0 ;
        end
        else begin
            id_ex_curr_pc           <= if_id_curr_pc  ;
            id_ex_next_pc           <= if_id_next_pc  ;
            id_ex_inst              <= if_id_inst     ;
            id_ex_branch            <= branch         ;
            id_ex_jump              <= jump           ;
            id_ex_reg_wen           <= reg_wen        ;
            id_ex_reg_waddr         <= reg_waddr      ;
            id_ex_regs_src_sel      <= regs_src_sel   ;
            id_ex_reg1_raddr        <= reg1_raddr     ;
            id_ex_reg2_raddr        <= reg2_raddr     ;
            id_ex_reg1_rdata        <= reg1_rdata     ;
            id_ex_reg2_rdata        <= reg2_rdata     ;
            id_ex_alu_op            <= alu_op         ;
            id_ex_alu_src_sel       <= alu_src_sel    ;
            id_ex_mem_access_type   <= mem_access_type;
            id_ex_mem_sign_ext      <= mem_sign_ext   ;
            id_ex_imm               <= imm            ;
            id_ex_control_hazard    <= if_id_control_hazard ;
            id_ex_forward_to_alu    <= forward_to_alu ;
        end
    end
endmodule