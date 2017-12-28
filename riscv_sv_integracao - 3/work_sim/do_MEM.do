vlib work
vdel -all -lib work
vlib work

vcom -f compile_vhdl.f
vlog -f compile_questa_sv_win.f

vsim -t ns -L cycloneive_ver -L altera_mf -L altera -L lpm -L cycloneive \
-L altera_mf_ver -L altera_ver -L lpm_ver -L sgate_ver -novopt work.tb 

run 1ns
add wave -position insertpoint -divider "CPU" \
sim:/tb/DUT/cpu1/riscv_fetch/program_counter

add wave -position insertpoint -divider "MEM_M1" \
sim:/tb/DUT/M1/wren \
sim:/tb/DUT/M1/q \
sim:/tb/DUT/M1/data \
sim:/tb/DUT/M1/address
 
add wave -position insertpoint -divider "MEM_ctrl" \
sim:/tb/DUT/mem_controller/wshbn_wr \
sim:/tb/DUT/mem_controller/wshbn_rd \
sim:/tb/DUT/mem_controller/wshbn_data_r \
sim:/tb/DUT/mem_controller/wshbn_data_o \
sim:/tb/DUT/mem_controller/wshbn_data_i \
sim:/tb/DUT/mem_controller/wshbn_data_av \
sim:/tb/DUT/mem_controller/wshbn_busy \
sim:/tb/DUT/mem_controller/wshbn_addr_o \
sim:/tb/DUT/mem_controller/wr \
sim:/tb/DUT/mem_controller/rst \
sim:/tb/DUT/mem_controller/rd \
sim:/tb/DUT/mem_controller/mem1_wr \
sim:/tb/DUT/mem_controller/mem1_rd \
sim:/tb/DUT/mem_controller/mem1_data_o \
sim:/tb/DUT/mem_controller/mem1_data_i \
sim:/tb/DUT/mem_controller/mem1_busy \
sim:/tb/DUT/mem_controller/mem1_addr_o \
sim:/tb/DUT/mem_controller/mem0_wr \
sim:/tb/DUT/mem_controller/mem0_rd \
sim:/tb/DUT/mem_controller/mem0_data_o \
sim:/tb/DUT/mem_controller/mem0_data_i \
sim:/tb/DUT/mem_controller/mem0_busy \
sim:/tb/DUT/mem_controller/mem0_addr_o \
sim:/tb/DUT/mem_controller/hold_cpu \
sim:/tb/DUT/mem_controller/data_o \
sim:/tb/DUT/mem_controller/data_i \
sim:/tb/DUT/mem_controller/clk \
sim:/tb/DUT/mem_controller/bus_trns \
sim:/tb/DUT/mem_controller/addr_mem \
sim:/tb/DUT/mem_controller/addr_i \
sim:/tb/DUT/mem_controller/addr_from_cpu_r \
sim:/tb/DUT/mem_controller/addr_from_cpu \
sim:/tb/DUT/mem_controller/addr_ext_cmp \
sim:/tb/DUT/mem_controller/addr_data_cmp \
sim:/tb/DUT/mem_controller/addr_cmp_r \
sim:/tb/DUT/mem_controller/addr_cmp \
sim:/tb/DUT/mem_controller/addcmp3 \
sim:/tb/DUT/mem_controller/add_ext

add wave -position insertpoint -divider "RISCV_WISHBONE" \
sim:/tb/DUT/instruction_o \
sim:/tb/DUT/inst_rden \
sim:/tb/DUT/inst_counter \
sim:/tb/DUT/inst_cache_rden \
sim:/tb/DUT/inst_cache_data \
sim:/tb/DUT/inst_cache_add \
sim:/tb/DUT/inst_add \
sim:/tb/DUT/inst \
sim:/tb/DUT/ext_ram_wren \
sim:/tb/DUT/ext_ram_rden \
sim:/tb/DUT/ext_ram_data_o \
sim:/tb/DUT/ext_ram_data_i \
sim:/tb/DUT/ext_ram_busy \
sim:/tb/DUT/ext_ram_addr_i \
sim:/tb/DUT/ext_inst_rden \
sim:/tb/DUT/ext_inst_data \
sim:/tb/DUT/ext_inst_add \
sim:/tb/DUT/en_eval_regs \
sim:/tb/DUT/data_cache_wren \
sim:/tb/DUT/data_cache_rden \
sim:/tb/DUT/data_cache_data_o \
sim:/tb/DUT/data_cache_data_i \
sim:/tb/DUT/data_cache_busy \
sim:/tb/DUT/data_cache_addr_i \
sim:/tb/DUT/data_av \
sim:/tb/DUT/cpu_data_wren \
sim:/tb/DUT/cpu_data_rden \
sim:/tb/DUT/cpu_data_o \
sim:/tb/DUT/cpu_data_i \
sim:/tb/DUT/cpu_data_add



run 30000ns