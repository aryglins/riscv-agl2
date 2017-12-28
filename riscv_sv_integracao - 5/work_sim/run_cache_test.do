vlib work
vdel -all -lib work
vlib work

vcom -f compile_vhdl.f
vlog -f compile_questa_sv_win.f

vsim -t ns -L altera_ver -L altera -L lpm -L altera_mf_ver -L altera_mf -L sgate_ver -novopt work.tb 

run 1ns
add wave -position insertpoint -divider "TOP" \
sim:/tb/DUT/inst_cache_add \
sim:/tb/DUT/inst_cache_data

add wave -position insertpoint -divider "CPU" \
sim:/tb/DUT/cpu1/riscv_fetch/program_counter \
sim:/tb/DUT/cpu1/inst_cache_add \
sim:/tb/DUT/cpu1/inst_cache_data \
sim:/tb/DUT/cpu1/data_rden \
sim:/tb/DUT/cpu1/data_wren \
sim:/tb/DUT/cpu1/data_add \
sim:/tb/DUT/cpu1/data_o \
sim:/tb/DUT/cpu1/data_i \
sim:/tb/DUT/cpu1/riscv_fetch/stall_i \
sim:/tb/DUT/cpu1/riscv_fetch/pc_input_mux_sel \
sim:/tb/DUT/cpu1/mem_busy


add wave -position insertpoint -divider "CACHE" \
sim:/tb/DUT/M1/clk \
sim:/tb/DUT/M1/rst \
sim:/tb/DUT/M1/proc_req \
sim:/tb/DUT/M1/proc_res \
sim:/tb/DUT/M1/mem_req \
sim:/tb/DUT/M1/mem_res \
sim:/tb/DUT/M1/state
 
add wave -position insertpoint -divider "CPU to MEM_ctrl" \
sim:/tb/DUT/mem_controller/rd \
sim:/tb/DUT/mem_controller/wr \
sim:/tb/DUT/mem_controller/addr_i \
sim:/tb/DUT/mem_controller/data_i \
sim:/tb/DUT/mem_controller/data_o \
sim:/tb/DUT/mem_controller/hold_cpu 

add wave -position insertpoint -divider "MEM_ctrl to CACHE" \
sim:/tb/DUT/mem_controller/mem0_rd \
sim:/tb/DUT/mem_controller/mem0_wr \
sim:/tb/DUT/mem_controller/mem0_addr_o \
sim:/tb/DUT/mem_controller/mem0_data_o \
sim:/tb/DUT/mem_controller/mem0_data_i \
sim:/tb/DUT/mem_controller/mem0_busy 

add wave -position insertpoint -divider "MASTER CACHE" \
sim:/tb/DUT/MST_CACHE/*

add wave -position insertpoint -divider "SLAVE RAM" \
sim:/tb/DUT/SLV_RAM/*

run 90ns