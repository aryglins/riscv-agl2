vlib work
vdel -all -lib work
vlib work

vcom -f compile_vhdl.f
vlog -f compile_questa_sv_win.f

vsim -t ns -L cycloneive_ver -L altera_mf -L altera -L lpm -L cycloneive \
-L altera_mf_ver -L altera_ver -L lpm_ver -L sgate_ver -novopt work.tb 

run 1ns

add wave -divider "CPU_OGG" \
sim:/tb/DUT/cpu1/riscv_regfile/clk_i \
sim:/tb/result \
{sim:/tb/DUT/cpu1/riscv_regfile/regfile[29]} \
sim:/tb/instruction_o \
sim:/tb/DUT/cpu1/riscv_fetch/stall_i \
sim:/tb/DUT/cpu1/riscv_fetch/inst_counter_o \
sim:/tb/DUT/cpu1/riscv_fetch/clk_counter_o \
sim:/tb/DUT/cpu1/riscv_fetch/rst_eval_regs \
sim:/tb/DUT/cpu1/riscv_fetch/reset

add wave -divider "CACHE_OGG" \
sim:/tb/DUT/cpu1/riscv_regfile/data_in \
sim:/tb/DUT/cpu1/npc_r \
sim:/tb/DUT/cpu1/wb_mux \
sim:/tb/DUT/cpu1/wb_mux_sel_int \
sim:/tb/DUT/cpu1/wb_mux_sel \
sim:/tb/DUT/cpu1/riscv_fetch/pc_input_mux_sel_w \
sim:/tb/DUT/cpu1/riscv_fetch/pc_input_mux_sel \
sim:/tb/DUT/cpu1/riscv_fetch/interrupt_req \
sim:/tb/DUT/cpu1/riscv_fetch/pc_input_sel_i\
sim:/tb/DUT/cpu1/instr_r \
sim:/tb/DUT/cpu1/riscv_regfile/op1_o \
sim:/tb/DUT/cpu1/riscv_regfile/op2_o \
sim:/tb/DUT/cpu1/riscv_regfile/ra \
sim:/tb/DUT/cpu1/riscv_regfile/rd_i \
sim:/tb/DUT/cpu1/riscv_regfile/regfile \
sim:/tb/DUT/cpu1/riscv_regfile/rs1_i \
sim:/tb/DUT/cpu1/riscv_regfile/rs2_i \
sim:/tb/DUT/cpu1/riscv_regfile/rst_i \
sim:/tb/DUT/cpu1/riscv_regfile/sp \
sim:/tb/DUT/cpu1/riscv_regfile/wrten_i \
sim:/tb/DUT/cpu1/riscv_fetch/state \
sim:/tb/DUT/cpu1/riscv_fetch/reset \
sim:/tb/DUT/cpu1/riscv_fetch/stall_i \
sim:/tb/DUT/cpu1/riscv_fetch/pc_input_mux \
sim:/tb/DUT/cpu1/riscv_fetch/pc_input_mux_sel \
sim:/tb/DUT/cpu1/riscv_fetch/rst_i \
sim:/tb/DUT/cpu1/riscv_fetch/inst_cache_ren \
sim:/tb/DUT/cpu1/riscv_fetch/take_br \
sim:/tb/DUT/cpu1/riscv_fetch/inst_cache_d \
sim:/tb/DUT/cpu1/riscv_fetch/inst_reg_mux \
sim:/tb/DUT/cpu1/riscv_fetch/pc_input_mux \
sim:/tb/DUT/cpu1/riscv_fetch/pc_input_mux_sel_w \
sim:/tb/DUT/cpu1/riscv_fetch/pc_input_sel_i \
sim:/tb/DUT/cpu1/riscv_fetch/pred_miss \
sim:/tb/DUT/cpu1/riscv_fetch/program_counter \
sim:/tb/DUT/cpu1/riscv_fetch/sb_si_ext \
sim:/tb/DUT/cpu1/riscv_fetch/take_br \
sim:/tb/DUT/cpu1/riscv_fetch/uj_si_ext 
add wave -divider "_____________________" \
sim:/tb/DUT/cpu1/riscv_decoder/alu_sel \
sim:/tb/DUT/cpu1/riscv_decoder/curr_rs1 \
sim:/tb/DUT/cpu1/riscv_decoder/curr_rs2 \
sim:/tb/DUT/cpu1/riscv_decoder/data_av \
sim:/tb/DUT/cpu1/riscv_decoder/div_en \
sim:/tb/DUT/cpu1/riscv_decoder/func3_i \
sim:/tb/DUT/cpu1/riscv_decoder/func7_i \
sim:/tb/DUT/cpu1/riscv_decoder/ir_en \
sim:/tb/DUT/cpu1/riscv_decoder/load_mem \
sim:/tb/DUT/cpu1/riscv_decoder/load_mem_i \
sim:/tb/DUT/cpu1/riscv_decoder/mem_align_mux \
sim:/tb/DUT/cpu1/riscv_decoder/mem_busy \
sim:/tb/DUT/cpu1/riscv_decoder/mem_clken \
sim:/tb/DUT/cpu1/riscv_decoder/mem_rden \
sim:/tb/DUT/cpu1/riscv_decoder/mem_unalign_add_mux \
sim:/tb/DUT/cpu1/riscv_decoder/mem_unalign_str_mux \
sim:/tb/DUT/cpu1/riscv_decoder/mem_unalign_wren \
sim:/tb/DUT/cpu1/riscv_decoder/mem_wrten \
sim:/tb/DUT/cpu1/riscv_decoder/op1_sel \
sim:/tb/DUT/cpu1/riscv_decoder/op2_sel \
sim:/tb/DUT/cpu1/riscv_decoder/opcode_i \
sim:/tb/DUT/cpu1/riscv_decoder/pc_mux_sel_o \
sim:/tb/DUT/cpu1/riscv_decoder/pred_miss \
sim:/tb/DUT/cpu1/riscv_decoder/prev_op \
sim:/tb/DUT/cpu1/riscv_decoder/prev_rd \
sim:/tb/DUT/cpu1/riscv_decoder/rf_wrten \
sim:/tb/DUT/cpu1/riscv_decoder/rs1 \
sim:/tb/DUT/cpu1/riscv_decoder/rs1_mux_sel \
sim:/tb/DUT/cpu1/riscv_decoder/rs2 \
sim:/tb/DUT/cpu1/riscv_decoder/rs2_mux_sel \
sim:/tb/DUT/cpu1/riscv_decoder/take_br \
sim:/tb/DUT/cpu1/riscv_decoder/wb_sel 

run 500000ns
