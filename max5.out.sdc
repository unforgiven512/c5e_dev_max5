## Generated SDC file "max5.out.sdc"

## Copyright (C) 1991-2012 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 12.1 Build 177 11/07/2012 SJ Full Version"

## DATE    "Fri Jun 22 18:58:32 2012"

##
## DEVICE  "5M2210ZF256C4"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 40.000 -waveform { 0.000 20.000 } [get_ports {altera_reserved_tck}]
create_clock -name {clk_config} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk_config}]
create_clock -name {clkin_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clkin_50}]
create_clock -name {flash_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {flash_clk}]
create_clock -name {fpga_dclk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {fpga_dclk}]



#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {altera_reserved_tck}]  5.000 [get_ports {altera_reserved_tdi}]
set_input_delay -add_delay  -clock [get_clocks {altera_reserved_tck}]  5.000 [get_ports {altera_reserved_tms}]
set_input_delay -add_delay  -clock [get_clocks {clkin_50}]  1.000 [get_ports {clock_scl}]
set_input_delay -add_delay  -clock [get_clocks {clkin_50}]  1.000 [get_ports {max5_csn}]
set_input_delay -add_delay  -clock [get_clocks {clkin_50}]  1.000 [get_ports {max5_oen}]
set_input_delay -add_delay  -clock [get_clocks {clkin_50}]  1.000 [get_ports {max5_wen}]



#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -fall -max -clock_fall -clock [get_clocks {altera_reserved_tck}]  5.000 [get_ports {altera_reserved_tdo}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {flash_advn}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {flash_advn}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {flash_cen[0]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {flash_cen[0]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {flash_cen[1]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {flash_cen[1]}]
set_output_delay -add_delay  -clock [get_clocks {clkin_50}]  0.000 [get_ports {flash_clk}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {flash_oen}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {flash_oen}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {flash_resetn}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {flash_resetn}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {flash_wen}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {flash_wen}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[0]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[0]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[1]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[1]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[2]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[2]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[3]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[3]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[4]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[4]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[5]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[5]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[6]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[6]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[7]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[7]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[8]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[8]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[9]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[9]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[10]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[10]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[11]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[11]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[12]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[12]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[13]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[13]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[14]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[14]}]
set_output_delay -add_delay -max -clock [get_clocks {clkin_50}]  3.500 [get_ports {fpga_config_d[15]}]
set_output_delay -add_delay -min -clock [get_clocks {clkin_50}]  -1.000 [get_ports {fpga_config_d[15]}]
set_output_delay -add_delay  -clock [get_clocks {clkin_50}]  0.000 [get_ports {fpga_dclk}]
set_output_delay -add_delay  -clock [get_clocks {clkin_50}]  2.000 [get_ports {sense_cs0n}]



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {fpga_conf_done}] 
set_false_path -from [get_ports {fpga_nstatus}] 
set_false_path -from [get_ports {pgm_config}] 
set_false_path -from [get_ports {factory_load}] 
set_false_path -from [get_ports {pgm_sel}] 
set_false_path -to [get_ports {max_error}]
set_false_path -to [get_ports {overtemp}]
set_false_path -to [get_ports {fpga_nconfig}]
set_false_path -to [get_ports {flash_resetn}]
set_false_path -to [get_ports {pgm_led[*]}]
set_false_path -from [get_ports {clock_sda}] 
set_false_path -from [get_ports {sense_sdo}] 
set_false_path -to [get_ports {fpga_nstatus}]
set_false_path -to [get_ports {sense_sck}]
set_false_path -to [get_ports {sense_sdi}]
set_false_path -to [get_ports {clock_scl}]
set_false_path -to [get_ports {clock_sda}]



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

