module seg_led (
    input  wire         clk,          // 系统时钟（如50MHz）
    input  wire         rst_n,        // 异步复位（低有效）
    
    // 寄存器读写接口（假设为APB总线）
    input  wire         psel,         // 外设选择
    input  wire         penable,      // 使能信号
    input  wire [3:0]   paddr,        // 字节地址
    input  wire         pwrite,       // 写使能
    input  wire [31:0]  pwdata,       // 写数据
    output reg  [31:0]  prdata,       // 读数据
    
    // 数码管硬件接口
    output reg  [5:0]   seg_sel_n,    // 位选信号（低有效，驱动PNP三极管）
    output wire [7:0]   seg_data      // 段选信号（a~g + 小数点，共阳极）
);

// ---- 寄存器定义 ----
reg [7:0] seg_data_reg [0:5];  // 6个段选数据寄存器
reg [7:0] seg_ctrl_reg;        // 控制寄存器 第0位控制扫描使能




// ---- 动态扫描参数 ----
localparam SCAN_FREQ  = 1000;   // 扫描频率1kHz
localparam CLK_FREQ   = 50_000_000; // 系统时钟50MHz
localparam SCAN_CYCLES = CLK_FREQ / (SCAN_FREQ * 6); // 每个数码管显示周期

reg [31:0] scan_counter;       // 扫描计数器
reg [2:0]  scan_index;         // 当前扫描的数码管索引（0~5）

// ---- 段选译码表（共阳数码管） ----
reg [7:0] seg_decoder [0:15];  // 0~F的段码（含小数点）
initial begin
    seg_decoder[0]  = 8'hC0; // 0
    seg_decoder[1]  = 8'hF9; // 1
    seg_decoder[2]  = 8'hA4; // 2
    seg_decoder[3]  = 8'hB0; // 3
    seg_decoder[4]  = 8'h99; // 4
    seg_decoder[5]  = 8'h92; // 5
    seg_decoder[6]  = 8'h82; // 6
    seg_decoder[7]  = 8'hF8; // 7
    seg_decoder[8]  = 8'h80; // 8
    seg_decoder[9]  = 8'h90; // 9
    seg_decoder[10] = 8'h88; // A
    seg_decoder[11] = 8'h83; // B
    seg_decoder[12] = 8'hC6; // C
    seg_decoder[13] = 8'hA1; // D
    seg_decoder[14] = 8'h86; // E
    seg_decoder[15] = 8'h8E; // F
end

// ---- APB总线读写逻辑 ----
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seg_ctrl_reg <= 8'h01; // 默认使能扫描
        for (integer i=0; i<6; i=i+1) begin
            seg_data_reg[i] <= 8'h00;
        end
        prdata <= 32'h0;
    end else if (psel && penable) begin
        if (pwrite) begin // 写操作
            case (paddr)
                4'h0: seg_data_reg[0] <= pwdata[7:0];
                4'h1: seg_data_reg[1] <= pwdata[7:0];
                4'h2: seg_data_reg[2] <= pwdata[7:0];
                4'h3: seg_data_reg[3] <= pwdata[7:0];
                4'h4: seg_data_reg[4] <= pwdata[7:0];
                4'h5: seg_data_reg[5] <= pwdata[7:0];
                4'h6: seg_ctrl_reg    <= pwdata[7:0];
            endcase
        end else begin // 读操作
            case (paddr)
                4'h0: prdata <= {24'h0, seg_data_reg[0]};
                4'h1: prdata <= {24'h0, seg_data_reg[1]};
                4'h2: prdata <= {24'h0, seg_data_reg[2]};
                4'h3: prdata <= {24'h0, seg_data_reg[3]};
                4'h4: prdata <= {24'h0, seg_data_reg[4]};
                4'h5: prdata <= {24'h0, seg_data_reg[5]};
                4'h6: prdata <= {24'h0, seg_ctrl_reg};
                default: prdata <= 32'h0;
            endcase
        end
    end
end

// ---- 动态扫描逻辑 ----
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        scan_counter <= 0;
        scan_index   <= 0;
        seg_sel_n    <= 6'b111111; // 默认关闭所有位选
    end else begin
        if (seg_ctrl_reg[0]) begin // 扫描使能
            if (scan_counter >= SCAN_CYCLES) begin
                scan_counter <= 0;
                seg_sel_n <= 6'b111111; // 短暂关闭显示，避免残影
                
                // 切换到下一个数码管
                scan_index <= (scan_index == 5) ? 0 : scan_index + 1;

                
            end else begin
                scan_counter <= scan_counter + 1;
                seg_sel_n[scan_index] <= 1'b0; // 低电平选中当前数码管
            end
        end else begin
            seg_sel_n <= 6'b111111; // 关闭所有数码管
        end
    end
end

// ---- 段选输出逻辑 ----
assign seg_data = seg_decoder[seg_data_reg[scan_index][3:0]]  // 数字译码
                & {~seg_data_reg[scan_index][7], 7'hFF};        // 小数点控制

endmodule