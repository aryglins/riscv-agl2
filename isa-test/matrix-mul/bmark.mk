#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

matrix-mul_c_src = \
	matrix-mul.c \
	#interrogator_controller.c \
	#Serial.c\



matrix-mul_riscv_src = \
	crt.S \

matrix-mul_c_objs     = $(patsubst %.c, %.o, $(matrix-mul_c_src))
matrix-mul_riscv_objs = $(patsubst %.S, %.o, $(matrix-mul_riscv_src))

matrix-mul_host_bin = matrix-mul.host
$(matrix-mul_host_bin): $(matrix-mul_c_src)
	$(HOST_COMP) $^ -o $(matrix-mul_host_bin)

matrix-mul_riscv_bin = matrix-mul.riscv
$(matrix-mul_riscv_bin): $(matrix-mul_c_objs) $(matrix-mul_riscv_objs)
	$(RISCV_LINK) $(matrix-mul_c_objs) $(matrix-mul_riscv_objs) \
    -o $(matrix-mul_riscv_bin) $(RISCV_LINK_OPTS)

junk += $(matrix-mul_c_objs) $(matrix-mul_riscv_objs) \
        $(matrix-mul_host_bin) $(matrix-mul_riscv_bin)
