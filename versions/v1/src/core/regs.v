/* -------寄存器堆模块-------- */

`include "defines.v"

module regs (
    input                            clk,
    input                            rst_n,

    input                            reg_wen,    // 寄存器写使能
    input      [`REG_ADDR_WIDTH-1:0] reg_waddr,  // 寄存器写地址
    input      [`CPU_WIDTH-1:0]      reg_wdata,  // 寄存器写数据
    input      [`REG_ADDR_WIDTH-1:0] reg1_raddr, // 寄存器1读地址
    input      [`REG_ADDR_WIDTH-1:0] reg2_raddr, // 寄存器2读地址
    output reg [`CPU_WIDTH-1:0]      reg1_rdata, // 寄存器1读数据
    output reg [`CPU_WIDTH-1:0]      reg2_rdata // 寄存器2读数据
);
    
reg [`CPU_WIDTH-1:0] regs [0:`REG_DATA_DEPTH-1]; 

// register write
always @(posedge clk or negedge rst_n) begin
    if (rst_n && reg_wen && (reg_waddr != `REG_ADDR_WIDTH'b0)) // x0 read only
        regs[reg_waddr] <= reg_wdata; 
end

// register 1 read
always @(*) begin
    if(reg1_raddr == `REG_ADDR_WIDTH'b0)
        reg1_rdata = `CPU_WIDTH'b0;
    else
        reg1_rdata = regs[reg1_raddr];
end

// register 2 read
always @(*) begin
    if(reg2_raddr == `REG_ADDR_WIDTH'b0)
        reg2_rdata = `CPU_WIDTH'b0;
    else
        reg2_rdata = regs[reg2_raddr];
end


endmodule
