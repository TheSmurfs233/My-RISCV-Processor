module uart_tx(
    input clk,  //50MHz
    input rst_n,
    input uart_tx_en,
    input [7:0] uart_tx_data,
    output reg uart_tx_busy,
    output reg uart_tx_d
);
//参数定义
parameter CLK_FREQ = 50_000_000;    
parameter UART_BAUD =115200;
localparam BAUD_CNT_MAX=CLK_FREQ/UART_BAUD;

//寄存器定义
reg [7:0] tx_data_t;//发送数据寄存器
reg [3:0] tx_cnt;//发送数据计数器
reg [15:0] baud_cnt;//波特率计数器

always @(posedge clk)begin
    //如果复位信号有效，那么清除发送数据寄存器，拉低标志位
    if(rst_n==0)begin
        tx_data_t<=8'd10;
        uart_tx_busy<=1'b0;
    end
    //发送使能
    else if(uart_tx_en)begin
        tx_data_t<=uart_tx_data;
        uart_tx_busy<=1'b1;
    end
    //如果计数到停止位，那么拉低标志位，清空数据寄存器
    else if(tx_cnt==4'd9&&baud_cnt==BAUD_CNT_MAX-BAUD_CNT_MAX/16)begin
        tx_data_t<=8'd10;
        uart_tx_busy<=1'b0;
    end
    else begin
        tx_data_t<=tx_data_t;
        uart_tx_busy<=uart_tx_busy;
    end
end

//波特率计数器
always @(posedge clk)begin
    if(rst_n==0)begin
        baud_cnt<=16'd0;
    end
    //当处于发送状态时，波特率计数器进行计数
    else if(uart_tx_busy)begin
        if(baud_cnt < BAUD_CNT_MAX - 1'b1)
            baud_cnt <= baud_cnt + 16'b1;
        else
            baud_cnt <=16'd0;
    end
    else
        baud_cnt <=16'd0;
end

//发送数据计数
always @(posedge clk)begin
    if(rst_n==0)
        tx_cnt<=4'd0;
    else if(uart_tx_busy)begin
        if (baud_cnt==BAUD_CNT_MAX - 1'b1)
            tx_cnt<=tx_cnt+1'b1;
        else
            tx_cnt<=tx_cnt;
    end
    else
        tx_cnt<=4'd0;
end

//根据发送计数器对发送端口赋值
always @(posedge clk)begin
    if(rst_n==0)
        uart_tx_d=1'b1;
    else if(uart_tx_busy)begin 
        case(tx_cnt)
            4'd0 : uart_tx_d <= 1'b0        ; //起始位
            4'd1 : uart_tx_d <= tx_data_t[0]; //数据位最低位
            4'd2 : uart_tx_d <= tx_data_t[1];
            4'd3 : uart_tx_d <= tx_data_t[2];
            4'd4 : uart_tx_d <= tx_data_t[3];
            4'd5 : uart_tx_d <= tx_data_t[4];
            4'd6 : uart_tx_d <= tx_data_t[5];
            4'd7 : uart_tx_d <= tx_data_t[6];
            4'd8 : uart_tx_d <= tx_data_t[7]; //数据位最高位
            4'd9 : uart_tx_d <= 1'b1        ; //停止位
            default : uart_tx_d <= 1'b1;
        endcase
    end
    else
        uart_tx_d=1'b1;
end

endmodule
