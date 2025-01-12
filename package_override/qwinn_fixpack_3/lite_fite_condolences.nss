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
#include "campaign_h"

#include "plt_lite_fite_condolences"
#include "plt_cod_lite_fite_widows"

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
        int nLetter1 = WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_1);
        int nLetter2 = WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_2);
        int nLetter3 = WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_3);
        int nLetter4 = WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_4);

        switch(nFlag)
        {
            case CONDOLENCES_QUEST_GIVEN:
            {
                //turn off fighter board
                WR_SetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_FIGHTER_BOARD, FALSE);
                //add codex
                WR_SetPlotFlag(PLT_COD_LITE_FITE_WIDOWS, CONDOLENCES_MAIN, TRUE, TRUE);
                //give out notices
                // Qwinn: Was giving out 5 notices instead of 4, which would leave one in inventory when quest complete
                // UT_AddItemToInventory(rLITE_IM_FITE_CONDOLENCE_LET, 5);
                UT_AddItemToInventory(rLITE_IM_FITE_CONDOLENCE_LET, 4);
                //activate any needed world map locations
                object oTarg = GetObjectByTag(WML_LC_DEN_ALLEY_2);
                WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_ACTIVE);

                break;
            }
            case CONDOLENCES_CONDOLENCE_GIVEN:
            {
                //figure out which condolence was given and set it
                string szAreaTag = GetTag(GetArea(oPC));
                if (szAreaTag == "arl110ar_chantry")
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_1, TRUE, TRUE);
                }
                if (szAreaTag == "cir110ar_inn")
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_2, TRUE, TRUE);
                }
                if (szAreaTag == "den200ar_market")
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_3, TRUE, TRUE);
                }
                if (szAreaTag == "den951ar_alley_justice_2")
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_4, TRUE, TRUE);
                }
                break;
            }
            case CONDOLENCES_END_CHECK:
            {
                string szAreaTag = GetTag(GetArea(oPC));
                object oWidow;
                //remove the letter
                UT_RemoveItemFromInventory(rLITE_IM_FITE_CONDOLENCE_LET);
                //check if this was the last one - set the final journal entry
                if (nLetter1 == TRUE && nLetter2 == TRUE && nLetter3 == TRUE && nLetter4 == TRUE)
                {
                    WR_SetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_DELIVERED, TRUE, TRUE);
                }

                //have the widow exit the area
                if (szAreaTag == "arl110ar_chantry")
                {
                    oWidow = UT_GetNearestCreatureByTag(oPC, LITE_CR_CONDOLENCES_WIDOW1);
                    SetPlotGiver(oWidow, FALSE);
                    SetObjectInteractive(oWidow, FALSE);
                    UT_ExitDestroy(oWidow, TRUE, "arl110wp_from_village");
                }
                else if (szAreaTag == "cir110ar_inn")
                {
                    oWidow = UT_GetNearestCreatureByTag(oPC, LITE_CR_CONDOLENCES_WIDOW2);
                    SetPlotGiver(oWidow, FALSE);
                    SetObjectInteractive(oWidow, FALSE);
                    UT_ExitDestroy(oWidow, TRUE, "cir110wp_widow_exit");
                }
                else if (szAreaTag == "den200ar_market")
                {
                    oWidow = UT_GetNearestCreatureByTag(oPC, LITE_CR_CONDOLENCES_WIDOW3);
                    SetPlotGiver(oWidow, FALSE);
                    SetObjectInteractive(oWidow, FALSE);
                    UT_ExitDestroy(oWidow, TRUE, "den200wp_widow_exit");
                }
                else
                {
                    oWidow = UT_GetNearestCreatureByTag(oPC, LITE_CR_CONDOLENCES_WIDOW4);
                    SetPlotGiver(oWidow, FALSE);
                    SetObjectInteractive(oWidow, FALSE);
                    UT_ExitDestroy(oWidow, TRUE, "den951wp_widow_exit");
                }
                break;
            }

            case CONDOLENCES_QUEST_COMPLETE:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLACKSTONE_4);

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