#include "assembler.hpp"

void tokenize(Assembler *assembler){ // splits program up into individual "tokens" and stores into vector
    if(assembler->errorCode!=NONE) return; // exit if error
    stringstream check1(assembler->program.rawAsm);
    string intermediate;

    while(getline(check1, intermediate, ' ')) {
        if (!intermediate.empty()){
            assembler->program.tokens.push_back(intermediate);
        }
    }

    #ifdef DEBUG_TOKENIZER
        for (int i=0; i<assembler->program.tokens.size(); i++){
            printf("%s,",assembler->program.tokens[i].c_str());
        }
    #endif
}
void passOne(Assembler *assembler) { // check syntax and get labels w their location counters
    Maps compareMaps;
    uint16_t byteCounter=0; // keeps track of byte position of every token
    string token;
    string pastToken ="";
    bool printOut=false;
    bool isTokenLabel=false;
    bool isTokenAddress=false;
    bool gSyntax=false;

    if(assembler->errorCode!=NONE) return;

    #ifdef DEBUG_FIRST_PASS
        printOut=true;
    #endif
    
    for (int i=0; i<assembler->program.tokens.size(); i++){ // check every token
        gSyntax=false; 
        isTokenLabel=false;
        token=assembler->program.tokens[i];
        if (printOut) printf("\nBYTE NO:%d -> %s IS BEING PASSED...",byteCounter, token.c_str());
        
        if (compareMaps.mnemonicMap.find(token) != compareMaps.mnemonicMap.end()) { // if mnemonic
            gSyntax=true;

        } else if (compareMaps.regMap.find(token) != compareMaps.regMap.end()){ // if reg number
            gSyntax=true;

        } else if (isNumber(token) )  { // check if its a literal number
            gSyntax=true; 

        } else if (token.back() == ':') { // check if its a label
            string labelName = token.substr(0, token.size() - 1);// Check if label or subroutine name is reserved
            
            if (compareMaps.mnemonicMap.find(labelName) != compareMaps.mnemonicMap.end() ||
                compareMaps.regMap.find(labelName) != compareMaps.regMap.end()) {
                assembler->errorCode = SYNTAX_ERROR;
                return;
            }
            gSyntax=true;
            isTokenLabel=true;
            token.pop_back(); // remove ':' before storing
            assembler->program.symbolTable[token]=byteCounter; // put label into symbol tabel w location counter

        } else if (assembler->program.symbolTable.find(token) != assembler->program.symbolTable.end()){
            gSyntax=true; // if label has been defined in symbol table

        } else if (isLabel(pastToken)) {// if undefined label or subroutine, will check if label actually exists in second pass
            gSyntax=true; 
            assembler->program.symbolTable[token]=UNDEFINED_LABEL;
        } 

        if (!gSyntax) {
            assembler->errorCode=SYNTAX_ERROR;
            assembler->program.invalidToken=token;
            return;
        }
        if (printOut)printf("OK");
        if (!isTokenLabel) byteCounter++; 
        pastToken=token;
    }
}
void passTwo(Assembler *assembler){ // generates binary and replaces symbols with their values
    areLabelsDefined(assembler);
    if(assembler->errorCode!=NONE) return;
    bool printOut=false; 
    int IndexM=0; // machine code index
    string verifiedToken;
    int16_t literal;
    int16_t location;
    int8_t bin;

    #ifdef DEBUG_SECOND_PASS
        printOut=true;
    #endif
    
    if(printOut) printf("GENERATING BIN CODE: ");

    for (int i=0; i<assembler->program.tokens.size(); i++) { 

        verifiedToken=assembler->program.tokens[i];
        if (verifiedToken.back() == ':') continue; // if label dont add to machine code

        location=getLabelLocation(assembler,verifiedToken); // check if token is a label and get location
        bin=mapMnemonics(assembler,verifiedToken); // check if token is mnemonic and map to binary
        literal=handleInt(assembler,verifiedToken); // check if token is literal and convert to an integer

        if (bin == INVALID && location == INVALID && literal == INVALID_LITERAL) { // if token is neither a mnemonic or defined label send error
            assembler->errorCode=BIN_GEN_ERROR;
            return;
        }        

        // if a valid token add binary to machine code verctor 
        if (location != INVALID) assembler->program.machineCode.push_back(location); 
        else if (bin != INVALID)  assembler->program.machineCode.push_back((uint8_t)bin); 
        else if (literal != INVALID_LITERAL) assembler->program.machineCode.push_back((uint8_t)literal);
        if (printOut) printf("%s -> 0x%02X\n",assembler->program.tokens[i].c_str(), assembler->program.machineCode[IndexM]);
        IndexM++;        
    } 
}

//_________________________________________________________________________________________________
void assemble(Assembler *assembler){ // runs assembler
    loadProgram(assembler);
    tokenize(assembler);
    
    passOne(assembler);
    passTwo(assembler);

    #ifndef HEX_ONLY
        exportMachineCodeBin(assembler);
    #endif
    exportMachineCodeHex(assembler);
}