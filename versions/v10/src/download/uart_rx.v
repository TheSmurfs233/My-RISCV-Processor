module uart_rx(
    input  wire clk,  //50MHz
    input  wire rst_n,
    input  wire uart_rx_d,
    output reg uart_rx_done,
    output reg [7:0] uart_rx_data,
    output wire rx_busy
);
//参数定义
parameter CLK_FREQ = 50_000_000;    
parameter UART_BAUD =115200;
localparam BAUD_CNT_MAX=CLK_FREQ/UART_BAUD;

//寄存器定义
reg  uart_rx_d0;
reg  uart_rx_d1;
reg  uart_rx_d2;
reg  rx_flag;   //接收数据标志位
reg [7:0] rx_data_t;//接收数据寄存器
reg [3:0] rx_cnt;//接收数据计数器
reg [15:0] baud_cnt;//波特率计数器

assign rx_busy = rx_flag; //输出接收忙状态

//线网定义
wire start_en;

//捕获接收端口下降沿(起始位)，得到一个时钟周期的脉冲信号
assign start_en=uart_rx_d2&(~uart_rx_d1)&(~rx_flag);

//针对异步信号的同步处理
always @(posedge clk) begin
    if(rst_n==0)begin
        uart_rx_d0<=0;
        uart_rx_d1<=0;
        uart_rx_d2<=0;
    end
    else begin
        uart_rx_d0<=uart_rx_d;
        uart_rx_d1<=uart_rx_d0;
        uart_rx_d2<=uart_rx_d1;
    end
end

//接收标志位赋值
always @(posedge clk) begin
    if(rst_n==0)
        rx_flag<=1'b0;
    else if(start_en)
        rx_flag<=1'b1;  //检测到起始信号，标志位置1
    else if (rx_cnt==4'd9 && baud_cnt==BAUD_CNT_MAX/2-1'b1)begin//接收结束，标志位置0 
        rx_flag<=1'b0;
    end
    else
        rx_flag<=rx_flag;
end



//波特率计数器
always @(posedge clk)begin
    if(rst_n==0)begin
        baud_cnt<=16'd0;
    end
    //当处于接收状态时，波特率计数器进行计数
    else if(rx_flag)begin
        if(baud_cnt < BAUD_CNT_MAX - 1'b1)
            baud_cnt <= baud_cnt + 16'b1;
        else
            baud_cnt <=16'd0;
    end
    else
        baud_cnt <=16'd0;
end

//接收数据计数
always @(posedge clk)begin
    if(rst_n==0)
        rx_cnt<=4'd0;
    else if(rx_flag)begin
        if (baud_cnt==BAUD_CNT_MAX - 1'b1)
            rx_cnt<=rx_cnt+1'b1;
        else
            rx_cnt<=rx_cnt;
    end
    else
        rx_cnt<=4'd0;
end

//根据发送计数器对接收数据寄存器进行赋值
always @(posedge clk)begin
    if(rst_n==0)
        rx_data_t=8'd0;
    else if(rx_flag)begin //判断是否处于接收状态
        if(baud_cnt==BAUD_CNT_MAX/2 - 1'b1)begin//判断是否计数到中间
            case(rx_cnt)
                4'd1 : rx_data_t[0] <= uart_rx_d2;   //寄存数据的最低位
                4'd2 : rx_data_t[1] <= uart_rx_d2;
                4'd3 : rx_data_t[2] <= uart_rx_d2;
                4'd4 : rx_data_t[3] <= uart_rx_d2;
                4'd5 : rx_data_t[4] <= uart_rx_d2;
                4'd6 : rx_data_t[5] <= uart_rx_d2;
                4'd7 : rx_data_t[6] <= uart_rx_d2;
                4'd8 : rx_data_t[7] <= uart_rx_d2;   //寄存数据的高低位
               default : ;
            endcase
        end
        else
            rx_data_t<=rx_data_t;
    end
    else
        rx_data_t=8'd0;
end

//给接收完成信号和接收到的数据赋值
always @(posedge clk) begin
    if(rst_n==0) begin
        uart_rx_done <= 1'b0;
        uart_rx_data <= 8'b0;
    end
    //当接收数据计数器计数到停止位，且baud_cnt计数到停止位的中间时
    else if(rx_cnt == 4'd9 && baud_cnt == BAUD_CNT_MAX/2 - 1'b1) begin
        uart_rx_done <= 1'b1     ;  //拉高接收完成信号
        uart_rx_data <= rx_data_t;  //并对UART接收到的数据进行赋值
    end    
    else begin
        uart_rx_done <= 1'b0;
        uart_rx_data <= uart_rx_data;
    end
end

endmodule
