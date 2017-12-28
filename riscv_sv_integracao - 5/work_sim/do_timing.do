vlib work
vdel -all -lib work
vlib work
vlog ../riscv_tb.sv C:/Users/vanessa/Documents/riscv_sv/work_sint/simulation/modelsim/riscv.vo


vsim -t ns +DUT=C:/Users/vanessa/Documents/riscv_sv/work_sint/simulation/modelsim/riscv_v.sdo \-L cycloneive_ver  -L altera_mf_ver -L altera_ver -L lpm_ver -L sgate_ver -sdftyp 
 -novopt work.tb 


run 1ns

add wave -position insertpoint  \
sim:/tb/tx \
sim:/tb/spi_tx \
sim:/tb/spi_mosi \
sim:/tb/spi_en \
sim:/tb/spi_clk \
sim:/tb/sp \
sim:/tb/rx \
sim:/tb/rst \
sim:/tb/regout \
sim:/tb/ra \
sim:/tb/pio_out \
sim:/tb/ir \
sim:/tb/full \
sim:/tb/empty \
sim:/tb/cmp \
sim:/tb/clk

run 15000000ns