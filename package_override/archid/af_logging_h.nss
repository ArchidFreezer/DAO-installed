#include "core_h"

// Name of the module local variable
const string AF_LOG_LEVEL = "AF_LOG_LEVEL";

const int AF_LOG_NONE  = 0;
const int AF_LOG_INFO  = 1;
const int AF_LOG_WARN = 2;
const int AF_LOG_DEBUG = 3;

/**
* @brief gets the maximum logging level
*
* This is used to check whether log messages should be written
*
**/
int GetLogLevel() {
    return GetLocalInt(GetModule(),AF_LOG_LEVEL);
}

/**
* @brief sets the maximum logging level
*
* Logging messages that are greater than this will not be written.
*
* @param nLevel The maximum log level to set, should be between 0 (NONE) and 2 (DEBUG)
**/
void SetLogLevel(int nLevel) {
    switch(nLevel) {
        case(AF_LOG_NONE):
        case(AF_LOG_INFO):
        case(AF_LOG_WARN):
        case(AF_LOG_DEBUG): {
            SetLocalInt(GetModule(),AF_LOG_LEVEL,nLevel);
            break;
        }
        default: {
            SetLocalInt(GetModule(),AF_LOG_LEVEL,AF_LOG_NONE);
            break;
        }
    }
}

/**
* @brief set maximum logging level from ini
*
* Reads the DragonAge.ini file for the configured global logging level.
* If no level is configured then no logging is assumed.
*
**/
void ReadIniLogLevel() {
    string sLogLevel = ReadIniEntry("Archid", "DebugLevel");
    if (sLogLevel == "3") SetLogLevel(AF_LOG_DEBUG);
    else if (sLogLevel == "2") SetLogLevel(AF_LOG_WARN);
    else if (sLogLevel == "1") SetLogLevel(AF_LOG_INFO);
    else SetLogLevel(AF_LOG_NONE);
}

/**
* @brief check whether a logging level is in scope
*
* The paramete level is checked against the global logging level and the function will
* return TRUE if the level should be logged; otherwise FALSE
*
* @param nLevel logging level to check
**/
int IsLoggingLevel(int nLevel) {
    return (GetLogLevel() >= nLevel);
}

/**
* @brief writes an info string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param nLogLevel   The log level of the calling script. This needs to be >= AF_LOG_INFO for the message to be logged
*
**/
void afLogInfo(string sMsg, int nLogLevel = AF_LOG_INFO) {
    if (IsLoggingLevel(Min(nLogLevel, AF_LOG_INFO)) && nLogLevel >= AF_LOG_INFO) PrintToLog("[INFO] " + sMsg);
}

/**
* @brief writes a warning string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param nLogLevel   The log level of the calling script. This needs to be >= AF_LOG_WARN for the message to be logged
*
**/
void afLogWarn(string sMsg, int nLogLevel = AF_LOG_WARN) {
    if (IsLoggingLevel(Min(nLogLevel, AF_LOG_WARN)) && nLogLevel >= AF_LOG_WARN) PrintToLog("[WARN] " + sMsg);
}

/**
* @brief writes a debug string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param nLogLevel   The log level of the calling script. This needs to be >= AF_LOG_DEBUG for the message to be logged
*
**/
void afLogDebug(string sMsg, int nLogLevel = AF_LOG_DEBUG) {
    if (IsLoggingLevel(Min(nLogLevel, AF_LOG_DEBUG)) && nLogLevel >= AF_LOG_DEBUG) PrintToLog("[DEBUG] " + sMsg);
}
