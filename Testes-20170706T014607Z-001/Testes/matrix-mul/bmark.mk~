#=======================================================================
# UCB CS250 Makefile fragment for benchmarks
#-----------------------------------------------------------------------
#
# Each benchmark directory should have its own fragment which
# essentially lists what the source files are and how to link them
# into an riscv and/or host executable. All variables should include
# the benchmark name as a prefix so that they are unique.
#

32-bit-math_c_src = \
	32-bit-math.c \
	#interrogator_controller.c \
	#Serial.c\



32-bit-math_riscv_src = \
	crt.S \

32-bit-math_c_objs     = $(patsubst %.c, %.o, $(32-bit-math_c_src))
32-bit-math_riscv_objs = $(patsubst %.S, %.o, $(32-bit-math_riscv_src))

32-bit-math_host_bin = 32-bit-math.host
$(32-bit-math_host_bin): $(32-bit-math_c_src)
	$(HOST_COMP) $^ -o $(32-bit-math_host_bin)

32-bit-math_riscv_bin = 32-bit-math.riscv
$(32-bit-math_riscv_bin): $(32-bit-math_c_objs) $(32-bit-math_riscv_objs)
	$(RISCV_LINK) $(32-bit-math_c_objs) $(32-bit-math_riscv_objs) \
    -o $(32-bit-math_riscv_bin) $(RISCV_LINK_OPTS)

junk += $(32-bit-math_c_objs) $(32-bit-math_riscv_objs) \
        $(32-bit-math_host_bin) $(32-bit-math_riscv_bin)
