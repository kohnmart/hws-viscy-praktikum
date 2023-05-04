# This file is part of the lab excercises of the Efficient Embedded Systems lab.
#
# (C) 2007-2019 Gundolf Kiefer, Augsburg University of Applied Sciences
#
# Description:
#   Demo-Makefile for small VHDL projects.


##### Simulation (GHDL) #####

#-fsynopsys

.PHONY: sim
sim:
	ghdl -a viscy_ir.vhdl viscy_ir_tb.vhdl
	ghdl -r viscy_ir_tb --wave=viscy_ir_tb.ghw 
	gtkwave -A viscy_ir_tb.ghw &

# Elaboration targets (GHDL with GCC/LLVM backend)
viscy_ir_tb: viscy_ir_tb.o viscy_ir.o 
	ghdl -e $@

# Generic rule to analyze files (GHDL with GCC/LLVM backend)
%.o:	%.vhdl
	ghdl -a $<

# File dependencies...
viscy_ir_tb.o: viscy_ir.o


