#pragma once

#include "config.hpp"

void loadProgram(Assembler *assembler);

void exportMachineCodeBin(Assembler *assembler);
void exportMachineCodeHex(Assembler *assembler);