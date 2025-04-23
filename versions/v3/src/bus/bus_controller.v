`include "../core/defines.v"



/*
           +------------+       +-----------------+
           |            |       |  地址解码器      |
CPU ------▶|  总线控制器 |-------|-----------------|-----▶ 数据存储器 (0x0000~0x7FFF)
           |            |       | 控制信号生成器   |
           +------------+       +-----------------+
                                     |
                                     ▼
                                 GPIO外设 (0x8000~0x800F)

                                 
           ┌───────────────────────────────────────────────┐
           │                  CPU 主设备                     │
           │                                               │
           │         ┌──────────┐      ┌──────────┐         │
           │         │  地址总线 │      │  数据总线 │         │
           │         │  (32-bit)│      │  (32-bit)│         │
           │         └────┬─────┘      └────┬─────┘         │
           │              │                 │              │
           │              ▼                 ▼              │
           └─────────────┼──────────────────┼──────────────┘
                         │                  │
                         │                  │
           ┌─────────────▼──────────────────▼──────────────┐
           │             总线控制器模块                    │
           │  ┌────────────────────────────────────────┐  │
           │  │            地址解码器                   │  │
           │  │ 0x00000000-0x00007FFF → 数据存储器       │  │
           │  │ 0x00008000-0x0000800F → GPIO外设        │  │
           │  └──────────────────┬─────────────────────┘  │
           │           │         │          │             │
           │           │         │          │             │
           │  ┌────────▼─┐ ┌─────▼──────┐ ┌─▼────────┐    │
           │  │控制信号   │ │读数据选择器 │ │错误检测   │    │
           │  │生成器     │ │(MUX)       │ │(地址对齐/ │    │
           │  └────┬──────┘ └─────┬──────┘ │非法地址)  │    │
           └───────┼──────────────┼────────┼───────────┘
                   │              │        │
          ┌────────┴───┐    ┌─────┴─────┐  │
          ▼            ▼    ▼           ▼  ▼
┌─────────────────┐  ┌─────────────────┐  ┌───────────────┐
│  数据存储器      │  │  GPIO外设       │  │  总线错误信号  │
│                 │  │                 │  │  (bus_error)  │
│ 接口信号：       │  │ 接口信号：      │  │               │
│ - mem_sel       │  │ - gpio_sel     │  └───────────────┘
│ - mem_addr[14:0]│  │ - gpio_addr[3:0]
│ - mem_we        │  │ - gpio_we      
│ - mem_wdata     │  │ - gpio_wdata   
└─────────────────┘  └─────────────────┘
*/



// 总线控制器模块
module bus_controller(
    // 全局信号
    input         clk,        // 时钟（上升沿有效）
    input         rst_n,      // 异步复位（低有效）

    // CPU主设备接口
    input  wire [31:0] cpu_addr,   // 地址总线
    input  wire [ 2:0] cpu_ctrl,   // CPU读写控制信号
    input  wire [31:0] cpu_wdata,  // 写数据
    output wire [31:0] cpu_rdata,  // 读数据
    output wire        bus_error,  // 总线错误指示

    // 数据存储器接口
    output wire        mem_sel,    // 存储器片选
    output wire [31:0] mem_addr,   // 存储器地址（32KB空间）
    output wire        mem_wen,    // 存储器写使能
    output reg  [31:0] mem_wdata,  // 存储器写数据
    input  wire [31:0] mem_rdata,  // 存储器读数据

    // GPIO外设接口
    output wire        gpio_sel,   // GPIO片选
    output wire [ 3:0] gpio_addr,  // GPIO寄存器地址
    output wire        gpio_wen ,  // GPIO写使能
    output wire [31:0] gpio_wdata, // GPIO写数据
    input  wire [31:0] gpio_rdata  // GPIO读数据
);

//-----------------------------------------------------------------
// 地址空间映射表
//-----------------------------------------------------------------
localparam MEM_BASE   = 32'h0000_1000;  // 存储器基地址  Slave1: DMEM
localparam MEM_SIZE   = 32'h0000_7FFF;  // 32KB存储空间

localparam GPIO_BASE  = 32'h0000_8000;  // GPIO基地址   Slave2: GPIO
localparam GPIO_SIZE  = 32'h0000_000F;  // 16字节空间

//-----------------------------------------------------------------
// 地址解码器
//-----------------------------------------------------------------
reg mem_select;
reg gpio_select;
reg invalid_select;

always @(*)
begin
    // 默认值
    mem_select    = 1'b0;
    gpio_select   = 1'b0;
    invalid_select= 1'b0;

    // 存储器地址范围检测
    if (cpu_addr >= MEM_BASE && cpu_addr <= (MEM_BASE + MEM_SIZE))begin
        mem_select = 1'b1;    
    end
    // GPIO地址范围检测
    else if (cpu_addr >= GPIO_BASE && cpu_addr <= (GPIO_BASE + GPIO_SIZE))begin
        gpio_select = 1'b1;
    end
    // 非法地址访问
    else begin
        invalid_select = 1'b1;
    end
end
//读数据存在一个周期的延迟,所以选择信号需要打一拍
reg mem_select_r;
reg gpio_select_r;
reg invalid_select_r;
always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        mem_select_r    <= 1'b0;
        gpio_select_r   <= 1'b0;
        invalid_select_r<= 1'b0;
    end
    else begin
        mem_select_r    <= mem_select;
        gpio_select_r   <= gpio_select;
        invalid_select_r<= invalid_select;
    end
end

//-----------------------------------------------------------------
// 地址对齐检查（32位字访问）
//-----------------------------------------------------------------
wire addr_aligned = (cpu_addr[1:0] == 2'b00);

//-----------------------------------------------------------------
// 错误信号生成
//-----------------------------------------------------------------
assign bus_error = invalid_select | ~addr_aligned;

//-----------------------------------------------------------------
// 存储器接口信号
//-----------------------------------------------------------------
assign mem_sel  = mem_select;
assign mem_wen  = (mem_select) && (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_WORD) || (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_HALF) || (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_BYTE); // 写使能信号
assign mem_addr = mem_select ? ((cpu_addr - MEM_BASE) >> 2) : 0; //将cpu地址映射为RAM地址


//mem_wdata:写数据
always @(*) begin
    if (mem_wen == 1'b1) begin
        case (cpu_ctrl)
            `MEM_ACCESS_TYPE_WRITE_BYTE: begin
                case (mem_addr[1:0]) 
                    2'b00: mem_wdata = {mem_rdata[31: 8], cpu_wdata[ 7:0]                 };
                    2'b01: mem_wdata = {mem_rdata[31:16], cpu_wdata[ 7:0], mem_rdata[ 7:0]};
                    2'b10: mem_wdata = {mem_rdata[31:24], cpu_wdata[ 7:0], mem_rdata[15:0]};
                    2'b11: mem_wdata = {cpu_wdata[ 7: 0], mem_rdata[23:0]                 };
                endcase
            end
            `MEM_ACCESS_TYPE_WRITE_HALF: begin
                case (mem_addr[1:0])
                    2'b00: mem_wdata = {mem_rdata[31:16], cpu_wdata[15:0]                 };
                    2'b01: mem_wdata = {mem_rdata[31:24], cpu_wdata[15:0], mem_rdata[ 7:0]};
                    2'b10: mem_wdata = {cpu_wdata[15: 0], mem_rdata[15:0]                 };
                    2'b11: mem_wdata = {cpu_wdata[ 7: 0], mem_rdata[23:8], cpu_wdata[15:8]};
                endcase
            end
            `MEM_ACCESS_TYPE_WRITE_WORD: begin
                mem_wdata = cpu_wdata;
            end
        endcase
    end
end


//-----------------------------------------------------------------
// GPIO接口信号
//-----------------------------------------------------------------
assign gpio_sel   = gpio_select;
// assign gpio_we    = gpio_select ? cpu_we : 1'b0;
assign gpio_addr  = cpu_addr[5:2];  // 寄存器偏移地址（每寄存器4字节）
assign gpio_wdata = cpu_wdata;

//-----------------------------------------------------------------
// 读数据多路复用器
//-----------------------------------------------------------------
reg [31:0] read_mux;

always @(*)
begin
    case (1'b1)
        mem_select_r:  read_mux = mem_rdata;
        gpio_select_r: read_mux = gpio_rdata;
        default:     read_mux = 32'hDEADBEEF; // 未映射地址返回特定值
    endcase
end

assign cpu_rdata = read_mux;

endmodule
