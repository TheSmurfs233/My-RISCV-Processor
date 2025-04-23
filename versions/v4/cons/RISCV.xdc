set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN R2 [get_ports {led[0]}]
set_property PACKAGE_PIN R3 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property PACKAGE_PIN R4 [get_ports clk]
set_property PACKAGE_PIN U2 [get_ports rst_n]

create_clock -period 20.000 -name clk [get_ports clk]












create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_wiz_0_inst/inst/clk_50m]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_riscv_0/alu_res[0]} {u_riscv_0/alu_res[1]} {u_riscv_0/alu_res[2]} {u_riscv_0/alu_res[3]} {u_riscv_0/alu_res[4]} {u_riscv_0/alu_res[5]} {u_riscv_0/alu_res[6]} {u_riscv_0/alu_res[7]} {u_riscv_0/alu_res[8]} {u_riscv_0/alu_res[9]} {u_riscv_0/alu_res[10]} {u_riscv_0/alu_res[11]} {u_riscv_0/alu_res[12]} {u_riscv_0/alu_res[13]} {u_riscv_0/alu_res[14]} {u_riscv_0/alu_res[15]} {u_riscv_0/alu_res[16]} {u_riscv_0/alu_res[17]} {u_riscv_0/alu_res[18]} {u_riscv_0/alu_res[19]} {u_riscv_0/alu_res[20]} {u_riscv_0/alu_res[21]} {u_riscv_0/alu_res[22]} {u_riscv_0/alu_res[23]} {u_riscv_0/alu_res[24]} {u_riscv_0/alu_res[25]} {u_riscv_0/alu_res[26]} {u_riscv_0/alu_res[27]} {u_riscv_0/alu_res[28]} {u_riscv_0/alu_res[29]} {u_riscv_0/alu_res[30]} {u_riscv_0/alu_res[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_riscv_0/ex_mem_next_pc[0]} {u_riscv_0/ex_mem_next_pc[1]} {u_riscv_0/ex_mem_next_pc[2]} {u_riscv_0/ex_mem_next_pc[3]} {u_riscv_0/ex_mem_next_pc[4]} {u_riscv_0/ex_mem_next_pc[5]} {u_riscv_0/ex_mem_next_pc[6]} {u_riscv_0/ex_mem_next_pc[7]} {u_riscv_0/ex_mem_next_pc[8]} {u_riscv_0/ex_mem_next_pc[9]} {u_riscv_0/ex_mem_next_pc[10]} {u_riscv_0/ex_mem_next_pc[11]} {u_riscv_0/ex_mem_next_pc[12]} {u_riscv_0/ex_mem_next_pc[13]} {u_riscv_0/ex_mem_next_pc[14]} {u_riscv_0/ex_mem_next_pc[15]} {u_riscv_0/ex_mem_next_pc[16]} {u_riscv_0/ex_mem_next_pc[17]} {u_riscv_0/ex_mem_next_pc[18]} {u_riscv_0/ex_mem_next_pc[19]} {u_riscv_0/ex_mem_next_pc[20]} {u_riscv_0/ex_mem_next_pc[21]} {u_riscv_0/ex_mem_next_pc[22]} {u_riscv_0/ex_mem_next_pc[23]} {u_riscv_0/ex_mem_next_pc[24]} {u_riscv_0/ex_mem_next_pc[25]} {u_riscv_0/ex_mem_next_pc[26]} {u_riscv_0/ex_mem_next_pc[27]} {u_riscv_0/ex_mem_next_pc[28]} {u_riscv_0/ex_mem_next_pc[29]} {u_riscv_0/ex_mem_next_pc[30]} {u_riscv_0/ex_mem_next_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 5 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_riscv_0/ex_mem_reg2_raddr[0]} {u_riscv_0/ex_mem_reg2_raddr[1]} {u_riscv_0/ex_mem_reg2_raddr[2]} {u_riscv_0/ex_mem_reg2_raddr[3]} {u_riscv_0/ex_mem_reg2_raddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 5 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_riscv_0/ex_mem_reg_waddr[0]} {u_riscv_0/ex_mem_reg_waddr[1]} {u_riscv_0/ex_mem_reg_waddr[2]} {u_riscv_0/ex_mem_reg_waddr[3]} {u_riscv_0/ex_mem_reg_waddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 32 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {u_riscv_0/curr_pc[0]} {u_riscv_0/curr_pc[1]} {u_riscv_0/curr_pc[2]} {u_riscv_0/curr_pc[3]} {u_riscv_0/curr_pc[4]} {u_riscv_0/curr_pc[5]} {u_riscv_0/curr_pc[6]} {u_riscv_0/curr_pc[7]} {u_riscv_0/curr_pc[8]} {u_riscv_0/curr_pc[9]} {u_riscv_0/curr_pc[10]} {u_riscv_0/curr_pc[11]} {u_riscv_0/curr_pc[12]} {u_riscv_0/curr_pc[13]} {u_riscv_0/curr_pc[14]} {u_riscv_0/curr_pc[15]} {u_riscv_0/curr_pc[16]} {u_riscv_0/curr_pc[17]} {u_riscv_0/curr_pc[18]} {u_riscv_0/curr_pc[19]} {u_riscv_0/curr_pc[20]} {u_riscv_0/curr_pc[21]} {u_riscv_0/curr_pc[22]} {u_riscv_0/curr_pc[23]} {u_riscv_0/curr_pc[24]} {u_riscv_0/curr_pc[25]} {u_riscv_0/curr_pc[26]} {u_riscv_0/curr_pc[27]} {u_riscv_0/curr_pc[28]} {u_riscv_0/curr_pc[29]} {u_riscv_0/curr_pc[30]} {u_riscv_0/curr_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 5 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {u_riscv_0/alu_op[0]} {u_riscv_0/alu_op[1]} {u_riscv_0/alu_op[2]} {u_riscv_0/alu_op[3]} {u_riscv_0/alu_op[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 2 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {u_riscv_0/id_ex_alu_src_sel[0]} {u_riscv_0/id_ex_alu_src_sel[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 2 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {u_riscv_0/id_ex_forward_to_alu[0]} {u_riscv_0/id_ex_forward_to_alu[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 5 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {u_riscv_0/ex_mem_reg1_raddr[0]} {u_riscv_0/ex_mem_reg1_raddr[1]} {u_riscv_0/ex_mem_reg1_raddr[2]} {u_riscv_0/ex_mem_reg1_raddr[3]} {u_riscv_0/ex_mem_reg1_raddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 32 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {u_riscv_0/id_ex_imm[0]} {u_riscv_0/id_ex_imm[1]} {u_riscv_0/id_ex_imm[2]} {u_riscv_0/id_ex_imm[3]} {u_riscv_0/id_ex_imm[4]} {u_riscv_0/id_ex_imm[5]} {u_riscv_0/id_ex_imm[6]} {u_riscv_0/id_ex_imm[7]} {u_riscv_0/id_ex_imm[8]} {u_riscv_0/id_ex_imm[9]} {u_riscv_0/id_ex_imm[10]} {u_riscv_0/id_ex_imm[11]} {u_riscv_0/id_ex_imm[12]} {u_riscv_0/id_ex_imm[13]} {u_riscv_0/id_ex_imm[14]} {u_riscv_0/id_ex_imm[15]} {u_riscv_0/id_ex_imm[16]} {u_riscv_0/id_ex_imm[17]} {u_riscv_0/id_ex_imm[18]} {u_riscv_0/id_ex_imm[19]} {u_riscv_0/id_ex_imm[20]} {u_riscv_0/id_ex_imm[21]} {u_riscv_0/id_ex_imm[22]} {u_riscv_0/id_ex_imm[23]} {u_riscv_0/id_ex_imm[24]} {u_riscv_0/id_ex_imm[25]} {u_riscv_0/id_ex_imm[26]} {u_riscv_0/id_ex_imm[27]} {u_riscv_0/id_ex_imm[28]} {u_riscv_0/id_ex_imm[29]} {u_riscv_0/id_ex_imm[30]} {u_riscv_0/id_ex_imm[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 3 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {u_riscv_0/id_ex_mem_access_type[0]} {u_riscv_0/id_ex_mem_access_type[1]} {u_riscv_0/id_ex_mem_access_type[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 32 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {u_riscv_0/ex_mem_curr_pc[0]} {u_riscv_0/ex_mem_curr_pc[1]} {u_riscv_0/ex_mem_curr_pc[2]} {u_riscv_0/ex_mem_curr_pc[3]} {u_riscv_0/ex_mem_curr_pc[4]} {u_riscv_0/ex_mem_curr_pc[5]} {u_riscv_0/ex_mem_curr_pc[6]} {u_riscv_0/ex_mem_curr_pc[7]} {u_riscv_0/ex_mem_curr_pc[8]} {u_riscv_0/ex_mem_curr_pc[9]} {u_riscv_0/ex_mem_curr_pc[10]} {u_riscv_0/ex_mem_curr_pc[11]} {u_riscv_0/ex_mem_curr_pc[12]} {u_riscv_0/ex_mem_curr_pc[13]} {u_riscv_0/ex_mem_curr_pc[14]} {u_riscv_0/ex_mem_curr_pc[15]} {u_riscv_0/ex_mem_curr_pc[16]} {u_riscv_0/ex_mem_curr_pc[17]} {u_riscv_0/ex_mem_curr_pc[18]} {u_riscv_0/ex_mem_curr_pc[19]} {u_riscv_0/ex_mem_curr_pc[20]} {u_riscv_0/ex_mem_curr_pc[21]} {u_riscv_0/ex_mem_curr_pc[22]} {u_riscv_0/ex_mem_curr_pc[23]} {u_riscv_0/ex_mem_curr_pc[24]} {u_riscv_0/ex_mem_curr_pc[25]} {u_riscv_0/ex_mem_curr_pc[26]} {u_riscv_0/ex_mem_curr_pc[27]} {u_riscv_0/ex_mem_curr_pc[28]} {u_riscv_0/ex_mem_curr_pc[29]} {u_riscv_0/ex_mem_curr_pc[30]} {u_riscv_0/ex_mem_curr_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 32 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {u_riscv_0/id_ex_inst[0]} {u_riscv_0/id_ex_inst[1]} {u_riscv_0/id_ex_inst[2]} {u_riscv_0/id_ex_inst[3]} {u_riscv_0/id_ex_inst[4]} {u_riscv_0/id_ex_inst[5]} {u_riscv_0/id_ex_inst[6]} {u_riscv_0/id_ex_inst[7]} {u_riscv_0/id_ex_inst[8]} {u_riscv_0/id_ex_inst[9]} {u_riscv_0/id_ex_inst[10]} {u_riscv_0/id_ex_inst[11]} {u_riscv_0/id_ex_inst[12]} {u_riscv_0/id_ex_inst[13]} {u_riscv_0/id_ex_inst[14]} {u_riscv_0/id_ex_inst[15]} {u_riscv_0/id_ex_inst[16]} {u_riscv_0/id_ex_inst[17]} {u_riscv_0/id_ex_inst[18]} {u_riscv_0/id_ex_inst[19]} {u_riscv_0/id_ex_inst[20]} {u_riscv_0/id_ex_inst[21]} {u_riscv_0/id_ex_inst[22]} {u_riscv_0/id_ex_inst[23]} {u_riscv_0/id_ex_inst[24]} {u_riscv_0/id_ex_inst[25]} {u_riscv_0/id_ex_inst[26]} {u_riscv_0/id_ex_inst[27]} {u_riscv_0/id_ex_inst[28]} {u_riscv_0/id_ex_inst[29]} {u_riscv_0/id_ex_inst[30]} {u_riscv_0/id_ex_inst[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 5 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {u_riscv_0/id_ex_reg1_raddr[0]} {u_riscv_0/id_ex_reg1_raddr[1]} {u_riscv_0/id_ex_reg1_raddr[2]} {u_riscv_0/id_ex_reg1_raddr[3]} {u_riscv_0/id_ex_reg1_raddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 32 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {u_riscv_0/id_ex_reg1_rdata[0]} {u_riscv_0/id_ex_reg1_rdata[1]} {u_riscv_0/id_ex_reg1_rdata[2]} {u_riscv_0/id_ex_reg1_rdata[3]} {u_riscv_0/id_ex_reg1_rdata[4]} {u_riscv_0/id_ex_reg1_rdata[5]} {u_riscv_0/id_ex_reg1_rdata[6]} {u_riscv_0/id_ex_reg1_rdata[7]} {u_riscv_0/id_ex_reg1_rdata[8]} {u_riscv_0/id_ex_reg1_rdata[9]} {u_riscv_0/id_ex_reg1_rdata[10]} {u_riscv_0/id_ex_reg1_rdata[11]} {u_riscv_0/id_ex_reg1_rdata[12]} {u_riscv_0/id_ex_reg1_rdata[13]} {u_riscv_0/id_ex_reg1_rdata[14]} {u_riscv_0/id_ex_reg1_rdata[15]} {u_riscv_0/id_ex_reg1_rdata[16]} {u_riscv_0/id_ex_reg1_rdata[17]} {u_riscv_0/id_ex_reg1_rdata[18]} {u_riscv_0/id_ex_reg1_rdata[19]} {u_riscv_0/id_ex_reg1_rdata[20]} {u_riscv_0/id_ex_reg1_rdata[21]} {u_riscv_0/id_ex_reg1_rdata[22]} {u_riscv_0/id_ex_reg1_rdata[23]} {u_riscv_0/id_ex_reg1_rdata[24]} {u_riscv_0/id_ex_reg1_rdata[25]} {u_riscv_0/id_ex_reg1_rdata[26]} {u_riscv_0/id_ex_reg1_rdata[27]} {u_riscv_0/id_ex_reg1_rdata[28]} {u_riscv_0/id_ex_reg1_rdata[29]} {u_riscv_0/id_ex_reg1_rdata[30]} {u_riscv_0/id_ex_reg1_rdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 32 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {u_riscv_0/alu_src1[0]} {u_riscv_0/alu_src1[1]} {u_riscv_0/alu_src1[2]} {u_riscv_0/alu_src1[3]} {u_riscv_0/alu_src1[4]} {u_riscv_0/alu_src1[5]} {u_riscv_0/alu_src1[6]} {u_riscv_0/alu_src1[7]} {u_riscv_0/alu_src1[8]} {u_riscv_0/alu_src1[9]} {u_riscv_0/alu_src1[10]} {u_riscv_0/alu_src1[11]} {u_riscv_0/alu_src1[12]} {u_riscv_0/alu_src1[13]} {u_riscv_0/alu_src1[14]} {u_riscv_0/alu_src1[15]} {u_riscv_0/alu_src1[16]} {u_riscv_0/alu_src1[17]} {u_riscv_0/alu_src1[18]} {u_riscv_0/alu_src1[19]} {u_riscv_0/alu_src1[20]} {u_riscv_0/alu_src1[21]} {u_riscv_0/alu_src1[22]} {u_riscv_0/alu_src1[23]} {u_riscv_0/alu_src1[24]} {u_riscv_0/alu_src1[25]} {u_riscv_0/alu_src1[26]} {u_riscv_0/alu_src1[27]} {u_riscv_0/alu_src1[28]} {u_riscv_0/alu_src1[29]} {u_riscv_0/alu_src1[30]} {u_riscv_0/alu_src1[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 2 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {u_riscv_0/forward_to_alu[0]} {u_riscv_0/forward_to_alu[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 32 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {u_riscv_0/id_ex_curr_pc[0]} {u_riscv_0/id_ex_curr_pc[1]} {u_riscv_0/id_ex_curr_pc[2]} {u_riscv_0/id_ex_curr_pc[3]} {u_riscv_0/id_ex_curr_pc[4]} {u_riscv_0/id_ex_curr_pc[5]} {u_riscv_0/id_ex_curr_pc[6]} {u_riscv_0/id_ex_curr_pc[7]} {u_riscv_0/id_ex_curr_pc[8]} {u_riscv_0/id_ex_curr_pc[9]} {u_riscv_0/id_ex_curr_pc[10]} {u_riscv_0/id_ex_curr_pc[11]} {u_riscv_0/id_ex_curr_pc[12]} {u_riscv_0/id_ex_curr_pc[13]} {u_riscv_0/id_ex_curr_pc[14]} {u_riscv_0/id_ex_curr_pc[15]} {u_riscv_0/id_ex_curr_pc[16]} {u_riscv_0/id_ex_curr_pc[17]} {u_riscv_0/id_ex_curr_pc[18]} {u_riscv_0/id_ex_curr_pc[19]} {u_riscv_0/id_ex_curr_pc[20]} {u_riscv_0/id_ex_curr_pc[21]} {u_riscv_0/id_ex_curr_pc[22]} {u_riscv_0/id_ex_curr_pc[23]} {u_riscv_0/id_ex_curr_pc[24]} {u_riscv_0/id_ex_curr_pc[25]} {u_riscv_0/id_ex_curr_pc[26]} {u_riscv_0/id_ex_curr_pc[27]} {u_riscv_0/id_ex_curr_pc[28]} {u_riscv_0/id_ex_curr_pc[29]} {u_riscv_0/id_ex_curr_pc[30]} {u_riscv_0/id_ex_curr_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 32 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {u_riscv_0/alu_src2[0]} {u_riscv_0/alu_src2[1]} {u_riscv_0/alu_src2[2]} {u_riscv_0/alu_src2[3]} {u_riscv_0/alu_src2[4]} {u_riscv_0/alu_src2[5]} {u_riscv_0/alu_src2[6]} {u_riscv_0/alu_src2[7]} {u_riscv_0/alu_src2[8]} {u_riscv_0/alu_src2[9]} {u_riscv_0/alu_src2[10]} {u_riscv_0/alu_src2[11]} {u_riscv_0/alu_src2[12]} {u_riscv_0/alu_src2[13]} {u_riscv_0/alu_src2[14]} {u_riscv_0/alu_src2[15]} {u_riscv_0/alu_src2[16]} {u_riscv_0/alu_src2[17]} {u_riscv_0/alu_src2[18]} {u_riscv_0/alu_src2[19]} {u_riscv_0/alu_src2[20]} {u_riscv_0/alu_src2[21]} {u_riscv_0/alu_src2[22]} {u_riscv_0/alu_src2[23]} {u_riscv_0/alu_src2[24]} {u_riscv_0/alu_src2[25]} {u_riscv_0/alu_src2[26]} {u_riscv_0/alu_src2[27]} {u_riscv_0/alu_src2[28]} {u_riscv_0/alu_src2[29]} {u_riscv_0/alu_src2[30]} {u_riscv_0/alu_src2[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 3 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {u_riscv_0/ex_mem_mem_access_type[0]} {u_riscv_0/ex_mem_mem_access_type[1]} {u_riscv_0/ex_mem_mem_access_type[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 32 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {u_riscv_0/ex_mem_reg2_rdata[0]} {u_riscv_0/ex_mem_reg2_rdata[1]} {u_riscv_0/ex_mem_reg2_rdata[2]} {u_riscv_0/ex_mem_reg2_rdata[3]} {u_riscv_0/ex_mem_reg2_rdata[4]} {u_riscv_0/ex_mem_reg2_rdata[5]} {u_riscv_0/ex_mem_reg2_rdata[6]} {u_riscv_0/ex_mem_reg2_rdata[7]} {u_riscv_0/ex_mem_reg2_rdata[8]} {u_riscv_0/ex_mem_reg2_rdata[9]} {u_riscv_0/ex_mem_reg2_rdata[10]} {u_riscv_0/ex_mem_reg2_rdata[11]} {u_riscv_0/ex_mem_reg2_rdata[12]} {u_riscv_0/ex_mem_reg2_rdata[13]} {u_riscv_0/ex_mem_reg2_rdata[14]} {u_riscv_0/ex_mem_reg2_rdata[15]} {u_riscv_0/ex_mem_reg2_rdata[16]} {u_riscv_0/ex_mem_reg2_rdata[17]} {u_riscv_0/ex_mem_reg2_rdata[18]} {u_riscv_0/ex_mem_reg2_rdata[19]} {u_riscv_0/ex_mem_reg2_rdata[20]} {u_riscv_0/ex_mem_reg2_rdata[21]} {u_riscv_0/ex_mem_reg2_rdata[22]} {u_riscv_0/ex_mem_reg2_rdata[23]} {u_riscv_0/ex_mem_reg2_rdata[24]} {u_riscv_0/ex_mem_reg2_rdata[25]} {u_riscv_0/ex_mem_reg2_rdata[26]} {u_riscv_0/ex_mem_reg2_rdata[27]} {u_riscv_0/ex_mem_reg2_rdata[28]} {u_riscv_0/ex_mem_reg2_rdata[29]} {u_riscv_0/ex_mem_reg2_rdata[30]} {u_riscv_0/ex_mem_reg2_rdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 32 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {u_riscv_0/ex_mem_inst[0]} {u_riscv_0/ex_mem_inst[1]} {u_riscv_0/ex_mem_inst[2]} {u_riscv_0/ex_mem_inst[3]} {u_riscv_0/ex_mem_inst[4]} {u_riscv_0/ex_mem_inst[5]} {u_riscv_0/ex_mem_inst[6]} {u_riscv_0/ex_mem_inst[7]} {u_riscv_0/ex_mem_inst[8]} {u_riscv_0/ex_mem_inst[9]} {u_riscv_0/ex_mem_inst[10]} {u_riscv_0/ex_mem_inst[11]} {u_riscv_0/ex_mem_inst[12]} {u_riscv_0/ex_mem_inst[13]} {u_riscv_0/ex_mem_inst[14]} {u_riscv_0/ex_mem_inst[15]} {u_riscv_0/ex_mem_inst[16]} {u_riscv_0/ex_mem_inst[17]} {u_riscv_0/ex_mem_inst[18]} {u_riscv_0/ex_mem_inst[19]} {u_riscv_0/ex_mem_inst[20]} {u_riscv_0/ex_mem_inst[21]} {u_riscv_0/ex_mem_inst[22]} {u_riscv_0/ex_mem_inst[23]} {u_riscv_0/ex_mem_inst[24]} {u_riscv_0/ex_mem_inst[25]} {u_riscv_0/ex_mem_inst[26]} {u_riscv_0/ex_mem_inst[27]} {u_riscv_0/ex_mem_inst[28]} {u_riscv_0/ex_mem_inst[29]} {u_riscv_0/ex_mem_inst[30]} {u_riscv_0/ex_mem_inst[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 5 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {u_riscv_0/id_ex_alu_op[0]} {u_riscv_0/id_ex_alu_op[1]} {u_riscv_0/id_ex_alu_op[2]} {u_riscv_0/id_ex_alu_op[3]} {u_riscv_0/id_ex_alu_op[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 32 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {u_riscv_0/ex_mem_alu_res[0]} {u_riscv_0/ex_mem_alu_res[1]} {u_riscv_0/ex_mem_alu_res[2]} {u_riscv_0/ex_mem_alu_res[3]} {u_riscv_0/ex_mem_alu_res[4]} {u_riscv_0/ex_mem_alu_res[5]} {u_riscv_0/ex_mem_alu_res[6]} {u_riscv_0/ex_mem_alu_res[7]} {u_riscv_0/ex_mem_alu_res[8]} {u_riscv_0/ex_mem_alu_res[9]} {u_riscv_0/ex_mem_alu_res[10]} {u_riscv_0/ex_mem_alu_res[11]} {u_riscv_0/ex_mem_alu_res[12]} {u_riscv_0/ex_mem_alu_res[13]} {u_riscv_0/ex_mem_alu_res[14]} {u_riscv_0/ex_mem_alu_res[15]} {u_riscv_0/ex_mem_alu_res[16]} {u_riscv_0/ex_mem_alu_res[17]} {u_riscv_0/ex_mem_alu_res[18]} {u_riscv_0/ex_mem_alu_res[19]} {u_riscv_0/ex_mem_alu_res[20]} {u_riscv_0/ex_mem_alu_res[21]} {u_riscv_0/ex_mem_alu_res[22]} {u_riscv_0/ex_mem_alu_res[23]} {u_riscv_0/ex_mem_alu_res[24]} {u_riscv_0/ex_mem_alu_res[25]} {u_riscv_0/ex_mem_alu_res[26]} {u_riscv_0/ex_mem_alu_res[27]} {u_riscv_0/ex_mem_alu_res[28]} {u_riscv_0/ex_mem_alu_res[29]} {u_riscv_0/ex_mem_alu_res[30]} {u_riscv_0/ex_mem_alu_res[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 5 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {u_riscv_0/id_ex_reg2_raddr[0]} {u_riscv_0/id_ex_reg2_raddr[1]} {u_riscv_0/id_ex_reg2_raddr[2]} {u_riscv_0/id_ex_reg2_raddr[3]} {u_riscv_0/id_ex_reg2_raddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 32 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {u_riscv_0/id_ex_next_pc[0]} {u_riscv_0/id_ex_next_pc[1]} {u_riscv_0/id_ex_next_pc[2]} {u_riscv_0/id_ex_next_pc[3]} {u_riscv_0/id_ex_next_pc[4]} {u_riscv_0/id_ex_next_pc[5]} {u_riscv_0/id_ex_next_pc[6]} {u_riscv_0/id_ex_next_pc[7]} {u_riscv_0/id_ex_next_pc[8]} {u_riscv_0/id_ex_next_pc[9]} {u_riscv_0/id_ex_next_pc[10]} {u_riscv_0/id_ex_next_pc[11]} {u_riscv_0/id_ex_next_pc[12]} {u_riscv_0/id_ex_next_pc[13]} {u_riscv_0/id_ex_next_pc[14]} {u_riscv_0/id_ex_next_pc[15]} {u_riscv_0/id_ex_next_pc[16]} {u_riscv_0/id_ex_next_pc[17]} {u_riscv_0/id_ex_next_pc[18]} {u_riscv_0/id_ex_next_pc[19]} {u_riscv_0/id_ex_next_pc[20]} {u_riscv_0/id_ex_next_pc[21]} {u_riscv_0/id_ex_next_pc[22]} {u_riscv_0/id_ex_next_pc[23]} {u_riscv_0/id_ex_next_pc[24]} {u_riscv_0/id_ex_next_pc[25]} {u_riscv_0/id_ex_next_pc[26]} {u_riscv_0/id_ex_next_pc[27]} {u_riscv_0/id_ex_next_pc[28]} {u_riscv_0/id_ex_next_pc[29]} {u_riscv_0/id_ex_next_pc[30]} {u_riscv_0/id_ex_next_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 3 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {cpu_ctrl[0]} {cpu_ctrl[1]} {cpu_ctrl[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 32 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list {u_riscv_0/id_ex_reg2_rdata[0]} {u_riscv_0/id_ex_reg2_rdata[1]} {u_riscv_0/id_ex_reg2_rdata[2]} {u_riscv_0/id_ex_reg2_rdata[3]} {u_riscv_0/id_ex_reg2_rdata[4]} {u_riscv_0/id_ex_reg2_rdata[5]} {u_riscv_0/id_ex_reg2_rdata[6]} {u_riscv_0/id_ex_reg2_rdata[7]} {u_riscv_0/id_ex_reg2_rdata[8]} {u_riscv_0/id_ex_reg2_rdata[9]} {u_riscv_0/id_ex_reg2_rdata[10]} {u_riscv_0/id_ex_reg2_rdata[11]} {u_riscv_0/id_ex_reg2_rdata[12]} {u_riscv_0/id_ex_reg2_rdata[13]} {u_riscv_0/id_ex_reg2_rdata[14]} {u_riscv_0/id_ex_reg2_rdata[15]} {u_riscv_0/id_ex_reg2_rdata[16]} {u_riscv_0/id_ex_reg2_rdata[17]} {u_riscv_0/id_ex_reg2_rdata[18]} {u_riscv_0/id_ex_reg2_rdata[19]} {u_riscv_0/id_ex_reg2_rdata[20]} {u_riscv_0/id_ex_reg2_rdata[21]} {u_riscv_0/id_ex_reg2_rdata[22]} {u_riscv_0/id_ex_reg2_rdata[23]} {u_riscv_0/id_ex_reg2_rdata[24]} {u_riscv_0/id_ex_reg2_rdata[25]} {u_riscv_0/id_ex_reg2_rdata[26]} {u_riscv_0/id_ex_reg2_rdata[27]} {u_riscv_0/id_ex_reg2_rdata[28]} {u_riscv_0/id_ex_reg2_rdata[29]} {u_riscv_0/id_ex_reg2_rdata[30]} {u_riscv_0/id_ex_reg2_rdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 32 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list {cpu_wdata[0]} {cpu_wdata[1]} {cpu_wdata[2]} {cpu_wdata[3]} {cpu_wdata[4]} {cpu_wdata[5]} {cpu_wdata[6]} {cpu_wdata[7]} {cpu_wdata[8]} {cpu_wdata[9]} {cpu_wdata[10]} {cpu_wdata[11]} {cpu_wdata[12]} {cpu_wdata[13]} {cpu_wdata[14]} {cpu_wdata[15]} {cpu_wdata[16]} {cpu_wdata[17]} {cpu_wdata[18]} {cpu_wdata[19]} {cpu_wdata[20]} {cpu_wdata[21]} {cpu_wdata[22]} {cpu_wdata[23]} {cpu_wdata[24]} {cpu_wdata[25]} {cpu_wdata[26]} {cpu_wdata[27]} {cpu_wdata[28]} {cpu_wdata[29]} {cpu_wdata[30]} {cpu_wdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 32 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list {mem_wdata[0]} {mem_wdata[1]} {mem_wdata[2]} {mem_wdata[3]} {mem_wdata[4]} {mem_wdata[5]} {mem_wdata[6]} {mem_wdata[7]} {mem_wdata[8]} {mem_wdata[9]} {mem_wdata[10]} {mem_wdata[11]} {mem_wdata[12]} {mem_wdata[13]} {mem_wdata[14]} {mem_wdata[15]} {mem_wdata[16]} {mem_wdata[17]} {mem_wdata[18]} {mem_wdata[19]} {mem_wdata[20]} {mem_wdata[21]} {mem_wdata[22]} {mem_wdata[23]} {mem_wdata[24]} {mem_wdata[25]} {mem_wdata[26]} {mem_wdata[27]} {mem_wdata[28]} {mem_wdata[29]} {mem_wdata[30]} {mem_wdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 3 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list {u_riscv_0/imm_gen_op[0]} {u_riscv_0/imm_gen_op[1]} {u_riscv_0/imm_gen_op[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 32 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list {u_riscv_0/mem_wb_mem_rdata[0]} {u_riscv_0/mem_wb_mem_rdata[1]} {u_riscv_0/mem_wb_mem_rdata[2]} {u_riscv_0/mem_wb_mem_rdata[3]} {u_riscv_0/mem_wb_mem_rdata[4]} {u_riscv_0/mem_wb_mem_rdata[5]} {u_riscv_0/mem_wb_mem_rdata[6]} {u_riscv_0/mem_wb_mem_rdata[7]} {u_riscv_0/mem_wb_mem_rdata[8]} {u_riscv_0/mem_wb_mem_rdata[9]} {u_riscv_0/mem_wb_mem_rdata[10]} {u_riscv_0/mem_wb_mem_rdata[11]} {u_riscv_0/mem_wb_mem_rdata[12]} {u_riscv_0/mem_wb_mem_rdata[13]} {u_riscv_0/mem_wb_mem_rdata[14]} {u_riscv_0/mem_wb_mem_rdata[15]} {u_riscv_0/mem_wb_mem_rdata[16]} {u_riscv_0/mem_wb_mem_rdata[17]} {u_riscv_0/mem_wb_mem_rdata[18]} {u_riscv_0/mem_wb_mem_rdata[19]} {u_riscv_0/mem_wb_mem_rdata[20]} {u_riscv_0/mem_wb_mem_rdata[21]} {u_riscv_0/mem_wb_mem_rdata[22]} {u_riscv_0/mem_wb_mem_rdata[23]} {u_riscv_0/mem_wb_mem_rdata[24]} {u_riscv_0/mem_wb_mem_rdata[25]} {u_riscv_0/mem_wb_mem_rdata[26]} {u_riscv_0/mem_wb_mem_rdata[27]} {u_riscv_0/mem_wb_mem_rdata[28]} {u_riscv_0/mem_wb_mem_rdata[29]} {u_riscv_0/mem_wb_mem_rdata[30]} {u_riscv_0/mem_wb_mem_rdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 5 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list {u_riscv_0/reg_waddr[0]} {u_riscv_0/reg_waddr[1]} {u_riscv_0/reg_waddr[2]} {u_riscv_0/reg_waddr[3]} {u_riscv_0/reg_waddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 32 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list {u_riscv_0/if_id_next_pc[0]} {u_riscv_0/if_id_next_pc[1]} {u_riscv_0/if_id_next_pc[2]} {u_riscv_0/if_id_next_pc[3]} {u_riscv_0/if_id_next_pc[4]} {u_riscv_0/if_id_next_pc[5]} {u_riscv_0/if_id_next_pc[6]} {u_riscv_0/if_id_next_pc[7]} {u_riscv_0/if_id_next_pc[8]} {u_riscv_0/if_id_next_pc[9]} {u_riscv_0/if_id_next_pc[10]} {u_riscv_0/if_id_next_pc[11]} {u_riscv_0/if_id_next_pc[12]} {u_riscv_0/if_id_next_pc[13]} {u_riscv_0/if_id_next_pc[14]} {u_riscv_0/if_id_next_pc[15]} {u_riscv_0/if_id_next_pc[16]} {u_riscv_0/if_id_next_pc[17]} {u_riscv_0/if_id_next_pc[18]} {u_riscv_0/if_id_next_pc[19]} {u_riscv_0/if_id_next_pc[20]} {u_riscv_0/if_id_next_pc[21]} {u_riscv_0/if_id_next_pc[22]} {u_riscv_0/if_id_next_pc[23]} {u_riscv_0/if_id_next_pc[24]} {u_riscv_0/if_id_next_pc[25]} {u_riscv_0/if_id_next_pc[26]} {u_riscv_0/if_id_next_pc[27]} {u_riscv_0/if_id_next_pc[28]} {u_riscv_0/if_id_next_pc[29]} {u_riscv_0/if_id_next_pc[30]} {u_riscv_0/if_id_next_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 32 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list {cpu_addr[0]} {cpu_addr[1]} {cpu_addr[2]} {cpu_addr[3]} {cpu_addr[4]} {cpu_addr[5]} {cpu_addr[6]} {cpu_addr[7]} {cpu_addr[8]} {cpu_addr[9]} {cpu_addr[10]} {cpu_addr[11]} {cpu_addr[12]} {cpu_addr[13]} {cpu_addr[14]} {cpu_addr[15]} {cpu_addr[16]} {cpu_addr[17]} {cpu_addr[18]} {cpu_addr[19]} {cpu_addr[20]} {cpu_addr[21]} {cpu_addr[22]} {cpu_addr[23]} {cpu_addr[24]} {cpu_addr[25]} {cpu_addr[26]} {cpu_addr[27]} {cpu_addr[28]} {cpu_addr[29]} {cpu_addr[30]} {cpu_addr[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 32 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list {cpu_rdata[0]} {cpu_rdata[1]} {cpu_rdata[2]} {cpu_rdata[3]} {cpu_rdata[4]} {cpu_rdata[5]} {cpu_rdata[6]} {cpu_rdata[7]} {cpu_rdata[8]} {cpu_rdata[9]} {cpu_rdata[10]} {cpu_rdata[11]} {cpu_rdata[12]} {cpu_rdata[13]} {cpu_rdata[14]} {cpu_rdata[15]} {cpu_rdata[16]} {cpu_rdata[17]} {cpu_rdata[18]} {cpu_rdata[19]} {cpu_rdata[20]} {cpu_rdata[21]} {cpu_rdata[22]} {cpu_rdata[23]} {cpu_rdata[24]} {cpu_rdata[25]} {cpu_rdata[26]} {cpu_rdata[27]} {cpu_rdata[28]} {cpu_rdata[29]} {cpu_rdata[30]} {cpu_rdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 32 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list {u_riscv_0/inst[0]} {u_riscv_0/inst[1]} {u_riscv_0/inst[2]} {u_riscv_0/inst[3]} {u_riscv_0/inst[4]} {u_riscv_0/inst[5]} {u_riscv_0/inst[6]} {u_riscv_0/inst[7]} {u_riscv_0/inst[8]} {u_riscv_0/inst[9]} {u_riscv_0/inst[10]} {u_riscv_0/inst[11]} {u_riscv_0/inst[12]} {u_riscv_0/inst[13]} {u_riscv_0/inst[14]} {u_riscv_0/inst[15]} {u_riscv_0/inst[16]} {u_riscv_0/inst[17]} {u_riscv_0/inst[18]} {u_riscv_0/inst[19]} {u_riscv_0/inst[20]} {u_riscv_0/inst[21]} {u_riscv_0/inst[22]} {u_riscv_0/inst[23]} {u_riscv_0/inst[24]} {u_riscv_0/inst[25]} {u_riscv_0/inst[26]} {u_riscv_0/inst[27]} {u_riscv_0/inst[28]} {u_riscv_0/inst[29]} {u_riscv_0/inst[30]} {u_riscv_0/inst[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 4 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list {mem_wen[0]} {mem_wen[1]} {mem_wen[2]} {mem_wen[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 32 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list {u_riscv_0/mem_wb_alu_res[0]} {u_riscv_0/mem_wb_alu_res[1]} {u_riscv_0/mem_wb_alu_res[2]} {u_riscv_0/mem_wb_alu_res[3]} {u_riscv_0/mem_wb_alu_res[4]} {u_riscv_0/mem_wb_alu_res[5]} {u_riscv_0/mem_wb_alu_res[6]} {u_riscv_0/mem_wb_alu_res[7]} {u_riscv_0/mem_wb_alu_res[8]} {u_riscv_0/mem_wb_alu_res[9]} {u_riscv_0/mem_wb_alu_res[10]} {u_riscv_0/mem_wb_alu_res[11]} {u_riscv_0/mem_wb_alu_res[12]} {u_riscv_0/mem_wb_alu_res[13]} {u_riscv_0/mem_wb_alu_res[14]} {u_riscv_0/mem_wb_alu_res[15]} {u_riscv_0/mem_wb_alu_res[16]} {u_riscv_0/mem_wb_alu_res[17]} {u_riscv_0/mem_wb_alu_res[18]} {u_riscv_0/mem_wb_alu_res[19]} {u_riscv_0/mem_wb_alu_res[20]} {u_riscv_0/mem_wb_alu_res[21]} {u_riscv_0/mem_wb_alu_res[22]} {u_riscv_0/mem_wb_alu_res[23]} {u_riscv_0/mem_wb_alu_res[24]} {u_riscv_0/mem_wb_alu_res[25]} {u_riscv_0/mem_wb_alu_res[26]} {u_riscv_0/mem_wb_alu_res[27]} {u_riscv_0/mem_wb_alu_res[28]} {u_riscv_0/mem_wb_alu_res[29]} {u_riscv_0/mem_wb_alu_res[30]} {u_riscv_0/mem_wb_alu_res[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 5 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list {u_riscv_0/reg2_raddr[0]} {u_riscv_0/reg2_raddr[1]} {u_riscv_0/reg2_raddr[2]} {u_riscv_0/reg2_raddr[3]} {u_riscv_0/reg2_raddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
set_property port_width 32 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list {u_riscv_0/reg_wdata[0]} {u_riscv_0/reg_wdata[1]} {u_riscv_0/reg_wdata[2]} {u_riscv_0/reg_wdata[3]} {u_riscv_0/reg_wdata[4]} {u_riscv_0/reg_wdata[5]} {u_riscv_0/reg_wdata[6]} {u_riscv_0/reg_wdata[7]} {u_riscv_0/reg_wdata[8]} {u_riscv_0/reg_wdata[9]} {u_riscv_0/reg_wdata[10]} {u_riscv_0/reg_wdata[11]} {u_riscv_0/reg_wdata[12]} {u_riscv_0/reg_wdata[13]} {u_riscv_0/reg_wdata[14]} {u_riscv_0/reg_wdata[15]} {u_riscv_0/reg_wdata[16]} {u_riscv_0/reg_wdata[17]} {u_riscv_0/reg_wdata[18]} {u_riscv_0/reg_wdata[19]} {u_riscv_0/reg_wdata[20]} {u_riscv_0/reg_wdata[21]} {u_riscv_0/reg_wdata[22]} {u_riscv_0/reg_wdata[23]} {u_riscv_0/reg_wdata[24]} {u_riscv_0/reg_wdata[25]} {u_riscv_0/reg_wdata[26]} {u_riscv_0/reg_wdata[27]} {u_riscv_0/reg_wdata[28]} {u_riscv_0/reg_wdata[29]} {u_riscv_0/reg_wdata[30]} {u_riscv_0/reg_wdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 32 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list {mem_rdata[0]} {mem_rdata[1]} {mem_rdata[2]} {mem_rdata[3]} {mem_rdata[4]} {mem_rdata[5]} {mem_rdata[6]} {mem_rdata[7]} {mem_rdata[8]} {mem_rdata[9]} {mem_rdata[10]} {mem_rdata[11]} {mem_rdata[12]} {mem_rdata[13]} {mem_rdata[14]} {mem_rdata[15]} {mem_rdata[16]} {mem_rdata[17]} {mem_rdata[18]} {mem_rdata[19]} {mem_rdata[20]} {mem_rdata[21]} {mem_rdata[22]} {mem_rdata[23]} {mem_rdata[24]} {mem_rdata[25]} {mem_rdata[26]} {mem_rdata[27]} {mem_rdata[28]} {mem_rdata[29]} {mem_rdata[30]} {mem_rdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
set_property port_width 5 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list {u_riscv_0/id_ex_reg_waddr[0]} {u_riscv_0/id_ex_reg_waddr[1]} {u_riscv_0/id_ex_reg_waddr[2]} {u_riscv_0/id_ex_reg_waddr[3]} {u_riscv_0/id_ex_reg_waddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 3 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list {u_riscv_0/mem_wb_mem_access_type[0]} {u_riscv_0/mem_wb_mem_access_type[1]} {u_riscv_0/mem_wb_mem_access_type[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
set_property port_width 32 [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list {u_riscv_0/if_id_curr_pc[0]} {u_riscv_0/if_id_curr_pc[1]} {u_riscv_0/if_id_curr_pc[2]} {u_riscv_0/if_id_curr_pc[3]} {u_riscv_0/if_id_curr_pc[4]} {u_riscv_0/if_id_curr_pc[5]} {u_riscv_0/if_id_curr_pc[6]} {u_riscv_0/if_id_curr_pc[7]} {u_riscv_0/if_id_curr_pc[8]} {u_riscv_0/if_id_curr_pc[9]} {u_riscv_0/if_id_curr_pc[10]} {u_riscv_0/if_id_curr_pc[11]} {u_riscv_0/if_id_curr_pc[12]} {u_riscv_0/if_id_curr_pc[13]} {u_riscv_0/if_id_curr_pc[14]} {u_riscv_0/if_id_curr_pc[15]} {u_riscv_0/if_id_curr_pc[16]} {u_riscv_0/if_id_curr_pc[17]} {u_riscv_0/if_id_curr_pc[18]} {u_riscv_0/if_id_curr_pc[19]} {u_riscv_0/if_id_curr_pc[20]} {u_riscv_0/if_id_curr_pc[21]} {u_riscv_0/if_id_curr_pc[22]} {u_riscv_0/if_id_curr_pc[23]} {u_riscv_0/if_id_curr_pc[24]} {u_riscv_0/if_id_curr_pc[25]} {u_riscv_0/if_id_curr_pc[26]} {u_riscv_0/if_id_curr_pc[27]} {u_riscv_0/if_id_curr_pc[28]} {u_riscv_0/if_id_curr_pc[29]} {u_riscv_0/if_id_curr_pc[30]} {u_riscv_0/if_id_curr_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe45]
set_property port_width 32 [get_debug_ports u_ila_0/probe45]
connect_debug_port u_ila_0/probe45 [get_nets [list {u_riscv_0/mem_wb_inst[0]} {u_riscv_0/mem_wb_inst[1]} {u_riscv_0/mem_wb_inst[2]} {u_riscv_0/mem_wb_inst[3]} {u_riscv_0/mem_wb_inst[4]} {u_riscv_0/mem_wb_inst[5]} {u_riscv_0/mem_wb_inst[6]} {u_riscv_0/mem_wb_inst[7]} {u_riscv_0/mem_wb_inst[8]} {u_riscv_0/mem_wb_inst[9]} {u_riscv_0/mem_wb_inst[10]} {u_riscv_0/mem_wb_inst[11]} {u_riscv_0/mem_wb_inst[12]} {u_riscv_0/mem_wb_inst[13]} {u_riscv_0/mem_wb_inst[14]} {u_riscv_0/mem_wb_inst[15]} {u_riscv_0/mem_wb_inst[16]} {u_riscv_0/mem_wb_inst[17]} {u_riscv_0/mem_wb_inst[18]} {u_riscv_0/mem_wb_inst[19]} {u_riscv_0/mem_wb_inst[20]} {u_riscv_0/mem_wb_inst[21]} {u_riscv_0/mem_wb_inst[22]} {u_riscv_0/mem_wb_inst[23]} {u_riscv_0/mem_wb_inst[24]} {u_riscv_0/mem_wb_inst[25]} {u_riscv_0/mem_wb_inst[26]} {u_riscv_0/mem_wb_inst[27]} {u_riscv_0/mem_wb_inst[28]} {u_riscv_0/mem_wb_inst[29]} {u_riscv_0/mem_wb_inst[30]} {u_riscv_0/mem_wb_inst[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe46]
set_property port_width 5 [get_debug_ports u_ila_0/probe46]
connect_debug_port u_ila_0/probe46 [get_nets [list {u_riscv_0/reg1_raddr[0]} {u_riscv_0/reg1_raddr[1]} {u_riscv_0/reg1_raddr[2]} {u_riscv_0/reg1_raddr[3]} {u_riscv_0/reg1_raddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe47]
set_property port_width 32 [get_debug_ports u_ila_0/probe47]
connect_debug_port u_ila_0/probe47 [get_nets [list {u_riscv_0/if_id_inst[0]} {u_riscv_0/if_id_inst[1]} {u_riscv_0/if_id_inst[2]} {u_riscv_0/if_id_inst[3]} {u_riscv_0/if_id_inst[4]} {u_riscv_0/if_id_inst[5]} {u_riscv_0/if_id_inst[6]} {u_riscv_0/if_id_inst[7]} {u_riscv_0/if_id_inst[8]} {u_riscv_0/if_id_inst[9]} {u_riscv_0/if_id_inst[10]} {u_riscv_0/if_id_inst[11]} {u_riscv_0/if_id_inst[12]} {u_riscv_0/if_id_inst[13]} {u_riscv_0/if_id_inst[14]} {u_riscv_0/if_id_inst[15]} {u_riscv_0/if_id_inst[16]} {u_riscv_0/if_id_inst[17]} {u_riscv_0/if_id_inst[18]} {u_riscv_0/if_id_inst[19]} {u_riscv_0/if_id_inst[20]} {u_riscv_0/if_id_inst[21]} {u_riscv_0/if_id_inst[22]} {u_riscv_0/if_id_inst[23]} {u_riscv_0/if_id_inst[24]} {u_riscv_0/if_id_inst[25]} {u_riscv_0/if_id_inst[26]} {u_riscv_0/if_id_inst[27]} {u_riscv_0/if_id_inst[28]} {u_riscv_0/if_id_inst[29]} {u_riscv_0/if_id_inst[30]} {u_riscv_0/if_id_inst[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe48]
set_property port_width 2 [get_debug_ports u_ila_0/probe48]
connect_debug_port u_ila_0/probe48 [get_nets [list {u_riscv_0/id_ex_regs_src_sel[0]} {u_riscv_0/id_ex_regs_src_sel[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe49]
set_property port_width 32 [get_debug_ports u_ila_0/probe49]
connect_debug_port u_ila_0/probe49 [get_nets [list {u_riscv_0/mem_wb_curr_pc[0]} {u_riscv_0/mem_wb_curr_pc[1]} {u_riscv_0/mem_wb_curr_pc[2]} {u_riscv_0/mem_wb_curr_pc[3]} {u_riscv_0/mem_wb_curr_pc[4]} {u_riscv_0/mem_wb_curr_pc[5]} {u_riscv_0/mem_wb_curr_pc[6]} {u_riscv_0/mem_wb_curr_pc[7]} {u_riscv_0/mem_wb_curr_pc[8]} {u_riscv_0/mem_wb_curr_pc[9]} {u_riscv_0/mem_wb_curr_pc[10]} {u_riscv_0/mem_wb_curr_pc[11]} {u_riscv_0/mem_wb_curr_pc[12]} {u_riscv_0/mem_wb_curr_pc[13]} {u_riscv_0/mem_wb_curr_pc[14]} {u_riscv_0/mem_wb_curr_pc[15]} {u_riscv_0/mem_wb_curr_pc[16]} {u_riscv_0/mem_wb_curr_pc[17]} {u_riscv_0/mem_wb_curr_pc[18]} {u_riscv_0/mem_wb_curr_pc[19]} {u_riscv_0/mem_wb_curr_pc[20]} {u_riscv_0/mem_wb_curr_pc[21]} {u_riscv_0/mem_wb_curr_pc[22]} {u_riscv_0/mem_wb_curr_pc[23]} {u_riscv_0/mem_wb_curr_pc[24]} {u_riscv_0/mem_wb_curr_pc[25]} {u_riscv_0/mem_wb_curr_pc[26]} {u_riscv_0/mem_wb_curr_pc[27]} {u_riscv_0/mem_wb_curr_pc[28]} {u_riscv_0/mem_wb_curr_pc[29]} {u_riscv_0/mem_wb_curr_pc[30]} {u_riscv_0/mem_wb_curr_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe50]
set_property port_width 32 [get_debug_ports u_ila_0/probe50]
connect_debug_port u_ila_0/probe50 [get_nets [list {u_riscv_0/mem_wb_next_pc[0]} {u_riscv_0/mem_wb_next_pc[1]} {u_riscv_0/mem_wb_next_pc[2]} {u_riscv_0/mem_wb_next_pc[3]} {u_riscv_0/mem_wb_next_pc[4]} {u_riscv_0/mem_wb_next_pc[5]} {u_riscv_0/mem_wb_next_pc[6]} {u_riscv_0/mem_wb_next_pc[7]} {u_riscv_0/mem_wb_next_pc[8]} {u_riscv_0/mem_wb_next_pc[9]} {u_riscv_0/mem_wb_next_pc[10]} {u_riscv_0/mem_wb_next_pc[11]} {u_riscv_0/mem_wb_next_pc[12]} {u_riscv_0/mem_wb_next_pc[13]} {u_riscv_0/mem_wb_next_pc[14]} {u_riscv_0/mem_wb_next_pc[15]} {u_riscv_0/mem_wb_next_pc[16]} {u_riscv_0/mem_wb_next_pc[17]} {u_riscv_0/mem_wb_next_pc[18]} {u_riscv_0/mem_wb_next_pc[19]} {u_riscv_0/mem_wb_next_pc[20]} {u_riscv_0/mem_wb_next_pc[21]} {u_riscv_0/mem_wb_next_pc[22]} {u_riscv_0/mem_wb_next_pc[23]} {u_riscv_0/mem_wb_next_pc[24]} {u_riscv_0/mem_wb_next_pc[25]} {u_riscv_0/mem_wb_next_pc[26]} {u_riscv_0/mem_wb_next_pc[27]} {u_riscv_0/mem_wb_next_pc[28]} {u_riscv_0/mem_wb_next_pc[29]} {u_riscv_0/mem_wb_next_pc[30]} {u_riscv_0/mem_wb_next_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe51]
set_property port_width 5 [get_debug_ports u_ila_0/probe51]
connect_debug_port u_ila_0/probe51 [get_nets [list {u_riscv_0/mem_wb_reg2_raddr[0]} {u_riscv_0/mem_wb_reg2_raddr[1]} {u_riscv_0/mem_wb_reg2_raddr[2]} {u_riscv_0/mem_wb_reg2_raddr[3]} {u_riscv_0/mem_wb_reg2_raddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe52]
set_property port_width 32 [get_debug_ports u_ila_0/probe52]
connect_debug_port u_ila_0/probe52 [get_nets [list {u_riscv_0/imm[0]} {u_riscv_0/imm[1]} {u_riscv_0/imm[2]} {u_riscv_0/imm[3]} {u_riscv_0/imm[4]} {u_riscv_0/imm[5]} {u_riscv_0/imm[6]} {u_riscv_0/imm[7]} {u_riscv_0/imm[8]} {u_riscv_0/imm[9]} {u_riscv_0/imm[10]} {u_riscv_0/imm[11]} {u_riscv_0/imm[12]} {u_riscv_0/imm[13]} {u_riscv_0/imm[14]} {u_riscv_0/imm[15]} {u_riscv_0/imm[16]} {u_riscv_0/imm[17]} {u_riscv_0/imm[18]} {u_riscv_0/imm[19]} {u_riscv_0/imm[20]} {u_riscv_0/imm[21]} {u_riscv_0/imm[22]} {u_riscv_0/imm[23]} {u_riscv_0/imm[24]} {u_riscv_0/imm[25]} {u_riscv_0/imm[26]} {u_riscv_0/imm[27]} {u_riscv_0/imm[28]} {u_riscv_0/imm[29]} {u_riscv_0/imm[30]} {u_riscv_0/imm[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe53]
set_property port_width 5 [get_debug_ports u_ila_0/probe53]
connect_debug_port u_ila_0/probe53 [get_nets [list {u_riscv_0/mem_wb_reg1_raddr[0]} {u_riscv_0/mem_wb_reg1_raddr[1]} {u_riscv_0/mem_wb_reg1_raddr[2]} {u_riscv_0/mem_wb_reg1_raddr[3]} {u_riscv_0/mem_wb_reg1_raddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe54]
set_property port_width 5 [get_debug_ports u_ila_0/probe54]
connect_debug_port u_ila_0/probe54 [get_nets [list {u_riscv_0/mem_wb_reg_waddr[0]} {u_riscv_0/mem_wb_reg_waddr[1]} {u_riscv_0/mem_wb_reg_waddr[2]} {u_riscv_0/mem_wb_reg_waddr[3]} {u_riscv_0/mem_wb_reg_waddr[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe55]
set_property port_width 32 [get_debug_ports u_ila_0/probe55]
connect_debug_port u_ila_0/probe55 [get_nets [list {u_riscv_0/next_pc[0]} {u_riscv_0/next_pc[1]} {u_riscv_0/next_pc[2]} {u_riscv_0/next_pc[3]} {u_riscv_0/next_pc[4]} {u_riscv_0/next_pc[5]} {u_riscv_0/next_pc[6]} {u_riscv_0/next_pc[7]} {u_riscv_0/next_pc[8]} {u_riscv_0/next_pc[9]} {u_riscv_0/next_pc[10]} {u_riscv_0/next_pc[11]} {u_riscv_0/next_pc[12]} {u_riscv_0/next_pc[13]} {u_riscv_0/next_pc[14]} {u_riscv_0/next_pc[15]} {u_riscv_0/next_pc[16]} {u_riscv_0/next_pc[17]} {u_riscv_0/next_pc[18]} {u_riscv_0/next_pc[19]} {u_riscv_0/next_pc[20]} {u_riscv_0/next_pc[21]} {u_riscv_0/next_pc[22]} {u_riscv_0/next_pc[23]} {u_riscv_0/next_pc[24]} {u_riscv_0/next_pc[25]} {u_riscv_0/next_pc[26]} {u_riscv_0/next_pc[27]} {u_riscv_0/next_pc[28]} {u_riscv_0/next_pc[29]} {u_riscv_0/next_pc[30]} {u_riscv_0/next_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe56]
set_property port_width 1 [get_debug_ports u_ila_0/probe56]
connect_debug_port u_ila_0/probe56 [get_nets [list u_riscv_0/branch]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe57]
set_property port_width 1 [get_debug_ports u_ila_0/probe57]
connect_debug_port u_ila_0/probe57 [get_nets [list u_riscv_0/control_hazard]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe58]
set_property port_width 1 [get_debug_ports u_ila_0/probe58]
connect_debug_port u_ila_0/probe58 [get_nets [list u_riscv_0/ex_mem_mem_sign_ext]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe59]
set_property port_width 1 [get_debug_ports u_ila_0/probe59]
connect_debug_port u_ila_0/probe59 [get_nets [list u_riscv_0/ex_mem_reg_wen]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe60]
set_property port_width 1 [get_debug_ports u_ila_0/probe60]
connect_debug_port u_ila_0/probe60 [get_nets [list u_riscv_0/id_ex_branch]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe61]
set_property port_width 1 [get_debug_ports u_ila_0/probe61]
connect_debug_port u_ila_0/probe61 [get_nets [list u_riscv_0/id_ex_control_hazard]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe62]
set_property port_width 1 [get_debug_ports u_ila_0/probe62]
connect_debug_port u_ila_0/probe62 [get_nets [list u_riscv_0/id_ex_jump]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe63]
set_property port_width 1 [get_debug_ports u_ila_0/probe63]
connect_debug_port u_ila_0/probe63 [get_nets [list u_riscv_0/id_ex_mem_sign_ext]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe64]
set_property port_width 1 [get_debug_ports u_ila_0/probe64]
connect_debug_port u_ila_0/probe64 [get_nets [list u_riscv_0/id_ex_reg_wen]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe65]
set_property port_width 1 [get_debug_ports u_ila_0/probe65]
connect_debug_port u_ila_0/probe65 [get_nets [list u_riscv_0/if_id_control_hazard]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe66]
set_property port_width 1 [get_debug_ports u_ila_0/probe66]
connect_debug_port u_ila_0/probe66 [get_nets [list u_riscv_0/jump]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe67]
set_property port_width 1 [get_debug_ports u_ila_0/probe67]
connect_debug_port u_ila_0/probe67 [get_nets [list mem_sel]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe68]
set_property port_width 1 [get_debug_ports u_ila_0/probe68]
connect_debug_port u_ila_0/probe68 [get_nets [list u_riscv_0/mem_wb_mem_sign_ext]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe69]
set_property port_width 1 [get_debug_ports u_ila_0/probe69]
connect_debug_port u_ila_0/probe69 [get_nets [list u_riscv_0/mem_wb_reg_wen]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe70]
set_property port_width 1 [get_debug_ports u_ila_0/probe70]
connect_debug_port u_ila_0/probe70 [get_nets [list u_riscv_0/pipe_flush]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe71]
set_property port_width 1 [get_debug_ports u_ila_0/probe71]
connect_debug_port u_ila_0/probe71 [get_nets [list u_riscv_0/reg_wen]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe72]
set_property port_width 1 [get_debug_ports u_ila_0/probe72]
connect_debug_port u_ila_0/probe72 [get_nets [list u_riscv_0/zero]]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[0]}]
set_property PACKAGE_PIN T3 [get_ports {gpio[0]}]
set_property PACKAGE_PIN Y2 [get_ports {gpio[1]}]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_50m]
