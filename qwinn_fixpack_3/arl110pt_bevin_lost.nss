//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Sheryl
//:: Created On: Feb 26th 2008                                                             F
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "arl_constants_h"

#include "plt_arl110pt_bevin_lost"
#include "plt_arl100pt_siege_prep"

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

    object oBevin = UT_GetNearestCreatureByTag(oPC, ARL_CR_BEVIN);
    object oKaitlyn = UT_GetNearestCreatureByTag(oPC, ARL_CR_KAITLYN);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
        case ARL_BEVIN_LOST_KAITLYN_FEARFUL:
        case ARL_BEVIN_LOST_KAITLYN_TOLD_PC_ABOUT_BEVIN:
        case ARL_BEVIN_LOST_ACCEPTED_QUEST:
        {
            SetPlotGiver(oKaitlyn, FALSE);
        }
        break;

        case ARL_BEVIN_LOST_BEVIN_FORCED_OUT:
        {
            // Bevin forced out of closet, activate Bevin
            WR_SetObjectActive(oBevin, TRUE);

        }
        break;

        case ARL_BEVIN_LOST_BEVIN_COAXED_OUT:
        {
            // Bevin coaxed out of closet, activate Bevin
            WR_SetObjectActive(oBevin, TRUE);

        }
        break;

        case ARL_BEVIN_LOST_BEVIN_EXITS_DRESSER:
        {
            // Bevin coaxed or forced out of closet, make him talk.
            UT_Talk(oBevin, oPC);
        }
        break;

        case ARL_BEVIN_LOST_BEVIN_JUST_FOUND:
        {
            WR_SetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_BEVIN_FOUND, TRUE);

            // You found Bevin but haven't spoken to Kaitlyn
            if (WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_KAITLYN_TOLD_PC_ABOUT_BEVIN) == FALSE)
            {
                WR_SetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_FOUND_BEVIN_WITHOUT_QUEST, TRUE, TRUE);
            }


        }
        break;

        case ARL_BEVIN_LOST_QUEST_DONE_KAITLYN_GRATEFUL:
        case ARL_BEVIN_LOST_QUEST_DONE_KAITLYN_FEARFUL:
        case ARL_BEVIN_LOST_KAITLYN_LEFT_WITH_BEVIN:
        {
            if (WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_QUEST_XP_REWARD) == FALSE)
            {
                WR_SetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_QUEST_XP_REWARD, TRUE, TRUE);
            }

            //percentage complete plot tracking
            ACH_TrackPercentageComplete(ACH_FAKE_REDCLIFFE_3);
        }
        break;

        case ARL_BEVIN_LOST_PC_HAS_CHEST_KEY:
        {
            UT_AddItemToInventory(ARL_R_IT_CHEST_KEY);
        }
        break;

        case ARL_BEVIN_LOST_PC_GIVES_HUGE_MONEY:
        {
            // PC gives 500 silver
            UT_MoneyTakeFromObject(oPC, 0, 500, 0);
        }
        break;

        case ARL_BEVIN_LOST_PC_GIVES_MED_MONEY:
        {
            // PC gives 100 silver
            UT_MoneyTakeFromObject(oPC, 0, 100, 0);
        }
        break;

        case ARL_BEVIN_LOST_PC_GIVES_SMALL_MONEY:
        {
            // PC gives 50 silver
            UT_MoneyTakeFromObject(oPC, 0, 50, 0);
        }
        break;

        case ARL_BEVIN_LOST_PC_GIVES_TINY_MONEY:
        {
            // PC gives 15 silver
            UT_MoneyTakeFromObject(oPC, 0, 15, 0);
        }
        break;

        // Qwinn:  This case was missing entirely.  No attempt to remove the sword.
        case ARL_BEVIN_LOST_KAITLYN_TAKES_SWORD_BACK:
        {
            object oSword = GetObjectByTag("kaitlyn_sword");
            RemoveItem(oSword);
        }
        break;        



        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
        case ARL_BEVIN_LOST_PC_HAS_KEY_OR_SWORD:
        {   /* Qwinn replaced everything
            // IF ARL_BEVIN_LOST_PC_HAS_CHEST_KEY
            // OR
            // IF ARL_BEVIN_LOST_PC_HAS_SWORD

            int bHasKey = WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_PC_HAS_CHEST_KEY);
            int bHasSword = UT_CountItemInInventory(ARL_R_IT_BEVIN_SWORD) >= 1;

            nResult = (bHasKey == TRUE) || (bHasSword == TRUE);
            */
            object oSword = GetObjectByTag("kaitlyn_sword");
            if (IsObjectValid(oSword)) 
               nResult = TRUE;
        }
        break;

        case ARL_BEVIN_LOST_PC_HAS_KEY_OR_SWORD_AND_NOT_DISCUSSED:
        {
            // IF ARL_BEVIN_LOST_PC_HAS_CHEST_KEY
            // OR
            // IF ARL_BEVIN_LOST_PC_HAS_SWORD
            // AND
            // IF NOT ARL_BEVIN_LOST_DISCUSSED_SWORD

            int bHasKeyOrSword = WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_PC_HAS_KEY_OR_SWORD, TRUE);
            int bDiscussedSword = WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_DISCUSSED_SWORD);

            nResult = (bHasKeyOrSword == TRUE) && (bDiscussedSword == FALSE);
        }
        break;

        case ARL_BEVIN_LOST_PC_HAS_HUGE_MONEY:
        {
            // PC has 500 silver
            nResult = UT_MoneyCheck(oPC, 0, 500, 0);
        }
        break;

        case ARL_BEVIN_LOST_PC_HAS_MED_MONEY:
        {
            // PC has 100 silver
            nResult = UT_MoneyCheck(oPC, 0, 100, 0);
        }
        break;

        case ARL_BEVIN_LOST_PC_HAS_SMALL_MONEY:
        {
            // PC has 50 silver
            nResult = UT_MoneyCheck(oPC, 0, 50, 0);
        }
        break;

        case ARL_BEVIN_LOST_PC_HAS_TINY_MONEY:
        {
            // PC has 15 silver
            nResult = UT_MoneyCheck(oPC, 0, 15, 0);
        }
        break;

        case ARL_BEVIN_LOST_BEVIN_DRESSER_TRIGGER_DISABLED:
        {
            int bSiegeStarted = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_SIEGE_BEGINS);
            int bVillageAnandoned = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_VILLAGE_ABANDONED);
            nResult = (bSiegeStarted == TRUE) || (bVillageAnandoned == TRUE);
        }
        break;

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}