//==============================================================================
/*
    den200pt_assassin_orz.nss
    The Ambassador Assassination.
*/
//==============================================================================
//  Created By: Ferret
//  Created On: June 20th, 2008
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "den_constants_h"

#include "plt_den200pt_gen_assassin"
#include "plt_den200pt_assassin_orz"
#include "plt_den200pt_assassin_nrd"

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

            case ASSASSIN_ORZ_QUEST_ACCEPTED:               // Picking up the quest
            {

                // If you get both quests then turn off the "!"
                if ( WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_NRD, ASSASSIN_NRD_QUEST_ACCEPTED) )
                {
                    // Update the journal
                    WR_SetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, CROW_JOURNAL_SCROLLS_RECEIVED, TRUE, TRUE);

                    // Turn off quests available on the chest
                    oTarg = UT_GetNearestObjectByTag(oPC, DEN_IP_ASSASSIN_CHEST);
                    SetPlotGiver(oTarg, FALSE);
                }

                break;

            }

            case ASSASSIN_ORZ_REWARD_PLACED:                // Upon entry to the Noble Tavern
            {

                oTarg = UT_GetNearestObjectByTag(oPC, DEN_IP_ASSASSIN_CHEST);
                object oReward = CreateItemOnObject(DEN_IM_ASSASSIN_ORZ, oTarg);

                SetLocalInt(oReward, ITEM_SEND_ACQUIRED_EVENT, 1);

                break;

            }

            case ASSASSIN_ORZ_QUEST_DONE:                   // From picking up the quest reward in the chest
            {

                // Remove the assassination contract
                UT_RemoveItemFromInventory(DEN_IM_ASSASSIN_CONTRACT_ORZ);

                // Queue up the last mission
                if ( WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_NRD, ASSASSIN_NRD_QUEST_DONE) )
                {
                    // Turn on quests available
                    oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_IGNACIO);
                    SetPlotGiver(oTarg, TRUE);

                    WR_SetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, CROW_LAST_MISSION_AVAILABLE, TRUE, TRUE);
                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_17d);

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