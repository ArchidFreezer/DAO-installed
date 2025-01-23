#include "core_h"

// Name of the module local variable
const string AF_LOG_LEVEL = "AF_LOG_LEVEL";
const string AF_LOGGROUP_NONE = "AF_LOGGROUP_NONE";
const string AF_LOGGROUP_INFO = "AF_LOGGROUP_INFO";
const string AF_LOGGROUP_WARN = "AF_LOGGROUP_WARN";
const string AF_LOGGROUP_DEBUG = "AF_LOGGROUP_DEBUG";

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
int GetGroupLogLevel(string sLogGroup) {
    // Get the maximum logging level for all groups
    int nMaxLevel = GetLocalInt(GetModule(),AF_LOG_LEVEL);

    // If the log group is not defined then use the max, otherwise get the lower of the global/group
    if (sLogGroup == "") {
        return nMaxLevel;
    } else if (FindSubString(GetLocalString(GetModule(), AF_LOGGROUP_DEBUG), sLogGroup) >= 0) {
        return Min(nMaxLevel, AF_LOG_DEBUG);
    } else if (FindSubString(GetLocalString(GetModule(), AF_LOGGROUP_WARN), sLogGroup) >= 0) {
        return Min(nMaxLevel, AF_LOG_WARN);
    } else if (FindSubString(GetLocalString(GetModule(), AF_LOGGROUP_INFO), sLogGroup) >= 0) {
        return Min(nMaxLevel, AF_LOG_INFO);
    } else if (FindSubString(GetLocalString(GetModule(), AF_LOGGROUP_NONE), sLogGroup) >= 0) {
        return Min(nMaxLevel, AF_LOG_NONE);
    } else {
        return nMaxLevel;
    }
}

/**
* @brief saves the logging info from the ini file
*
* Stores the provided logging details in the module local variables.
*
* @param nLevel The maximum log level to set, should be between 0 (NONE) and 3 (DEBUG)
* @param sNone The list of log groups that have logging turned off
* @param sInfo The list of log groups that should only log INFO level statements
* @param sWarn The list of log groups that should log WARN and lower level statements
* @param sDebug The list of log groups that should log DEBUG and lower level statements
**/
void SetLogLevels(int nLevel, string sNone, string sInfo, string sWarn, string sDebug) {
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
    SetLocalString(GetModule(), AF_LOGGROUP_NONE, sNone);
    SetLocalString(GetModule(), AF_LOGGROUP_INFO, sInfo);
    SetLocalString(GetModule(), AF_LOGGROUP_WARN, sWarn);
    SetLocalString(GetModule(), AF_LOGGROUP_DEBUG, sDebug);
}

/**
* @brief save logging details from DragonAge.ini file
*
* Reads the DragonAge.ini file for the loggin entries and sends these to be saved in the
* module local variables
*
**/
void ReadIniLogLevel() {
    string sLogGlobalLevel = ReadIniEntry("Archid", "LogGlobalLevel");
    int nLogGlobalLevel = AF_LOG_NONE;
    if (sLogGlobalLevel == "3") nLogGlobalLevel = AF_LOG_DEBUG;
    else if (sLogGlobalLevel == "2") nLogGlobalLevel = AF_LOG_WARN;
    else if (sLogGlobalLevel == "1") nLogGlobalLevel = AF_LOG_INFO;

    string sLogGroupsNone = ReadIniEntry("Archid", "LogGroupsNone");
    string sLogGroupsInfo = ReadIniEntry("Archid", "LogGroupsInfo");
    string sLogGroupsWarn = ReadIniEntry("Archid", "LogGroupsWarn");
    string sLogGroupsDebug = ReadIniEntry("Archid", "LogGroupsDebug");

    if (nLogGlobalLevel >= AF_LOG_INFO) {
        PrintToLog("[INFO Logging] ReadIniLogLevel: Global - '" + IntToString(nLogGlobalLevel) + "'");
        PrintToLog("[INFO Logging] ReadIniLogLevel: NoneGroups - '" + sLogGroupsNone + "'");
        PrintToLog("[INFO Logging] ReadIniLogLevel: InfoGroups - '" + sLogGroupsInfo + "'");
        PrintToLog("[INFO Logging] ReadIniLogLevel: WarnGroups - '" + sLogGroupsWarn + "'");
        PrintToLog("[INFO Logging] ReadIniLogLevel: DebugGroups - '" + sLogGroupsDebug + "'");
    }

    SetLogLevels(nLogGlobalLevel, sLogGroupsNone, sLogGroupsInfo, sLogGroupsWarn, sLogGroupsDebug);
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
* @param sLogGroup log group to check; empty string to check global level only
**/
int IsLoggingLevel(int nLogLevel, string sLogGroup = "") {
    return (GetGroupLogLevel(sLogGroup) >= nLogLevel);
}

/**
* @brief writes an info string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param sLogGroup   The log level of the calling script. This needs to be >= AF_LOG_INFO for the message to be logged
*
**/
void afLogInfo(string sMsg, string sLogGroup = "") {
    if (IsLoggingLevel(AF_LOG_INFO, sLogGroup)) PrintToLog("[INFO " + sLogGroup + "] " + sMsg);
}

/**
* @brief writes a warning string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param sLogGroup   The log level of the calling script. This needs to be >= AF_LOG_WARN for the message to be logged
*
**/
void afLogWarn(string sMsg, string sLogGroup = "") {
    if (IsLoggingLevel(AF_LOG_WARN, sLogGroup)) PrintToLog("[WARN " + sLogGroup + "] " + sMsg);
}

/**
* @brief writes a debug string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param sLogGroup   The log level of the calling script. This needs to be >= AF_LOG_DEBUG for the message to be logged
*
**/
void afLogDebug(string sMsg, string sLogGroup = "") {
    if (IsLoggingLevel(AF_LOG_DEBUG, sLogGroup)) PrintToLog("[DEBUG " + sLogGroup + "] " + sMsg);
}
