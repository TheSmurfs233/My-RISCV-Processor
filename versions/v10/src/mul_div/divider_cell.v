// parameter M means the actual width of divisor
module    divider_cell
#(parameter N=32,
  parameter M=32)
(
  input                     clk,
  input                     rstn,
  input                     en,

  input [M:0]               dividend,
  input [M-1:0]             divisor,
  input [N-M:0]             merchant_ci , //上一级输出的商
  input [N-M-1:0]           dividend_ci , //原始除数

  output reg [N-M-1:0]      dividend_kp,  //原始被除数信息
  output reg [M-1:0]        divisor_kp,   //原始除数信息
  output reg                rdy ,
  output reg [N-M:0]        merchant ,  //运算单元输出商
  output reg [M-1:0]        remainder   //运算单元输出余数
);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rdy            <= 'b0 ;
        merchant       <= 'b0 ;
        remainder      <= 'b0 ;
        divisor_kp     <= 'b0 ;
        dividend_kp    <= 'b0 ;
    end
    else if (en) begin
        rdy            <= 1'b1 ;
        divisor_kp     <= divisor ;  //原始除数保持不变
        dividend_kp    <= dividend_ci ;  //原始被除数传递
        if (dividend >= {1'b0, divisor}) begin
            merchant    <= (merchant_ci<<1) + 1'b1 ; //商为1
            remainder   <= dividend - {1'b0, divisor} ; //求余
        end
        else begin
            merchant    <= merchant_ci<<1 ;  //商为0
            remainder   <= dividend ;        //余数不变
        end
    end // if (en)
    else begin
        rdy            <= 'b0 ;
        merchant       <= 'b0 ;
        remainder      <= 'b0 ;
        divisor_kp     <= 'b0 ;
        dividend_kp    <= 'b0 ;
    end
end 

endmodule