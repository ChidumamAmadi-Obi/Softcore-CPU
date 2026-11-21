#pragma once

#include "config.hpp"

bool isLabel(string pastToken); // checks if token is an nudefined label or subroutine. else returns false

bool isNumber(string token); // checks if number is in desired format, else returns false

int16_t handleInt(Assembler *assembler,string token); // checks for correct literal format, and returns interger

int16_t getLabelLocation(Assembler *assembler, string label); // returns location of label or start of subroutine to be replaced

int8_t mapMnemonics(Assembler *assembler, string token);

void areLabelsDefined(Assembler *assembler);// verify that all labels are defined

