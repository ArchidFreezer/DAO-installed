//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 21st, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_lotpt_defined"
#include "plt_gen00pt_party"
#include "plt_lotpt_talked_to"
#include "plt_lot110pt_bryant"
#include "plt_genpt_news"

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

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {


        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case TALKED_TO_LELIANA_AND_LELIENA_NOT_IN_PARTY:
            {
                if(WR_GetPlotFlag( PLT_LOTPT_TALKED_TO, TALKED_TO_LELIANA) &&
                    !WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED))
                    nResult = TRUE;
                break;
            }
            case BRYNAT_NOT_SPOKE_TO_LELIANA_AND_LELIANA_IN_PARTY:
            {
                // Qwinn:  This should be did not speak to Leliana, instead it returns true if he did.
                // if(WR_GetPlotFlag( PLT_LOT110PT_BRYANT, BRYANT_SPOKE_TO_LELIANA) &&
                if((!WR_GetPlotFlag( PLT_LOT110PT_BRYANT, BRYANT_SPOKE_TO_LELIANA)) &&
                    WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED))
                    nResult = TRUE;
                break;
            }
            case PC_NOT_KNOW_EAMON_ILL_AND_ALISTAIR_IN_PARTY:
            {
                if(!WR_GetPlotFlag( PLT_GENPT_NEWS, NEWS_PC_KNOWS_ARL_EAMON_IS_ILL) &&
                    WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED))
                    nResult = TRUE;
                break;
            }

        }

    }

    return nResult;
}