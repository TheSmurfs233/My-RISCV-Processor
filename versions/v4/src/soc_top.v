module soc_top(
    input                               clk,
    input                               rst_n,
    output wire [1:0]                   led,

    inout  wire [1:0]                   gpio
);
/*
指令集架构：RISC-V基本整数指令集
指令地址:   0x0000_0000 程序默认从这个地址开始执行
GPIO基地址: 0x0000_2000

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
wire [ 3:0] gpio_wen;
wire [31:0] gpio_addr;
wire [31:0] gpio_wdata;
wire [31:0] gpio_rdata;


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
    .gpio_rdata                     (gpio_rdata                    )
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
wire[1:0] io_in;
wire[31:0] gpio_ctrl;
wire[31:0] gpio_data;

// io0  
assign gpio[0] = (gpio_ctrl[1:0] == 2'b01)? gpio_data[0]: 1'bz;  // 01:输出  10:输入  00:高阻
assign io_in[0] = gpio[0];  
// io1  
assign gpio[1] = (gpio_ctrl[3:2] == 2'b01)? gpio_data[1]: 1'bz;  
assign io_in[1] = gpio[1];  

gpio  gpio_inst (
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
endmodule

