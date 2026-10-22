# warning diable
RTL_DISABLE_WARNING ?= -Wno-WIDTHEXPAND
TB_DISABLE_WARNING ?=  $(RTL_DISABLE_WARNING) -Wno-WIDTHTRUNC

# log file for tbs if needed
TB_LOG_FILE = verilator_tb_log.txt

# source files ***********************
# rtl
TOP_RTL_SRC = top
MEM_RTL_SRC = memory

# tbs
TOP_TB_SRC = top_tb
MEM_TB_SRC = memory_tb

# directories
RTL_DIR = rtl
TB_DIR = tb
OBJ_DIR = obj_dir

# executables ************************
# rtl executables
TOP_RTL_EXEC = ./$(OBJ_DIR)/V$(TOP_RTL_SRC)
MEM_RTL_EXEC = ./$(OBJ_DIR)/V$(MEM_RTL_SRC)

# tb executalbes
TOP_TB_EXEC = ./$(OBJ_DIR)/V$(TOP_TB_SRC)
MEM_TB_EXEC = ./$(OBJ_DIR)/V$(MEM_TB_SRC)

# ***************************************************************************************************
help: # shows message
	@echo  MAKEFILE TARGETS:
	@echo  - lint-rtl
	@echo  - lint-rtl-mem
	@echo  - run-tb
	@echo  - run-tb-mem
	@echo  - clean
	@echo  - help

# lint rtl modules
lint-rtl:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(TOP_RTL_SRC).v --top top
lint-rtl-mem:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(MEM_RTL_SRC).v --top memory

# run tbs
run-tb:
	verilator --binary --trace -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(TOP_RTL_SRC).v $(TB_DIR)/$(TOP_TB_SRC).sv --top top_tb
	$(TOP_TB_EXEC) | tee $(TB_LOG_FILE)
run-tb-mem:
	verilator --binary --trace -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(MEM_RTL_SRC).v $(TB_DIR)/$(MEM_TB_SRC).sv --top memory_tb
	$(MEM_TB_EXEC) | tee $(TB_LOG_FILE)

clean: # remove generated stuff
	rm $(OBJ_DIR)/*
