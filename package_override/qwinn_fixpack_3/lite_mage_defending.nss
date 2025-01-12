//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for lite_mage_defending
*/
//:://////////////////////////////////////////////
//:: Created By: Keith
//:: Created On: Jan 13th, 2009
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "lit_constants_h"

#include "plt_lite_mage_defending"
#include "plt_lite_mage_defying"

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
            case DEFENDING_QUEST_GIVEN:
            {
                //turn off the mage board
                WR_SetPlotFlag(PLT_LITE_MAGE_DEFENDING, DEFENDING_MAGE_BOARD, FALSE);
                //getting this plot also gives the lite_mage_defying plot
                WR_SetPlotFlag(PLT_LITE_MAGE_DEFYING, DEFYING_QUEST_GIVEN, TRUE, TRUE);
                //give the testimonies
                UT_AddItemToInventory(rLITE_IM_MAGE_DEFEND_TEST, 1);
                break;
            }

            case DEFENDING_TESTIMONY_GIVEN:
            {
                //this turns off the defying plot
                WR_SetPlotFlag(PLT_LITE_MAGE_DEFYING, DEFYING_NOT_DONE, TRUE, TRUE);

                //Qwinn: Also need to remove the testimonies plot item here
                UT_RemoveItemFromInventory(rLITE_IM_MAGE_DEFEND_TEST, 1);

                break;
            }

            case DEFENDING_DEFIANCE_DONE:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COLLECTIVE_6a);

                break;
            }

            case DEFENDING_QUEST_COMPLETE:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COLLECTIVE_6a);

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case DEFENDING_READY_FOR_TURNIN:
            {
                if (WR_GetPlotFlag(PLT_LITE_MAGE_DEFENDING, DEFENDING_QUEST_GIVEN) == TRUE &&
                    WR_GetPlotFlag(PLT_LITE_MAGE_DEFENDING, DEFENDING_DEFIANCE_DONE) == FALSE &&
                    WR_GetPlotFlag(PLT_LITE_MAGE_DEFENDING, DEFENDING_TESTIMONY_GIVEN) == FALSE)
                {
                    nResult = TRUE;
                }
                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}