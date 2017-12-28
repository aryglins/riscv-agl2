vlib work
vdel -all -lib work
vlib work

vcom -f compile_vhdl.f
vlog -f compile_questa_sv_win.f

vsim -t ns -L altera_ver -L altera -L lpm -L altera_mf_ver -L altera_mf -L sgate_ver -novopt work.tb 

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
sim:/tb/DUT/cpu1/interrupt_req \
sim:/tb/DUT/cpu1/wb_mux_sel_int \
sim:/tb/DUT/cpu1/rf_wrten_pipe \
sim:/tb/DUT/cpu1/mem_busy



add wave -position insertpoint -divider "CACHE" \
sim:/tb/DUT/M1/clk \
sim:/tb/DUT/M1/rst \
sim:/tb/DUT/M1/proc_req \
sim:/tb/DUT/M1/proc_res \
sim:/tb/DUT/M1/mem_req \
sim:/tb/DUT/M1/mem_res \
sim:/tb/DUT/M1/state


add wave -position insertpoint -divider "ALU" \
sim:/tb/DUT/cpu1/riscv_alu/clk \
sim:/tb/DUT/cpu1/riscv_alu/rst \
sim:/tb/DUT/cpu1/riscv_alu/div_en \
sim:/tb/DUT/cpu1/riscv_alu/freeze_pipe \
sim:/tb/DUT/cpu1/riscv_alu/A \
sim:/tb/DUT/cpu1/riscv_alu/B \
sim:/tb/DUT/cpu1/riscv_alu/C \
sim:/tb/DUT/cpu1/riscv_alu/C_hi \
sim:/tb/DUT/cpu1/riscv_alu/op \
sim:/tb/DUT/cpu1/riscv_alu/b_w

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



run 90ns