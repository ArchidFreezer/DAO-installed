//==============================================================================
/*
    den200pt_thief_sneak4.nss
    This will track "Slim" Couldry's fourth and final sneak quest.
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
#include "dlc_functions_h"

#include "plt_den200pt_thief"
#include "plt_den200pt_thief_sneak4"

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

    object  oEstate             =   GetObjectByTag("wml_lc_franderel_estate_2");
    object  oCouldry            =   UT_GetNearestCreatureByTag(oPC, DEN_CR_COULDRY);

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case THIEF_SNEAK4_ASSIGNED:             // DEN200_COULDRY
                                                    // You're given the mission
            {

                WR_SetPlotFlag(PLT_DEN200PT_THIEF, THIEF_SNEAK_ACTIVE, TRUE, TRUE);

                // Add main journal entry
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, THIEF_ON_LAST_MISSION, TRUE, TRUE);

                // Add the spot to the map
                WR_SetWorldMapLocationStatus(oEstate, WM_LOCATION_ACTIVE);

                // He has no more quests
                SetPlotGiver(oCouldry, FALSE);

                break;

            }

            case TRIGGER_ESTATE_ACTIVITY:           // When you enter Bann Franderel's estate
                                                    // there's some activity.
            {

                // The patrollers walk
                DLC_PatrolWPs(DEN_CR_FRAN_PATROL_1_1, 4);
                DLC_PatrolWPs(DEN_CR_FRAN_PATROL_1_2, 4);
                DLC_PatrolWPs(DEN_CR_FRAN_PATROL_2, 4);
                DLC_PatrolWPs(DEN_CR_FRAN_PATROL_3_1, 2);
                DLC_PatrolWPs(DEN_CR_FRAN_PATROL_3_2, 2);
                DLC_PatrolWPs(DEN_CR_FRAN_PATROL_3_3, 2);
                DLC_PatrolWPs(DEN_CR_FRAN_PATROL_3_4, 2);

                break;

            }

            case INNER_GOSSIP_WALKS_1:              // DEN971_INNER_GOSSIP
                                                    // The gossip takes a walk
            {

                DLC_PatrolWPs(DEN_CR_SNEAK4_INNER_GOSSIP_2, 4, FALSE, FALSE);

                break;

            }

            case INNER_GOSSIP_WALKS_2:              // DEN971_INNER_GOSSIP
                                                    // The gossip takes a walk
            {

                DLC_PatrolWPs(DEN_CR_SNEAK4_INNER_GOSSIP_2, 4);

                break;

            }

            case FRANDEREL_ALARM_SOUNDED:           // The guards spot the PC, the alarm is sounded
            {

                int nCounter;

                // Make the nearest person cry out
                oTarg = UT_GetNearestHostileCreature(oPC);

                UT_Talk(oTarg, oPC, DEN_CONV_SNEAK4_GUARD);

                // Make the servant run
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_SNEAK4_DRINK_SERVER);

                UT_ExitDestroy(oTarg, TRUE);

                // Open all the reinforcement doors
                object [] oDoor = UT_GetTeam(DEN_TEAM_FRAN_REINFORCE_DOORS, OBJECT_TYPE_PLACEABLE);

                while ( IsObjectValid(oDoor[nCounter]) )
                {
                    LogTrace(LOG_CHANNEL_PLOT, "Door Tag: " + GetTag(oDoor[nCounter]) );

                    SetPlot(oDoor[nCounter], FALSE);

                    SetPlaceableActionResult(oDoor[nCounter], PLACEABLE_ACTION_UNLOCK, TRUE);

                    SetPlaceableActionResult(oDoor[nCounter], PLACEABLE_ACTION_OPEN, TRUE);

                    nCounter++;
                }

                // Make all the reinforcements go to their positions
                nCounter = 0;

                UT_TeamAppears(DEN_TEAM_FRAN_REINFORCEMENTS);

                object [] oReinforcements = UT_GetTeam(DEN_TEAM_FRAN_REINFORCEMENTS);

                while ( IsObjectValid(oReinforcements[nCounter]) )
                {
                    LogTrace(LOG_CHANNEL_PLOT, "Reinforce Tag: " + GetTag(oReinforcements[nCounter]) );

                    UT_QuickMove(GetTag(oReinforcements[nCounter]), "0", TRUE);

                    nCounter++;
                }

                break;

            }

            case GOSSIPS_DRINKS_POISONED:           // The PC has poisoned the drinks
            {

                // Remove the Rat Poison if the PC has it
                UT_RemoveItemFromInventory(DEN_IM_FRAN_RAT_POISON);

                // The servant goes to the drinks and then talks to himself.
                // That immediately fires GOSSIPS_SERVANT_DELIVERING_DRINKS.
                UT_QuickMove(DEN_CR_SNEAK4_DRINK_SERVER, "1");
                /*
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_SNEAK4_DRINK_SERVER);
                object oWP = UT_GetNearestObjectByTag(oPC, DEN_WP_SNEAK4_DRINK_SERVER_1);
                AddCommand(oTarg, CommandMoveToObject(oWP));
                AddCommand(oTarg, CommandStartConversation(oTarg));
                */

                break;

            }

            case GOSSIPS_SERVANT_DELIVERING_DRINKS: // The servant goes to deliver the drinks
            {

                // Flagging so the conversation recognizes the next stage
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, GOSSIPS_DRINKS_DELIVERED, TRUE, FALSE);

                UT_QuickMove(DEN_CR_SNEAK4_DRINK_SERVER, "2");

                /*
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_SNEAK4_DRINK_SERVER);
                object oWP = UT_GetNearestObjectByTag(oPC, DEN_WP_SNEAK4_DRINK_SERVER_2);
                object oListener = UT_GetNearestCreatureByTag(oPC, DEN_CR_SNEAK4_GOSSIP_1);
                AddCommand(oTarg, CommandMoveToObject(oWP));
                AddCommand(oTarg, CommandStartConversation(oListener, R"den971_gossip_guards.dlg"));
                //AddCommand(oTarg, CommandStartConversation(oListener, DEN_CONV_SNEAK4_GOSSIP));
                */

                break;

            }

            case GOSSIPS_SERVANT_GOES_AWAY:         // The servant leaves
            {

                // Flagging so the conversation recognizes the next stage
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, GOSSIPS_POISONED, TRUE, FALSE);

                // After 3 seconds the gossips die from the poison
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_SNEAK4_GOSSIP_1);
                // AddCommand(oTarg, CommandWait(3.0));
                // AddCommand(oTarg, CommandStartConversation(oTarg, DEN_CONV_SNEAK4_GOSSIP));
                
                object oTarg2 = UT_GetNearestCreatureByTag(oPC, DEN_CR_SNEAK4_GOSSIP_2);
                AddCommand(oTarg,  CommandWait(3.0), TRUE, TRUE);
                AddCommand(oTarg2, CommandWait(3.0), TRUE, TRUE);
                AddCommand(oTarg, CommandMoveToObject(oTarg2, FALSE, 1.0));
                AddCommand(oTarg2, CommandStartConversation(oTarg));                  

                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_SNEAK4_DRINK_SERVER);
                UT_ExitDestroy(oTarg);

                break;

            }

            case GOSSIPS_DIE:                       // The gossips die (or are KOed) from the poison
            {

                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_SNEAK4_GOSSIP_2);
                KillCreature(oTarg);

                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_SNEAK4_GOSSIP_1);
                KillCreature(oTarg);

                break;

            }

            case GOLEMS_ACTIVATED:                  // The golems come alive
            {

                object  [] arTeam   =   GetTeam(DEN_TEAM_FRAN_GOLEMS);
                object  oGolem;

                int     nTeam       =   GetArraySize(arTeam);
                int     nLoop;

                for(nLoop = 0; nLoop < nTeam; nLoop++)
                {

                    oGolem  =   arTeam[nLoop];

                    SetCreatureIsStatue(oGolem, FALSE);

                }

                UT_SetTeamInteractive(DEN_TEAM_FRAN_GOLEMS, TRUE);

                UT_TeamGoesHostile(DEN_TEAM_FRAN_GOLEMS);

                break;

            }

            case THIEF_SNEAK4_SUCCESSFUL:           // You've escaped, now kill the hot spot for the estate
            {

                // Remove the spot to the map
                WR_SetWorldMapLocationStatus(oEstate, WM_LOCATION_INACTIVE);

                // If the PC didn't manage to sneak through the entire level, then spawn in one last wave
                if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, FRANDEREL_ALARM_SOUNDED) )
                {
                    object oDoor = GetObjectByTag(DEN_IP_FRAN_INNER_DOOR);

                    SetPlaceableActionResult(oDoor, PLACEABLE_ACTION_CLOSE, TRUE);

                    UT_TeamAppears(DEN_TEAM_FRAN_LAST_WAVE);
                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_4h);

                break;

            }

            case THIEF_SNEAK4_LEFT_FRANDEREL:       // After you've succesfully finished the mission, kill
                                                    // the hotspot on the map for it.
            {

                // Remove the spot on the map
                WR_SetWorldMapLocationStatus(oEstate, WM_LOCATION_INACTIVE);

                break;

            }

            case THIEF_SNEAK4_QUEST_DONE:           // DEN200_COULDRY
                                                    // The quest is over, end the main quest
            {

                int bAlarmSounded   =   WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, FRANDEREL_ALARM_SOUNDED);

                // Remove the Tears of Andraste from the PC's inventory
                UT_RemoveItemFromInventory(DEN_IM_TEARS_OF_ANDRASTE);

                if(bAlarmSounded == FALSE)
                {

                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, THIEF_SNEAK4_ALARM_NOT_SOUNDED, TRUE, TRUE);

                }

                // End the parent quest
                // Qwinn:  This will now be set in the dialogue so order is correct and subequest is closed
                // prior to main quest closing
                // WR_SetPlotFlag(PLT_DEN200PT_THIEF, THIEF_QUEST_DONE, TRUE, TRUE);


                break;

            }

            case THIEF_SNEAK4_TEARS_KEPT:           // DEN200_COULDRY
                                                    // The quest is over, end the main quest
            {
                // Qwinn:  This will now be set in the dialogue so order is correct and subequest is closed
                // prior to main quest closing
                // WR_SetPlotFlag(PLT_DEN200PT_THIEF, THIEF_QUEST_DONE, TRUE, TRUE);

                break;

            }


        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case PC_HAS_RAT_POISON:
            {

                int bCondition  =  UT_CountItemInInventory(DEN_IM_FRAN_RAT_POISON, oPC);

                nResult = bCondition;

                break;

            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}