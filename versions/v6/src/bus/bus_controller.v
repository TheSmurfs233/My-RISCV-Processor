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

/*
能够接入总线的标准:
时序电路实现读数据,当给出读地址后下一周期读出数据,具有一个时钟延迟
写数据支持字节写使能功能,一个4位宽的写使能信号,能够对字节进行写入(可选)
存储器具有双端口且读优先模式,当读写同时发生时,读出数据为写入的数据

目前只有BRAM支持字节写使能功能,即4位宽的写使能信号,GPIO和数码管外设不支持32位宽的字节写使能功能
遵循的设计原则为访问多少位宽的寄存器就使用对应的数据类型
例如GPIO外设是32位宽的,就定义数据类型为uin32_t,而数码管外设是8位宽的,就定义数据类型为uint8_t
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
    output reg  [ 3:0] mem_wen,    // 存储器写使能
    output reg  [31:0] mem_wdata,  // 存储器写数据
    input  wire [31:0] mem_rdata,  // 存储器读数据

    // GPIO外设接口
    output wire        gpio_sel,   // GPIO片选
    output wire [31:0] gpio_addr,  // GPIO寄存器地址
    output reg         gpio_wen ,  // GPIO写使能
    output reg  [31:0] gpio_wdata, // GPIO写数据
    input  wire [31:0] gpio_rdata,  // GPIO读数据

    // 8段数码管接口
    output wire        seg_led_sel, // 8段数码管片选
    output wire [31:0] seg_led_addr, // 8段数码管寄存器地址
    output reg         seg_led_wen, // 8段数码管写使能
    output reg  [31:0] seg_led_wdata, // 8段数码管写数据
    input  wire [31:0] seg_led_rdata // 8段数码管读数据
);

//-----------------------------------------------------------------
// 地址空间映射表
//-----------------------------------------------------------------
localparam MEM_BASE   = 32'h1001_0000;  // 存储器基地址  Slave1: DMEM
localparam MEM_SIZE   = 32'h0000_7FFF;  // 32KB存储空间

localparam GPIO_BASE  = 32'h1003_0000;  // GPIO基地址   Slave2: GPIO
localparam GPIO_SIZE  = 32'h0000_000F;  // 16字节空间

localparam SEG_LED_BASE = 32'h1003_0100; // 8段数码管基地址 Slave3: LED
localparam SEG_LED_SIZE = 32'h0000_0007; // 7字节空间

//-----------------------------------------------------------------
// 地址解码器
//-----------------------------------------------------------------
reg mem_select;
reg gpio_select;
reg seg_led_select;

reg invalid_select;

always @(*)
begin
    // 默认值
    mem_select    = 1'b0;
    gpio_select   = 1'b0;
    seg_led_select = 1'b0;
    invalid_select= 1'b0;

    // 存储器地址范围检测
    if (cpu_addr >= MEM_BASE && cpu_addr <= (MEM_BASE + MEM_SIZE))begin
        mem_select = 1'b1;    
    end
    // GPIO地址范围检测
    else if (cpu_addr >= GPIO_BASE && cpu_addr <= (GPIO_BASE + GPIO_SIZE))begin
        gpio_select = 1'b1;
    end
    // 数码管地址范围检测
    else if (cpu_addr >= SEG_LED_BASE && cpu_addr <= (SEG_LED_BASE + SEG_LED_SIZE))begin
        seg_led_select = 1'b1;
    end
    // 非法地址访问
    else begin
        invalid_select = 1'b1;
    end
end
//读数据存在一个周期的延迟,所以选择信号需要打一拍
reg mem_select_r;
reg gpio_select_r;
reg seg_led_select_r;
reg invalid_select_r;
always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        mem_select_r    <= 1'b0;
        gpio_select_r   <= 1'b0;
        seg_led_select_r <= 1'b0;
        invalid_select_r<= 1'b0;
    end
    else begin
        mem_select_r    <= mem_select;
        gpio_select_r   <= gpio_select;
        seg_led_select_r <= seg_led_select;
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
// 存储器接口信号 mem_addr, mem_wen, mem_wdata, mem_rdata
//-----------------------------------------------------------------
assign mem_sel  = mem_select;
// assign mem_wen  = (mem_select) && (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_WORD) || (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_HALF) || (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_BYTE); // 写使能信号
assign mem_addr = mem_sel ? (((cpu_addr - MEM_BASE) & 32'hFFFFFFFC) >> 2) : 32'bz; //将地址映射为RAM地址(字地址),因为RAM是按字访问的，所以需要将地址右移2位,并且低两位清零
wire [1:0] offset = cpu_addr[1:0]; // 地址的低两位
/*写数据的逻辑:
cpu_addr, cpu_ctrl,cpu_wdata分别为CPU的写地址信号、写控制信号和写数据信号,在同一周期内给出
原本是想写入操作放在CPU给出信号后当前周期完成,也就是在访存阶段对数据存储器(ram)给出写数据和写使能信号
但是riscv存在半字和字节写入操作,数据存储器的写入操作又是以32位为单位的,所以需要在CPU给出信号后,先对数据存储器的读操作,然后根据字节和半字写入控制信号在下一个周期对数据存储器进行写操作
所以在CPU看来,写指令在写回阶段才将数据写入到数据存储器中,而不是在访存阶段
----------------------------------
上面针对的是不支持字节写的情况,如果支持字节写,那么在访存阶段就可以直接将数据写入到数据存储器中,而不是在写回阶段
这里使用BRAM IP核,启用字节写使能
*/

// mem_wen:写使能信号
always @(*) begin
    if (rst_n == 1'b0) begin
        mem_wen = 4'b0000; //复位时写使能信号为0
    end
    else if(mem_sel == 1'b1) begin
        if (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_WORD) begin
            mem_wen = 4'b1111; //写使能信号为1111,表示写入32位数据
        end
        else if (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_HALF) begin
            case (offset) //根据地址的低两位判断是高16位还是低16位
                2'b00: mem_wen = 4'b0011; //低16位写使能信号为0011,表示写入低16位数据
                2'b10: mem_wen = 4'b1100; //高16位写使能信号为1100,表示写入高16位数据
                default: mem_wen = 4'b0000; //其他情况不允许写入
            endcase
        end
        else if (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_BYTE) begin
            case (offset) //根据地址的低两位判断是第几字节
                2'b00: mem_wen = 4'b0001; //第一个字节写使能信号为0001,表示写入第一个字节数据
                2'b01: mem_wen = 4'b0010; //第二个字节写使能信号为0010,表示写入第二个字节数据
                2'b10: mem_wen = 4'b0100; //第三个字节写使能信号为0100,表示写入第三个字节数据
                2'b11: mem_wen = 4'b1000; //第四个字节写使能信号为1000,表示写入第四个字节数据
                default: mem_wen = 4'b0000; //其他情况不允许写入
            endcase
        end
        else begin
            mem_wen = 4'b0000; //其他情况不允许写入
        end
    end
    else begin
        mem_wen = 4'b0000; //其他情况不允许写入
    end
end

//mem_wdata:写数据
always @(*) begin
    if (rst_n == 1'b0) begin
        mem_wdata = 32'bz; //复位时写数据为0
    end
    else if (mem_sel == 1'b1) begin
        case (cpu_ctrl)
            `MEM_ACCESS_TYPE_WRITE_WORD: begin
                mem_wdata = cpu_wdata; //写入32位数据
            end
            `MEM_ACCESS_TYPE_WRITE_HALF: begin
                case (offset) //根据地址的低两位判断是高16位还是低16位
                    2'b00: mem_wdata = (cpu_wdata & 32'h0000_FFFF)      ; //低16位写入数据
                    2'b10: mem_wdata = (cpu_wdata & 32'h0000_FFFF) << 16; //高16位写入数据
                    default: mem_wdata = 32'bz; //其他情况不允许写入
                endcase
            end
            `MEM_ACCESS_TYPE_WRITE_BYTE: begin
                case (offset) //根据地址的低两位判断是第几字节
                    2'b00: mem_wdata = (cpu_wdata & 32'h0000_00FF)      ; //第一个字节写入数据
                    2'b01: mem_wdata = (cpu_wdata & 32'h0000_00FF) <<  8; //第二个字节写入数据
                    2'b10: mem_wdata = (cpu_wdata & 32'h0000_00FF) << 16; //第三个字节写入数据
                    2'b11: mem_wdata = (cpu_wdata & 32'h0000_00FF) << 24;
                    default: mem_wdata = 32'b0; //其他情况不允许写入
                endcase
            end
            default: begin
                mem_wdata = 32'bz; //其他情况不允许写入
            end
        endcase
    end else begin
        mem_wdata = 32'bz; //其他情况不允许写入
    end
end


//-----------------------------------------------------------------
// GPIO接口信号
//-----------------------------------------------------------------
assign gpio_sel  = gpio_select;

assign gpio_addr = gpio_sel ?(((cpu_addr - GPIO_BASE) & 32'hFFFFFFFC) >> 2) : 32'bz; //将地址映射为RAM地址(字地址),因为RAM是按字访问的，所以需要将地址右移2位,并且低两位清零

// gpio_wen:写使能信号
always @(*) begin
    if (rst_n == 1'b0) begin
        gpio_wen = 1'b0; //复位时写使能信号为0
    end
    else if(gpio_sel == 1'b1) begin
        if (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_WORD) begin
            gpio_wen = 1'b1; //写使能信号为1111,表示写入32位数据
        end
        else if (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_HALF) begin
            gpio_wen = 1'b1;
        end
        else if (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_BYTE) begin
            gpio_wen = 1'b1;
        end
        else begin
            gpio_wen = 1'b0; //其他情况不允许写入
        end
    end
    else begin
        gpio_wen = 1'b0; //其他情况不允许写入
    end
end

//gpio_wdata:写数据
always @(*) begin
    if (rst_n == 1'b0) begin
        gpio_wdata = 32'bz; //复位时写数据为0
    end
    else if (gpio_sel == 1'b1) begin
        gpio_wdata = cpu_wdata; //写入32位数据
    end else begin
        gpio_wdata = 32'bz; //其他情况不允许写入
    end
end

//-----------------------------------------------------------------
// 8段数码管接口信号 不支持字节写入使能(使能信号位宽为0)
//-----------------------------------------------------------------
assign seg_led_sel  = seg_led_select;

assign seg_led_addr = seg_led_sel ?(cpu_addr - SEG_LED_BASE)  : 32'bz; //将地址映射为外设地址(字节地址)

// seg_led_wen:写使能信号
always @(*) begin
    if (rst_n == 1'b0) begin
        seg_led_wen = 1'b0; //复位时写使能信号为0
    end
    else if(seg_led_sel == 1'b1) begin
        if (cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_WORD || cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_HALF || cpu_ctrl == `MEM_ACCESS_TYPE_WRITE_BYTE) begin
            seg_led_wen = 1'b1; 
        end
        else begin
            seg_led_wen = 1'b0; //其他情况不允许写入
        end
    end
    else begin
        seg_led_wen = 1'b0; //其他情况不允许写入
    end
end

//seg_led_wdata:写数据
always @(*) begin
    if (rst_n == 1'b0) begin
        seg_led_wdata = 32'bz; //复位时写数据为0
    end
    else if (seg_led_sel == 1'b1) begin
        case (cpu_ctrl)
            `MEM_ACCESS_TYPE_WRITE_WORD: begin
                seg_led_wdata = cpu_wdata; //写入32位数据
            end
            `MEM_ACCESS_TYPE_WRITE_HALF: begin
                seg_led_wdata = (cpu_wdata & 32'h0000_FFFF);
            end
            `MEM_ACCESS_TYPE_WRITE_BYTE: begin
                seg_led_wdata = (cpu_wdata & 32'h0000_00FF);
            end
            default: begin
                seg_led_wdata = 32'bz; //其他情况不允许写入
            end
        endcase
    end else begin
        seg_led_wdata = 32'bz; //其他情况不允许写入
    end
end


//-----------------------------------------------------------------
// 读数据多路复用器
//-----------------------------------------------------------------
reg [31:0] read_mux;

always @(*)
begin
    case (1'b1)
        mem_select_r:  read_mux = mem_rdata;
        gpio_select_r: read_mux = gpio_rdata;
        seg_led_select_r: read_mux = seg_led_rdata;
        default:     read_mux = 32'hDEADBEEF; // 未映射地址返回特定值
    endcase
end

assign cpu_rdata = read_mux;

endmodule
