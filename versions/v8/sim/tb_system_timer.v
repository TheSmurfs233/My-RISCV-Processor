`timescale 1ns/1ps
module tb_system_timer();

reg clk;
reg rst_n;
reg sel;
reg [2:0] addr;
reg [31:0] wdata;
reg wen;
wire [31:0] rdata;
wire irq;

// 时钟生成（50MHz）
always #10 clk = ~clk;

system_timer dut (
    .clk(clk),
    .rst_n(rst_n),
    .sel(sel),
    .addr(addr),
    .wdata(wdata),
    .wen(wen),
    .rdata(rdata),
    .irq(irq)
);

initial begin
    // 初始化
    clk = 0;
    rst_n = 0;
    sel = 0;
    addr = 0;
    wdata = 0;
    wen = 0;
    
    // 复位相位
    #20 rst_n = 1;
    
    // 测试1：默认值验证
    $display("\n=== Test 1: Default Values ===");
    sel = 1;
    check_reg(3'b000, 0, "CTRL");
    check_reg(3'b001, 0, "LOAD_L");
    check_reg(3'b011, 0, "LOAD_H");
    check_reg(3'b010, 0, "VAL_L");
    check_reg(3'b100, 0, "VAL_H");
    
    // 测试2：装载值操作 & 手动重载
    $display("\n=== Test 2: Manual Load ===");
    sel = 1;
    write_reg(3'b001, 32'h2345_6789);   // LOAD_L = 0x0000_0001
    write_reg(3'b011, 32'h0000_0001);   // LOAD_H = 0x2345_6789
    write_reg(3'b010, 32'h0);           // 触发重载
    #20
    check_reg(3'b010, 32'h2345_6789, "VAL_L after reload");
    check_reg(3'b100, 32'h0000_0001, "VAL_H after reload");
    check_reg(3'b000, 32'h0, "COUNTFLAG after reload");
    
    // 测试3：读清除功能验证
    $display("\n=== Test 3: Read-Clear Function ===");
    write_reg(3'b001, 32'h0000_0030);   // LOAD_L = 0x0000_6789
    write_reg(3'b011, 32'h0000_0000);   // LOAD_H = 0x0000_0000
    write_reg(3'b010, 32'h0);           // 触发重载
    write_reg(3'b000, 32'h3);           // 使能定时器和中断
    wait(dut.counter == 64'h10);  // 等待接近重载
    #100; 
    sel = 0;
    #1000;
    
    // 等待计数翻到全F（触发重载）
    wait(irq == 1);
    $display("\n[IRQ Asserted @%0t]", $realtime);
    sel = 1;
    check_reg(3'b000, (1<<16)|3, "CTRL before read");
    
    @(negedge clk);
    read_reg(3'b000);                      // 这会触发清除
    #10
    check_reg(3'b000, 3, "CTRL after read"); // COUNTFLAG应清除
    
    // 测试4：写VAL清除验证
    $display("\n=== Test 4: Write VAL Clear ===");
    #100; // 等待自动触发IRQ
    write_reg(3'b010, 32'hABCD);  // 任意写VAL_L
    check_reg(3'b000, 3, "COUNTFLAG after VAL write");
    
    // 测试5：读VAL后不清除验证
    $display("\n=== Test 5: VAL Read Persistence ===");
    write_reg(3'b000, 0);       // 关闭定时器
    write_reg(3'b001, 32'h2);   // LOAD_L小值加速测试
    write_reg(3'b010, 0);       // 重载
    write_reg(3'b000, 32'h3);   // 重新使能
    
    wait(irq == 1);
    repeat(2) @(negedge clk);
    read_reg(3'b010);            // 读VAL_L
    check_reg(3'b000, (1<<16)|3, "COUNTFLAG persist after VAL read");
    
    // 测试6：中断禁用测试
    $display("\n=== Test 6: Interrupt Disable ===");
    write_reg(3'b000, 32'h1);   // 禁用中断
    write_reg(3'b010, 0);        // 重载后
    #100;
    check_reg(3'b000, 1<<16, "COUNTFLAG trigger");
    check_irq(0);               // 中断应不触发
    
    #100 $finish;
end

// 自动化检查任务
task check_reg;
    input [2:0] addr_in;
    input [31:0] expect_val;
    input [160:0] msg;
begin
    read_reg(addr_in);
    #20;
    if(rdata !== expect_val) begin
        $error("[ERROR] %s: Expected 0x%h, Got 0x%h", 
              msg, expect_val, rdata);
    end else begin
        $display("[PASS] %s: 0x%h", msg, rdata);
    end
end
endtask

task check_irq;
    input expect_val;
begin
    #1; // 时序对齐
    if(irq !== expect_val) begin
        $error("[ERROR] IRQ state error: Expected %b, Got %b",
              expect_val, irq);
    end else begin
        $display("[PASS] IRQ check: %b", irq);
    end
end
endtask

task read_reg;
    input [2:0] addr_in;
begin
    @(negedge clk);
    addr = addr_in;
    #1;
    $display("[READ] addr=0x%h => 0x%08h", addr_in, rdata);
end
endtask

task write_reg;
    input [2:0] addr_in;
    input [31:0] data;
begin
    @(negedge clk);
    wen = 1;
    addr = addr_in;
    wdata = data;
    @(negedge clk);
    wen = 0;
    $display("[WRITE] addr=0x%h <= 0x%08h", addr_in, data);
end
endtask

endmodule