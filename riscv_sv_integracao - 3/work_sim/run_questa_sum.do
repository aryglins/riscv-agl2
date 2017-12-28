vlib work
vdel -all -lib work
vlib work

vcom -f compile_vhdl.f
vlog -f compile_questa_sv_win.f

vsim -t ns -L cycloneive_ver -L altera_mf -L altera -L lpm -L cycloneive \
-L altera_mf_ver -L altera_ver -L lpm_ver -L sgate_ver -novopt work.tb 

run 1ns

add wave -divider "CACHE_OGG" \
sim:/tb/DUT/cpu1/riscv_alu/sub \
sim:/tb/DUT/cpu1/riscv_alu/rst \
sim:/tb/DUT/cpu1/riscv_alu/rem_w \
sim:/tb/DUT/cpu1/riscv_alu/quot_w \
sim:/tb/DUT/cpu1/riscv_alu/op \
sim:/tb/DUT/cpu1/riscv_alu/oflw \
sim:/tb/DUT/cpu1/riscv_alu/mul64 \
sim:/tb/DUT/cpu1/riscv_alu/freeze_pipe \
sim:/tb/DUT/cpu1/riscv_alu/div_en \
sim:/tb/DUT/cpu1/riscv_alu/clk \
sim:/tb/DUT/cpu1/riscv_alu/c_w \
sim:/tb/DUT/cpu1/riscv_alu/b_w \
sim:/tb/DUT/cpu1/riscv_alu/bU_w \
sim:/tb/DUT/cpu1/riscv_alu/add \
sim:/tb/DUT/cpu1/riscv_alu/a_xor_b \
sim:/tb/DUT/cpu1/riscv_alu/a_w \
sim:/tb/DUT/cpu1/riscv_alu/a_or_b \
sim:/tb/DUT/cpu1/riscv_alu/a_and_b \
sim:/tb/DUT/cpu1/riscv_alu/a_SRL_b \
sim:/tb/DUT/cpu1/riscv_alu/a_SRA_b \
sim:/tb/DUT/cpu1/riscv_alu/a_SLT_b \
sim:/tb/DUT/cpu1/riscv_alu/a_SLTU_b \
sim:/tb/DUT/cpu1/riscv_alu/a_SLL_b \
sim:/tb/DUT/cpu1/riscv_alu/aU_w \
sim:/tb/DUT/cpu1/riscv_alu/C_hi \
sim:/tb/DUT/cpu1/riscv_alu/C \
sim:/tb/DUT/cpu1/riscv_alu/B \
sim:/tb/DUT/cpu1/riscv_alu/A \
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
sim:/tb/DUT/cpu1/riscv_regfile/wrten_i 

add wave -divider "_____________________" \
sim:/tb/DUT/cpu1/op1_mux_sel \
sim:/tb/DUT/cpu1/op1_mux \
sim:/tb/DUT/cpu1/rs1_mux \
sim:/tb/DUT/cpu1/u_imm \
sim:/tb/DUT/cpu1/rs1_mux_sel \
sim:/tb/DUT/cpu1/rs1_mux \
sim:/tb/DUT/cpu1/rs1o_w \
sim:/tb/DUT/cpu1/wb_mux \
sim:/tb/DUT/cpu1/mem_align_mux_w 


run 50000ns
