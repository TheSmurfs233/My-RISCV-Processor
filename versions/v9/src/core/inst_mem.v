/* -------指令/数据存储器模块-------- */

`include "defines.v"
//0~1023存储指令，1024~2047存储数据
module inst_mem (
    input   wire [`CPU_WIDTH - 1:0]   pc_addr_i ,   // 程序计数器地址
    output  reg  [`CPU_WIDTH - 1:0]   inst_o       // 指令输出

);
reg [`CPU_WIDTH - 1:0] inst_mem [0:`INST_MEM_ADDR_DEPTH - 1]; // 存储器

wire [`CPU_WIDTH - 1:0] inst_addr; // 指令地址
assign inst_addr = (pc_addr_i - `RESET_PC_VALUE) >> 2; // 映射为字地址,即指令存储器索引
always @(*) begin
    inst_o = inst_mem[inst_addr]; // 取指令，因为指令是32位的，所以需要一次取一个字32位bit，所以最低两位是没有意义的，或者说相当于除4， 例如 pc_addr_i = 10'b00_0000_0100, 对应十进制为4，应该取第五个地址，一个指令32位对应4个地址，所以取地址应该取第二个32位的指令
end



initial begin
    $readmemh ("../../text.hex", inst_mem); // 从文件中读取指令

end


endmodule
