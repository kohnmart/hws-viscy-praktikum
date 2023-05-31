########################################################################################
##
## This file is part of the VISCY project.
## (C) 2007-2022 Gundolf Kiefer, Fachhochschule Augsburg, University of Applied Sciences
##
## Description:
##   Makefile template for the VISCY CPU
##
########################################################################################


# OWN SOURCES; top-level must be last; TO BE ADAPTED at "..."
CPU_SRC = alu/alu.vhdl rf/viscy_rf.vhdl pc/pc.vhdl ir/viscy_ir.vhdl cpu/cpu.vhdl cpu/cpu_tb.vhdl
CPU_OBJ = $(CPU_SRC:%.vhdl=%.o)

# EES/VISCY installation path
EES_VISCY=/opt/ees/share/viscy/



##### Simulation targets (GHDL) #####

# Main target: Simulate and display ...
.PHONY:sim
sim: viscy_cpu_tb
	./$< --wave=$<.ghw
	gtkwave -A $<.ghw &

# Elaborate ...
viscy_cpu_tb: ${CPU_OBJ} viscy_cpu_tb.o
	ees ghdl -e $@

# Generic rule to analyze files (GHDL)...
%.o: %.vhdl
	ees ghdl -a $<

# File dependences ...
cpu.o: alu/alu.o rf/viscy_rf.o pc/pc.o ir/viscy_ir.o cpu/cpu.o
cpu_tb.o: cpu.o



##### Synthesis, implementation and programming (Xilinx) #####

# Main target ...
.PHONY:syn
syn: viscy_system.bit

# Synthesis and implementation ...
viscy_system.bit: ${CPU_SRC}
	ees synthesize -b -x ${EES_VISCY}/zybo-viscy.xdc \
	    ${EES_VISCY}/viscy_system.vhd \
	    ${EES_VISCY}/viscy_debug.dcp \
	    ${CPU_SRC}

# Programming ...
.PHONY:prog
prog: viscy_system.bit
	ees program viscy_system.bit



##### Clean #####

clean:
	ees ghdl --remove
	rm -fr viscy_cpu_tb *.ghw
	rm -fr viscy_system.bit
	rm -fr viscy_system-ees-synthesize
	rm -fr viscy_system-ees viscy_cpu-ees
	rm -fr .Xil vivado*.jou vivado*.log fsm_encoding.os usage_statistics_webtalk.*ml
