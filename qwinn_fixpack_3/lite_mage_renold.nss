//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for lite_mage_renold
*/
//:://////////////////////////////////////////////
//:: Created By: Keith
//:: Created On: Jan 12/09
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_lite_mage_renold"

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
            case RENOLD_QUEST_GIVEN:
            {
                //turn off the mage board
                WR_SetPlotFlag(PLT_LITE_MAGE_RENOLD, RENOLD_MAGE_BOARD, FALSE);
                break;
            }

            case RENOLD_QUEST_COMPLETE:
            {
                //Qwinn:  Remove useless feldspar ring plot item, would make sellable but sell value only 2-3 copper
                RemoveItemsByTag(oPC,"lite_mage_feldsparring");

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COLLECTIVE_8);

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