
FILE_LIST = rtl_files
TOP_MODULE = top
JSON_FILE = Softcore-CPU
YOSYS_FLAGS ?=

help: # shows msg
	@echo MAKEFILE TARGETS
	@echo	- synth
	@echo	- help

-h:
	make help

synth: # parse sv and synthesize
	yosys $(YOSYS_FLAGS) -m slang -p "read_slang -F $(FILE_LIST).f; synth_gowin -top $(TOP_MODULE) -json $(JSON_FILE).json"