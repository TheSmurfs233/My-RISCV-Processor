`timescale 1ns/1ps

module tb_seg_led();
    reg          clk;
    reg          rst_n;
    reg          psel;
    reg          penable;
    reg  [4:0]   paddr;
    reg          pwrite;
    reg  [31:0]  pwdata;
    wire [31:0]  prdata;
    wire [5:0]   seg_sel_n;
    wire [7:0]   seg_data;

    // 实例化被测模块
    seg_led u_seg_led (
        .clk        (clk),
        .rst_n      (rst_n),
        .psel       (psel),
        .penable    (penable),
        .paddr      (paddr),
        .pwrite     (pwrite),
        .pwdata     (pwdata),
        .prdata     (prdata),
        .seg_sel_n  (seg_sel_n),
        .seg_data   (seg_data)
    );

    // 时钟生成（50MHz）
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 20ns周期 = 50MHz
    end

    // 复位初始化
    initial begin
        rst_n = 0;
        psel = 0;
        penable = 0;
        paddr = 0;
        pwrite = 0;
        pwdata = 0;
        #100;
        rst_n = 1;
        // #100;
        
        // ---------------------------
        // 测试用例开始
        // ---------------------------
        
        // 测试1: 复位后寄存器默认值
        check_reset_values();
        
        // 测试2: 写入段数据寄存器
        apb_write(5'h00, 32'h1); // 数码管0显示"A"
        apb_write(5'h01, 32'hA); // 数码管1显示"5"
        apb_write(5'h06, 32'h01); // 使能扫描
        
        // 测试3: 读取寄存器验证写入
        apb_read(5'h00, 32'h00000001);
        apb_read(5'h01, 32'h0000000A);
        
        // 测试4: 观察扫描过程
        #2_000_000; // 观察2ms扫描过程
        
        // 测试5: 关闭扫描
        apb_write(5'h6, 32'h00);
        #100_000;
        
        $display("All tests passed!");
        $finish;
        seg_led.seg_data_reg[0]=8'h01;
        seg_led.seg_data_reg[1]=8'h02;
        seg_led.seg_data_reg[2]=8'h03;
        seg_led.seg_data_reg[3]=8'h04;
        seg_led.seg_data_reg[4]=8'h0A;
        seg_led.seg_data_reg[5]=8'h0F; 
        apb_write(5'h6, 32'h01);
    end

    // ---------------------------
    // APB总线读写任务
    // ---------------------------
    task apb_write;
        input [4:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            psel = 1;
            paddr = addr;
            pwrite = 1;
            pwdata = data;
            @(posedge clk);
            
            penable = 1;
            @(posedge clk);
            psel = 0;
            penable = 0;
            #20;
        end
    endtask

    task apb_read;
        input [4:0] addr;
        input [31:0] expected_data;
        begin
            @(posedge clk);
            psel = 1;
            paddr = addr;
            pwrite = 0;
            @(posedge clk);
            penable = 1;
            @(posedge clk);
            if (prdata !== expected_data) begin
                $display("ERROR: Addr 0x%h Read 0x%h, Expected 0x%h", 
                        addr, prdata, expected_data);
                $finish;
            end
            psel = 0;
            penable = 0;
            #20;
        end
    endtask

    // ---------------------------
    // 复位值检查任务
    // ---------------------------
    task check_reset_values;
        begin
            if (seg_sel_n !== 6'b111_111) begin
                $display("ERROR: seg_sel_n reset value %b", seg_sel_n);
                $finish;
            end
            if (prdata !== 32'h0) begin
                $display("ERROR: prdata reset value %h", prdata);
                $finish;
            end
        end
    endtask

    // ---------------------------
    // 实时监控输出信号
    // ---------------------------
    // always @(posedge clk) begin
    //     if (seg_sel_n !== 6'b111_111) begin
    //         $display("[%t] Display Seg:%d Data:0x%h", 
    //                 $time, seg_sel_n, seg_data);
    //     end
    // end

endmodule