#pragma once

#include "config.hpp"
#include <terminal_colors.h>

void inspectErrors(Assembler *assembler);

void inspectSymbolTable(Assembler *assembler);

void inspectBinary(Assembler *assembler);

void inspect(Assembler *assembler);
