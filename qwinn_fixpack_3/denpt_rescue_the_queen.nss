//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Events in the Rescue plot
*/
//:://////////////////////////////////////////////
//:: Created By: Craig
//:: Created On: February 20, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "cutscenes_h"
#include "campaign_h"
#include "party_h"

#include "plt_den200pt_mia"

#include "plt_denpt_rescue_the_queen"
//#include "den_constants_h"
#include "plt_gen00pt_party"
#include "plt_bec000pt_main"
#include "plt_denpt_generic"
#include "den_functions_h"
#include "plt_denpt_map"
#include "plt_denpt_irminric"
#include "plt_denpt_oswyn"
#include "plt_cod_cha_anora"
#include "plt_cod_cha_howe"

#include "plt_den500pt_generic"

#include "plt_tut_disguise"
#include "plt_den200pt_mia"
#include "camp_functions_h"
#include "sys_ambient_h"


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

    object oErlina          = UT_GetNearestCreatureByTag(oPC, DEN_CR_ERLINA);
    object oAnora           = UT_GetNearestCreatureByTag(oPC, DEN_CR_ANORA);
    object oRearGuard1      = UT_GetNearestCreatureByTag(oPC, DEN_CR_REAR_GUARD_1);
    object oRearGuard2      = UT_GetNearestCreatureByTag(oPC, DEN_CR_REAR_GUARD_2);
    object oHeadCook        = UT_GetNearestCreatureByTag(oPC, DEN_CR_HEAD_COOK);
    //object oCook1       = UT_GetNearestCreatureByTag(oPC, DEN_CR_COOK_1);
    object oDistraction     = UT_GetNearestObjectByTag(oPC, DEN_TR_RESCUE_ERLINA_DISTRACTION);
    //object oDistractionStart = UT_GetNearestObjectByTag(oPC, DEN_TR_RESCUE_ERLINA_DISTRACTION);
    object oServantsDoor    = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_SERVANTS_WING_DOOR);
    object oVaughan         = UT_GetNearestCreatureByTag(oPC, DEN_CR_VAUGHAN);
    object oVaughansDoor    = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_VAUGHANS_DOOR);
    object oIrminric        = UT_GetNearestCreatureByTag(oPC, DEN_CR_IRMINRIC);
    object oIrminricDoor    = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_IRMINRIC_DOOR);
    object oSorisDoor       = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_SORIS_DOOR);
    object oSoris           = UT_GetNearestCreatureByTag(oPC, DEN_CR_SORIS);
    object oCrazy           = UT_GetNearestCreatureByTag(oPC, DEN_CR_CRAZY_VICTIM);
    object oCrazyDoor       = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_CRAZY_DOOR);
    object oOswyn           = UT_GetNearestCreatureByTag(oPC, DEN_CR_OSWYN);
    object oRiordan         = UT_GetNearestCreatureByTag(oPC, DEN_CR_RIORDAN);
    object oAnoraTalkTrigger = UT_GetNearestObjectByTag(oPC, DEN_TR_RESCUE_ANORA_TALK);
    object oSorisLeftTrigger = UT_GetNearestObjectByTag(oPC, DEN_TR_RESCUE_SORIS_LEFT);
    object oShale           = Party_GetFollowerByTag(GEN_FL_SHALE);

    object oExitToMap       = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_TO_MAP);

    object oCM_ArlEstate        = GetObjectByTag(WML_DEN_ARL_ESTATE);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case DEN_RESCUE_EAMON_IN_STUDY:
            {
                object oEamon = UT_GetNearestObjectByTag(oPC, DEN_CR_ARL_EAMON);
                object oHouseKeeper = UT_GetNearestObjectByTag(oPC, DEN_CR_HOUSEKEEPER);

                UT_LocalJump(oEamon, DEN_WP_EAMON_UPSTAIRS);
                WR_SetObjectActive(oErlina, TRUE);
                Ambient_Start(oHouseKeeper);

                //UT_PartyStore();
                Camp_PlaceFollowersInCamp();
                DoAutoSave();

                break;
            }
            case DEN_RESCUE_MAP_OPENED:
            {
                WR_SetWorldMapLocationStatus(oCM_ArlEstate, WM_LOCATION_ACTIVE);
                WR_SetObjectActive(oErlina, FALSE);
                break;
            }
            case DEN_RESCUE_ERLINA_MOVES_TO_WAGON:
            {
                UT_QuickMoveObject(oErlina, DEN_WP_RESCUE_ERLINA_BY_WAGON, TRUE);
                break;
            }
            case DEN_RESCUE_CRAFTSMEN_INITIAL_DONE:
            {
                object[] arAmbientTriggers = GetNearestObjectByTag(oPC, DEN_TR_RESCUE_CRAFTSMEN_AMBIENT, OBJECT_TYPE_TRIGGER, 5);
                object oTrigger;
                int n;
                for (n = 0; n <= GetArraySize(arAmbientTriggers); n++)
                {
                    oTrigger = arAmbientTriggers[n];
                    if (IsObjectValid(oTrigger))
                    {
                        WR_SetObjectActive(arAmbientTriggers[n], TRUE);
                    }
                }

                if (!WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ERLINA_GOES_AROUND_ESTATE))
                {
                    UT_Talk(oErlina, oPC);
                }
                break;
            }
            case DEN_RESCUE_ERLINA_GOES_AROUND_ESTATE:
            {
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_CAMP, TRUE, TRUE);
                    WR_SetFollowerState(oShale, FOLLOWER_STATE_UNAVAILABLE);
                    WR_SetObjectActive(oShale, FALSE);
                    SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);
                    ShowPartyPickerGUI();
                }
                else
                {
                    AddNonPartyFollower(oErlina);
                }

                SetObjectInteractive(oExitToMap, FALSE);

                break;
            }
            case DEN_RESCUE_REMOVED_SHALE:
            {
                SetPartyPickerGUIStatus(PP_GUI_STATUS_READ_ONLY);
                AddNonPartyFollower(oErlina);

                break;
            }
            case DEN_RESCUE_PC_AND_ERLINA_ARRIVE_AT_GARDEN:
            {
                if (GetGameMode() == GM_COMBAT)
                {
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_REAR_GUARDS_GO_HOSTILE, TRUE, TRUE);
                }
                else
                {
                    RemoveNonPartyFollower(oErlina);
                    //SetGroupId(oErlina, GROUP_NEUTRAL);
                    // Stop patrols (despawn teams)
                    WR_SetPlotFlag(PLT_DEN500PT_GENERIC, DEN_ARL_ESTATE_PATROLLER_STOP, TRUE, TRUE);

                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_REAR_GUARDS_GO_HOSTILE, FALSE, TRUE);

                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_PC_AND_ERLINA_ARRIVE_AT_GARDEN, TRUE, FALSE);

                    UT_Talk(oErlina, oPC);
                }

                break;
            }

            case DEN_RESCUE_ERLINA_HAS_PC_EQUIP_DISGUISE_IN_GARDEN:
            {
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_DISGUISE_EQUIP_DISGUISE, TRUE, TRUE);
                UT_Talk(oErlina, oPC);
                break;
            }
            case DEN_RESCUE_PC_IN_HIDING_SPOT:
            {
                if (!IsPartyPerceivingHostiles(oPC))
                {
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_REAR_GUARDS_GO_HOSTILE, FALSE, TRUE);

                    // avoiding delay for now - moved this here from den500tr_distraction_start.nss
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ERLINA_DISTRACTION_1, TRUE, TRUE);
                    //UT_QuickMoveObject(oErlina, DEN_WP_RESCUE_ERLINA_NEAR_GUARDS, TRUE);
                }

                break;
            }
            /*    removing hiding behind the wall conversation
            case DEN_RESCUE_PC_LEAVES_HIDING:
            {
                if (!WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ERLINA_AND_GUARDS_IN_GARDEN, TRUE)
                    && !WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_REAR_GUARDS_GO_HOSTILE))
                {
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_REAR_GUARDS_GO_HOSTILE, TRUE, TRUE);
                }
                break;
            }*/
            case DEN_RESCUE_ERLINA_DISTRACTION_1:
            {
                UT_Talk(oErlina, oRearGuard1);


                // Set this flag here so that the trigger can't double fire the conversation
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_PC_LEAVING_HIDING, TRUE);

                // jump the party into place while the conversation is going on
                UT_LocalJump(oPC, DEN_WP_RESCUE_HIDING_SPOT, TRUE, FALSE, FALSE, TRUE);
                break;
            }
            case DEN_RESCUE_ERLINA_LURES_GUARDS:
            {

                UT_LocalJump(oErlina, DEN_WP_RESCUE_DISTRACTION_ERLINA, TRUE, TRUE);
                UT_LocalJump(oRearGuard1, DEN_WP_RESCUE_DISTRACTION_GUARD_1, TRUE, TRUE);
                UT_LocalJump(oRearGuard2, DEN_WP_RESCUE_DISTRACTION_GUARD_2, TRUE, TRUE);

                //UT_LocalJump(oErlina, DEN_WP_RESCUE_DIST_START_ERLINA, FALSE, TRUE, TRUE);
                //UT_LocalJump(oRearGuard1, DEN_WP_RESCUE_DIST_START_GUARD_1, FALSE, TRUE, TRUE);
                //UT_LocalJump(oRearGuard2, DEN_WP_RESCUE_DIST_START_GUARD_2, FALSE, TRUE, TRUE);
                //UT_QuickMoveObject(oErlina, DEN_WP_RESCUE_DISTRACTION_ERLINA, TRUE);
                //UT_QuickMoveObject(oRearGuard1, DEN_WP_RESCUE_DISTRACTION_GUARD_1, FALSE);
                //UT_QuickMoveObject(oRearGuard2, DEN_WP_RESCUE_DISTRACTION_GUARD_2, FALSE);

                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ERLINA_IN_GARDEN, TRUE);
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_GUARD_1_IN_GARDEN, TRUE);
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_GUARD_2_IN_GARDEN, TRUE);
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ERLINA_DISTRACTION_2, TRUE);

                //removing hiding behind the wall conversation
                //UT_Talk(oPC, oPC, DEN_CONV_LEAVE_HIDING);

                break;
            }
            case DEN_RESCUE_REAR_GUARDS_GO_HOSTILE:
            {
                if (nValue == 1)
                {
                    UT_TeamGoesHostile(DEN_TEAM_RESCUE_REAR_GUARDS);
                }
                else //if nValue == 0
                {
                    UT_TeamGoesHostile(DEN_TEAM_RESCUE_REAR_GUARDS, FALSE);
                }
                break;
            }
            case DEN_RESCUE_REAR_GUARDS_DEAD:
            {
                if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ERLINA_REJOINS))
                {
                    RemoveNonPartyFollower(oErlina);
                    ShowAsAllyOnMap(oErlina, FALSE);
                }
                else
                {
                    ShowAsAllyOnMap(oErlina, TRUE);
                    AddNonPartyFollower(oErlina);
                    WR_SetObjectActive(oDistraction, FALSE);
                }

                break;
            }
            case DEN_RESCUE_ERLINA_REJOINS:
            {
                WR_SetObjectActive(oErlina, TRUE);
                ShowAsAllyOnMap(oErlina, FALSE);
                //RemoveNonPartyFollower(oErlina);
                UT_Talk(oErlina, oPC);
                break;
            }
            case DEN_RESCUE_DISGUISE_EQUIP_DISGUISE:
            {
                WR_SetPlotFlag(PLT_TUT_DISGUISE, TUT_DISGUISE_0, TRUE, TRUE);
                Rescue_TeamsGoHostile(FALSE);
                DEN_CreateDisguises();

                break;
            }
            case DEN_RESCUE_DISGUISE_REMOVE_DISGUISE:
            {
                Log_Trace(LOG_CHANNEL_TEMP, "DEN_RESCUE_DISGUISE_REMOVE_DISGUISE", "firing remove disguise");
                DEN_RemoveDisguises();
                Rescue_TeamsGoHostile(TRUE);


                break;
            }
            case DEN_RESCUE_ERLINA_ENTERS_KITCHEN:
            {
                if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_DISGUISE_WILL_EQUIP_DISGUISE))
                {
                    WR_SetPlotFlag( PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_DISGUISE_WILL_EQUIP_DISGUISE, FALSE);
                    WR_SetPlotFlag( PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_DISGUISE_EQUIP_DISGUISE, TRUE, TRUE);
                }
                AddNonPartyFollower(oErlina);
                break;
            }

            case DEN_RESCUE_COOKS_FLEE:
            {
                object[] arTalkTriggers = GetNearestObjectByTag(oPC, DEN_TR_RESCUE_COOKS_TALK, OBJECT_TYPE_TRIGGER, 5);
                object oTrigger;
                int n;
                for (n = 0; n < GetArraySize(arTalkTriggers); n++)
                {
                    oTrigger = arTalkTriggers[n];
                    if (IsObjectValid(oTrigger))
                    {
                        WR_SetObjectActive(arTalkTriggers[n], FALSE);
                    }
                }

                UT_TeamExit(DEN_TEAM_RESCUE_COOKS, TRUE, DEN_WP_RESCUE_REAR_EXIT);
                UT_TeamMove(DEN_TEAM_RESCUE_DINING_ROOM, DEN_WP_RESCUE_ERLINA_EXITS_KITCHEN, TRUE, 4.0);
                break;
            }
            case DEN_RESCUE_WALK_GROUP_1_WALKS:
            {
                object oGuard1 = UT_GetNearestCreatureByTag(oPC, DEN_CR_WALKER_1_1);
                object oGuard2 = UT_GetNearestCreatureByTag(oPC, DEN_CR_WALKER_1_2);
                UT_QuickMoveObject(oGuard1, "3", FALSE, TRUE);
                UT_QuickMoveObject(oGuard2, "3", FALSE, TRUE);

                UT_Talk(oGuard1, oGuard2);

                break;
            }
            case DEN_RESCUE_WALK_GROUP_2_WALKS:
            {
                object oGuard1 = UT_GetNearestCreatureByTag(oPC, DEN_CR_WALKER_2_1);
                object oGuard2 = UT_GetNearestCreatureByTag(oPC, DEN_CR_WALKER_2_2);
                UT_QuickMoveObject(oGuard1, "3", FALSE, TRUE);
                UT_QuickMoveObject(oGuard2, "3", FALSE, TRUE);
                UT_QuickMove(DEN_CR_WALKER_2_3, "3", FALSE, TRUE);

                UT_Talk(oGuard1, oGuard2);
                break;
            }
            case DEN_RESCUE_CAPTAIN_GOES_HOSTILE:
            {
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_DISGUISE_REMOVE_DISGUISE, TRUE, TRUE);

                break;
            }
            case DEN_RESCUE_GUARD_ROOM_GOES_HOSTILE:
            {
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_DISGUISE_REMOVE_DISGUISE, TRUE, TRUE);

                break;
            }
            case DEN_RESCUE_ANORA_FOUND:
            {
                ShowAsAllyOnMap(oErlina, FALSE);
                RemoveNonPartyFollower(oErlina);
                //SetGroupId(oErlina, GROUP_NEUTRAL);
                UT_Talk(oAnora, oPC);
                //UT_QuickMove(DEN_CR_ERLINA, DEN_WP_RESCUE_ERLINA_AT_QUEEN, TRUE, TRUE, TRUE, TRUE);
                break;
            }
            case DEN_RESCUE_ANORA_TALK_TRIGGER_REMOVED:
            {
                WR_SetObjectActive(oAnoraTalkTrigger, FALSE);
                break;
            }
            case DEN_RESCUE_MAKEOUT_GUARD_GOES_HOSTILE:
            {
                object oServant = UT_GetNearestCreatureByTag(oPC, DEN_CR_MAKEOUT_SERVANT);
                UT_ExitDestroy(oServant, TRUE);

                UT_TeamGoesHostile(DEN_TEAM_RESCUE_MAKEOUT_GUARD);

                if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_PARTY_IS_DISGUISED, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_DISGUISE_REMOVE_DISGUISE, TRUE, TRUE);
                }
                break;
            }
            case DEN_RESCUE_RIORDAN_INTRO:
            {
                // Cutscene is now embedded in the dialog (to avoid a rough
                // transition).

                UT_TeamAppears(DEN_TEAM_RESCUE_RIORDAN);
                UT_Talk(oRiordan, oPC);
                break;
            }
            case DEN_RESCUE_RIORDAN_INTRO_CUTSCENE_DONE:
            {
                object oJailDoor = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_RIORDAN_DOOR);
                SetPlaceableState(oJailDoor, PLC_STATE_DOOR_OPEN_2);
                break;
            }
            case DEN_RESCUE_RIORDAN_RESCUED:
            {
                object oJailor = UT_GetNearestCreatureByTag(oPC, DEN_CR_RIORDAN_JAILOR);
                WR_SetObjectActive(oJailor, FALSE);

                object oJailDoor = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_RIORDAN_DOOR);
                SetPlaceableState(oJailDoor, PLC_STATE_DOOR_OPEN_2);
                WR_SetObjectActive(oRiordan, FALSE);
                break;
            }
            case DEN_RESCUE_GATEKEEPER_GOES_HOSTILE:
            {
                if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_PARTY_IS_DISGUISED, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_DISGUISE_REMOVE_DISGUISE, TRUE, TRUE);
                }
                break;
            }
            case DEN_RESCUE_OSWYN_SAVED:
            {
                WR_SetObjectActive(oOswyn, FALSE);
                WR_SetPlotFlag(PLT_DENPT_OSWYN, DEN_OSWYN_FREED, TRUE);
                break;
            } /*  setting journal plot flag in conversation instead
            case DEN_RESCUE_OSWYN_PC_SPOKE_TO_SIGHARD:
            {
                WR_SetPlotFlag(PLT_DENPT_OSWYN, DEN_OSWYN_ASKED_FOR_NO_REWARD, TRUE, TRUE);
                break;
            }   */
            case DEN_RESCUE_OSWYN_REWARD_LARGE:
            case DEN_RESCUE_OSWYN_REWARD_NORMAL:
            {
                WR_SetPlotFlag(PLT_DENPT_OSWYN, DEN_OSWYN_REWARD_GIVEN, TRUE, TRUE);
                break;
            }
            case DEN_RESCUE_CRAZY_KILLED:
            {
                // If the PC has the chanter's MIA quest then update it, otherwise turn the chanter's board
                // quest off (since it can't be completed any more).
                if ( WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_ACCEPTED) )
                {
                    WR_SetPlotFlag(PLT_DEN200PT_MIA, MIA_REXEL_LEFT_TO_ROT, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_DEN200PT_MIA, MIA_CHANTER_BOARD, FALSE, TRUE);
                }

                KillCreature(oCrazy);
                break;
            }
            case DEN_RESCUE_CRAZY_RELEASED:
            {
                // If the PC has the chanter's MIA quest then update it, otherwise turn the chanter's board
                // quest off.
                if ( WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_ACCEPTED) )
                {
                    WR_SetPlotFlag(PLT_DEN200PT_MIA, MIA_REXEL_FOUND, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_DEN200PT_MIA, MIA_CHANTER_BOARD, FALSE, TRUE);
                }

                // He will wander around.
                Ambient_Start(oCrazy);

                break;
            }
            case DEN_RESCUE_CRAZY_LEFT_BEHIND:
            {
                // lock the door and keep it from opening again
                SetPlaceableState(oCrazyDoor, PLC_STATE_DOOR_LOCKED);
                SetLocalInt(oCrazyDoor, PLC_DO_ONCE_A, TRUE);
                break;
            }
            case DEN_RESCUE_FREED_SORRIS:
            {
                //TO DO: consider having the PC use the door or rerouting dialog
                SetPlaceableState(oSorisDoor, PLC_STATE_DOOR_OPEN);
                WR_SetPlotFlag(PLT_DENPT_GENERIC, DEN_GENERIC_TALK_DOOR_OPENED, TRUE);
                WR_SetObjectActive(oSorisLeftTrigger, FALSE);
                UT_Talk(oSoris, oPC);
                break;
            }
            case DEN_RESCUE_SORIS_LEAVES:
            {
                // Qwinn:  Adding set here of FREED_SORIS because that's what's checked in epilogue boon
                // Don't want to run the script though.
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN,DEN_RESCUE_FREED_SORRIS,TRUE,FALSE);
                WR_SetObjectActive(oSoris, FALSE);
                break;
            }
            case DEN_RESCUE_SORIS_HATES_PC:
            {
                // lock the door and keep it from opening again
                SetPlaceableState(oSorisDoor, PLC_STATE_DOOR_LOCKED);
                SetLocalInt(oSorisDoor, PLC_DO_ONCE_A, TRUE);
                break;
            }
            case DEN_RESCUE_HOWE_ATTACKS:
            {
                // replaced with autosave trigger before conversation
                //DoAutoSave();
                UT_TeamGoesHostile(DEN_TEAM_RESCUE_HOWE);
                break;
            }
            case DEN_RESCUE_HOWE_TEAM_DEAD:
            {
                CS_LoadCutscene(CUTSCENE_DEN_HOWES_DEATH);

                WR_SetPlotFlag(PLT_COD_CHA_HOWE, COD_CHA_HOWE_RESCUE, TRUE, TRUE);
                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_HOWE_KILLED, TRUE, FALSE);

                if (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE))
                {
                    //ensure proper journal tracking
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_HOWE_KILLED_BY_HUMAN_NOBLE, TRUE, FALSE);
                }
                
                // Qwinn:  Try to turn Howe flag off if have key
                if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_HOWE_KEY_ACQUIRED))
                {
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_HOWE_KEY_ACQUIRED, FALSE, FALSE);
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_HOWE_KEY_ACQUIRED, TRUE, FALSE);
                }

                break;
            }
            case DEN_RESCUE_HOWE_KEY_ACQUIRED:
            {
                Ambient_Start(oVaughan, AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 89);

                break;
            }

            case DEN_RESCUE_IRMINRIC_GAVE_SIGNET_RING:
            {
                WR_SetPlotFlag(PLT_DENPT_IRMINRIC, DEN_IRMINRIC_GAVE_RING, TRUE);
                UT_AddItemToInventory(DEN_IM_IRMINRIC_SIGNET_RING);
                break;
            }
            case DEN_RESCUE_IRMINRIC_REWARD:
            {
                WR_SetPlotFlag(PLT_DENPT_IRMINRIC, DEN_IRMINRIC_REWARD_GIVEN, TRUE);
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_6);
                break;
            }
            case DEN_RESCUE_IRMINRIC_OFFER_REFUSED:
            {
                WR_SetPlotFlag(PLT_DENPT_IRMINRIC, DEN_IRMINRIC_OFFER_REFUSED, TRUE);
                break;
            }
            case DEN_RESCUE_IRMINRIC_PROOF_GIVEN:
            {
                UT_RemoveItemFromInventory(DEN_IM_IRMINRIC_SIGNET_RING);
                break;
            }
            case DEN_RESCUE_VAUGHAN_FREED:
            {
                SetPlaceableState(oVaughansDoor, PLC_STATE_DOOR_OPEN);
                WR_SetObjectActive(oVaughan, FALSE);
                break;
            }
            case DEN_RESCUE_VAUGHAN_KILLED:
            {
                KillCreature(oVaughan, oPC);
                break;
            }
            case DEN_RESCUE_VAUGHAN_GIVES_KEY:
            {
                UT_AddItemToInventory(DEN_IM_VAUGHANS_KEY, 1);
                break;
            }
            case DEN_RESCUE_VAUGHAN_LEFT_TO_ROT:
            {
                // lock the door and keep it from opening again
                SetPlaceableState(oVaughansDoor, PLC_STATE_DOOR_LOCKED);
                SetLocalInt(oVaughansDoor, PLC_DO_ONCE_A, TRUE);

                Ambient_Start(oVaughan, AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 89);
                break;
            }
            case DEN_RESCUE_ANORA_FREED_HANDLE_REWARDS:
            {
                ShowAsAllyOnMap(oErlina, TRUE);
                ShowAsAllyOnMap(oAnora, TRUE);

                AddNonPartyFollower(oAnora);
                AddNonPartyFollower(oErlina);
                SetObjectInteractive(oErlina, TRUE);

                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ALISTAIR_PRESENT_WHEN_ANORA_FREED, TRUE);
                }

                UT_TeamAppears(DEN_TEAM_RESCUE_ARMORY, FALSE);
                UT_TeamAppears(DEN_TEAM_RESCUE_BARRACKS_1, FALSE);
                UT_TeamAppears(DEN_TEAM_RESCUE_BARRACKS_2, FALSE);
                UT_TeamAppears(DEN_TEAM_RESCUE_GUARD_ROOM, FALSE);
                UT_TeamAppears(DEN_TEAM_RESCUE_GUARD_ROOM, FALSE);

                UT_TeamAppears(DEN_TEAM_CAPTURED_CAUTHRIEN);

                SetPlaceableState(oServantsDoor, PLC_STATE_DOOR_LOCKED);

                WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ANORA_FREED, TRUE, FALSE);
                if (!WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_PEACEFUL_APPROACH_FAILED))
                {
                    //ensure proper reward tracking, script must be called
                    WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ANORA_RESCUED_WITHOUT_UNNECESSARY_BLOODSHED, TRUE, TRUE);
                }

                DoAutoSave();
                break;
            }
            case DEN_RESCUE_CAUTHRIEN_SPEAKS:
            {
                SetPlaceableState(oServantsDoor, PLC_STATE_DOOR_UNLOCKED);
                ShowAsAllyOnMap(oErlina, FALSE);
                ShowAsAllyOnMap(oAnora, FALSE);
                RemoveNonPartyFollower(oAnora);
                RemoveNonPartyFollower(oErlina);
                WR_SetWorldMapLocationStatus(oCM_ArlEstate, WM_LOCATION_COMPLETE);

                WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_RESCUE, TRUE, TRUE);


                // Close off the MIA subplot, it can't be completed any more
                if ( !WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_ACCEPTED) )
                    WR_SetPlotFlag(PLT_DEN200PT_MIA, MIA_CHANTER_BOARD, FALSE, FALSE);

                // If the MIA quest was accepted but you didn't find him, close the quest
                if ( WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_ACCEPTED) &&
                    !WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_REXEL_FOUND) &&
                    !WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_REXEL_LEFT_TO_ROT) )
                {
                    WR_SetPlotFlag(PLT_DEN200PT_MIA, MIA_QUEST_FAILED, TRUE, TRUE);
                }


                break;
            }
            case DEN_RESCUE_QUEST_COMPLETE:
            {
                UT_RemoveItemFromInventory(DEN_IM_RESCUE_HOWE_KEY);
                UT_RemoveItemFromInventory(DEN_IM_LOWER_PRISON_KEY);
                UT_RemoveItemFromInventory(DEN_IM_VAUGHANS_KEY);


                WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_POSTRESCUE, TRUE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_2);

                break;
            }

            // Qwinn: Remove Grey Warden documents from PC inventory after giving to Riordan
            case DEN_RESCUE_RIORDAN_TALKED_ABOUT_VAULT:
            {
                RemoveItemsByTag(oPC,"den511im_riordan_papers");
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case DEN_RESCUE_PC_IS_DISGUISED:
            case DEN_RESCUE_PARTY_IS_DISGUISED:
            {
                // Disguise can't be equipped after it has been removed
                nResult = WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_DISGUISE_EQUIP_DISGUISE)
                           && !WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_DISGUISE_REMOVE_DISGUISE);
                break;
            }
            case DEN_RESCUE_NOBLE_NOT_CONFRONTED_HOWE:
            {
                if (!WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_HOWE_CONFRONTED)
                    && WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case DEN_RESCUE_PC_HAS_KEY_TO_LOWER_PRISON:
            {
                if (UT_CountItemInInventory(DEN_IM_LOWER_PRISON_KEY) >= 1)
                {
                    nResult = TRUE;
                }
                break;
            }
            case DEN_RESCUE_ERLINA_AND_GUARDS_IN_GARDEN:
            {
                if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_ERLINA_IN_GARDEN)
                    && WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_GUARD_1_IN_GARDEN)
                    && WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_GUARD_2_IN_GARDEN)
                    && !WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_REAR_GUARDS_DEAD))
                {
                    nResult = TRUE;
                }

                break;
            }
            case DEN_RESCUE_PC_HAS_HALF_VAUGHAN_MONEY_FOR_SORIS:
            {
                if (WR_GetPlotFlag(PLT_BEC000PT_MAIN, BEC_MAIN_BRIBE_HIDDEN)
                    && UT_MoneyCheck(oPC, 0, 0, DEN_MONEY_HALF_VAUGHAN_TREASURE_FOR_SORIS_GOLD))
                {
                    nResult = TRUE;
                }
                break;
            }
            case DEN_RESCUE_PC_HAS_MONEY_FOR_SORIS:
            {
                if (!WR_GetPlotFlag(PLT_BEC000PT_MAIN, BEC_MAIN_BRIBE_ACCEPTED)
                    && UT_MoneyCheck(oPC, 0, 0, DEN_MONEY_FOR_SORIS_GOLD))
                {
                    nResult = TRUE;
                }
                break;
            }
            case DEN_RESCUE_PC_NOBLE_OR_CITYELF_HEARD_ABOUT_PURGE:
            {
                int bCityElfHeardAboutPurge = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY)
                                              && WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_MASSACRE);
                int bNoble = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE);

                nResult = bCityElfHeardAboutPurge || bNoble;


                break;
            }
            case DEN_RESCUE_RIORDAN_PC_CAN_ASK_ABOUT_PAPERS:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_RIORDAN_PC_HAS_PAPERS)
                          && !WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_RIORDAN_TALKED_ABOUT_VAULT);
                break;
            }


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}