#include "windows.h"
#include "process.h"
unsigned int WINAPI ThreadScanFolder(void* pvParam);
unsigned int WINAPI ThreadScanFile(void* pvParam);
unsigned int WINAPI LogWindow(void* pvParam);
unsigned int WINAPI ThreadParseLogFile(void* pvParam);
unsigned int WINAPI ThreadPrepareMon(void* pvParam);