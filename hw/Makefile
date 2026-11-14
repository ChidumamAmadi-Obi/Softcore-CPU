# enter project name
PROJ ?= top 

# enter warning disables
RTL_DISABLE_WARNING ?= -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC
TB_DISABLE_WARNING ?=  $(RTL_DISABLE_WARNING)

# specify flags
TB_FLAGS = --binary --timing --assert --trace 
DEFINE ?= 

# specify log file for tbs if needed
LOG_DIR = logs
LOG_FILE ?= tb_log

# source files ***********************
RTL_SRC = $(PROJ)
TB_SRC  = $(PROJ)_tb

# directories ************************
RTL_DIR = rtl
TB_DIR = tb
OBJ_DIR = obj_dir

# executables ************************
RTL_EXEC = ./$(OBJ_DIR)/V$(RTL_SRC)
TB_EXEC = ./$(OBJ_DIR)/V$(TB_SRC)

# ***************************************************************************************************

PROJ_LIST := alu control_unit memory periphs reg_file cpu top
INCLUDED_MODULES := $(foreach mod,$(PROJ_LIST),$(RTL_DIR)/$(mod).sv)

# ***************************************************************************************************
help: # shows message
	@echo  MAKEFILE TARGETS:
	@echo  - lint PROJ=module_name
	@echo  - run-tb PROJ=module_name
	@echo  - run-regression
	@echo  - run-sim
	@echo  - clean
	@echo  - help

-h:
	make help

lint: # lint rtl modules
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(RTL_SRC).sv --top $(RTL_SRC)

run-tb: # run tbs
	verilator $(TB_FLAGS) $(DEFINE) -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(RTL_SRC).sv $(TB_DIR)/$(TB_SRC).sv --top $(TB_SRC)
	$(TB_EXEC) | tee $(LOG_DIR)/$(LOG_FILE).txt

run-sim: # simulate cpu running program in rtl/hex with metrics
	make run-tb PROJ=top DEFINE="-DSIM -DMETRICS"

run-regression:
	./regression.sh | tee $(LOG_DIR)/regression.txt

clean-hex:
	rm tb/hex_dump/*

clean-logs:
	rm $(LOG_DIR)/*

clean-obj: # remove generated stuff
	rm $(OBJ_DIR)/*

clean-all:
	make clean-hex
	make clean-obj
	make clean-logs
