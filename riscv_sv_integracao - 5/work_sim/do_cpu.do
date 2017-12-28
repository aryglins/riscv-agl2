vlib work
vdel -all -lib work
vlib work

vcom -f compile_vhdl.f
vlog -f compile_questa_sv_win.f

vsim -t ns -L cycloneive_ver -L altera_mf -L altera -L lpm -L cycloneive \
-L altera_mf_ver -L altera_ver -L lpm_ver -L sgate_ver -novopt work.tb 

run 1ns

add wave -position insertpoint -divider "OGG_CPU" \
sim:/tb/DUT/cpu1/riscv_fetch/sb_si_ext \
sim:/tb/DUT/cpu1/riscv_fetch/uj_si_ext \
sim:/tb/DUT/cpu1/instr_r \
sim:/tb/DUT/cpu1/riscv_alu/B \
sim:/tb/DUT/cpu1/riscv_alu/A 

add wave -position insertpoint -divider "rs1_mux" \
sim:/tb/DUT/cpu1/rs1_mux_sel \
sim:/tb/DUT/cpu1/rs1_mux \
sim:/tb/DUT/cpu1/rs1o_w \
sim:/tb/DUT/cpu1/mem_align_mux

add wave -position insertpoint -divider "REGFILE" \
sim:/tb/DUT/cpu1/clk_i \
sim:/tb/DUT/cpu1/rd_mux \
sim:/tb/DUT/cpu1/rs1_w \
sim:/tb/DUT/cpu1/rs2_w \
sim:/tb/DUT/cpu1/wb_mux \
sim:/tb/DUT/cpu1/rf_wrten_pipe \
sim:/tb/DUT/cpu1/ra \
sim:/tb/DUT/cpu1/sp \
sim:/tb/DUT/cpu1/rs1o_w \
sim:/tb/DUT/cpu1/rs2o_w 
 
run 30000ns