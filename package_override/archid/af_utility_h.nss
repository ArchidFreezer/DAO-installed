#include "af_constants_h"
                  
const int AF_LOG_NONE  = 0;
const int AF_LOG_INFO  = 1;
const int AF_LOG_DEBUG = 2;

/**
* @brief writes a string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param nLogLevel   The log level of the calling script. This needs to be >= AF_LOG_INFO for the message to be logged
*
**/
void afLogInfo(string sMsg, int nLogLevel = AF_LOG_INFO) {
    if (AF_LOG_ACTIVE && nLogLevel >= AF_LOG_INFO) PrintToLog("> " + sMsg);
}

/**
* @brief writes a string to DragonAge_1.log
*
* The string will only be written if af_constants_h.AF_LOG_ACTIVE == TRUE
*
* @param sMsg        The string to write to the log
* @param nLogLevel   The log level of the calling script. This needs to be >= AF_LOG_DEBUG for the message to be logged
*
**/
void afLogDebug(string sMsg, int nLogLevel = AF_LOG_DEBUG) {
    if (AF_LOG_ACTIVE && nLogLevel >= AF_LOG_DEBUG) PrintToLog("---> " + sMsg);
}
