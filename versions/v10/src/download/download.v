`include "../core/defines.v"
module download(
    input  wire clk,
    input  wire rst_n,

    // URAT接口
    input  wire uart_rx_d,

    output wire                      inst_meme_we_o,         // 写使能信
    output reg  [`CPU_WIDTH - 1:0]   inst_meme_waddr_o,      // 写地址
    output wire [`CPU_WIDTH - 1:0]   inst_meme_wdata_o,       // 写数据
    output wire                      downloading             // 正在下载信号
);

wire uart_rx_done; // 接收完成标志
wire [7:0] uart_rx_data; // 接收数据

//串口接收模块
uart_rx  uart_rx_inst (
    .clk(clk),
    .rst_n(rst_n),
    .uart_rx_d(uart_rx_d),
    .uart_rx_done(uart_rx_done),
    .uart_rx_data(uart_rx_data),
    .rx_busy(downloading)
);

//将byte数据转换为word数据
wire [`CPU_WIDTH - 1:0] word_data; // 接收数据
wire word_valid; // 接收数据有效标志
byte_to_word  byte_to_word_inst (
    .clk(clk),
    .rst_n(rst_n),
    .uart_rx_done(uart_rx_done),
    .uart_rx_data(uart_rx_data),
    .word_data(word_data),
    .word_valid(word_valid)
);

assign inst_meme_we_o = word_valid;
assign inst_meme_wdata_o = word_data;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        inst_meme_waddr_o <= 0;
    end
    else if (word_valid) begin
        inst_meme_waddr_o <= inst_meme_waddr_o + 1; // 每次接收一个字，地址加1
    end
    else begin
        inst_meme_waddr_o <= inst_meme_waddr_o; // 保持不变
    end
end


endmodule