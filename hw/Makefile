# warning diable
RTL_DISABLE_WARNING ?= -Wno-WIDTHEXPAND
TB_DISABLE_WARNING ?=  $(RTL_DISABLE_WARNING) -Wno-WIDTHTRUNC

# log file for tbs if needed
TB_LOG_FILE = verilator_tb_log.txt

# source files ***********************
# rtl
TOP_RTL_SRC = top
MEM_RTL_SRC = memory
ALU_RTL_SRC = alu
CU_RTL_SRC  = control_unit
CPU_RTL_SRC = cpu
PPH_RTL_SRC = periphs
REG_RTL_SRC = reg_file

# tbs
TOP_TB_SRC  = top_tb
MEM_TB_SRC  = memory_tb
ALU_TB_SRC  = alu_tb
CU_TB_SRC   = control_unit_tb
CPU_TB_SRC  = cpu_tb
PPH_TB_SRC  = periphs_tb
REG_TB_SRC = reg_file_tb

# directories
RTL_DIR = rtl
TB_DIR = tb
OBJ_DIR = obj_dir

# executables ************************
# rtl executables
TOP_RTL_EXEC = ./$(OBJ_DIR)/V$(TOP_RTL_SRC)
MEM_RTL_EXEC = ./$(OBJ_DIR)/V$(MEM_RTL_SRC)
ALU_RTL_EXEC = ./$(OBJ_DIR)/V$(ALU_RTL_SRC)
CU_RTL_EXEC  = ./$(OBJ_DIR)/V$(CU_RTL_SRC)
CPU_RTL_EXEC = ./$(OBJ_DIR)/V$(CPU_RTL_SRC)
PPH_RTL_EXEC = ./$(OBJ_DIR)/V$(PPH_RTL_SRC)
REG_RTL_EXEC = ./$(OBJ_DIR)/V$(REG_RTL_SRC)

# tb executalbes
TOP_TB_EXEC = ./$(OBJ_DIR)/V$(TOP_TB_SRC)
MEM_TB_EXEC = ./$(OBJ_DIR)/V$(MEM_TB_SRC)
ALU_TB_EXEC = ./$(OBJ_DIR)/V$(ALU_TB_SRC)
CU_TB_EXEC  = ./$(OBJ_DIR)/V$(CU_TB_SRC)
CPU_TB_EXEC = ./$(OBJ_DIR)/V$(CPU_TB_SRC)
PPH_TB_EXEC = ./$(OBJ_DIR)/V$(PPH_TB_SRC)
REG_TB_EXEC = ./$(OBJ_DIR)/V$(REG_TB_SRC)

# ***************************************************************************************************
help: # shows message
	@echo  MAKEFILE TARGETS:
	@echo  - lint-rtl
	@echo  - lint-rtl-mem
	@echo  - lint-rtl-cu	
	@echo  - lint-rtl-cpu
	@echo  - lint-rtl-pph
	@echo  - lint-rtl-alu	
	@echo  - lint-rtl-reg	

	@echo  - run-tb
	@echo  - run-tb-mem
	@echo  - run-tb-alu
	
	@echo  - clean
	@echo  - help

-h:
	make help

# lint rtl modules
lint-rtl:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(TOP_RTL_SRC).sv --top top
lint-rtl-cpu:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(CPU_RTL_SRC).sv --top cpu
lint-rtl-mem:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(MEM_RTL_SRC).sv --top memory
lint-rtl-alu:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(ALU_RTL_SRC).sv --top alu
lint-rtl-cu:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(CU_RTL_SRC).sv --top control_unit
lint-rtl-pph:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(PPH_RTL_SRC).sv --top periphs
lint-rtl-reg:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(REG_RTL_SRC).sv --top reg_file

# run tbs
run-tb:
	verilator --binary --assert --trace -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(TOP_RTL_SRC).sv $(TB_DIR)/$(TOP_TB_SRC).sv --top top_tb
	$(TOP_TB_EXEC) | tee $(TB_LOG_FILE)
run-tb-mem:
	verilator --binary --assert --trace -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(MEM_RTL_SRC).sv $(TB_DIR)/$(MEM_TB_SRC).sv --top memory_tb
	$(MEM_TB_EXEC) | tee $(TB_LOG_FILE)
run-tb-alu:
	verilator --binary --assert --trace -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(ALU_RTL_SRC).sv $(TB_DIR)/$(ALU_TB_SRC).sv --top alu_tb
	$(ALU_TB_EXEC) | tee $(TB_LOG_FILE)	

clean: # remove generated stuff
	rm $(OBJ_DIR)/*
