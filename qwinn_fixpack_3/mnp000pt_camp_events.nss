//::///////////////////////////////////////////////
//:: Camp Events Plot Script
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Defined conditions for the camp events plot.
*/
//:://////////////////////////////////////////////
//:: Created By: David Sims
//:: Created On: July 5th, 2007
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_gen00pt_party"
#include "plt_genpt_leliana_main"
#include "plt_mnp000pt_camp_events"

int StartingConditional()
{
    event       eParms      = GetCurrentEvent();            // Contains all input parameters
    int         nType       = GetEventType(eParms);         // GET or SET call
    string      strPlot     = GetEventString(eParms, 0);    // Plot GUID
    int         nFlag       = GetEventInteger(eParms, 1);   // The bit flag # being affected
    object      oParty      = GetEventCreator(eParms);      // The owner of the plot table for this script
    object      oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int         nResult     = FALSE;                        // used to return value for DEFINED GET events
    object      oPC         = GetHero();

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case CAMP_EVENT_ASHES_TAINTED:
            {
                // Start conversation with Leliana about destroying the ashes
                // Leliana will talk next time the player enters the camp
                WR_SetPlotFlag(PLT_MNP000PT_CAMP_EVENTS, CAMP_EVENT_ASHES_TAINTED, TRUE);
                break;
            }

            case CAMP_EVENT_TALK_ABOUT_DREAM:
            {

                UT_Talk(oPC, oPC, GEN_DL_CAMP_EVENTS);

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case CAMP_EVENTS_LELIANA_RECRUITED_NOT_INTIMIDATED:
            {
                //IF: Leliana is recruited
                //If not: INTIMIDATED_AFTER_TAINTING_URN [leliana_main]
                int bRecruited = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED, TRUE);
                int bIntimidated = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_INTIMIDATED_AFTER_TAINTING_URN);
                nResult = bRecruited && !bIntimidated;
                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}