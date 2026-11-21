#pragma once

// control color output by operating system

#ifdef _WIN32 // for colors on windows
#include <windows.h>

// get and cache the console handle
static inline HANDLE getConsoleHandle() {
    static HANDLE hConsole = NULL;
    if (hConsole == NULL) {
        hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    }
    return hConsole;
}

#define RED 4
#define GREEN 2
#define YELLOW 6
#define BRIGHT_RED 12
#define BRIGHT_GREEN 10
#define BRIGHT_YELLOW 14
#define BRIGHT_WHITE 15
#define RESET 7

#define COLOR_RED SetConsoleTextAttribute(getConsoleHandle(), RED)
#define COLOR_GREEN SetConsoleTextAttribute(getConsoleHandle(), GREEN)
#define COLOR_YELLOW SetConsoleTextAttribute(getConsoleHandle(), YELLOW)
#define COLOR_BOLD_RED SetConsoleTextAttribute(getConsoleHandle(), BRIGHT_RED)    
#define COLOR_BOLD_GREEN SetConsoleTextAttribute(getConsoleHandle(), BRIGHT_GREEN) 
#define COLOR_BOLD_YELLOW SetConsoleTextAttribute(getConsoleHandle(), BRIGHT_YELLOW) 
#define COLOR_BOLD_WHITE SetConsoleTextAttribute(getConsoleHandle(), BRIGHT_WHITE) 
#define COLOR_RESET SetConsoleTextAttribute(getConsoleHandle(),RESET)

#else
// use ANSI excape codes if on mac/linux
#include <stdio.h>  // Add this for printf

#define COLOR_RED printf("\x1b[31m")
#define COLOR_GREEN printf("\x1b[32m")
#define COLOR_YELLOW printf("\x1b[33m")
#define COLOR_BOLD_RED printf("\x1b[1;31m")    
#define COLOR_BOLD_GREEN printf("\x1b[1;32m") 
#define COLOR_BOLD_WHITE printf("\x1b[1;37m") 
#define COLOR_BOLD_YELLOW printf("\x1b[1;33m")
#define COLOR_RESET printf("\x1b[0m")

#endif
