#include "helpers.hpp"

bool isLabel(string pastToken){ // checks if token is an nudefined label or subroutine. else returns false
    if (pastToken.compare("CALL") == 0) return true;
    if (pastToken.compare("JMP_ABV") == 0) return true;
    if (pastToken.compare("JMP_ZRO") == 0) return true;
    if (pastToken.compare("JMP_OFW") == 0) return true;
    if (pastToken.compare("JMP_NEG") == 0) return true;
    if (pastToken.compare("JMP") == 0) return true;
    return false;
}
bool isNumber(string token) { // checks if number is in desired format, else returns false
    if (token.empty()) return false;
    if (token.front() != '-') { // if positive number 
        if (token.size() > 2 && token[0] == '0' && (token[1] == 'x' || token[1] == 'X')) {// hex prefix
            for (size_t i = 2; i < token.size(); i++) {
                if (!isxdigit(token[i])) return false;
            } return true;
        }
        
        if (token.size() > 1 && (token[0] == 'b' || token[0] == 'B')) {// bin prefix
            for (size_t i = 1; i < token.size(); i++) {
                if (token[i] != '0' && token[i] != '1') return false;
            } return true;
        }
       
        for (size_t i = 0; i < token.size(); i++) { // is decimal?
            if (!isdigit(token[i])) return false;
        } return true;
    } else if (token.front() == '-') { // if negative number
        if (token[1] == '0' && (token[2] == 'x' || token[2] == 'X')) {  // hex prefix
            for (size_t i=3; i < token.size(); i++) {
                if (!isxdigit(token[i])) return false;
            } return true;
        }
      
        if (token.size() > 1 && (token[1] == 'b' || token[2] == 'B')) {  // bin prefix
            for (size_t i = 2; i < token.size(); i++) {
                if (token[i] != '0' && token[i] != '1') return false;
            } return true;
        }
        
        for (size_t i = 1; i < token.size(); i++) { // is decimal?
            if (!isdigit(token[i])) return false;
        } return true;
    } 
    return false;
}

int16_t handleInt(Assembler *assembler,string token){ // checks for correct literal format, and returns interger
    if (token.back() == ':') return -1; // if label return
    if (token.front() =='*'){ // " * " symbolize memory locations in ram
        if ((token[1] == '0') && (token[2] == 'x' || token[2] == 'X')) {
            long decNumberLong = strtol(token.c_str()+1, NULL, 16);
            return (int16_t)decNumberLong;
        } else if (token[1] == 'b'  || token[1] == 'B') {
            long decNumberLong = strtol(token.c_str()+2, NULL, 2);
            return (int16_t)decNumberLong;
        } else {
            long decNumberLong = strtol(token.c_str()+1, NULL, 10);
            return (int16_t)decNumberLong;
        }
    } else {
        if ((token.front() == '0') && (token[1] == 'x' || token[1] == 'X')) {
            long decNumberLong = strtol(token.c_str(), NULL, 16);
            return (int16_t)decNumberLong;
        } else if (token.front() == 'b' || token.front() == 'B') {
            long decNumberLong = strtol(token.c_str()+1, NULL, 2);
            return (int16_t)decNumberLong;
        } else { // just a normal number
            long decNumberLong = strtol(token.c_str(), NULL, 10);
            return (int16_t)decNumberLong;
        }
    } return INVALID_LITERAL; // if invalid
}
int16_t getLabelLocation(Assembler *assembler, string label) { // returns location of label or start of subroutine to be replaced
    if(assembler->program.symbolTable.find(label) == assembler->program.symbolTable.end()){ 
        return INVALID;
    } return assembler->program.symbolTable[label];
}
int8_t mapMnemonics(Assembler *assembler, string token){
    static Maps gmaps; // get unordered maps to compare tokens to
    if (gmaps.mnemonicMap.find(token) != gmaps.mnemonicMap.end()) { // if valid mnemonic
        return (int8_t)gmaps.mnemonicMap[token];
    } 
    if (gmaps.regMap.find(token) != gmaps.regMap.end()) { // if valid reg number
        return (int8_t)gmaps.regMap[token];
    } return INVALID; // if not found return -1 error
}
void areLabelsDefined(Assembler *assembler){// verify that all labels are defined
    for (auto& pair : assembler->program.symbolTable) { 
        if (pair.second == UNDEFINED_LABEL) {  
            assembler->errorCode = SYMBOL_ERROR;
            assembler->program.invalidLabel = pair.first;
            return;
        }
    }
}
