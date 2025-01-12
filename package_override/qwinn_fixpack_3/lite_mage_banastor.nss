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
#include "lit_constants_h"

#include "plt_lite_mage_banastor"

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
            case BANASTOR_QUEST_GIVEN:
            {
                //turn off mage board
                WR_SetPlotFlag(PLT_LITE_MAGE_BANASTOR, BANASTOR_MAGE_BOARD, FALSE);
                //check how many scrolls the PC has already picked up - if all of them then set quest done
                object [] arrScrollCount = GetItemsInInventory(oPC, GET_ITEMS_OPTION_ALL, 0, LITE_IM_MAGE_BANASTOR);
                if (IsObjectValid(arrScrollCount[0]) == TRUE)
                {
                    //if the stack is valid - and all scrolls are picked up - mark quest done
                    int nScrollCount = GetItemStackSize(arrScrollCount[0]);
                    if (nScrollCount >= 5)
                    {
                        WR_SetPlotFlag(PLT_LITE_MAGE_BANASTOR, BANASTOR_SCROLLS_FOUND, TRUE, TRUE);
                    }
                }
                break;
            }

            case BANASTOR_QUEST_COMPLETE:
            {
                // Qwinn: Remove scrolls upon quest completion
                RemoveItemsByTag(oPC,"lite_mage_banastor");
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COLLECTIVE_5);

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