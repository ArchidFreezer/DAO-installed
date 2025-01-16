//==============================================================================
/*
    den200pt_gen_assassin.ncs
    This will track the assassination assignments.
*/
//==============================================================================
//  Created By: Ferret
//  Created On: June 18th, 2008
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "den_constants_h"

#include "plt_den200pt_gen_assassin"
#include "plt_den200pt_assassin_den"
#include "plt_den200pt_assassin_end"
#include "plt_den200pt_thief_pick3"

#include "plt_genpt_zevran_main"
#include "plt_denpt_talked_to"
#include "plt_mnp000pt_main_events"

// Merchant Scaling
#include "scalestorefix_h"
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
    object  oIgnacio            =   UT_GetNearestCreatureByTag(oPC, DEN_CR_IGNACIO);
    object  oSecondStore        =   UT_GetNearestObjectByTag(oPC, DEN_IP_CESARS_SECOND_STORE);

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case IGNACIO_MESSENGER_ARRIVES_TO_TALK: // From the exit triggers of the Market District
            {
                WR_SetObjectActive(oMessenger, TRUE);

                //UT_Talk(oMessenger, oPC);

                break;
            }

            case CROW_ASSASIN_LETTER_RECEIVED:      // DEN200_IGNACIO_DELIVERY
                                                    // The PC ges the assassin opening letter
            {
                if(WR_GetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, IGNACIO_MESSENGER_CAN_TALK) &&
                    WR_GetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, IGNACIO_MESSENGER_ARRIVES_TO_TALK) &&
                    !WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_DEN, ASSASSIN_QUEST_INTRO) )
                {

                    // Add the note to the PC's inventory
                UT_AddItemToInventory(DEN_IM_ASSASSIN_INTRO);

                // Trigger a journal entry
                WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_DEN, ASSASSIN_QUEST_INTRO, TRUE, TRUE);

                WR_SetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, IGNACIO_MESSENGER_ARRIVES_TO_TALK, FALSE);

                // Ignacio disappears
                object oMarketIgnacio = UT_GetNearestObjectByTag(oPC, DEN_CR_IGNACIO);
                WR_SetObjectActive(oMarketIgnacio, FALSE);

                // The messenger runs away forever
                // UT_ExitDestroy(oMessenger, TRUE, "den200wp_ignacio_delivery_exit", TRUE);

                 WR_SetObjectActive(oMessenger, FALSE);

                }

                break;
            }

            case IGNACIO_TALKED_TO_ABOUT_NOTE:      // DEN200_IGNACIO
                                                    // You've talked to Ignacio with the note in hand
            {
                // Remove the note from inventory
                UT_RemoveItemFromInventory(DEN_IM_ASSASSIN_INTRO);

                break;
            }

            case CESAR_OPENS_SPECIAL_STORE:         // DEN200_CESAR
                                                    // He opens his cool store
            {
                ScaleStoreEdited(oSecondStore);     // Merchant Scaling
                OpenStore(oSecondStore);

                break;
            }

            case IGNACIO_ATTACKED:                  // DEN200_IGNACIO
                                                    // The assassin is attacked
            {
                // Now lock his door
                oTarg = GetObjectByTag(DEN_IP_GNAWED_IGNACIO_DOOR);

                object  oTrap   =   UT_GetNearestObjectByTag(oPC, DEN_IP_IGNACIO_TRAP);

                SetPlaceableState(oTarg, PLC_STATE_DOOR_LOCKED);

                // Equip Ignacio's daggers
                object [] oDagger1 = GetItemsInInventory(oIgnacio, GET_ITEMS_OPTION_ALL, 0, "gen_im_wep_mel_dag_crw");
                object [] oDagger2 = GetItemsInInventory(oIgnacio, GET_ITEMS_OPTION_ALL, 0, "den200im_ignacio_dagger");

                EquipItem(oIgnacio, oDagger1[0], INVENTORY_SLOT_OFFHAND, 0);
                EquipItem(oIgnacio, oDagger2[0], INVENTORY_SLOT_MAIN, 0);

                // Now his guys attack
                UT_TeamGoesHostile(DEN_TEAM_IGNACIO);

                // He is no longer a plot giver.
                SetPlotGiver(oIgnacio, FALSE);

                break;
            }

            case IGNACIO_KILLED:                    // Master Ignacio is killed
            {
                // Now unlock his door
                oTarg = GetObjectByTag(DEN_IP_GNAWED_IGNACIO_DOOR);

                SetPlaceableState(oTarg, PLC_STATE_DOOR_UNLOCKED);

                break;
            }

            case IGNACIO_REJECTED:                  // DEN200_IGNACIO
                                                    // His offer is rejected
            {
                // Make Ignacio and his party leave
                UT_TeamExit(DEN_TEAM_IGNACIO);

                break;
            }

            case IGNACIO_QUESTS_DONE:               // DEN200_IGNACIO
                                                    // The assassin line of quests is over
            {
                // Make the special store available
                WR_SetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, CESAR_SPECIAL_STORE_AVAILABLE, TRUE, TRUE);

                // Make Ignacio and his party leave
                UT_TeamExit(DEN_TEAM_IGNACIO);

                break;
            }

            case CROW_LAST_MISSION_AVAILABLE:       // Once you pick up the last reward from the chest
            {
                UT_Talk(oIgnacio, oPC);

                break;
            }

            case CROW_LAST_MISSION_ACCEPTED:        // Once you pick up the last reward from the chest
            {
                WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_END, ASSASSIN_END_QUEST_ACCEPTED, TRUE, TRUE);

                break;
            }

        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case IGNACIO_MESSENGER_CAN_TALK:
            {
                int     bZevranFightAlly    = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_START_AMBUSH_FIGHT_ZEVRAN_ALLY);
                int     bZevranFightFlee    = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_START_AMBUSH_FIGHT_ZEVRAN_FLEE);
                int     bZevranFightEnemy   = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_START_AMBUSH_FIGHT_ZEVRAN_ENEMY);
                int     bZevranFightGone    = WR_GetPlotFlag(PLT_GENPT_ZEVRAN_MAIN, ZEVRAN_MAIN_START_AMBUSH_FIGHT_ZEVRAN_GONE);
                int     bMessengerTalked    = WR_GetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, IGNACIO_MESSENGER_ARRIVES_TO_TALK);
                int     bIgnacioTalkedTo    = WR_GetPlotFlag(PLT_DENPT_TALKED_TO, DEN_TT_IGNACIO);
                int     bZevranFirstDone    = WR_GetPlotFlag(PLT_MNP000PT_MAIN_EVENTS, ZEVRAN_ATTACK_ONE);
                int     bPick3StartNotDone  = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_ACTIVE_AND_NO_KEY);
                int     bLetterReceived     = WR_GetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, CROW_ASSASIN_LETTER_RECEIVED);

                // The messenger can talk only if Zevran has attacked the PC again
                // AND the PC has talked to Ignacio
                // AND the PC hasn't talked to the messenger already.
                if( bIgnacioTalkedTo && (bZevranFightAlly || bZevranFightEnemy ||
                    bZevranFightFlee || bZevranFightGone || bZevranFirstDone) &&
                        (!bLetterReceived) && !(bPick3StartNotDone))
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