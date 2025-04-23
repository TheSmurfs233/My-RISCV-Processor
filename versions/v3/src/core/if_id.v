/*----- 取指译码流水线寄存 -----*/
`include "defines.v"

module if_id(
    input   wire                    clk,
    input   wire                    pipeline_flush,
    input   wire [`CPU_WIDTH-1:0]   inst,
    input   wire [`CPU_WIDTH-1:0]   curr_pc,
    input   wire [`CPU_WIDTH-1:0]   next_pc,
    input   wire                    control_hazard,

    output  reg  [`CPU_WIDTH-1:0]   if_id_inst,
    output  reg  [`CPU_WIDTH-1:0]   if_id_curr_pc,
    output  reg  [`CPU_WIDTH-1:0]   if_id_next_pc,
    output  reg                     if_id_control_hazard
);

    always @(posedge clk ) begin
        if (pipeline_flush == 1) begin
            if_id_inst      <= `CPU_WIDTH'h0;
            if_id_curr_pc   <= `CPU_WIDTH'h0;
            if_id_next_pc   <= `CPU_WIDTH'h0;
            if_id_control_hazard <= 1'b0;
        end
        else begin
            if_id_inst      <= inst;
            if_id_curr_pc   <= curr_pc;
            if_id_next_pc   <= next_pc;
            if_id_control_hazard <= control_hazard;
        end
    end
endmodule