//==============================================================================
/*
    den200pt_assassin_end.nss
    The Ransom Drop quest.
*/
//==============================================================================
//  Created By: Ferret
//  Created On: June 23rd, 2008
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "campaign_h"
#include "den_constants_h"

#include "plt_den200pt_gen_assassin"
#include "plt_den200pt_assassin_end"

//------------------------------------------------------------------------------

int StartingConditional()
{
    event   eParms              =   GetCurrentEvent();              // Contains all input parameters

    int     nType               =   GetEventType(eParms);           // GET or SET call
    int     nFlag               =   GetEventInteger(eParms, 1);     // The bit flag # being affected
    int     nResult             =   FALSE;                          // used to return value for DEFINED GET events

    string  strPlot             =   GetEventString(eParms, 0);      // Plot GUID

    object  oParty              =   GetEventCreator(eParms);        // The owner of the plot table for this script
    object  oConversationOwner  =   GetEventObject(eParms, 0);      // Owner on the conversation, if any
    object  oPC                 =   GetHero();
    object  oTarg;

    plot_GlobalPlotHandler(eParms);                         // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);     // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case ASSASSIN_END_QUEST_ACCEPTED:       // DEN200_IGNACIO
                                                    // The quest is accepted
            {

                object  oIgnacio    =   UT_GetNearestCreatureByTag(oPC, DEN_CR_IGNACIO);
                object  oMapNote    =   GetObjectByTag(WML_LC_DEN_ASSASSIN_RANSOM);

                // Turn off quests available
                SetPlotGiver(oIgnacio, FALSE);

                // You get a contract
                UT_AddItemToInventory(DEN_IM_ASSASSIN_CONTRACT_END);

                // Make the map point appear
                WR_SetWorldMapLocationStatus(oMapNote, WM_LOCATION_ACTIVE);

                break;

            }

            case CHASE_ATTACKS:                     // Chase and his goons attack
            {

                object  [] arCrows  =   GetTeam(DEN_TEAM_CHASE_CROW_ALLIES);
                object  oCurrent;

                int     nCrowsSize  =   GetArraySize(arCrows);
                int     nLoop;

                // For all the disguised crows, equip weapons.
                for(nLoop = 0; nLoop < nCrowsSize; nLoop++)
                {

                    oCurrent = arCrows[nLoop];

                    object  [] arDaggers    =   GetItemsInInventory(oCurrent, GET_ITEMS_OPTION_ALL, 0, DEN_IT_CROW_DAGGER);

                    EquipItem(oCurrent, arDaggers[0], INVENTORY_SLOT_MAIN, 0);
                    EquipItem(oCurrent, arDaggers[1], INVENTORY_SLOT_OFFHAND, 0);

                }


                // Team goes hostile.
                UT_TeamGoesHostile(DEN_TEAM_CHASE);

                // One of the assassins is immortal, so at the end he can talk and such
                /*oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_DISGUISED_CROW);
                SetImmortal(oTarg, TRUE);*/

                break;

            }

            case CROWS_LEAVE_RANDSOM_AREA:          // DEN200_CROW_RANSOM
                                                    // The Crows leave the area
            {

                UT_TeamExit(DEN_TEAM_CHASE_CROW_ALLIES, FALSE, "mn_exit_city_map");

                break;

            }

            case ASSASSIN_END_REWARD_PLACED:        // Upon entry to the Noble Tavern
            {

                object  oChest  =   UT_GetNearestObjectByTag(oPC, DEN_IP_ASSASSIN_CHEST);
                object  oReward =   CreateItemOnObject(DEN_IM_ASSASSIN_END, oChest);

                SetLocalInt(oReward, ITEM_SEND_ACQUIRED_EVENT, 1);

                break;

            }

            case ASSASSIN_END_QUEST_DONE:           // DEN200_IGNACIO
                                                    // You are done with the quest
            {

                object oPin =   GetObjectByTag(WML_LC_DEN_ASSASSIN_RANSOM);

                // Remove the contract
                UT_RemoveItemFromInventory(DEN_IM_ASSASSIN_CONTRACT_END);

                // Make the map point appear
                WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_INACTIVE);

                // Close off the global quest
                // Moved this as a separate set in the dialogue file so the journal updates properly.
                // WR_SetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, IGNACIO_QUESTS_DONE, TRUE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_17b);

                break;

            }

        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}