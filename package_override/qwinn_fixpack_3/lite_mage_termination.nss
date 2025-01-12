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

#include "plt_lite_mage_termination"
#include "plt_cod_lite_tow_terminatio"

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
    string szAreaTag = GetTag(GetArea(oPC));

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        int nMet1 = WR_GetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_APPRENTICE1_MET);
        int nMet2 = WR_GetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_APPRENTICE2_MET);
        int nMet3 = WR_GetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_APPRENTICE3_MET);

        switch(nFlag)
        {
            case TEMINATION_QUEST_GIVEN:
            {
                //unset the mage board
                WR_SetPlotFlag(PLT_LITE_MAGE_TERMINATION, TEMINATION_MAGE_BOARD, FALSE);
                //give the termination notices
                UT_AddItemToInventory(rLITE_IM_MAGE_TERMINATION, 3);
                //add codex entry
                WR_SetPlotFlag(PLT_COD_LITE_TOW_TERMINATIO, TOW_TERMINATION_MAIN, TRUE, TRUE);
                break;
            }
            case TERMINATION_LEAVE_ONE:
            {
                //Apprentice1 Leaves
                object oApprentice = UT_GetNearestCreatureByTag(oPC, LITE_CR_MAGE_TERMINATION1);
                SetObjectInteractive(oApprentice, FALSE);
                UT_ExitDestroy(oApprentice, FALSE, "orz100wp_exit");

                //Remove a letter
                UT_RemoveItemFromInventory(rLITE_IM_MAGE_TERMINATION, 1);

                //check if this was the last apprentice - if so, mark quest done
                if (nMet2 == TRUE && nMet3 == TRUE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_APPRENTICES_TERMINATED, TRUE, TRUE);
                }
                break;
            }
            case TERMINATION_LEAVE_TWO:
            {
                //Apprentice2 Leaves
                object oApprentice = UT_GetNearestCreatureByTag(oPC, LITE_CR_MAGE_TERMINATION2);
                SetObjectInteractive(oApprentice, FALSE);
                UT_ExitDestroy(oApprentice, FALSE, "den230wp_from_market");

                //Remove a letter
                UT_RemoveItemFromInventory(rLITE_IM_MAGE_TERMINATION, 1);

                //check if this was the last apprentice - if so, mark quest done
                if (nMet1 == TRUE && nMet3 == TRUE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_APPRENTICES_TERMINATED, TRUE, TRUE);
                    // Qwinn:  If this apprentice is the last one fired, add the reward-available flag to mage in this same area.
                    object oMage = UT_GetNearestCreatureByTag(oPC, "lite_mage_collective");
                    SetPlotGiver(oMage, TRUE);
                }
                break;
            }
            case TERMINATION_LEAVE_THREE:
            {
                //Apprentice3 Leaves
                object oApprentice = UT_GetNearestCreatureByTag(oPC, LITE_CR_MAGE_TERMINATION3);
                SetObjectInteractive(oApprentice, FALSE);
                UT_ExitDestroy(oApprentice, FALSE, "jp_den200cr_ignacio_delivery_2");

                //Remove a letter
                UT_RemoveItemFromInventory(rLITE_IM_MAGE_TERMINATION, 1);

                //check if this was the last apprentice - if so, mark quest done
                if (nMet1 == TRUE && nMet2 == TRUE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_TERMINATION, TERMINATION_APPRENTICES_TERMINATED, TRUE, TRUE);
                }
                break;
            }
            case TERMINATION_QUEST_COMPLETE:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COLLECTIVE_2);

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case TERMINATION_APPRENTICE1:
            {
               if (szAreaTag == "orz100ar_mountain_pass")
               {
                    nResult = TRUE;
               }

                break;
            }
            case TERMINATION_APPRENTICE2:
            {
               if (szAreaTag == "den230ar_wonders_of_thedas")
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