module byte_to_word(
    input clk,                  // 时钟信号
    input rst_n,                // 复位信号（低电平有效）
    input uart_rx_done,         // UART接收完成信号
    input [7:0] uart_rx_data,   // UART接收数据（8位）
    output reg [31:0] word_data, // 组合后的32位数据
    output reg word_valid       // 32位数据有效信号
);

// 状态寄存器
reg [1:0] byte_count;  // 字节计数器 (0-3)
reg [23:0] data_buffer; // 数据缓冲寄存器

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 复位状态
        byte_count <= 2'b00;
        data_buffer <= 24'b0;
        word_data <= 32'b0;
        word_valid <= 1'b0;
    end
    else begin
        // 默认值
        word_valid <= 1'b0;
        
        // 当UART接收到新字节时
        if (uart_rx_done) begin
            case (byte_count)
                2'b00: begin
                    // 接收第一个字节 (最低字节)
                    data_buffer[23:16] <= uart_rx_data;
                    byte_count <= byte_count + 1;
                end
                2'b01: begin
                    // 接收第二个字节
                    data_buffer[15:8] <= uart_rx_data;
                    byte_count <= byte_count + 1;
                end
                2'b10: begin
                    // 接收第三个字节
                    data_buffer[7:0] <= uart_rx_data;
                    byte_count <= byte_count + 1;
                end
                2'b11: begin
                    // 接收第四个字节 (最高字节)
                    word_data <= {data_buffer,uart_rx_data}; // 更新输出
                    word_valid <= 1'b1;      // 输出有效信号
                    byte_count <= 2'b00;     // 重置计数器
                    
                end
            endcase
        end
    end
end

endmodule