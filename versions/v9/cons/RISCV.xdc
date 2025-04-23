set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN R2 [get_ports {led[0]}]
set_property PACKAGE_PIN R3 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property PACKAGE_PIN R4 [get_ports clk]
set_property PACKAGE_PIN U2 [get_ports rst_n]

#create_clock -period 20.000 -name clk_50m [get_ports clk]












set_property IOSTANDARD LVCMOS33 [get_ports {gpio[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[0]}]
set_property PACKAGE_PIN T3 [get_ports {gpio[0]}]
set_property PACKAGE_PIN Y2 [get_ports {gpio[1]}]


set_property IOSTANDARD LVCMOS33 [get_ports {seg_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_sel_n[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_sel_n[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_sel_n[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_sel_n[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_sel_n[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_sel_n[0]}]
set_property PACKAGE_PIN J15 [get_ports {seg_sel_n[0]}]
set_property PACKAGE_PIN H17 [get_ports {seg_sel_n[1]}]
set_property PACKAGE_PIN H13 [get_ports {seg_sel_n[2]}]
set_property PACKAGE_PIN G17 [get_ports {seg_sel_n[3]}]
set_property PACKAGE_PIN H18 [get_ports {seg_sel_n[4]}]
set_property PACKAGE_PIN G18 [get_ports {seg_sel_n[5]}]
set_property PACKAGE_PIN H15 [get_ports {seg_data[0]}]
set_property PACKAGE_PIN L13 [get_ports {seg_data[2]}]
set_property PACKAGE_PIN G16 [get_ports {seg_data[1]}]
set_property PACKAGE_PIN G15 [get_ports {seg_data[3]}]
set_property PACKAGE_PIN K13 [get_ports {seg_data[4]}]
set_property PACKAGE_PIN G13 [get_ports {seg_data[5]}]
set_property PACKAGE_PIN H14 [get_ports {seg_data[6]}]
set_property PACKAGE_PIN J14 [get_ports {seg_data[7]}]



create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]
create_clock -period 6.250 -name clk -waveform {0.000 5.000} [get_pins clk_wiz_0_inst/clk_50m]
