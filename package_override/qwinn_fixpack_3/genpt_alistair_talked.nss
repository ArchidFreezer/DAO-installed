// Alistair talked plot events

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "approval_h"

#include "plt_genpt_alistair_defined"
#include "plt_genpt_alistair_main"
#include "plt_genpt_alistair_talked"
#include "plt_genpt_app_alistair"
#include "den_constants_h"

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
            case ALISTAIR_TALKED_ABOUT_GROUP:
            {
                WR_SetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_FRIEND_TRACK_INC, TRUE);
                break;
            }
            case ALISTAIR_TALKED_ABOUT_RESPONSE_TOLD_HARDEN:
            case ALISTAIR_TALKED_ABOUT_RESPONSE_NOT_TOLD_HARDEN:
            {
                if(Approval_GetRomanceActive(nAlistair))
                    Approval_SetLoveEligible(nAlistair);
                else
                    Approval_SetFriendlyEligible(nAlistair);

                break;
            }
            case ALISTAIR_TALKED_ABOUT_SISTER:
            {
                string sArea = GetTag(GetArea(oPC));
                object oDoorToGoldana = UT_GetNearestObjectByTag(oPC,DEN_IP_OUTSIDE_GOLDANA);
                if(sArea == DEN_AR_MARKET)
                {
                    SetObjectInteractive(oDoorToGoldana,TRUE);
                }
                break;
            }
            case ALISTAIR_TALKED_ABOUT_SISTER_HOUSE:
            {
                object oGoldanaMP = UT_GetNearestObjectByTag(oPC,DEN_WP_FROM_GOLDANAS);
                SetMapPinState(oGoldanaMP,TRUE);
                object oGoldannaHouseTrigger = UT_GetNearestObjectByTag(oPC,"den200tr_outside_goldanna");
                Safe_Destroy_Object(oGoldannaHouseTrigger);
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
        }
    }
    return nResult;
}