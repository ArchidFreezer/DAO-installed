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

#include "arl_constants_h"
#include "lit_constants_h"

#include "plt_lite_chant_red_zombie"

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
            case RED_ZOMBIE_ACCEPTED:
            {
                //turn off the chantry board
                WR_SetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CHANTER_BOARD, FALSE);

                //check if we already have enough items

                int nStackSize = UT_CountItemInInventory(rLITE_IM_CORPSE_GALL);
                //check the item count - update if 9 or 18
                if (nStackSize >= 18)
                {
                    if (WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_18) == FALSE &&
                        WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_9) == FALSE)
                    {
                        WR_SetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_18, TRUE, TRUE);
                    }
                }
                else if (nStackSize >= 9)
                {
                    if (WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_9) == FALSE)
                    {
                        WR_SetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_9, TRUE, TRUE);
                    }
                }

                break;
            }

            case RED_ZOMBIE_CLOSED_WITH_18:
            case RED_ZOMBIE_CLOSED_WITH_9:
            {
                // Qwinn:  Removing corpse gall plot item from inventory when quest closed
                RemoveItemsByTag(oPC,"gen_it_corpse_gall");

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_CHANTRY_1);

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