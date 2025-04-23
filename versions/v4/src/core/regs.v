/* -------寄存器堆模块-------- */

`include "defines.v"

module regs (
    input                            clk,
    input                            rst_n,

    input                            reg_wen,    // 寄存器写使能
    input      [`REG_ADDR_WIDTH-1:0] reg_waddr,  // 寄存器写地址
    input      [`CPU_WIDTH-1:0]      reg_wdata,  // 寄存器写数据

    input      [`REG_ADDR_WIDTH-1:0] reg1_raddr, // 寄存器1读地址
    input      [`REG_ADDR_WIDTH-1:0] reg2_raddr, // 寄存器2读地址
    output reg [`CPU_WIDTH-1:0]      reg1_rdata, // 寄存器1读数据
    output reg [`CPU_WIDTH-1:0]      reg2_rdata, // 寄存器2读数据

    input      [`REG_ADDR_WIDTH-1:0] ex_forward_addr,
    input                            ex_reg_wen,
    input      [`REG_ADDR_WIDTH-1:0] mem_forward_addr,
    input                            mem_reg_wen,
    input      [`REG_ADDR_WIDTH-1:0] wb_forward_addr,
    input                            wb_reg_wen,
    input      [`CPU_WIDTH-1:0]      ex_forward_data,
    input      [`CPU_WIDTH-1:0]      mem_forward_data,
    input      [`CPU_WIDTH-1:0]      wb_forward_data,
    input      [`MEM_ACCESS_TYPE_WIDTH-1:0]   id_ex_mem_access_type,
    output reg [1:0]                      forward_to_alu,
    

    input      [`MEM_ACCESS_TYPE_WIDTH-1:0]   ex_mem_mem_access_type,
    input                                     ex_mem_mem_sign_ext,
    input      [`CPU_WIDTH-1:0]               mem_forward_data_mem_rdata,
    input      [`MEM_ACCESS_TYPE_WIDTH-1:0]   mem_wb_mem_access_type,
    input                                     mem_wb_mem_sign_ext,
    input      [`CPU_WIDTH-1:0]               wb_forward_data_mem_rdata,

    //上板测试引出寄存器
    output wire [`CPU_WIDTH-1:0]      test_reg1,
    output wire [`CPU_WIDTH-1:0]      test_reg2
);
    
reg [`CPU_WIDTH-1:0] regs [0:`REG_DATA_DEPTH-1]; 

assign test_reg1 = regs[26];//s10_x26
assign test_reg2 = regs[27];//s11_x27
// register write
always @(posedge clk or negedge rst_n) begin
    if (rst_n && reg_wen && (reg_waddr != `REG_ADDR_WIDTH'b0)) // x0 read only
        regs[reg_waddr] <= reg_wdata; 
end

// register 1 read
// always @(*) begin
//     if(reg1_raddr == `REG_ADDR_WIDTH'b0)
//         reg1_rdata = `CPU_WIDTH'b0;
//     else
//         reg1_rdata = regs[reg1_raddr];
// end
always @(*) begin
    forward_to_alu[0] = 1'b0;
    if(reg1_raddr == `REG_ADDR_WIDTH'b0)begin
        reg1_rdata = `CPU_WIDTH'b0;
    end
    else if(reg1_raddr == ex_forward_addr && ex_reg_wen == 1'b1) begin    //上一条是访存指令，需要等待下一周期从mem中取出数据然后前递，此时本条指令已经执行到ex执行阶段，所以前递到ALU
        if (id_ex_mem_access_type == `MEM_ACCESS_TYPE_READ_BYTE || id_ex_mem_access_type == `MEM_ACCESS_TYPE_READ_HALF || id_ex_mem_access_type == `MEM_ACCESS_TYPE_READ_WORD) begin
            forward_to_alu[0] = 1'b1;
        end //如果上一条写存储器指令，那么ex阶段数据不需要前递，因为ALU计算出来的是地址数据，并非需要前递的写存储器数据
        else begin
            forward_to_alu[0] = 1'b0;
            reg1_rdata = ex_forward_data;
        end  
    end
    else if(reg1_raddr == mem_forward_addr && mem_reg_wen == 1'b1) begin
        case (ex_mem_mem_access_type)                                       
            `MEM_ACCESS_TYPE_READ_BYTE:begin
                case (mem_forward_data[1:0])
                    2'b00: reg1_rdata = ex_mem_mem_sign_ext ?{{24{mem_forward_data_mem_rdata[7]}},mem_forward_data_mem_rdata[7:0]}:{{24{1'b0}},mem_forward_data_mem_rdata[7:0]}; 
                    2'b01: reg1_rdata = ex_mem_mem_sign_ext ?{{24{mem_forward_data_mem_rdata[15]}},mem_forward_data_mem_rdata[15:8]}:{{24{1'b0}},mem_forward_data_mem_rdata[15:8]}; 
                    2'b10: reg1_rdata = ex_mem_mem_sign_ext ?{{24{mem_forward_data_mem_rdata[23]}},mem_forward_data_mem_rdata[23:16]}:{{24{1'b0}},mem_forward_data_mem_rdata[23:16]};  
                    2'b11: reg1_rdata = ex_mem_mem_sign_ext ?{{24{mem_forward_data_mem_rdata[31]}},mem_forward_data_mem_rdata[31:24]}:{{24{1'b0}},mem_forward_data_mem_rdata[31:24]};
                    default: reg1_rdata = mem_forward_data;
                endcase
            end
            `MEM_ACCESS_TYPE_READ_HALF: begin
                case (mem_forward_data[1])
                    1'b0: reg1_rdata = ex_mem_mem_sign_ext ?{{16{mem_forward_data_mem_rdata[15]}},mem_forward_data_mem_rdata[15:0]}:{{16{1'b0}},mem_forward_data_mem_rdata[15:0]}; 
                    1'b1: reg1_rdata = ex_mem_mem_sign_ext ?{{16{mem_forward_data_mem_rdata[31]}},mem_forward_data_mem_rdata[31:16]}:{{16{1'b0}},mem_forward_data_mem_rdata[31:16]};
                    default: reg1_rdata = mem_forward_data;
                endcase
            end
            `MEM_ACCESS_TYPE_READ_WORD: reg1_rdata = mem_forward_data_mem_rdata;
            default:  reg1_rdata = mem_forward_data;
        endcase
    end
    else if(reg1_raddr == wb_forward_addr && wb_reg_wen == 1'b1) begin
        case (mem_wb_mem_access_type)
            `MEM_ACCESS_TYPE_READ_BYTE:begin
                case (wb_forward_data[1:0])
                    2'b00: reg1_rdata = mem_wb_mem_sign_ext ?{{24{wb_forward_data_mem_rdata[7 ]}},wb_forward_data_mem_rdata[ 7: 0]}:{{24{1'b0}},wb_forward_data_mem_rdata[7:0]}; 
                    2'b01: reg1_rdata = mem_wb_mem_sign_ext ?{{24{wb_forward_data_mem_rdata[15]}},wb_forward_data_mem_rdata[15: 8]}:{{24{1'b0}},wb_forward_data_mem_rdata[15:8]}; 
                    2'b10: reg1_rdata = mem_wb_mem_sign_ext ?{{24{wb_forward_data_mem_rdata[23]}},wb_forward_data_mem_rdata[23:16]}:{{24{1'b0}},wb_forward_data_mem_rdata[23:16]};  
                    2'b11: reg1_rdata = mem_wb_mem_sign_ext ?{{24{wb_forward_data_mem_rdata[31]}},wb_forward_data_mem_rdata[31:24]}:{{24{1'b0}},wb_forward_data_mem_rdata[31:24]};
                    default: reg1_rdata = wb_forward_data;
                endcase
            end
            `MEM_ACCESS_TYPE_READ_HALF: begin
                case (wb_forward_data[1])
                    1'b0: reg1_rdata = mem_wb_mem_sign_ext ?{{16{wb_forward_data_mem_rdata[15]}},wb_forward_data_mem_rdata[15:0]}:{{16{1'b0}},wb_forward_data_mem_rdata[15:0]}; 
                    1'b1: reg1_rdata = mem_wb_mem_sign_ext ?{{16{wb_forward_data_mem_rdata[31]}},wb_forward_data_mem_rdata[31:16]}:{{16{1'b0}},wb_forward_data_mem_rdata[31:16]};
                    default: reg1_rdata = wb_forward_data;
                endcase
            end
            `MEM_ACCESS_TYPE_READ_WORD: reg1_rdata = wb_forward_data_mem_rdata;
            default:  reg1_rdata = wb_forward_data;
        endcase
    end
    else
        reg1_rdata = regs[reg1_raddr];
end

// register 2 read
// always @(*) begin
//     if(reg2_raddr == `REG_ADDR_WIDTH'b0)
//         reg2_rdata = `CPU_WIDTH'b0;
//     else
//         reg2_rdata = regs[reg2_raddr];
// end
always @(*) begin
    forward_to_alu[1] = 1'b0;
    if(reg2_raddr == `REG_ADDR_WIDTH'b0)begin
        reg2_rdata = `CPU_WIDTH'b0;
    end
    else if(reg2_raddr == ex_forward_addr  && ex_reg_wen == 1'b1) begin
        if (id_ex_mem_access_type == `MEM_ACCESS_TYPE_READ_BYTE || id_ex_mem_access_type == `MEM_ACCESS_TYPE_READ_HALF || id_ex_mem_access_type == `MEM_ACCESS_TYPE_READ_WORD) begin
            forward_to_alu[1] = 1'b1;
        end
        else begin
            forward_to_alu[1] = 1'b0;
            reg2_rdata = ex_forward_data;
        end   
    end
    else if(reg2_raddr == mem_forward_addr && mem_reg_wen == 1'b1) begin
        case (ex_mem_mem_access_type)                                       
            `MEM_ACCESS_TYPE_READ_BYTE:begin
                case (mem_forward_data[1:0])
                    2'b00: reg2_rdata = ex_mem_mem_sign_ext ?{{24{mem_forward_data_mem_rdata[7]}},mem_forward_data_mem_rdata[7:0]}:{{24{1'b0}},mem_forward_data_mem_rdata[7:0]}; 
                    2'b01: reg2_rdata = ex_mem_mem_sign_ext ?{{24{mem_forward_data_mem_rdata[15]}},mem_forward_data_mem_rdata[15:8]}:{{24{1'b0}},mem_forward_data_mem_rdata[15:8]}; 
                    2'b10: reg2_rdata = ex_mem_mem_sign_ext ?{{24{mem_forward_data_mem_rdata[23]}},mem_forward_data_mem_rdata[23:16]}:{{24{1'b0}},mem_forward_data_mem_rdata[23:16]};  
                    2'b11: reg2_rdata = ex_mem_mem_sign_ext ?{{24{mem_forward_data_mem_rdata[31]}},mem_forward_data_mem_rdata[31:24]}:{{24{1'b0}},mem_forward_data_mem_rdata[31:24]};
                    default: reg2_rdata = mem_forward_data;
                endcase
            end
            `MEM_ACCESS_TYPE_READ_HALF: begin
                case (mem_forward_data[1])
                    1'b0: reg2_rdata = ex_mem_mem_sign_ext ?{{16{mem_forward_data_mem_rdata[15]}},mem_forward_data_mem_rdata[15:0]}:{{16{1'b0}},mem_forward_data_mem_rdata[15:0]}; 
                    1'b1: reg2_rdata = ex_mem_mem_sign_ext ?{{16{mem_forward_data_mem_rdata[31]}},mem_forward_data_mem_rdata[31:16]}:{{16{1'b0}},mem_forward_data_mem_rdata[31:16]};
                    default: reg2_rdata = mem_forward_data;
                endcase
            end
            `MEM_ACCESS_TYPE_READ_WORD: reg2_rdata = mem_forward_data_mem_rdata;
            default:  reg2_rdata = mem_forward_data;
        endcase
    end
    else if(reg2_raddr == wb_forward_addr && wb_reg_wen == 1'b1) begin
        case (mem_wb_mem_access_type)
            `MEM_ACCESS_TYPE_READ_BYTE:begin
                case (wb_forward_data[1:0])
                    2'b00: reg2_rdata = mem_wb_mem_sign_ext ?{{24{wb_forward_data_mem_rdata[7 ]}},wb_forward_data_mem_rdata[ 7: 0]}:{{24{1'b0}},wb_forward_data_mem_rdata[7:0]}; 
                    2'b01: reg2_rdata = mem_wb_mem_sign_ext ?{{24{wb_forward_data_mem_rdata[15]}},wb_forward_data_mem_rdata[15: 8]}:{{24{1'b0}},wb_forward_data_mem_rdata[15:8]}; 
                    2'b10: reg2_rdata = mem_wb_mem_sign_ext ?{{24{wb_forward_data_mem_rdata[23]}},wb_forward_data_mem_rdata[23:16]}:{{24{1'b0}},wb_forward_data_mem_rdata[23:16]};  
                    2'b11: reg2_rdata = mem_wb_mem_sign_ext ?{{24{wb_forward_data_mem_rdata[31]}},wb_forward_data_mem_rdata[31:24]}:{{24{1'b0}},wb_forward_data_mem_rdata[31:24]};
                    default: reg2_rdata = wb_forward_data;
                endcase
            end
            `MEM_ACCESS_TYPE_READ_HALF: begin
                case (wb_forward_data[1])
                    1'b0: reg2_rdata = mem_wb_mem_sign_ext ?{{16{wb_forward_data_mem_rdata[15]}},wb_forward_data_mem_rdata[15:0]}:{{16{1'b0}},wb_forward_data_mem_rdata[15:0]}; 
                    1'b1: reg2_rdata = mem_wb_mem_sign_ext ?{{16{wb_forward_data_mem_rdata[31]}},wb_forward_data_mem_rdata[31:16]}:{{16{1'b0}},wb_forward_data_mem_rdata[31:16]};
                    default: reg2_rdata = wb_forward_data;
                endcase
            end
            `MEM_ACCESS_TYPE_READ_WORD: reg2_rdata = wb_forward_data_mem_rdata;
            default:  reg2_rdata = wb_forward_data;
        endcase
    end
    else
        reg2_rdata = regs[reg2_raddr];
end

endmodule
