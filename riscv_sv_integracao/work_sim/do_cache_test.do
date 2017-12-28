vlib work
vdel -all -lib work
vlib work

vcom -f compile_vhdl.f
vlog -f compile_questa_sv_win.f

vsim -t ns -L cycloneive_ver  -L altera_ver -L altera -L lpm -L cycloneivgx \
-L altera_mf_ver -L altera_mf-L lpm_ver -L sgate_ver -novopt work.tb 

run 1ns
add wave -position insertpoint -divider "CPU" \
sim:/tb/DUT/cpu1/riscv_fetch/program_counter \
sim:/tb/DUT/cpu1/inst_cache_add \
sim:/tb/DUT/cpu1/inst_cache_data \
sim:/tb/DUT/cpu1/data_rden \
sim:/tb/DUT/cpu1/data_wren \
sim:/tb/DUT/cpu1/data_add \
sim:/tb/DUT/cpu1/data_o \
sim:/tb/DUT/cpu1/data_i \
sim:/tb/DUT/cpu1/mem_busy

add wave -position insertpoint -divider "RAM" \
sim:/tb/DUT/RAM_CRTL/clk \
sim:/tb/DUT/RAM_CRTL/rst \
sim:/tb/DUT/RAM_CRTL/mem_req \
sim:/tb/DUT/RAM_CRTL/mem_res

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

add wave -position insertpoint -divider "REGISTER BANK" \
sim:/tb/DUT/cpu1/riscv_regfile/clk_i \
sim:/tb/DUT/cpu1/riscv_regfile/rst_i \
sim:/tb/DUT/cpu1/riscv_regfile/rd_i \
sim:/tb/DUT/cpu1/riscv_regfile/rs1_i \
sim:/tb/DUT/cpu1/riscv_regfile/rs2_i \
sim:/tb/DUT/cpu1/riscv_regfile/data_in \
sim:/tb/DUT/cpu1/riscv_regfile/wrten_i \
sim:/tb/DUT/cpu1/riscv_regfile/ra \
sim:/tb/DUT/cpu1/riscv_regfile/sp \
sim:/tb/DUT/cpu1/riscv_regfile/op1_o \
sim:/tb/DUT/cpu1/riscv_regfile/op2_o \
sim:/tb/DUT/cpu1/riscv_regfile/result


run 40000ns