module soc_top(
    input                               clk,
    input                               rst_n,
    output wire [1:0]                   led,

    // GPIO外设接口
    inout  wire [1:0]                   gpio,

    // 数码管外设接口
    output wire [5:0]   seg_sel_n,    // 位选信号（低有效，驱动PNP三极管）
    output wire [7:0]   seg_data      // 段选信号（a~g + 小数点，共阴极）
);
/*
指令集架构：RISC-V基本整数指令集
*/
wire clk_50m;
wire pll_locked;

clk_wiz_0 clk_wiz_0_inst(
    // Clock out ports
    .clk_50m(clk_50m),     // output clk_50m
    // Status and control signals
    .resetn(1'b1), // input resetn
    .locked(pll_locked),       // output locked
    // Clock in ports
    .clk_in1(clk)
);      // input clk_in1

wire [31:0] cpu_addr;
wire [2:0]  cpu_ctrl;
wire [31:0] cpu_wdata;
wire [31:0] cpu_rdata;
wire bus_error;

riscv  u_riscv_0 (
    .clk                            (clk_50m                       ),
    .rst_n                          (rst_n && pll_locked           ),
    .sys_bus_addr_o                 (cpu_addr                      ),
    .sys_bus_access_type            (cpu_ctrl                      ),
    .sys_bus_rdata_i                (cpu_rdata                     ),
    .sys_bus_wdata_o                (cpu_wdata                     ),
    .led                            (led                           )
);


wire mem_sel;
wire [ 3:0] mem_wen;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [31:0] mem_rdata;

wire gpio_sel;
wire gpio_wen;
wire [31:0] gpio_addr;
wire [31:0] gpio_wdata;
wire [31:0] gpio_rdata;

wire seg_led_sel;
wire seg_led_wen;
wire [31:0] seg_led_addr;
wire [31:0] seg_led_wdata;
wire [31:0] seg_led_rdata;

wire system_timer_sel;
wire [31:0] system_timer_addr;
wire system_timer_wen;
wire [31:0] system_timer_wdata;
wire [31:0] system_timer_rdata;
wire system_timer_irq;

//总线控制器
bus_controller  bus_controller_inst (
    .clk                            (clk_50m                       ),
    .rst_n                          (rst_n && pll_locked           ),

    //CPU总线接口
    .cpu_addr                       (cpu_addr                      ),
    .cpu_ctrl                       (cpu_ctrl                      ),
    .cpu_wdata                      (cpu_wdata                     ),
    .cpu_rdata                      (cpu_rdata                     ),
    .bus_error                      (bus_error                     ),

    //数据存储器总线接口
    .mem_sel                        (mem_sel                       ),
    .mem_wen                        (mem_wen                       ),
    .mem_addr                       (mem_addr                      ),
    .mem_wdata                      (mem_wdata                     ),
    .mem_rdata                      (mem_rdata                     ),

    //GPIO总线接口
    .gpio_sel                       (gpio_sel                      ),
    .gpio_wen                       (gpio_wen                      ),
    .gpio_addr                      (gpio_addr                     ),
    .gpio_wdata                     (gpio_wdata                    ),
    .gpio_rdata                     (gpio_rdata                    ),

    //八段数码管外设总线接口
    .seg_led_sel                    (seg_led_sel                   ),
    .seg_led_addr                   (seg_led_addr                  ),
    .seg_led_wen                    (seg_led_wen                   ),
    .seg_led_wdata                  (seg_led_wdata                 ),
    .seg_led_rdata                  (seg_led_rdata                 ),

    //系统定时器总线接口
    .system_timer_sel               (system_timer_sel              ),
    .system_timer_addr              (system_timer_addr             ),
    .system_timer_wen               (system_timer_wen              ),
    .system_timer_wdata             (system_timer_wdata            ),
    .system_timer_rdata             (system_timer_rdata            ),
    .system_timer_irq               (system_timer_irq              )
);


//数据存储器模块
data_mem u_data_mem_0 (
    .clka(clk_50m),    // input wire clka
    .wea(mem_wen),      // input wire [3 : 0] wea
    .addra(mem_addr),  // input wire [4 : 0] addra
    .dina(mem_wdata),    // input wire [31 : 0] dina
    .clkb(clk_50m),    // input wire clkb
    .addrb(mem_addr),  // input wire [4 : 0] addrb
    .doutb(mem_rdata)  // output wire [31 : 0] doutb
);

//gpio模块
parameter GPIO_NUM = 16;
wire[1:0] io_in;
wire[31:0] gpio_ctrl; // 01:输出  10:输入  00:高阻
wire[31:0] gpio_data;

// 批量生成GPIO输入输出逻辑
generate
    genvar i;
    for (i = 0; i < GPIO_NUM; i = i + 1) begin : gpio_assign
        // 输出逻辑:若控制位为2'b01则输出数据，否则高阻态
        assign gpio[i] = (gpio_ctrl[2*i +: 2] == 2'b01) ? gpio_data[i] : 1'bz;
        // 输入逻辑:实时捕获IO引脚状态
        assign io_in[i] = gpio[i];
    end
endgenerate

// // io0  
// assign gpio[0] = (gpio_ctrl[1:0] == 2'b01)? gpio_data[0]: 1'bz;  
// assign io_in[0] = gpio[0];  
// // io1  
// assign gpio[1] = (gpio_ctrl[3:2] == 2'b01)? gpio_data[1]: 1'bz;  
// assign io_in[1] = gpio[1];  

gpio  # (
    .GPIO_NUM(GPIO_NUM)
)gpio_inst (
    .clk(clk_50m),
    .rst_n(rst_n && pll_locked),
    .we_i(gpio_wen),
    .addr_i(gpio_addr),
    .data_i(gpio_wdata),
    .data_o(gpio_rdata),
    .io_pin_i(io_in),
    .reg_ctrl(gpio_ctrl),
    .reg_data(gpio_data)
);


//8段数码管外设

seg_led  seg_led_inst (
    .clk(clk_50m),
    .rst_n(rst_n && pll_locked),
    .psel(seg_led_sel),
    .penable(1),
    .paddr(seg_led_addr),
    .pwrite(seg_led_wen),
    .pwdata(seg_led_wdata),
    .prdata(seg_led_rdata),
    .seg_sel_n(seg_sel_n),
    .seg_data(seg_data)
);


// 系统定时器
system_timer  system_timer_inst (
    .clk(clk_50m),
    .rst_n(rst_n && pll_locked),
    .sel(system_timer_sel),
    .addr(system_timer_addr),
    .wdata(system_timer_wdata),
    .wen(system_timer_wen),
    .rdata(system_timer_rdata),
    .irq(system_timer_irq)
);


endmodule

