# enter project name
PROJ ?= top 

# enter warning disables
RTL_DISABLE_WARNING ?= -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC
TB_DISABLE_WARNING ?=  $(RTL_DISABLE_WARNING)

# specify test bench flags
TB_FLAGS = --binary --timing --assert --trace 

# specify log file for tbs if needed
LOG_DIR = logs
LOG_FILE ?= verilator_tb_log

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
	@echo  - clean
	@echo  - help

-h:
	make help

lint: # lint rtl modules
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(RTL_SRC).sv --top $(RTL_SRC)

run-tb: # run tbs
	verilator $(TB_FLAGS) -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(RTL_SRC).sv $(TB_DIR)/$(TB_SRC).sv --top $(TB_SRC)
	$(TB_EXEC) | tee $(LOG_DIR)/$(LOG_FILE).txt

run-regression:
	./regression.sh | tee $(LOG_DIR)/regression.txt

clean: # remove generated stuff
	rm $(OBJ_DIR)/*
