/* -------程序计数器模块-------- */

`include "defines.v"
// `define CPU_WIDTH               32
module pc_reg (
    input   wire                        clk         ,
    input   wire                        rst_n       ,
    input   wire    [`CPU_WIDTH - 1:0]  rst_pc      ,
    output  reg                         ena         ,
    input   wire    [`CPU_WIDTH - 1:0]  next_pc_i   ,   // 下一个程序计数器地址
    output  reg     [`CPU_WIDTH - 1:0]  curr_pc_o       // 当前程序计数器地址

);
//ena:系统使能信号
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ena <= 1'b0;
    end
    else begin
        ena <= 1'b1;
    end
end

//curr_pc_o:当前程序计数器输出
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        curr_pc_o <= rst_pc; //复位时，回到复位地址的指令
    end
    else begin
        curr_pc_o <= next_pc_i;     
    end

end
endmodule
