CXX = g++
MACRO ?= -DSHOW_ERRORS -DHEX_ONLY

PROJ ?= default_program

ASM  ?= programs/$(PROJ)
BIN  ?= bin/$(PROJ) # not used here, only for emulator
HEX  ?= ../hw/tb/test_programs/$(PROJ)

ASSEMBLER_DIR  = assembler
ASSEMBLER_SRC  = $(wildcard $(ASSEMBLER_DIR)/src/*.cpp)
ASSEMBLER_INC  = -I$(ASSEMBLER_DIR)/include
ASSEMBLER_EXEC = assembler_e

CLEAN = rm -f $(ASSEMBLER_EXEC)

.PHONY: all build run clean help -h

all: $(ASSEMBLER_EXEC)

build: all

run: $(ASSEMBLER_EXEC)
	./$(ASSEMBLER_EXEC) $(BIN) $(HEX) $(ASM)

$(ASSEMBLER_EXEC): $(ASSEMBLER_SRC)
	$(CXX) $(MACRO) $(ASSEMBLER_INC) -o $@ $(ASSEMBLER_SRC)

clean:
	$(CLEAN)

-h: help

help:
	@echo ""
	@echo MAKEFILE TARGETS:
	@echo   run    "Build if needed, then run"
	@echo   clean  "Remove executables"
	@echo   help   "Show this help"

	@echo MACROS:
	@echo SHOW_ERRORS, SHOW_SYMBOL_TABLE, SHOW_GENERATED_BINARY, DEBUG_RAW_ASM, DEBUG_TOKENIZER,DEBUG_FIRST_PASS, DEBUG_SECOND_PASS	
	@echo ""