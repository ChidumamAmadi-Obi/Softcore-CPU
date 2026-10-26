# enter project name
PROJ ?= top 

# enter warning disables
RTL_DISABLE_WARNING ?= -Wno-WIDTHEXPAND
TB_DISABLE_WARNING ?=  $(RTL_DISABLE_WARNING) -Wno-WIDTHTRUNC

# specify log file for tbs if needed
LOG_FILE ?= verilator_tb_log.txt

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
help: # shows message
	@echo  MAKEFILE TARGETS:
	@echo  - lint PROJ=source_file_name
	@echo  - run-tb PROJ=source_file_name
	@echo  - clean
	@echo  - help

-h:
	make help

lint: # lint rtl modules
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(RTL_SRC).sv --top $(RTL_SRC)

run-tb: # run tbs
	verilator --binary --assert --trace -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(RTL_SRC).sv $(TB_DIR)/$(TB_SRC).sv --top $(TB_SRC)
	$(TB_EXEC) | tee $(LOG_FILE)

clean: # remove generated stuff
	rm $(OBJ_DIR)/*
