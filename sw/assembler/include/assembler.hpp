#pragma once

#include "config.hpp"
#include "file_io.hpp"
#include "helpers.hpp"

void tokenize(Assembler *assembler); // splits program up into individual "tokens" and stores into vector

void passOne(Assembler *assembler); // check syntax and get labels w their location counters

void passTwo(Assembler *assembler); // generates binary and replaces symbols with their values

void assemble(Assembler *assembler); // runs assembler

