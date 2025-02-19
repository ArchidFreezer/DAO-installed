//::///////////////////////////////////////////////
//:: Approval System (follower) plot manager script
//:://////////////////////////////////////////////
/*
    This script handles all the per-follower approval flags (ranges, romances etc')
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: Oct 2nd, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_genpt_app_alistair"
#include "plt_genpt_app_dog"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_loghain"
#include "plt_genpt_app_morrigan"
#include "plt_genpt_app_oghren"
#include "plt_genpt_app_shale"
#include "plt_genpt_app_sten"
#include "plt_genpt_app_wynne"
#include "plt_genpt_app_zevran"
#include "approval_h"

#include "achievement_core_h"

// #include "plt_mnp000pt_camp_events"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    int nResult = FALSE; // used to return value for DEFINED GET events

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    // Determine the follower in question - we use Alistair's flag as generic

    object oPC = GetHero();

    int nFollower;
    if(strPlot == PLT_GENPT_APP_ALISTAIR) nFollower = APP_FOLLOWER_ALISTAIR;
    else if(strPlot == PLT_GENPT_APP_DOG) nFollower = APP_FOLLOWER_DOG;
    else if(strPlot == PLT_GENPT_APP_LELIANA) nFollower = APP_FOLLOWER_LELIANA;
    else if(strPlot == PLT_GENPT_APP_LOGHAIN) nFollower = APP_FOLLOWER_LOGHAIN;
    else if(strPlot == PLT_GENPT_APP_MORRIGAN) nFollower = APP_FOLLOWER_MORRIGAN;
    else if(strPlot == PLT_GENPT_APP_OGHREN) nFollower = APP_FOLLOWER_OGHREN;
    else if(strPlot == PLT_GENPT_APP_SHALE) nFollower = APP_FOLLOWER_SHALE;
    else if(strPlot == PLT_GENPT_APP_STEN) nFollower = APP_FOLLOWER_STEN;
    else if(strPlot == PLT_GENPT_APP_WYNNE) nFollower = APP_FOLLOWER_WYNNE;
    else if(strPlot == PLT_GENPT_APP_ZEVRAN) nFollower = APP_FOLLOWER_ZEVRAN;


    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!

            // NOTE:
            // ALL FOLLOWERS USE THE SAME FLAG NUMBERS AS ALISTAIR SO IT IS SAFE TO SHARE

            switch(nFlag)
            {
               case APP_ALISTAIR_FRIENDLY_ELIGIBLE:
               {
                    object oFollower = Approval_GetFollowerObject(nFollower);
                    int nApproval = GetFollowerApproval(oFollower);
                    int nLoveRange = GetM2DAInt(TABLE_APPROVAL_ROMANCE_RANGES, "Range", APP_ROMANCE_RANGE_ADORE);
                    int nFriendlyRange = GetM2DAInt(TABLE_APPROVAL_NORMAL_RANGES, "Range", APP_RANGE_WARM);

                    if(nValue == 1) // setting
                    {
                        // if approval in high-end range then update GUI
                        if(Approval_GetRomanceActive(nFollower) && nApproval >= nLoveRange)
                        {
                            int nStringRef = GetM2DAInt(TABLE_APPROVAL_ROMANCE_RANGES, "StringRef", APP_ROMANCE_RANGE_LOVE);
                            SetFollowerApprovalDescription(oFollower, nStringRef);
                        }
                        else if(!Approval_GetRomanceActive(nFollower) && nApproval >= nFriendlyRange)
                        {
                            int nStringRef = GetM2DAInt(TABLE_APPROVAL_NORMAL_RANGES, "StringRef", APP_RANGE_FRIENDLY);
                            SetFollowerApprovalDescription(oFollower, nStringRef);
                        }
                    }
                    else // clearing
                    {
                        // if approval is high enough then clear special tags
                        if(Approval_GetRomanceActive(nFollower) && nApproval >= nLoveRange)
                        {
                            int nStringRef = GetM2DAInt(TABLE_APPROVAL_ROMANCE_RANGES, "StringRef", APP_ROMANCE_RANGE_ADORE);
                            SetFollowerApprovalDescription(oFollower, nStringRef);
                        }
                        else if(!Approval_GetRomanceActive(nFollower) && nApproval >= nFriendlyRange)
                        {
                            int nStringRef = GetM2DAInt(TABLE_APPROVAL_NORMAL_RANGES, "StringRef", APP_RANGE_WARM);
                            SetFollowerApprovalDescription(oFollower, nStringRef);
                        }
                    }
                    break;
               }
               case APP_ALISTAIR_LOVE_ELIGIBLE:
               {
                    // NOT USED
                    break;
               }
               case APP_ALISTAIR_MAKE_LOVE:
                {
                    // Grant achievement for romance
                    ACH_HandleHeroRomance(nFollower);
                    break;
                }
                case APP_ALISTAIR_ROMANCE_ACTIVE:
                {
                    if(nValue == TRUE) // Setting the flag (not clearing it)
                        Approval_SetRomanceActive(nFollower, TRUE);
                    else // clearing the flag
                        Approval_SetRomanceActive(nFollower, FALSE);

                    break;
                }
                case APP_ALISTAIR_ROMANCE_CUT_OFF:
                {
                    if(nValue == TRUE) // Setting the flag (not clearing it)
                        Approval_SetRomanceActive(nFollower, FALSE);
                    break;
                }
                case APP_ALISTAIR_SET_TO_0:
                {
                    Approval_SetToZero(nFollower);
                    break;
                }
                case APP_ALISTAIR_INC_VLOW:
                {
                    Approval_ChangeApproval(nFollower, 1);
                    break;
                }
                case APP_ALISTAIR_INC_LOW:
                {
                    Approval_ChangeApproval(nFollower, 2);
                    break;
                }
                case APP_ALISTAIR_INC_MED:
                {
                    Approval_ChangeApproval(nFollower, 4);
                    break;
                }
                case APP_ALISTAIR_INC_HIGH:
                {
                    Approval_ChangeApproval(nFollower, 7);
                    break;
                }
                case APP_ALISTAIR_INC_VHIGH:
                {
                    Approval_ChangeApproval(nFollower, 12);
                    break;
                }
                case APP_ALISTAIR_INC_EXTREME:
                {
                    Approval_ChangeApproval(nFollower, 20);
                    break;
                }
                case APP_ALISTAIR_DEC_VLOW:
                {
                    Approval_ChangeApproval(nFollower, -1);
                    break;
                }
                case APP_ALISTAIR_DEC_LOW:
                {
                    Approval_ChangeApproval(nFollower, -3);
                    break;
                }
                case APP_ALISTAIR_DEC_MED:
                {
                    Approval_ChangeApproval(nFollower, -5);
                    break;
                }
                case APP_ALISTAIR_DEC_HIGH:
                {
                    Approval_ChangeApproval(nFollower, -10);
                    break;
                }
                case APP_ALISTAIR_DEC_VHIGH:
                {
                    Approval_ChangeApproval(nFollower, -15);
                    break;
                }
                case APP_ALISTAIR_DEC_EXTREME:
                {
                    Approval_ChangeApproval(nFollower, -20);
                    break;
                }
                case APP_ALISTAIR_ROMANCE_DUMPED:
                {
                    if(nValue == TRUE) // Setting the flag (not clearing it)
                        Approval_SetRomanceActive(nFollower, FALSE);
                    break;
                }
            }

     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case APP_SHALE_NOT_CHANGED:
            {
                if(!WR_GetPlotFlag(PLT_GENPT_APP_SHALE, APP_SHALE_CHANGED_BROKEN_GEM) &&
                    !WR_GetPlotFlag(PLT_GENPT_APP_SHALE, APP_SHALE_CHANGED_NEW_GEM))
                    nResult = TRUE;
                break;
            }
            case APP_ALISTAIR_IS_ADORE:
            {
                if(Approval_IsRangeValid(nFollower, APP_ROMANCE_RANGE_ADORE, TRUE))
                    nResult = TRUE;
                break;
            }
            case APP_ALISTAIR_IS_CARE:
            {
                if(Approval_IsRangeValid(nFollower, APP_ROMANCE_RANGE_CARE, TRUE))
                    nResult = TRUE;
                break;
            }
            case APP_ALISTAIR_IS_CRISIS:
            {
                if(Approval_IsRangeValid(nFollower, APP_RANGE_CRISIS, FALSE))
                    nResult = TRUE;
                break;
            }
            case APP_ALISTAIR_IS_FRIENDLY:
            {
                if(Approval_IsRangeValid(nFollower, APP_RANGE_FRIENDLY, FALSE))
                    nResult = TRUE;
                break;
            }
            case APP_ALISTAIR_IS_HOSTILE:
            {
                if(Approval_IsRangeValid(nFollower, APP_RANGE_HOSTILE, FALSE))
                    nResult = TRUE;
                break;
            }
            case APP_ALISTAIR_IS_IN_LOVE:
            {
                if(Approval_IsRangeValid(nFollower, APP_ROMANCE_RANGE_LOVE, TRUE))
                    nResult = TRUE;
                break;
            }
            case APP_ALISTAIR_IS_INTERESTED:
            {
                if(Approval_IsRangeValid(nFollower, APP_ROMANCE_RANGE_INTERESTED, TRUE))
                    nResult = TRUE;
                break;
            }
            case APP_ALISTAIR_IS_NEUTRAL:
            {
                if(Approval_IsRangeValid(nFollower, APP_RANGE_NEUTRAL, FALSE))
                    nResult = TRUE;
                break;
            }
            case APP_ALISTAIR_IS_WARM:
            {
                if(Approval_IsRangeValid(nFollower, APP_RANGE_WARM, FALSE))
                    nResult = TRUE;
                break;
            }

        }

    }
    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}