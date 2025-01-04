//:://////////////////////////////////////////////
//:: den200pt_assassin_den
//:: Copyright (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Ferret
//:: Created On: June 18th, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "den_constants_h"

#include "plt_den200pt_gen_assassin"
#include "plt_den200pt_assassin_den"
#include "plt_den200pt_assassin_nrd"
#include "plt_den200pt_assassin_orz"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                       // Contains all input parameters
    int nType = GetEventType(eParms);                       // GET or SET call
    string strPlot = GetEventString(eParms, 0);             // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);                 // The bit flag # being affected
    object oParty = GetEventCreator(eParms);                // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0);  // Owner on the conversation, if any
    int nResult = FALSE;                                    // used to return value for DEFINED GET events
    object oPC = GetHero();
    object oTarg;

    plot_GlobalPlotHandler(eParms);                         // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case PAEDAN_DOOR_UNLOCKED:              // DEN220_PAEDAN_DOOR
                                                    // The door is unlocked
            {
                oTarg = UT_GetNearestObjectByTag(oPC, DEN_IP_LC_PAEDAN_DOOR);
                SetPlaceableState(oTarg, PLC_STATE_DOOR_UNLOCKED);
                break;
            }

            case PAEDAN_ATTACKS:                    // DEN220_PAEDAN
                                                    // Paedan and his pals attack
            {
                // Lock the back doors
                object [] oDoors = UT_GetTeam(DEN_TEAM_PEARL_BACK_DOORS, OBJECT_TYPE_PLACEABLE);
                int nArraySize = GetArraySize(oDoors);
                int nCount;
                for (nCount = 0; nCount < nArraySize; nCount++)
                {
                    SetPlaceableState(oDoors[nCount], PLC_STATE_DOOR_LOCKED);
                }

                // His team attacks
                UT_TeamGoesHostile(DEN_TEAM_PAEDAN);
                break;
            }

            case PAEDAN_KILLED:                     // Paedan is killed
            {
                // Open the doors
                object [] oDoors = UT_GetTeam(DEN_TEAM_PEARL_BACK_DOORS, OBJECT_TYPE_PLACEABLE);
                int nArraySize = GetArraySize(oDoors);
                int nCount;
                for (nCount = 0; nCount < nArraySize; nCount++)
                {
                    SetPlaceableState(oDoors[nCount], PLC_STATE_DOOR_UNLOCKED);
                }

                // If you have the quest, you get a journal entry
                if ( WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_DEN, ASSASSIN_DEN_QUEST_ACCEPTED) )
                    WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_DEN, JOURNAL_PAEDAN_KILLED, TRUE, TRUE);
                break;
            }

            case ASSASSIN_DEN_QUEST_ACCEPTED:       // DEN200_IGNACIO
                                                    // You get the first mission to kill someone
            {
                // Turn off quests available
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_IGNACIO);
                SetPlotGiver(oTarg, FALSE);

                // You get a contract
                UT_AddItemToInventory(DEN_IM_ASSASSIN_CONTRACT_DEN);

                // You could've already killed Paedan
                if ( WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_DEN, PAEDAN_KILLED) )
                    WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_DEN, JOURNAL_PAEDAN_ALREADY_KILLED, TRUE, TRUE);
                else WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_DEN, JOURNAL_DEN_QUEST_ACCEPTED, TRUE, TRUE);

                // Journal update
                WR_SetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, CROW_JOURNAL_QUEST_START, TRUE, TRUE);
                break;
            }

            case ASSASSIN_DEN_QUEST_DONE:           // You get this when you open the reward chest
            {
                // Remove the contract
                UT_RemoveItemFromInventory(DEN_IM_ASSASSIN_CONTRACT_DEN);

                // Journal update
                WR_SetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, CROW_JOURNAL_SCROLLS_PRESENTED, TRUE, TRUE);


                // Add assassination contracts to the chest
                // Qwinn added reward
                object oContract;
                oTarg = UT_GetNearestObjectByTag(oPC, DEN_IP_ASSASSIN_CHEST);

                object oMoney = CreateItemOnObject(R"gen_im_copper.uti", oTarg, 60000, "", TRUE);


                oContract = CreateItemOnObject(DEN_IM_ASSASSIN_CONTRACT_NRD, oTarg);
                SetLocalInt(oContract, ITEM_SEND_ACQUIRED_EVENT, 1);

                oContract = CreateItemOnObject(DEN_IM_ASSASSIN_CONTRACT_ORZ, oTarg);
                SetLocalInt(oContract, ITEM_SEND_ACQUIRED_EVENT, 1);

                // Turn on quests available on the chest
                oTarg = UT_GetNearestObjectByTag(oPC, DEN_IP_ASSASSIN_CHEST);
                SetPlotGiver(oTarg, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_17a);

                break;
            }

        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case PAEDAN_CAN_ASK_ABOUT_POSTER:
            {

                int bCondition1 =   WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_DEN, PAEDAN_DOOR_UNLOCKED);
                int bCondition2 =   WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_DEN, PAEDAN_PASSWORD_KNOWN);

                nResult =   !bCondition1 && bCondition2;

                break;
            }


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}