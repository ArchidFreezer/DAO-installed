//::///////////////////////////////////////////////
//:: denpt_talked_to
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Craig
//:: Created On: February 12, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_denpt_talked_to"
#include "plt_denpt_slave_trade"
#include "den_constants_h"       

#include "plt_qwinn"

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
    object oShianniRandom = UT_GetNearestObjectByTag(oPC, DEN_TR_SHIANNI_RANDOM);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            // Qwinn:  This was empty before, added both cases.
            // This is to reset journal entries in the correct order if it was looted before team died
            // Should also clear plot flag from Caladrius corpse
            case DEN_TT_CYRION:
            case DEN_TT_VALENDRIAN:
            {
                if (nOldValue == 0 && WR_GetPlotFlag(PLT_QWINN, DEN_LOOTED_EVIDENCE_DURING_CALADRIUS_FIGHT))
                    WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE,DEN_SLAVE_TRADE_PC_ACQUIRED_EVIDENCE,TRUE,TRUE);
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}