//==============================================================================
/*
    den200pt_thief_pick3.nss
    The third quest in the Crime Wave series of plots from "Slim" Couldry.
*/
//==============================================================================
//  Created By: Ferret
//  Created On: June 24th, 2008
//==============================================================================
//  Modified By: Kaelin
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "campaign_h"
#include "den_constants_h"

#include "plt_gen00pt_skills"
#include "plt_den200pt_thief"
#include "plt_den200pt_thief_pick3"

#include "plt_qwinn"

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

    object  oMessenger          =   UT_GetNearestCreatureByTag(oPC, DEN_CR_IGNACIO_DELIVERY);
    object  oCouldry            =   UT_GetNearestCreatureByTag(oPC, DEN_CR_COULDRY);
    object  oRestless           =   UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK3_GUARD2);
    object  oAlert              =   UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK3_GUARD1);
    object  oTilver             =   UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK3_SILVERSMITH);
    object  oTimer              =   GetObjectByTag(DEN_TR_PICK3_GUARD2_TIMER);

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case THIEF_PICK3_ASSIGNED:              // DEN200_COULDRY
                                                    // You're given the mission
            {
                // Qwinn:  To reduce lag, only activating these while quest is active.
                object oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_guard2_chat");
                SetObjectActive(oTrig,TRUE);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_guard2_mv");
                SetObjectActive(oTrig,TRUE);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_guard2_timer");
                SetObjectActive(oTrig,TRUE);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_msngr_taunt");
                SetObjectActive(oTrig,TRUE);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_stealth2");
                SetObjectActive(oTrig,TRUE);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_stealth2_bad");
                SetObjectActive(oTrig,TRUE);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_stealth3");
                SetObjectActive(oTrig,TRUE);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_stealth3_bad");
                SetObjectActive(oTrig,TRUE);

                WR_SetPlotFlag(PLT_DEN200PT_THIEF, THIEF_PICKPOCKET_ACTIVE, TRUE, TRUE);

                // Make the silversmith appear
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_SILVERSMITH_IS_PRESENT, TRUE, TRUE);

                UT_TeamAppears(DEN_TEAM_PICK3_SILVERSMITH);

                // Make the messenger appear nearby
                WR_SetObjectActive(oMessenger, TRUE);

                UT_LocalJump(oMessenger, "4");

                // See if you should toggle quest giver notification
                if ( !WR_GetPlotFlag(PLT_DEN200PT_THIEF, THIEF_CHECK_IF_SNEAK_AVAILABLE) )
                {

                    SetPlotGiver(oCouldry, FALSE);

                }

                break;

            }

            case THIEF_PICK3_TAKE_FEE:              // DEN200_COULDRY
                                                    // He takes your money
            {

                // Remove the required fee of 3 gold from the PC.
                UT_MoneyTakeFromObject(oPC, 0, 0, 3);

                break;

            }

            case PICK3_GUARD_WANDER_TIMER:          // Start a timer for an event
            {
                // When you run over the trigger it starts a timer before Guard2 wanders over to his bud
                // (or back to his start location). This assigns an event to the area, so some of the heavy
                // lifting logic continues in "den200cr_pick3_silver_grd_2".
                // This bit of code isn't 100% necessary, so if isn't 100% infallible - that's all right.

                /*object oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK3_GUARD2);
                event evWander = Event(EVENT_TYPE_PICK3_WANDER);
                WR_AddCommand(oTarg, CommandWait(10.0), FALSE, TRUE);
                //WR_AddCommand(oTarg, CommandDoEvent(evWander), FALSE, TRUE);
                SignalEvent(oTarg, evWander); */

                break;
            }

            case PICK3_GUARD_WANDERS:               // The restless guard moves
            {
                // Qwinn:  Added condition so guard doesn't go up a third time and trigger incorrect
                // dialogue and not return to position
                if ( !WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDERS_1) ||
                     !WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDERS_2))
                {
                   WR_AddCommand(oRestless, CommandWait(4.0f), TRUE, TRUE);
                   UT_QuickMove(DEN_CR_PICK3_GUARD2, "1");
                }
                break;
            }

            case PICK3_GUARD_HITS_TRIGGER_CHAT:     // The restless guard now blabs with his pal
            {
                if ( !WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDERS_1) )
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDERS_1, TRUE, TRUE);
                else
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDERS_2, TRUE, TRUE);

                WR_SetPlotFlag(PLT_QWINN,DEN_PICK3_GUARDS_TALKING,TRUE,TRUE);

                UT_Talk(oAlert, oRestless);

                break;

            }

            case PICK3_GUARD_GOES_TO_POSITION:      // At the end of chatting he goes back to his spot
            {
                // Qwinn added
                WR_SetPlotFlag(PLT_QWINN,DEN_PICK3_GUARDS_TALKING,FALSE,TRUE);
                UT_QuickMove(DEN_CR_PICK3_GUARD2);
                break;

            }

            case PICK3_GUARD_HITS_TRIGGER_HOME:     // This is the home trigger
            {

                // Make sure the quest is active
                if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_SILVERSMITH_IS_PRESENT) )
                {
                    // Turn this off so that it recognizes guard 2 is back in position
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDERS, FALSE, TRUE);

                    // And if guard 2 hasn't done the second wander, queue it up
                    if ( !WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDERS_2) )
                        WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDER_TIMER, TRUE, TRUE);
                }

                break;

            }

            case PC_KNOWS_ABOUT_TILVERS_TART:       // The PC may over hear stuff about Tilver's "tart"
            {

                // If the player isn't even close, then he can't overhear the reference
                if ( !IsInTrigger(oPC, oTimer) )
                {

                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PC_KNOWS_ABOUT_TILVERS_TART, FALSE, TRUE);

                }

                break;

            }

            case SILVERSMITH_CAUGHT_PC_STEALING:    // PC was caught, have him speak
            {

                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, SILVERSMITH_CAUGHT_STEALING_DIALOG_READY, TRUE, TRUE);

                UT_Talk(oTilver, oPC);

                break;

            }

            case MESSENGER_PAID_TO_DISTRACT:        // DEN200_IGNACIO_DELIVERY
                                                    // The kid is paid to distract the guards
            {

                // Qwinn added
                UT_MoneyTakeFromObject( oPC, 0, 10, 0 );

                // The kid runs
                UT_QuickMove(DEN_CR_IGNACIO_DELIVERY, "1", TRUE);

                // Kill any actions on the guard
                WR_ClearAllCommands(oAlert);

                WR_ClearAllCommands(oRestless);

                break;

            }

            case MESSENGER_TAUNTS:                  // The messenger taunts the guards
            {

                WR_ClearAllCommands(oMessenger);

                // And the kid talks
                UT_Talk(oAlert, oMessenger);

                break;

            }

            case MESSENGER_RUNS:                    // The guards chase the messenger
            {

                // The kid runs
                UT_ExitDestroy(oMessenger, TRUE);

                break;

            }

            case PICK3_GUARDS_CHASE_MESSENGER:      // The guards chase the messenger
            {

                // The guards run
                UT_ExitDestroy(oAlert, TRUE);

                UT_ExitDestroy(oRestless, TRUE);

                break;

            }

            case PICK3_SILVERSMITH_LEAVES:          // DEN200_PICK3_SILVERSMITH
                                                    // In conversation his mean and him leave
            {

                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_SILVERSMITH_IS_PRESENT, FALSE, TRUE);

                UT_TeamAppears(DEN_TEAM_PICK3_SILVERSMITH, FALSE);

                break;

            }

            case THIEF_PICK3_KEY_STOLEN:            // The key is stolen from the silversmith
            {

                // You can get the key via dialog or via pickpocketing. "denev_item_acquired"
                // handles picking up the pickpocketing route and flagging this.

                // This check is so that you don't endlessly loop getting the key

                // Qwinn added so it can't be stolen after dialogue theft.
                UT_RemoveItemFromInventory (DEN_IM_PICK3_KEY, 1, oTilver);

                int nKeys   =   UT_CountItemInInventory(DEN_IM_PICK3_KEY);

                if ( nKeys == 0 )
                {

                    UT_AddItemToInventory(DEN_IM_PICK3_KEY);

                }

                break;

            }

            case THIEF_PICK3_SUCCESSFUL:
            {

                // Disappear the Silversmith and his guys
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_SILVERSMITH_IS_PRESENT, FALSE, TRUE);

                // Qwinn:  Destroying the creatures, hopefully reduce lag.
                // UT_TeamAppears(DEN_TEAM_PICK3_SILVERSMITH, FALSE);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den200cr_pick3_silversmith");
                Safe_Destroy_Object(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den200cr_pick3_silver_guard");
                Safe_Destroy_Object(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den200cr_pick3_silver_grd_2");
                Safe_Destroy_Object(oTarg);                

                // Flagging so checks below properly recognize this quest has been completed
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_SUCCESSFUL, TRUE, FALSE);

                // See if you should toggle quest giver notification
                // Note: This will turn it to TRUE
                if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF, THIEF_CHECK_IF_SNEAK_AVAILABLE) )
                {

                    SetPlotGiver(oCouldry, TRUE);

                }

                // Force the flag to be set immediately for logic in another plot script
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_SUCCESSFUL, TRUE, FALSE);

                // Check to see if the Final Pickpocket Mission is available
                if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_READY_FOR_FINAL_PICK) )
                {

                    SetPlotGiver(oCouldry, TRUE);

                }

                // Qwinn:  Destroying all the triggers, hopefully reduces lag
                object oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_guard2_chat");
                Safe_Destroy_Object(oTrig);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_guard2_mv");
                Safe_Destroy_Object(oTrig);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_guard2_timer");
                Safe_Destroy_Object(oTrig);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_msngr_taunt");
                Safe_Destroy_Object(oTrig);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_stealth2");
                Safe_Destroy_Object(oTrig);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_stealth2_bad");
                Safe_Destroy_Object(oTrig);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_stealth3");
                Safe_Destroy_Object(oTrig);
                oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_pick3_stealth3_bad");
                Safe_Destroy_Object(oTrig);



                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_4c);


                break;
            }

            case SILVERSMITH_TALKING_FAILED:
            case PICK3_PC_JUMPED_BACK:
            {

                // Jump the player back from the guards to prevent the conversation from firing all the time.
                UT_LocalJump(oPC, "jp_den200wp_pick3_bad_stealth", TRUE, FALSE, TRUE, TRUE);

                break;

            }

        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case THIEF_PICK3_PC_HAS_MONEY:      // Check to see if the PC has enough money
            {

                // Does the PC have the required fee of 3 gold.
                int bCondition = UT_MoneyCheck(oPC, 0, 0, 3);

                nResult = bCondition;

                break;

            }

            case THIEF_PICK3_ACTIVE_AND_NO_KEY:     // Is the quest still open? Does the PC have the key?
            {

                int bCondition1 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_ASSIGNED);
                int bCondition2 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_KEY_STOLEN);
                int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_SUCCESSFUL);

                nResult = bCondition1 && !bCondition2 && !bCondition3;

                break;

            }

            case PICK3_STEALTH2_CHECK:              // Check to see if the PC can get by the guard
            {

                int bCondition1 = GetStealthEnabled(oPC);
                int bCondition2 = WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_STEALTH_MED);
                int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARDS_CHASE_MESSENGER);

                nResult = (bCondition1 && bCondition2) || bCondition3;

                break;

            }

            case PICK3_STEALTH3_CHECK:              // Check to see if the PC can get by the guard
            {

                int bCondition1 = IsStealthy(oPC);
                int bCondition2 = WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_STEALTH_HIGH);
                int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARDS_CHASE_MESSENGER);

                nResult = (bCondition1 && bCondition2) || bCondition3;

                break;

            }

            case PICK3_STEALTH2_CHECK_WITH_BAD_GUARD:   // See if the PC meets the stealth criteria
            {

                int bCondition1 = IsStealthy(oPC);
                int bCondition2 = WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_STEALTH_MED);
                int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDERS);
                int bCondition4 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARDS_CHASE_MESSENGER);

                nResult = ( bCondition1 && bCondition2 ) || bCondition3 || bCondition4;

                if (bCondition1 && !nResult)
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARDS_CAUGHT_PC_STEALTHING, TRUE, TRUE);

                break;

            }

            case PICK3_STEALTH3_CHECK_WITH_BAD_GUARD:   // See if the PC meets the stealth criteria
            {

                int bCondition1 = IsStealthy(oPC);
                int bCondition2 = WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_STEALTH_HIGH);
                int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDERS);
                int bCondition4 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARDS_CHASE_MESSENGER);

                nResult = ( bCondition1 && bCondition2 ) || bCondition3 || bCondition4;
                if (bCondition1 && !nResult)
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARDS_CAUGHT_PC_STEALTHING, TRUE, TRUE);

                break;

            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}