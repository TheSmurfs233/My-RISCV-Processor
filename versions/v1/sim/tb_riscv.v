`timescale 1ns / 1ps
`include "../src/core/defines.v"
`include "../src/core/riscv.v"

module tb_riscv ();

reg                  clk;
reg                  rst_n;

reg [300-1:0]        inst_name;//指令文件名

initial begin
    #(`SIM_CLK_PERIOD/2);
    clk       = 1'b0;
    rst_n     = 1'b0;
    
    inst_name = "../../../tests/inst/LB";

    inst_load(inst_name);
    
    #(`SIM_CLK_PERIOD * 1);
    rst_n = 1'b1;
    #(`SIM_CLK_PERIOD * 500);
    $stop;
end

// register file
wire [`CPU_WIDTH-1:0] zero_x0  = u_riscv_0. u_regs_0. regs[0];
wire [`CPU_WIDTH-1:0] ra_x1    = u_riscv_0. u_regs_0. regs[1];
wire [`CPU_WIDTH-1:0] sp_x2    = u_riscv_0. u_regs_0. regs[2];
wire [`CPU_WIDTH-1:0] gp_x3    = u_riscv_0. u_regs_0. regs[3];
wire [`CPU_WIDTH-1:0] tp_x4    = u_riscv_0. u_regs_0. regs[4];
wire [`CPU_WIDTH-1:0] t0_x5    = u_riscv_0. u_regs_0. regs[5];
wire [`CPU_WIDTH-1:0] t1_x6    = u_riscv_0. u_regs_0. regs[6];
wire [`CPU_WIDTH-1:0] t2_x7    = u_riscv_0. u_regs_0. regs[7];
wire [`CPU_WIDTH-1:0] s0_fp_x8 = u_riscv_0. u_regs_0. regs[8];
wire [`CPU_WIDTH-1:0] s1_x9    = u_riscv_0. u_regs_0. regs[9];
wire [`CPU_WIDTH-1:0] a0_x10   = u_riscv_0. u_regs_0. regs[10];
wire [`CPU_WIDTH-1:0] a1_x11   = u_riscv_0. u_regs_0. regs[11];
wire [`CPU_WIDTH-1:0] a2_x12   = u_riscv_0. u_regs_0. regs[12];
wire [`CPU_WIDTH-1:0] a3_x13   = u_riscv_0. u_regs_0. regs[13];
wire [`CPU_WIDTH-1:0] a4_x14   = u_riscv_0. u_regs_0. regs[14];
wire [`CPU_WIDTH-1:0] a5_x15   = u_riscv_0. u_regs_0. regs[15];
wire [`CPU_WIDTH-1:0] a6_x16   = u_riscv_0. u_regs_0. regs[16];
wire [`CPU_WIDTH-1:0] a7_x17   = u_riscv_0. u_regs_0. regs[17];
wire [`CPU_WIDTH-1:0] s2_x18   = u_riscv_0. u_regs_0. regs[18];
wire [`CPU_WIDTH-1:0] s3_x19   = u_riscv_0. u_regs_0. regs[19];
wire [`CPU_WIDTH-1:0] s4_x20   = u_riscv_0. u_regs_0. regs[20];
wire [`CPU_WIDTH-1:0] s5_x21   = u_riscv_0. u_regs_0. regs[21];
wire [`CPU_WIDTH-1:0] s6_x22   = u_riscv_0. u_regs_0. regs[22];
wire [`CPU_WIDTH-1:0] s7_x23   = u_riscv_0. u_regs_0. regs[23];
wire [`CPU_WIDTH-1:0] s8_x24   = u_riscv_0. u_regs_0. regs[24];
wire [`CPU_WIDTH-1:0] s9_x25   = u_riscv_0. u_regs_0. regs[25];
wire [`CPU_WIDTH-1:0] s10_x26  = u_riscv_0. u_regs_0. regs[26];
wire [`CPU_WIDTH-1:0] s11_x27  = u_riscv_0. u_regs_0. regs[27];
wire [`CPU_WIDTH-1:0] t3_x28   = u_riscv_0. u_regs_0. regs[28];
wire [`CPU_WIDTH-1:0] t4_x29   = u_riscv_0. u_regs_0. regs[29];
wire [`CPU_WIDTH-1:0] t5_x30   = u_riscv_0. u_regs_0. regs[30];
wire [`CPU_WIDTH-1:0] t6_x31   = u_riscv_0. u_regs_0. regs[31];

integer r;
initial begin
    wait(s10_x26 == 32'b1)   // wait sim end, when x26 == 1
        #(`SIM_CLK_PERIOD * 1 + 1)
        if (s11_x27 == 32'b1) begin
            $display("~~~~~~~~~~~~~~~~~~~ %s PASS ~~~~~~~~~~~~~~~~~~~",inst_name[47:0]);
            $display("~~~~~~~~~~~~~~~~~~~  PASS ~~~~~~~~~~~~~~~~~~~");
            #(`SIM_CLK_PERIOD * 1);
        end 
        else begin
            $display("~~~~~~~~~~~~~~~~~~~ %s FAIL ~~~~~~~~~~~~~~~~~~~~",inst_name[47:0]);
            $display("~~~~~~~~~~~~~~~~~~~  FAIL ~~~~~~~~~~~~~~~~~~~");
            $display("fail testnum = %2d", gp_x3);
            #(`SIM_CLK_PERIOD * 1);
            $stop;
            for (r = 0; r < 32; r = r + 1)
                $display("x%2d = 0x%x", r, u_riscv_0. u_regs_0. regs[r]);
        end
end



initial begin
    #(`SIM_CLK_PERIOD * 50000);
    $display("Time Out");
    $finish;
end

always #(`SIM_CLK_PERIOD/2) clk = ~clk;

task reset;                // reset 1 clock
    begin
        rst_n = 0; 
        #(`SIM_CLK_PERIOD * 1);
        rst_n = 1;
    end
endtask

task inst_load;
    input [300-1:0] inst_name;
    begin
        $readmemh (inst_name, u_riscv_0.u_inst_mem_0.inst_mem);
        $display("Instructions loaded from: %s", inst_name);
    end
endtask

riscv u_riscv_0(
    .clk                            ( clk                           ),
    .rst_n                          ( rst_n                         )

);

// iverilog 
initial begin
    $dumpfile("sim_out.vcd");
    $dumpvars;
end

endmodule
