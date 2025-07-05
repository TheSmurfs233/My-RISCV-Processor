`timescale 1ns / 1ps
module tb_gpio();
    reg clk_50m;
    reg rst_n;
    reg pll_locked;
    reg gpio_wen;
    reg [31:0] gpio_addr;
    reg [31:0] gpio_wdata;
    wire [31:0] gpio_rdata;
    wire [1:0] gpio;          // 双向端口
    reg [1:0] external_drv;  // 外部驱动模拟

    //gpio模块
    wire[1:0] io_in;
    wire[31:0] gpio_ctrl;
    wire[31:0] gpio_data;
    // 双向信号驱动控制

    // io0  
    assign gpio[0] = (gpio_ctrl[1:0] == 2'b01)? gpio_data[0]: external_drv[0];  
    assign io_in[0] = gpio[0];  
    // io1  
    assign gpio[1] = (gpio_ctrl[3:2] == 2'b01)? gpio_data[1]: external_drv[1];  
    assign io_in[1] = gpio[1];  
    
    // 实例化被测系统
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
    // 时钟生成（50MHz）
    always #10 clk_50m = ~clk_50m;

    // 冲突检测任务
    task check_conflict;
        input [1:0] pin;
        if(gpio[pin] === 1'bx) begin
            $display("[ERROR] @%0t: GPIO%0d has bus conflict!", $time, pin);
            $finish;
        end
    endtask

    initial begin
        // 初始化
        clk_50m = 0;
        rst_n = 0;
        pll_locked = 0;
        gpio_wen = 0;
        gpio_addr = 0;
        gpio_wdata = 0;
        external_drv = 2'bzz;  // 初始外部高阻

        // 复位序列
        #20 rst_n = 1;
        #10 pll_locked = 1;
        #20;

        // 测试1：复位后寄存器状态
        if(gpio_ctrl !== 32'h0 || gpio_data !== 32'h0)
            $display("Test1 Failed: Reset values error");
        else
            $display("Test1 Passed");
        
        #40

        // 测试2：配置GPIO0为输出，GPIO1为输入
        gpio_wen = 1;
        gpio_addr = 32'h0;          // CTRL寄存器地址
        gpio_wdata = 32'h00000009;  // GPIO0:01（输出）, GPIO1:10（输入）
        #20;
        // @(posedge clk_50m);
        gpio_wen = 0;
        
        if(gpio_ctrl !== 32'h9)
            $display("Test2 Failed: CTRL register write error");
        else
            $display("Test2 Passed");
        #40

        // 测试3：GPIO0输出测试
        gpio_wen = 1;
        gpio_addr = 32'h1;  // DATA寄存器地址
        gpio_wdata = 32'h1; // GPIO0输出高电平
        #20;
        // @(posedge clk_50m);
        gpio_wen = 0;
        
        check_conflict(0);
        if(gpio[0] !== 1'b1)
            $display("Test3 Failed: GPIO0 output error");
        else
            $display("Test3 Passed");
        #40

        // 测试4：GPIO1输入测试
        external_drv[1] = 1'b1;  // 外部驱动GPIO1为高
        #50;
        if(gpio_data[1] !== 1'b1)
            $display("Test4 Failed: GPIO1 input error");
        else
            $display("Test4 Passed");
        #40

        // 测试5：双向端口冲突测试
        external_drv[0] = 1'b0;  // 尝试驱动输出模式的GPIO0
        #20;
        check_conflict(0);  // 应检测到总线冲突

        // 测试6：高阻态输入测试
        gpio_wen = 1;
        gpio_addr = 32'h0;
        gpio_wdata = 32'h00000008;  // GPIO0设为高阻(00)
        // @(posedge clk_50m);
        #20;
        gpio_wen = 0;
        external_drv[0] = 1'b1;  // 外部驱动高电平
        #20;
        if(gpio_data[0] !== 1'b1)
            $display("Test6 Failed: Hi-Z input error");
        else
            $display("Test6 Passed");
        #40

        // 测试7：动态模式切换
        gpio_wen = 1;
        gpio_addr = 32'h0;
        gpio_wdata = 32'h00000005;  // GPIO0:01（输出）, GPIO1:01（输出）
        @(posedge clk_50m);
        gpio_wen = 0;
        gpio_addr = 32'h1;
        gpio_wdata = 32'h3;  // 输出全高
        @(posedge clk_50m);
        #20;
        if(gpio !== 2'b11)
            $display("Test7 Failed: Mode switch error");
        else
            $display("Test7 Passed");

        $display("All tests completed");
        $finish;
    end

    // 波形记录
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_gpio);
    end
endmodule