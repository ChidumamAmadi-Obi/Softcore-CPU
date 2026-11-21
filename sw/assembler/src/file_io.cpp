
#include "file_io.hpp"


void loadProgram(Assembler *assembler){ // loads program from external file and stores in string
    ifstream asmFile((assembler->programInputFilePath + ".asm"));
    string line="";
    
    if (!asmFile.is_open()) {
        assembler->errorCode = LOADING_PROGRAM_ERROR; return;
    }

    while (getline(asmFile, line)) {
        size_t firstNonSpace = line.find_first_not_of(" \t"); 

        if (line.empty()) continue; // skip empty lines
        if (firstNonSpace != string::npos) line = line.substr(firstNonSpace);// rim leading whitespace
        else line.clear();
        
        size_t pos = line.find(';'); 

        if (pos != string::npos) line = line.substr(0, pos);// remove inline comments
        if (line.empty())  continue; // sip if line is empty after comment removal
        
        line.erase(line.find_last_not_of(" \t\r\n") + 1); // trim trailing whitespace before puttin ginto string

        #ifdef DEBUG_RAW_ASM
            printf("%s\n", line.c_str());
        #endif
        
        assembler->program.rawAsm += line + " ";
        
    }

    if (assembler->program.rawAsm.empty()) {
        assembler->errorCode = NO_ASM_ERROR; return;
    }

    asmFile.close();
}

void exportMachineCodeBin(Assembler *assembler){
    if(assembler->errorCode!=NONE) return;

    ofstream binOut((assembler->programOutputFilePath + ".bin"),ios::binary);

    if (!binOut.is_open()) {
        assembler->errorCode = EXPORTING_BINARY_ERROR;
        return;
    } 
    assembler->program.sizeOfProgam = assembler->program.machineCode.size(); // size in bytes
    binOut.write((char*)&assembler->program.sizeOfProgam,sizeof(uint16_t));

    for (int i=0; i<assembler->program.machineCode.size(); i++) {
        binOut.write((char*)&assembler->program.machineCode[i], sizeof(uint8_t));
    }

    binOut.flush();
    binOut.close();
}

// deepseek generated // 
void exportMachineCodeHex(Assembler *assembler) {
    if (assembler->errorCode != NONE) return;

    const auto &mc = assembler->program.machineCode;   // vector<uint8_t>

    if (mc.size() > MAX_WORDS) {
        assembler->errorCode = PRGM_SIZE_ERROR;   // program doesn't fit 4 banks
        return;
    }

    size_t word_i = 0;
    for (size_t bank = 0; bank < NUM_BANKS; ++bank) {
        const string path =
            assembler->programHexDirectoryPath + "/ram_" + to_string(bank) + ".hex";

        ofstream hexOut(path, ios::out | ios::trunc);
        if (!hexOut.is_open()) {
            assembler->errorCode = EXPORTING_BINARY_ERROR;
            return;
        }

        if (word_i >= mc.size()) {
            // Empty bank: a single blank line so the file still exists and is readable.
            hexOut << '\n';
        } else {
            const size_t wordsInBank = min(BANK_SIZE, mc.size() - word_i);
            for (size_t i = 0; i < wordsInBank; ++i, ++word_i) {
                char buf[4];
                snprintf(buf, sizeof(buf), "%02x\n",
                              static_cast<unsigned>(mc[word_i]) & 0xFFu);
                hexOut << buf;
            }
        }

        hexOut.flush();
        hexOut.close();
    }
}
// deepseek generated // 
