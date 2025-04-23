/* -------运算逻辑单元模块-------- */
// 对输入的两个数进行运算，并输出运算结果


`include "defines.v"

module alu(
    input                          clk,      // 时钟信号
    input                          rst_n,    // 复位信号
    input      [`ALU_OP_WIDTH-1:0] alu_op,   // ALU操作码
    input      [`CPU_WIDTH-1:0]    alu_src1, // ALU源1
    input      [`CPU_WIDTH-1:0]    alu_src2, // ALU源2
    output reg                     zero,     // ALU结果是否为0
    output reg [`CPU_WIDTH-1:0]    alu_res,   // ALU结果
    output reg                     alu_pipestall // 流水线暂停信号
);
/*******乘法单元********/

// 根据指令类型（由控制逻辑给出）扩展操作数
reg [32:0] A, B;
wire [65:0] P;
always @(*) begin
  case (alu_op)
    `ALU_MUL,`ALU_MULH:    begin 
        A = {alu_src1[31],alu_src1};
        B = {alu_src2[31],alu_src2};
    end
    `ALU_MULHSU: begin 
        A = {alu_src1[31],alu_src1};
        B = {1'b0,alu_src2};
    end
    `ALU_MULHU:begin
        A = {1'b0,alu_src1};
        B = {1'b0,alu_src2};
    end
    default:begin      
        A = 33'h0;
        B = 33'h0;
    end // MUL
  endcase
end

multiplier multiplier_inst (
  .A(A),  // input wire [32 : 0] A
  .B(B),  // input wire [32 : 0] B
  .P(P)  // output wire [65 : 0] P
);

/*******除法单元********/
wire div_data_rdy_pulse;  // 单周期触发信号
wire div_res_rdy;
wire div_inst;       
reg div_inst_r;

reg [`CPU_WIDTH-1:0] dividend;
reg [`CPU_WIDTH-1:0] divisor;
wire [`CPU_WIDTH-1:0] merchant;
wire [`CPU_WIDTH-1:0] remainder;

assign  div_inst = (alu_op == `ALU_DIV || alu_op == `ALU_DIVU || alu_op == `ALU_REM || alu_op == `ALU_REMU) ? 1'b1 : 1'b0;
always @(posedge clk ) begin
    if (div_inst == 1'b1) begin
        div_inst_r <= 1'b1;
    end
    else begin
        div_inst_r <= 1'b0;
    end
end
//div_data_rdy_pulse: 边沿检测生成除法单元触发信号
assign div_data_rdy_pulse = (div_inst == 1'b1 && div_inst_r == 1'b0);

//alu_pipestall:流水线暂停信号
always @(*) begin
    if(div_res_rdy == 1'b1) begin
        alu_pipestall = 1'b0;
    end
    else if(div_inst == 1'b1) begin
        alu_pipestall = 1'b1;
    end
    else begin
        alu_pipestall = 1'b0;
    end
end

//符号位
wire sign_dividend = alu_src1[`CPU_WIDTH-1];
wire sign_divisor  = alu_src2[`CPU_WIDTH-1];
wire [`CPU_WIDTH-1:0] abs_dividend = sign_dividend ? (-alu_src1) : alu_src1;
wire [`CPU_WIDTH-1:0] abs_divisor  = sign_divisor  ? (-alu_src2) : alu_src2;

//dividend:被除数 divisor:除数
always @(*) begin
    case (alu_op)
        `ALU_DIV:begin
            dividend = abs_dividend;
            divisor = abs_divisor;
        end
        `ALU_DIVU:begin
            dividend = alu_src1;
            divisor = alu_src2;
        end
        `ALU_REM:begin
            dividend = abs_dividend;
            divisor = abs_divisor;
        end
        `ALU_REMU:begin
            dividend = alu_src1;
            divisor = alu_src2;
        end
        default:begin      
            dividend = 32'h0;
            divisor = 32'h0;
        end 
    endcase
end

divider_man # (
    .N(`CPU_WIDTH),
    .M(`CPU_WIDTH),
    .N_ACT(`CPU_WIDTH * 2-1)
  )
divider_man_inst (
    .clk(clk),
    .rstn(rst_n),
    .data_rdy(div_data_rdy_pulse),
    .dividend(dividend),
    .divisor(divisor),
    .res_rdy(div_res_rdy),
    .merchant(merchant),
    .remainder(remainder)
);



always @(*) begin
    zero = 1'b1;
    alu_res = `CPU_WIDTH'b0;
    case (alu_op)
        `ALU_ADD: begin // 加法运算
            alu_res = alu_src1 + alu_src2;
        end
        `ALU_SUB:begin // 减法运算,相等时zero返回1,mux_pc模块不进行跳转
            alu_res = alu_src1 - alu_src2;
            zero = (alu_res == `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_SUB_NE:begin // 减法运算,不相等时返回1,mux_pc模块里进行跳转
            alu_res = alu_src1 - alu_src2;
            zero = (alu_res != `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_AND:begin // 与运算
            alu_res = alu_src1 & alu_src2;
        end
        `ALU_OR:begin // 或运算
            alu_res = alu_src1 | alu_src2;
        end
        `ALU_XOR:begin // 异或运算
            alu_res = alu_src1 ^ alu_src2;
        end
        `ALU_SLL:begin // 逻辑左移
            alu_res = alu_src1 << alu_src2[4:0];
        end
        `ALU_SRL:begin // 逻辑右移
            alu_res = alu_src1 >> alu_src2[4:0];
        end
        `ALU_SRA:begin // 算术右移
            alu_res = $signed(alu_src1) >>> alu_src2[4:0];
        end
        `ALU_SLT:begin // 带符号比较，若alu_src1 < alu_src2,则结果为1,否则为0
            alu_res = $signed(alu_src1) < $signed(alu_src2) ? `CPU_WIDTH'b1 : `CPU_WIDTH'b0;
            zero = (alu_res == `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_SLT_GTE:begin // 带符号比较，若alu_src1 >= alu_src2,则结果为1,否则为0
            alu_res = $signed(alu_src1) >= $signed(alu_src2) ? `CPU_WIDTH'b1 : `CPU_WIDTH'b0;
            zero = (alu_res == `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_SLTU:begin // 不带符号比较，若alu_src1 < alu_src2,则结果为1,否则为0
            alu_res = alu_src1 < alu_src2 ? `CPU_WIDTH'b1 : `CPU_WIDTH'b0;
            zero = (alu_res == `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_SLTU_GTE:begin // 不带符号比较，若alu_src1 >= alu_src2,则结果为1,否则为0
            alu_res = (alu_src1 >= alu_src2) ? `CPU_WIDTH'b1 : `CPU_WIDTH'b0;
            zero = (alu_res == `CPU_WIDTH'b0) ? 1'b1 : 1'b0;
        end
        `ALU_MUL:begin // 乘法运算
            alu_res = P[`CPU_WIDTH-1:0];
        end
        `ALU_MULH,`ALU_MULHSU,`ALU_MULHU:begin // 乘法运算，结果高32位
            alu_res = P[`CPU_WIDTH*2-1:32];
        end
        `ALU_DIV:begin
            alu_res = div_res_rdy ? ((sign_dividend ^ sign_divisor) ? -merchant : merchant): `CPU_WIDTH'b0;
        end
        `ALU_DIVU:begin // 除法运算
            alu_res = div_res_rdy ? merchant : `CPU_WIDTH'b0;
        end
        `ALU_REM:begin // 余数运算
            alu_res = div_res_rdy ? ((sign_dividend) ? -remainder : remainder) : `CPU_WIDTH'b0;
        end
        `ALU_REMU:begin // 余数运算
            alu_res = div_res_rdy ? remainder : `CPU_WIDTH'b0;
        end
    endcase
end


endmodule
