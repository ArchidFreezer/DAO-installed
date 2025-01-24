#include "af_constants_h"
#include "core_h"

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
    int nMaxLevel = GetM2DAInt(AF_TABLE_LOGGING, "value", AF_LOG_GLOBAL);   
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
* @brief check whether a log group should write logs
*
* Cehcks whether the log group specified should write out logs of the given level, based on both
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
    if (IsLoggingLevel(AF_LOG_INFO, nLogGroup)) PrintToLog("[INFO " + GetM2DAString(AF_TABLE_LOGGING, "GroupName", nLogGroup) + "] " + sMsg);
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
    if (IsLoggingLevel(AF_LOG_WARN, nLogGroup)) PrintToLog("[WARN " + GetM2DAString(AF_TABLE_LOGGING, "GroupName", nLogGroup) + "] " + sMsg);
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
    if (IsLoggingLevel(AF_LOG_DEBUG, nLogGroup)) PrintToLog("[DEBUG " + GetM2DAString(AF_TABLE_LOGGING, "GroupName", nLogGroup) + "] " + sMsg);
}
