/*----- 执行访存流水线寄存 -----*/
`include "defines.v"

module ex_mem(
    input   wire                                clk                         ,   
    input   wire [`CPU_WIDTH-1:0]               id_ex_inst                  ,
    input   wire [`CPU_WIDTH-1:0]               id_ex_curr_pc               ,
    input   wire [`CPU_WIDTH-1:0]               id_ex_next_pc               ,
    input   wire [`CPU_WIDTH-1:0]               alu_res                     ,
    input   wire                                id_ex_reg_wen               ,
    input   wire [`REG_ADDR_WIDTH-1:0]          id_ex_reg_waddr             ,
    input   wire [`CPU_WIDTH-1:0]               id_ex_reg2_rdata            ,
    input   wire [`MEM_ACCESS_TYPE_WIDTH-1:0]   id_ex_mem_access_type       ,
    input   wire                                id_ex_mem_sign_ext          ,
    input   wire [`REG_ADDR_WIDTH-1:0]          id_ex_reg1_raddr            ,
    input   wire [`REG_ADDR_WIDTH-1:0]          id_ex_reg2_raddr            ,

    output  reg  [`CPU_WIDTH-1:0]               ex_mem_inst                 ,
    output  reg  [`CPU_WIDTH-1:0]               ex_mem_curr_pc              ,
    output  reg  [`CPU_WIDTH-1:0]               ex_mem_next_pc              ,
    output  reg  [`CPU_WIDTH-1:0]               ex_mem_alu_res              ,
    output  reg                                 ex_mem_reg_wen              ,
    output  reg  [`REG_ADDR_WIDTH-1:0]          ex_mem_reg_waddr            ,
    output  reg  [`CPU_WIDTH-1:0]               ex_mem_reg2_rdata           ,
    output  reg  [`MEM_ACCESS_TYPE_WIDTH-1:0]   ex_mem_mem_access_type      ,
    output  reg                                 ex_mem_mem_sign_ext         ,
    output  reg [`REG_ADDR_WIDTH-1:0]           ex_mem_reg1_raddr           ,    
    output  reg [`REG_ADDR_WIDTH-1:0]           ex_mem_reg2_raddr           
);

    always @(posedge clk ) begin
        ex_mem_inst            <= id_ex_inst            ;
        ex_mem_curr_pc         <= id_ex_curr_pc         ;
        ex_mem_next_pc         <= id_ex_next_pc         ;
        ex_mem_alu_res         <= alu_res               ;
        ex_mem_reg_wen         <= id_ex_reg_wen         ;
        ex_mem_reg_waddr       <= id_ex_reg_waddr       ;
        ex_mem_reg2_rdata      <= id_ex_reg2_rdata      ;
        ex_mem_mem_access_type <= id_ex_mem_access_type ;
        ex_mem_mem_sign_ext    <= id_ex_mem_sign_ext    ;
        ex_mem_reg1_raddr      <= id_ex_reg1_raddr      ;
        ex_mem_reg2_raddr      <= id_ex_reg2_raddr      ;
    end
endmodule