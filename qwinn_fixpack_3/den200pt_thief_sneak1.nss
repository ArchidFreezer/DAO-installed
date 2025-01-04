//==============================================================================
/*
    den200pt_thief_sneak1.nss
    The first sneak mission given by "Slim" Couldry.
*/
//==============================================================================
//  Created By: Ferret
//  Created On: June 24th, 2008
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "campaign_h"
#include "den_constants_h"

#include "plt_den200pt_thief"
#include "plt_den200pt_thief_sneak1"

//------------------------------------------------------------------------------

int StartingConditional()
{
    event   eParms              = GetCurrentEvent();                // Contains all input parameters

    int     nType               = GetEventType(eParms);             // GET or SET call
    int     nFlag               = GetEventInteger(eParms, 1);       // The bit flag # being affected
    int     nResult             = FALSE;                            // used to return value for DEFINED GET events

    string  strPlot             = GetEventString(eParms, 0);        // Plot GUID

    object  oParty              = GetEventCreator(eParms);          // The owner of the plot table for this script
    object  oConversationOwner  = GetEventObject(eParms, 0);        // Owner on the conversation, if any
    object  oPC                 = GetHero();
    object  oTarg;

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)                                // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case THIEF_SNEAK1_ASSIGNED:             // DEN200_COULDRY
                                                    // You're given the mission
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, THIEF_SNEAK_ACTIVE, TRUE, TRUE);

                // See if you should toggle quest giver notification
                if ( !WR_GetPlotFlag(PLT_DEN200PT_THIEF, THIEF_CHECK_IF_PICKPOCKET_AVAILABLE) )
                {
                    object oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_COULDRY);
                    SetPlotGiver(oTarg, FALSE);
                }
                break;
            }

            case COULDRY_REFUNDS_PC:
            {

                //Give back the money
                RewardMoney(0, 0, 1);

                break;
            }

            case THIEF_SNEAK1_TAKE_FEE:             // DEN200_COULDRY
                                                    // He takes your money
            {
                // Remove the required fee of 1 gold.
                UT_MoneyTakeFromObject(oPC, 0, 0, 1);

                break;
            }

            case SOPHIE_GUARD_ARRIVES:              // On a trigger in her room if the guard's been alerted
            {
                // Jump in the guard to her spot and have her speak
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_SOPHIE_GUARD);

                UT_LocalJump(oTarg, "1");

                UT_Talk(oTarg, oPC);

                break;
            }

            case SOPHIE_GUARD_ATTACKS:              // Sophie's guard attacks
            {
                // Now lock the door
                oTarg = GetObjectByTag(DEN_IP_GNAWED_SOPHIE_DOOR);

                SetPlaceableState(oTarg, PLC_STATE_DOOR_LOCKED);

                // She goes hostile
                UT_TeamGoesHostile(DEN_TEAM_SNEAK1_SOPHIE_GUARD);

                break;
            }

            case SOPHIE_GUARD_KILLED:               // The guard dies, unlock the door
            {
                // Now unlock the door
                oTarg = GetObjectByTag(DEN_IP_GNAWED_SOPHIE_DOOR);

                SetPlaceableState(oTarg, PLC_STATE_DOOR_UNLOCKED);

                break;
            }

            case STOLE_SOPHIES_STUFF:               // When you take the main loot for Lady Sophie's room
            {
                if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, THIEF_SNEAK1_ASSIGNED) )
                {
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, JOURNAL_THIEF_SNEAK1_COMPLETED, TRUE, TRUE);

                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, THIEF_SNEAK1_SUCCESSFUL, TRUE, TRUE);
                }

                break;
            }

            case THIEF_SNEAK1_SUCCESSFUL:           // DEN200_COULDRY
                                                    // This can be triggered if you are on the mission
                                                    // (see STOLE_SOPHIES_STUFF) or in dialog.
            {
                // If you haven't been assigned the quest, it means you did the quest before he handed it out
                if ( !WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, THIEF_SNEAK1_ASSIGNED) )
                {
                    
                    object  oChest  =   GetObjectByTag("den220ip_sophie_chest");
                    
                    WR_TogglePlotIcon(oChest, FALSE);

                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, THIEF_SNEAK1_ASSIGNED, TRUE, FALSE);
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, JOURNAL_THIEF_SNEAK1_COMPLETED_ALREADY, TRUE, TRUE);

                }


                // You always get the next quest available
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_QUEUE_UP_PLOT_GIVER, TRUE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_4e);

                break;
            }

        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case THIEF_SNEAK1_PC_HAS_MONEY:     // Check to see if the PC has enough money
            {
                // Does the PC have the required fee of 1 gold?
                int bCondition  =   UT_MoneyCheck(oPC, 0, 0, 1);

                nResult = bCondition;

                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}