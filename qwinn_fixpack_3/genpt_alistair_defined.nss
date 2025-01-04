// Alistair plot-defined script
// In here we define all of Alistair generic defined flags

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "approval_h"

#include "plt_genpt_alistair_defined"
#include "plt_genpt_alistair_main"
#include "plt_genpt_alistair_talked"
#include "plt_genpt_app_alistair"
#include "plt_genpt_app_zevran"
#include "plt_gen00pt_party"
#include "plt_mnp000pt_main_events"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int nResult = FALSE; // used to return value for DEFINED GET events
    object oPC = GetHero();

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    int nAlistair = APP_FOLLOWER_ALISTAIR;

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case ALISTAIR_DEFINED_HARDENED_CHANGE_MOTIVATIONS:
            {
                WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_CHANGED, TRUE);
                break;
            }
            case ALISTAIR_DEFINED_SET_LOVE_AND_FRIENDLY_ELIGIBLE:
            {
                WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_FRIENDLY_ELIGIBLE,TRUE,TRUE);
                WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_LOVE_ELIGIBLE,TRUE,TRUE);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case ALISTAIR_DEFINED_PC_FEMALE_ALISTAIR_NOT_RECRUITED:
            {
                if(GetCreatureGender(oPC) == GENDER_FEMALE &&
                    !WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED))
                        nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_PC_FEMALE_ALISTAIR_RECRUITED:
            {
                if(GetCreatureGender(oPC) == GENDER_FEMALE &&
                    WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED))
                        nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_NEUTRAL_OR_HOSTILE:
            {
                // Qwinn fixed.  This would appear for everyone because IS_NEUTRAL includes
                // anything higher.
                /*
                if(((WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_HOSTILE) ||
                    WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_NEUTRAL))) &&
                    Approval_GetRomanceActive(nAlistair) == FALSE)
                        nResult = TRUE;
                */
                if(WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM) == FALSE &&
                     Approval_GetRomanceActive(nAlistair) == FALSE)
                        nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_FRIENDLY_OR_IN_LOVE:
            {
                int nLove = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_IN_LOVE, TRUE);
                int nFriendly = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_FRIENDLY, TRUE);
                if((nLove == TRUE) || (nFriendly == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ALISTAIR_DEFINED_WARM_OR_CARE:
            {
                int nWarm = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM, TRUE);
                int nCare = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_CARE, TRUE);
                if((nWarm == TRUE) || (nCare == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ALISTAIR_DEFINED_NEUTRAL_OR_INTERESTED:
            {
                int nNeutral = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_NEUTRAL, TRUE);
                int nInterested = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_INTERESTED, TRUE);
                if((nNeutral == TRUE) || (nInterested == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ALISTAIR_DEFINED_IN_LOVE_OR_STILL_IN_LOVE:
            {
                if(WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_IN_LOVE, TRUE) ||
                     WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_STILL_IN_LOVE, TRUE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_ROMANCE_ACTIVE_OR_STILL_IN_LOVE:
            {
                if(WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE, TRUE) ||
                     WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_STILL_IN_LOVE, TRUE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_ROMANCE_ACTIVE_NOT_IN_LOVE:
            {
                if(Approval_GetRomanceActive(nAlistair) &&
                    (WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_IN_LOVE, TRUE) == FALSE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_ROMANCE_INACTIVE_AND_WARM:
            {
                if((Approval_GetRomanceActive(nAlistair) == FALSE) &&
                    WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM, TRUE) )
                    nResult = TRUE;
                break;
            }

            case ALISTAIR_DEFINED_ZEVRAN_ROMANCE_OR_ALISTAIR_ROMANCE:
            {
                if(WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_ACTIVE) ||
                    WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_ROMANCE_CUT_OFF_CAN_RESTART:
            {
                if(WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_CUT_OFF) &&
                    !WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_CAN_NOT_RESTART))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_WARM_ROMANCE_NOT_ACTIVE:
            {
                if(WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM, TRUE) &&
                    !WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_PC_FEMALE_ROMANCE_NOT_ACTIVE_NOT_CUT_OFF_WARM:
            {
                if(GetCreatureGender(oPC) == GENDER_FEMALE &&
                    !WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE, TRUE) &&
                    !WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_CUT_OFF) &&
                    WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM, TRUE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_PC_FEMALE_ROMANCE_NOT_CUT_OFF_WARM:
            {
                if(GetCreatureGender(oPC) == GENDER_FEMALE &&
                    !WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_CUT_OFF, TRUE) &&
                    WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM, TRUE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_PC_FEMALE_ROMANCE_NOT_CUT_OFF:
            {
                if(GetCreatureGender(oPC) == GENDER_FEMALE &&
                    !WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_CUT_OFF, TRUE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_CAN_TALK_ABOUT_TEMPLAR:
            {
                if(WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_NEUTRAL, TRUE) &&
                    WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_FRIEND_TRACK_IS_1, TRUE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_CAN_TALK_ABOUT_ARL_EAMON_FIRST_TIME:
            {
                if(WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_ENTER_REDCLIFFE_TOLD_ABOUT_EAMON) &&
                    WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_FRIEND_TRACK_IS_0, TRUE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_CAN_ASK_ABOUT_ARL_EAMON:
            {
                // Qwinn:  Added condition that he told you he came from Chantry
                if(!WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_ENTER_REDCLIFFE_TOLD_ABOUT_EAMON) &&
                    WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_FRIEND_TRACK_IS_0, TRUE) &&
                    WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_TOLD_PAST))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_CAN_TALK_ABOUT_DUNCAN:
            {
                if(WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_TOLD_PAST) &&
                    !WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_DUNCAN) &&
                    WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_NEUTRAL, TRUE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_CAN_TALK_ABOUT_ROMANCE_DUMPED:
            {
                if(WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_DUMPED, TRUE) &&
                    !WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_ROMANCE_DUMPED))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_CAN_TALK_ABOUT_SISTER:
            {
                int nWarm = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM,TRUE);
                int nInterest = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_INTERESTED,TRUE);
                int nTruth = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_TOLD_TRUTH);
                int nSister = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_SISTER);

                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","INTERESTED: " + IntToString(nInterest));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","WARM: " + IntToString(nWarm));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","SISTER: " + IntToString(nSister));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","TRUTH: " + IntToString(nTruth));
                if(((nWarm == TRUE) || (nInterest == TRUE)) &&
                    (nTruth == TRUE) &&
                    (nSister == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ALISTAIR_DEFINED_CAN_TALK_ABOUT_GROUP:
            {
                if(WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM, TRUE) &&
                    WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_FRIEND_TRACK_IS_4, TRUE) &&
                    !WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_GROUP))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_CAN_TALK_ABOUT_RESPONSE_TOLD_HARDEN:
            {
                // Crazy condition... no point in even trying to understand it...
                int nPreFriendly = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_PRE_FRIENDLY_ELIGIBLE);
                int nPreLove = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_PRE_LOVE_ELIGIBLE);
                int nFriendly = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_DEFINED, ALISTAIR_DEFINED_FRIENDLY_OR_IN_LOVE,TRUE);
                int nLove = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_DEFINED, ALISTAIR_DEFINED_IN_LOVE_OR_STILL_IN_LOVE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE);
                int nHarden = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_GOLDANA_TOLD_HARDEN);
                int nTalked = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_RESPONSE_TOLD_HARDEN);

                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","PreFriendly: " + IntToString(nPreFriendly));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","PreLove: " + IntToString(nPreLove));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","Friendly: " + IntToString(nFriendly));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","Love: " + IntToString(nLove));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","Romance:" + IntToString(nRomance));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","Hardened: " + IntToString(nHarden));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","Talked about Hardened: " + IntToString(nTalked));

                if((nPreFriendly || nPreLove || nFriendly || nLove || nRomance)
                    && nHarden && !nTalked)
                {
                    nResult = TRUE;
                }
                break;
            }
            case ALISTAIR_DEFINED_CAN_TALK_ABOUT_RESPONSE_NOT_TOLD_HARDEN:
            {
                // Another crazy condition. There is some perfect logic hiding somewhere inside.
                // Crazy condition... no point in even trying to understand it...
                int nPreFriendly = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_PRE_FRIENDLY_ELIGIBLE);
                int nPreLove = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_PRE_LOVE_ELIGIBLE);
                int nFriendly = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_DEFINED, ALISTAIR_DEFINED_FRIENDLY_OR_IN_LOVE,TRUE);
                int nLove = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_DEFINED, ALISTAIR_DEFINED_IN_LOVE_OR_STILL_IN_LOVE,TRUE);
                int nRomance = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE);
                int nCalm = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_GOLDANA_CALMED_DOWN);
                int nTalked = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_RESPONSE_NOT_TOLD_HARDEN);

                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","PreFriendly: " + IntToString(nPreFriendly));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","PreLove: " + IntToString(nPreLove));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","Friendly: " + IntToString(nFriendly));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","Love: " + IntToString(nLove));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","Romance:" + IntToString(nRomance));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","Calmed: " + IntToString(nCalm));
                Log_Trace(LOG_CHANNEL_PLOT,"genpt_alistair_defined.nss","Talked about Calmed: " + IntToString(nTalked));

                if((nPreFriendly || nPreLove || nFriendly || nLove || nRomance)
                    && nCalm && !nTalked)
                {
                    nResult = TRUE;
                }
                break;
            }
            case ALISTAIR_DEFINED_ADORE_NOT_TALKED_ABOUT_ADORE:
            {
                if(WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_ADORE, TRUE) &&
                    !WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_ADORE))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_CARE_NOT_TALKED_ABOUT_CARE:
            {
                int nCare = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_CARE, TRUE);
                int nTalked = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_CARE);
                int nMain = WR_GetPlotFlag(PLT_MNP000PT_MAIN_EVENTS, PLAYER_FINISHED_A_MAJOR_PLOT);
                if((nCare == TRUE) && (nTalked == FALSE) && (nMain == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case ALISTAIR_DEFINED_CAN_TALK_ABOUT_TEACHING_TEMPLAR:
            {
                if(WR_GetPlotFlag(PLT_GENPT_ALISTAIR_TALKED, ALISTAIR_TALKED_ABOUT_TEMPLAR, TRUE) &&
                    !WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_AGREED_TO_TEACH_TEMPLAR))
                    nResult = TRUE;
                break;
            }
            case ALISTAIR_DEFINED_ROMANCE_ACTIVE_AND_MADE_LOVE:
            {
                nResult = Approval_GetRomanceActive(nAlistair)
                          && WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_MAKE_LOVE);
                break;
            }
            case ALISTAIR_DEFINED_AT_LEAST_ADORE:
            {
                nResult = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_ADORE, TRUE)
                          || WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_STILL_IN_LOVE, TRUE);
                break;
            }
            case ALISTAIR_DEFINED_AT_LEAST_FRIENDLY:
            {
                nResult = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_FRIENDLY, TRUE)
                          || WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_ADORE, TRUE)
                          || WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_STILL_IN_LOVE, TRUE);
                break;
            }
            case ALISTAIR_DEFINED_AT_LEAST_WARM:
            {
                nResult = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_INTERESTED, TRUE)
                          || WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_WARM, TRUE)
                          || WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_STILL_IN_LOVE, TRUE);
                break;
            }
            case ALISTAIR_DEFINED_ADORE_BUT_NOT_IN_LOVE:
            {
                //IF: APP_ALISTAIR_IS_ADORE
                //and IF (NOT): APP_ALISTAIR_IS_IN_LOVE
                int nAdore = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_ADORE, TRUE);
                int nInLove = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_IN_LOVE, TRUE);
                if((nAdore == TRUE) && (nInLove == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }

        }

    }

    return nResult;
}