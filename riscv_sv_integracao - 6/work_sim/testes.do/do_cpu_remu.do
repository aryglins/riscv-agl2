vcom -f compile_vhdl.f
vlog -f compile_questa_sv_win.f
vsim -t ns -L cycloneiii_ver -L cycloneive_ver \
-L altera_mf -L altera -L lpm -L cycloneive \
-L altera_mf_ver -L altera_ver -L lpm_ver \
-L sgate_ver -novopt work.tb 

run 1ns

add wave -position insertpoint -divider "OGG_CPU" \
	sim:/tb/DUT/cpu1/instr_r \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/state \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/rst \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/r \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/q \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/div_zero \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/div_sub \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/div_r \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/div_neg \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/div_n \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/div_en \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/div_done \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/div_d \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/div_count \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/div_by_zero_r \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/clk \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/b \
	sim:/tb/DUT/cpu1/riscv_alu/riscv_div/a \
	sim:/tb/DUT/SLV0/pio_0_out \
	sim:/tb/DUT/cpu1/riscv_regfile/wrten_i \
	sim:/tb/DUT/cpu1/riscv_regfile/sp \
	sim:/tb/DUT/cpu1/riscv_regfile/rst_i \
	sim:/tb/DUT/cpu1/riscv_regfile/rs2_i \
	sim:/tb/DUT/cpu1/riscv_regfile/rs1_i \
	sim:/tb/DUT/cpu1/riscv_regfile/regfile \
	sim:/tb/DUT/cpu1/riscv_regfile/rd_i \
	sim:/tb/DUT/cpu1/riscv_regfile/ra \
	sim:/tb/DUT/cpu1/riscv_regfile/op2_o \
	sim:/tb/DUT/cpu1/riscv_regfile/op1_o \
	sim:/tb/DUT/cpu1/riscv_regfile/data_in \
	sim:/tb/DUT/cpu1/riscv_regfile/clk_i

run 50000ns