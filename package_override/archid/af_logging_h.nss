#include "core_h"
#include "log_h"

// 2DA table ID with log level definitions
const int AF_TABLE_LOGGING = 6610004;
// 2DA row with the global log level
const int AF_LOGGROUP_GLOBAL = 0;
// 2DA row with log script inclusion enabled
const int AF_INCLUDE_SCRIPT = 12;

// Defined log levels
const int AF_LOG_NONE  = 0;
const int AF_LOG_INFO  = 1;
const int AF_LOG_WARN = 2;
const int AF_LOG_DEBUG = 3;

/**
* @brief get the max log level for a log group
*
* Checks the module variables to see if the log group is defined, if it is then
* the maximum level it is configured for is returned, otherwise it assumes that
* there are no constraints and returns the maximum level (AF_LOG_DEBUG).
*
* @param sLogGroup Name of the log group to check against
**/
int GetGroupLogLevel(int nLogGroup) {
    // Get the maximum logging level for all groups
    int nMaxLevel = GetM2DAInt(AF_TABLE_LOGGING, "value", AF_LOGGROUP_GLOBAL);
    // Thgis will return 0 if the log group is not defined, turning off logging
    int nLogGroupLevel = GetM2DAInt(AF_TABLE_LOGGING, "value", nLogGroup);

    // If the log group is not defined then use the max, otherwise get the lower of the global/group
    if (nLogGroupLevel >= 0 && nLogGroupLevel <= 3) {
        return Min(nMaxLevel, nLogGroupLevel);
    } else {
        return nMaxLevel;
    }
}

/**
* @brief returns the string to print to the log file
*
* Builds the string to print to log from the various components. Adds the script name if that
* is configured in the global options 2da.
*
* @param sMsg Log string from the initial calling function
* @param nLogLevel The level of logging requested
* @param nLogGroup   The log group the message is for, defaults to the Global group
**/
string GetLogMessage(string sMsg, int nLogLevel, int nLogGroup = 0) {
    string sReturn;
    switch (nLogLevel) {
        case AF_LOG_INFO:
            sReturn = "[INFO ";
            break;
        case AF_LOG_WARN:
            sReturn = "[WARN ";
            break;
        case AF_LOG_DEBUG:
            sReturn = "[DEBUG ";
            break;
        default:
            sReturn = " ";
            break;
    }
    sReturn = sReturn + GetM2DAString(AF_TABLE_LOGGING, "GroupName", nLogGroup) + "] ";
    if (GetM2DAInt(TABLE_OPTIONS, "enabled", AF_INCLUDE_SCRIPT)) sReturn = sReturn + "[" + GetCurrentScriptName() + "] ";
    sReturn = sReturn + sMsg;
    return sReturn;
}

/**
* @brief check whether a log group should write logs
*
* Checks whether the log group specified should write out logs of the given level, based on both
* the global permitted level and the log groups specific config. If no log group is specified
* then the check is only agains the global logging level.
* return TRUE if the level should be logged; otherwise FALSE
*
* @param nLogLevel logging level to check
* @param nLogGroup log group to check; default check global level only
**/
int IsLoggingLevel(int nLogLevel, int nLogGroup = 0) {
    return (GetGroupLogLevel(nLogGroup) >= nLogLevel);
}

/**
* @brief writes an info string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param nLogGroup   The log group the message is for, defaults to the Global group
*
**/
void afLogInfo(string sMsg, int nLogGroup = 0) {
    if (IsLoggingLevel(AF_LOG_INFO, nLogGroup)) PrintToLog(GetLogMessage(sMsg, AF_LOG_INFO, nLogGroup));
}

/**
* @brief writes a warning string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param nLogGroup   The log group the message is for, defaults to the Global group
*
**/
void afLogWarn(string sMsg, int nLogGroup = 0) {
    if (IsLoggingLevel(AF_LOG_WARN, nLogGroup)) PrintToLog(GetLogMessage(sMsg, AF_LOG_WARN, nLogGroup));
}

/**
* @brief writes a debug string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param nLogGroup   The log group the message is for, defaults to the Global group
*
**/
void afLogDebug(string sMsg, int nLogGroup = 0) {
    if (IsLoggingLevel(AF_LOG_DEBUG, nLogGroup)) PrintToLog(GetLogMessage(sMsg, AF_LOG_DEBUG, nLogGroup));
}
