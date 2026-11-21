
ASM_FILE ?= default_program
YOSYS_FLAGS ?= -q
# HEX_PATH ?= ../hw/tb/test_programs/$(ASM_FILE)
HEX_PATH  ?= ../hw/rtl/hex

FILE_LIST = rtl_files
TOP_MODULE = top
PROJ_NAME = Softcore-CPU

help: # shows msg
	@echo MAKEFILE TARGETS
	@echo	- synth
	@echo	- assemble
	@echo	- regression
	@echo	- simulate
	@echo	- run
	@echo	- clean
	@echo	- help

h:
	make help

synth: # parse sv and synthesize
	yosys $(YOSYS_FLAGS) -m slang -p "read_slang -F $(FILE_LIST).f; synth_gowin -top $(TOP_MODULE) -json $(PROJ_NAME).json -nodffe"

assemble: # asm to machine code (by default .hex code sent to hw/rtl/tb)
	cd sw && make run PROJ=$(ASM_FILE) HEX_SRC="$(HEX_PATH)"

regression: # run regression test
	cd hw && make run-regression

simulate: # softcore runs asm in tb (with .hex files in hw/rtl/hex)
	cd hw && make run-sim

run:
	make assemble HEX_PATH="$(HEX_PATH)"
	make simulate

clean:
	cd sw && make clean