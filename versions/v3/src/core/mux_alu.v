/* -------ALU多路选择器模块-------- */
// 选择ALU的输入数据，包括寄存器数据、立即数、PC+4、或其他
// ALU模块进行运算，mux_alu模块选择ALU的输入数据源

`include "defines.v"

module mux_alu ( 
    input      [`ALU_SRC_WIDTH-1:0]             alu_src_sel,// ALU 输入数据源选择信号

    input      [`CPU_WIDTH-1:0]                 reg1_rdata, // 寄存器1读出数据
    input      [`CPU_WIDTH-1:0]                 reg2_rdata, // 寄存器2读出数据
    input      [`CPU_WIDTH-1:0]                 imm,        // 立即数
    input      [`CPU_WIDTH-1:0]                 curr_pc,    // 当前pc地址

    output reg [`CPU_WIDTH-1:0]                 alu_src1,   // ALU 源1
    output reg [`CPU_WIDTH-1:0]                 alu_src2,   // ALU 源2
    input      [1:0]                            forward_to_alu,
    input      [`CPU_WIDTH-1:0]                 mem_forward_data,
    input      [`MEM_ACCESS_TYPE_WIDTH-1:0]     ex_mem_mem_access_type,
    input                                       ex_mem_mem_sign_ext,
    input      [`CPU_WIDTH-1:0]                 ex_mem_alu_res
    
);

always @(*) begin
    alu_src1 = reg1_rdata;     // 默认选择reg1数据
    alu_src2 = reg2_rdata;     // 默认选择reg2数据
    case (alu_src_sel)
        `ALU_SRC_REG: begin
            if (forward_to_alu[0] == 1'b1) begin    // 到alu的前递数据
                case (ex_mem_mem_access_type)
                    `MEM_ACCESS_TYPE_READ_WORD: alu_src1 = mem_forward_data; 
                    `MEM_ACCESS_TYPE_READ_HALF: begin
                        case (ex_mem_alu_res[1])
                            1'b0: alu_src1 = ex_mem_mem_sign_ext ?{{16{mem_forward_data[15]}},mem_forward_data[15:0]}:{{16{1'b0}},mem_forward_data[15:0]}; 
                            1'b1: alu_src1 = ex_mem_mem_sign_ext ?{{16{mem_forward_data[31]}},mem_forward_data[31:16]}:{{16{1'b0}},mem_forward_data[31:16]};
                            default: alu_src1 = mem_forward_data;
                        endcase
                    end
                    `MEM_ACCESS_TYPE_READ_BYTE: begin
                        case (ex_mem_alu_res[1:0])
                            2'b00: alu_src1 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[7]}},mem_forward_data[7:0]}:{{24{1'b0}},mem_forward_data[7:0]}; 
                            2'b01: alu_src1 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[15]}},mem_forward_data[15:8]}:{{24{1'b0}},mem_forward_data[15:8]}; 
                            2'b10: alu_src1 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[23]}},mem_forward_data[23:16]}:{{24{1'b0}},mem_forward_data[23:16]}; 
                            2'b11: alu_src1 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[31]}},mem_forward_data[31:24]}:{{24{1'b0}},mem_forward_data[31:24]};
                            default: alu_src1 = mem_forward_data;
                        endcase
                    end
                    default: alu_src1 = mem_forward_data; 
                endcase
            end
            else if(forward_to_alu[1] == 1'b1) begin
                case (ex_mem_mem_access_type)
                `MEM_ACCESS_TYPE_READ_WORD: alu_src2 = mem_forward_data; 
                `MEM_ACCESS_TYPE_READ_HALF: begin
                    case (ex_mem_alu_res[1])
                        1'b0: alu_src2 = ex_mem_mem_sign_ext ?{{16{mem_forward_data[15]}},mem_forward_data[15:0]}:{{16{1'b0}},mem_forward_data[15:0]}; 
                        1'b1: alu_src2 = ex_mem_mem_sign_ext ?{{16{mem_forward_data[31]}},mem_forward_data[31:16]}:{{16{1'b0}},mem_forward_data[31:16]};
                        default: alu_src2 = mem_forward_data;
                    endcase
                end
                `MEM_ACCESS_TYPE_READ_BYTE: begin
                    case (ex_mem_alu_res[1:0])
                        2'b00: alu_src2 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[7]}},mem_forward_data[7:0]}:{{24{1'b0}},mem_forward_data[7:0]}; 
                        2'b01: alu_src2 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[15]}},mem_forward_data[15:8]}:{{24{1'b0}},mem_forward_data[15:8]}; 
                        2'b10: alu_src2 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[23]}},mem_forward_data[23:16]}:{{24{1'b0}},mem_forward_data[23:16]}; 
                        2'b11: alu_src2 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[31]}},mem_forward_data[31:24]}:{{24{1'b0}},mem_forward_data[31:24]};
                        default: alu_src2 = mem_forward_data;
                    endcase
                end
                default: alu_src2 = mem_forward_data; 
            endcase
            end
            else begin
                alu_src2 = reg2_rdata;     // 来自于寄存器，选择reg1数据
            end
        end
        `ALU_SRC_IMM: begin
            if (forward_to_alu[0] == 1'b1) begin // 前递数据
                case (ex_mem_mem_access_type)
                    `MEM_ACCESS_TYPE_READ_WORD: alu_src1 = mem_forward_data; 
                    `MEM_ACCESS_TYPE_READ_HALF: begin
                        case (ex_mem_alu_res[1])
                            1'b0: alu_src1 = ex_mem_mem_sign_ext ?{{16{mem_forward_data[15]}},mem_forward_data[15:0]}:{{16{1'b0}},mem_forward_data[15:0]}; 
                            1'b1: alu_src1 = ex_mem_mem_sign_ext ?{{16{mem_forward_data[31]}},mem_forward_data[31:16]}:{{16{1'b0}},mem_forward_data[31:16]};
                            default: alu_src1 = mem_forward_data;
                        endcase
                    end
                    `MEM_ACCESS_TYPE_READ_BYTE: begin
                        case (ex_mem_alu_res[1:0])
                            2'b00: alu_src1 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[7]}},mem_forward_data[7:0]}:{{24{1'b0}},mem_forward_data[7:0]}; 
                            2'b01: alu_src1 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[15]}},mem_forward_data[15:8]}:{{24{1'b0}},mem_forward_data[15:8]}; 
                            2'b10: alu_src1 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[23]}},mem_forward_data[23:16]}:{{24{1'b0}},mem_forward_data[23:16]}; 
                            2'b11: alu_src1 = ex_mem_mem_sign_ext ?{{24{mem_forward_data[31]}},mem_forward_data[31:24]}:{{24{1'b0}},mem_forward_data[31:24]};
                            default: alu_src1 = mem_forward_data;
                        endcase
                    end
                    default: alu_src1 = mem_forward_data; 
                endcase
            end
            alu_src2 = imm;        // 来自于立即数，选择立即数
        end
        `ALU_SRC_FOUR_PC: begin
            alu_src1 = `CPU_WIDTH'h4; // pc + 4 
            alu_src2 = curr_pc;       //
        end
        `ALU_SRC_IMM_PC: begin  
            alu_src1 = imm;
            alu_src2 = curr_pc;
        end
    endcase

end
endmodule
