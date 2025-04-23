/*----- 访存写回流水线寄存 -----*/
`include "defines.v"

module mem_wb( 
    input   wire                                 clk,
    input   wire  [`CPU_WIDTH-1:0]               ex_mem_inst                 ,
    input   wire  [`CPU_WIDTH-1:0]               ex_mem_curr_pc              ,
    input   wire  [`CPU_WIDTH-1:0]               ex_mem_next_pc              ,
    input   wire  [`CPU_WIDTH-1:0]               ex_mem_alu_res              ,
    input   wire  [`CPU_WIDTH-1:0]               mem_rdata                   ,
    input   wire                                 ex_mem_reg_wen              ,
    input   wire  [`REG_ADDR_WIDTH-1:0]          ex_mem_reg_waddr            ,
    input   wire  [`MEM_ACCESS_TYPE_WIDTH-1:0]   ex_mem_mem_access_type      ,
    input   wire                                 ex_mem_mem_sign_ext         ,
    input   wire  [`REG_ADDR_WIDTH-1:0]          ex_mem_reg1_raddr           ,
    input   wire  [`REG_ADDR_WIDTH-1:0]          ex_mem_reg2_raddr           ,

    output  reg   [`CPU_WIDTH-1:0]               mem_wb_inst                 ,
    output  reg   [`CPU_WIDTH-1:0]               mem_wb_curr_pc              ,
    output  reg   [`CPU_WIDTH-1:0]               mem_wb_next_pc              ,
    output  reg   [`CPU_WIDTH-1:0]               mem_wb_mem_rdata            ,
    output  reg   [`CPU_WIDTH-1:0]               mem_wb_alu_res              ,
    output  reg                                  mem_wb_reg_wen              ,
    output  reg   [`REG_ADDR_WIDTH-1:0]          mem_wb_reg_waddr            ,
    output  reg   [`MEM_ACCESS_TYPE_WIDTH-1:0]   mem_wb_mem_access_type      ,
    output  reg                                  mem_wb_mem_sign_ext         ,
    output  reg   [`REG_ADDR_WIDTH-1:0]          mem_wb_reg1_raddr           ,
    output  reg   [`REG_ADDR_WIDTH-1:0]          mem_wb_reg2_raddr            

);

    always @(posedge clk ) begin
        mem_wb_inst               <= ex_mem_inst                 ;
        mem_wb_curr_pc            <= ex_mem_curr_pc              ;
        mem_wb_next_pc            <= ex_mem_next_pc              ;
        mem_wb_mem_rdata          <= mem_rdata                   ;
        mem_wb_alu_res            <= ex_mem_alu_res              ;
        mem_wb_reg_wen            <= ex_mem_reg_wen              ;
        mem_wb_reg_waddr          <= ex_mem_reg_waddr            ;
        mem_wb_mem_access_type    <= ex_mem_mem_access_type      ;
        mem_wb_mem_sign_ext       <= ex_mem_mem_sign_ext         ;
        mem_wb_reg1_raddr         <= ex_mem_reg1_raddr           ;
        mem_wb_reg2_raddr         <= ex_mem_reg2_raddr           ;
    end
endmodule