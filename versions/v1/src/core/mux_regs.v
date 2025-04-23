/* -------寄存器堆多路选择模块-------- */

`include "defines.v"
module mux_regs (
    input   wire   [`REGS_SRC_WIDTH-1:0] regs_src_sel,// regs 输入数据源选择信号
    
    

    output  wire [`CPU_WIDTH-1:0]      reg_wdata  // 寄存器写数据

);
    
endmodule
