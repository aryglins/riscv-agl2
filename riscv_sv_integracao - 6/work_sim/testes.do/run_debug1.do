vcom -f compile_vhdl.f

vlog -f compile_questa_sv_win.f

vsim -t ns -L cycloneiii_ver -L cycloneiv_ver \
-L altera_mf -L altera -L lpm -L cycloneiv \
-L altera_mf_ver -L altera_ver -L lpm_ver \
-L sgate_ver -novopt work.tb 

run 1ns

add wave -divider "CACHE_OGG" \
sim:/tb/DUT/cpu1/riscv_alu/bU_w \
sim:/tb/DUT/cpu1/riscv_alu/aU_w \
sim:/tb/DUT/cpu1/riscv_alu/B \
sim:/tb/DUT/cpu1/riscv_alu/A \
sim:/tb/DUT/cpu1/riscv_alu/a_SLTU_b \
sim:/tb/DUT/cpu1/riscv_decoder/alu_busy \
sim:/tb/DUT/cpu1/riscv_decoder/alu_en \
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
sim:/tb/DUT/cpu1/instr_r \
sim:/tb/DUT/cpu1/clk_i \
sim:/tb/DUT/cpu1/riscv_decoder/prev_op \
sim:/tb/DUT/cpu1/riscv_decoder/prev_rd \
sim:/tb/DUT/cpu1/riscv_decoder/rf_wrten \
sim:/tb/DUT/cpu1/riscv_decoder/rom_mux_sel \
sim:/tb/DUT/cpu1/riscv_decoder/rs1 \
sim:/tb/DUT/cpu1/riscv_decoder/rs1_mux_sel \
sim:/tb/DUT/cpu1/riscv_decoder/rs2 \
sim:/tb/DUT/cpu1/riscv_decoder/rs2_mux_sel \
sim:/tb/DUT/cpu1/riscv_decoder/take_br \
sim:/tb/DUT/cpu1/riscv_decoder/wb_sel


run 30000ns
