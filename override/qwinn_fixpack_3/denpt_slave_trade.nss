//::///////////////////////////////////////////////
//:: denpt_slave_trade
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Craig
//:: Created On: January 21, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "campaign_h"

#include "plt_denpt_slave_trade"
#include "plt_denpt_rescue_the_queen"
#include "plt_denpt_talked_to"
#include "plt_bec100pt_soris"
#include "plt_gen00pt_class_race_gend"
#include "plt_cod_cha_valendrian"
#include "cai_h"

#include "den_constants_h"
#include "sys_audio_h"

//void DEN_WrapUpSlaveTrade(


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

    object oTevinterGuard1 = UT_GetNearestCreatureByTag(oPC, DEN_CR_TEVINTER_GUARD_1);
    object oTevinterGuard2 = UT_GetNearestCreatureByTag(oPC, DEN_CR_TEVINTER_GUARD_2);
    object oAlleyGuard  = UT_GetNearestCreatureByTag(oPC, DEN_CR_ALLEY_GUARD);
    object oShianni     = UT_GetNearestCreatureByTag(oPC, DEN_CR_SHIANNI);
    object oAlleyDoor   = UT_GetNearestObjectByTag(oPC, DEN_IP_FROM_APARTMENT_BACK);
    object oHospiceSlaveTrigger = UT_GetNearestObjectByTag(oPC, DEN_TR_HOSPICE_SLAVES_TALK);
    object oCaladrius   = UT_GetNearestCreatureByTag(oPC, DEN_CR_CALADRIUS);
    object oValendrian  = UT_GetNearestCreatureByTag(oPC, DEN_CR_VALENDRIAN);
    object oFather      = UT_GetNearestCreatureByTag(oPC, DEN_CR_CITY_ELF_FATHER);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case DEN_SLAVE_TRADE_PC_QUARANTINED:
            {
                // take the player into the hospice
                UT_DoAreaTransition(DEN_AR_HOSPICE, DEN_WP_HOSPICE_FRONT_ENTRANCE);

                UT_PartyStore(TRUE);

                WR_SetObjectActive(oTevinterGuard1, FALSE);
                WR_SetObjectActive(oTevinterGuard2, FALSE);
                SetTeamId(oTevinterGuard1, -1);
                SetTeamId(oTevinterGuard2, -1);
                break;
            }
            case DEN_SLAVE_TRADE_SHIANNI_PIPES_UP:
            {
                if (!WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_SHIANNI_OFFERED_ALTERNATIVE))
                {
                    UT_Talk(oShianni, oPC);
                }
                break;
            }
            case DEN_SLAVE_TRADE_PC_HEARD_ABOUT_VALENDRIAN:
            {
                WR_SetPlotFlag(PLT_COD_CHA_VALENDRIAN, COD_CHA_VALENDRIAN_MAIN, TRUE);
                break;
            }
            case DEN_SLAVE_TRADE_PC_ATTACKED_VERAS:
            {
                // No more crowd sound
                AudioTriggerPlotEvent(46);

                DoAutoSave();

                // This should only have positioning, deactivation, and hostility logic
                UT_QuickMove(DEN_CR_SHIANNI, "0", TRUE, FALSE, FALSE, TRUE);
                if (GetObjectActive(oAlleyGuard))
                {
                    UT_TeamMerge(DEN_TEAM_ALIENAGE_HOSPICE_SIDE_GUARD, DEN_TEAM_ALIENAGE_HOSPICE_FRONT_GUARD);
                }
                UT_TeamJump(DEN_TEAM_ALIENAGE_ELF_CROWD_EXPLODERS, "1", TRUE, TRUE);
                //UT_TeamGoesHostile(DEN_TEAM_ALIENAGE_ELF_CROWD_EXPLODERS, TRUE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_ELF_CROWD, FALSE);

                SetGroupHostility(DEN_GROUP_WALKING_BOMBS, GROUP_HOSTILE, TRUE);
                SetGroupHostility(DEN_GROUP_WALKING_BOMBS, GROUP_PC, TRUE);
                SetGroupHostility(DEN_GROUP_WALKING_BOMBS, GROUP_NEUTRAL, FALSE);

                UT_TeamGoesHostile(DEN_TEAM_ALIENAGE_HOSPICE_FRONT_GUARD, TRUE);
                break;
            }
            case DEN_SLAVE_TRADE_PC_KILLED_VERAS:
            {
                Rubber_GoHome(oShianni);
                UT_TeamExit(DEN_TEAM_ALIENAGE_ELF_CROWD_EXPLODERS);
                break;
            }
            case DEN_SLAVE_TRADE_SIDEGUARD_ATTACKED:
            {
                UT_TeamGoesHostile(DEN_TEAM_ALIENAGE_HOSPICE_SIDE_GUARD, TRUE);
                break;
            }
            case DEN_SLAVE_TRADE_SIDEGUARD_BRIBED:
            {
                if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_SIDEGUARD_BRIBE_ATTEMPTED))
                {
                    UT_MoneyTakeFromObject(oPC, 0, 0, DEN_MONEY_SIDEGUARD_BRIBE_LARGE_GOLD);
                }
                else
                {
                    UT_MoneyTakeFromObject(oPC, 0, 0, DEN_MONEY_SIDEGUARD_BRIBE_SMALL_GOLD);
                }
                UT_AddItemToInventory(DEN_IM_HOSPICE_KEY);

                UT_TeamAppears(DEN_TEAM_ALIENAGE_HOSPICE_SIDE_GUARD, FALSE);
                break;
            }
            case DEN_SLAVE_TRADE_PC_ENTERED_HOSPICE:
            {
                object oSupervisor = UT_GetNearestCreatureByTag(oPC, DEN_CR_HOSPICE_SUPERVISOR);
                if (!WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ATTACKED_HOSPICE_INTERIOR_GUARDS))
                {
                    if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_QUARANTINED))
                    {
                        CAI_SetCustomAI(oSupervisor, CAI_DISABLED);
                        UT_TeamAppears(DEN_TEAM_ALIENAGE_HOSPICE_FRONT_GUARD, TRUE);
                    }
                    else
                    {
                        WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ATTACKED_HOSPICE_INTERIOR_GUARDS, TRUE, TRUE);
                    }
                }
                break;
            }
            case DEN_SLAVE_TRADE_PC_ATTACKED_HOSPICE_INTERIOR_GUARDS:
            {
                if(WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_QUARANTINED))
                {
                    UT_TeamGoesHostile(DEN_TEAM_ALIENAGE_HOSPICE_FRONT_GUARD, TRUE);
                }
                UT_TeamGoesHostile(DEN_TEAM_ALIENAGE_HOSPICE_INTERIOR_GUARDS, TRUE);
                break;
            }

            case DEN_SLAVE_TRADE_HOSPICE_SLAVES_LEAVE:
            {
                UT_TeamAppears(DEN_TEAM_ALIENAGE_HOSPICE_SLAVES, FALSE);
                WR_SetObjectActive(oHospiceSlaveTrigger, FALSE);
                break;
            }
            case DEN_SLAVE_TRADE_SCARED_ELF_BRIBED:
            {
                UT_MoneyTakeFromObject(oPC, 0, 0, DEN_MONEY_SCARED_ELF_BRIBE_GOLD);
                break;
            }
            case DEN_SLAVE_TRADE_ALLEY_GUARD_AMBUSHES:
            {
                DoAutoSave();
                UT_TeamGoesHostile(DEN_TEAM_ALIENAGE_ALLEY_GUARD_AMBUSH, TRUE);

                break;
            }
            case DEN_SLAVE_TRADE_ALLEY_GUARD_AMBUSH_DIED:
            {
                //DoAutoSave();
                break;
            }
            case DEN_SLAVE_TRADE_DEVERA_PERSUADED_TO_LEAVE:
            {
                UT_TeamAppears(DEN_TEAM_ALIENAGE_DEVERAS_GROUP, FALSE);
                break;
            }
            case DEN_SLAVE_TRADE_DEVERA_ESCORTS_TO_CALADRIUS:
            {
                object oDevera = UT_GetNearestCreatureByTag(oPC, DEN_CR_DEVERA);
                SetTeamId(oDevera, DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_2);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_DEVERAS_GROUP, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_1, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_COMPOUND_GUARDS, FALSE);

                UT_LocalJump(oDevera, DEN_WP_SLAVE_DEVERA);
                UT_LocalJump(oCaladrius, DEN_WP_SLAVE_CALADRIUS);
                UT_LocalJump(oPC, DEN_WP_SLAVE_COMPOUND_PLAYER, TRUE, FALSE, FALSE, TRUE);
                UT_Talk(oCaladrius, oPC);

                object[] arrDoors = UT_GetTeam(DEN_TEAM_ALIENAGE_CALADRIUS_DOORS, OBJECT_TYPE_PLACEABLE);
                int n;
                for (n = 0; n < GetArraySize(arrDoors); n++)
                {
                    SetPlaceableState(arrDoors[n], PLC_STATE_DOOR_OPEN);
                    SetLocalInt(arrDoors[n], PLC_DO_ONCE_A, TRUE);
                }
                break;
            }
            case DEN_SLAVE_TRADE_DEVERA_ATTACKS:
            {
                DoAutoSave();
                UT_QuickMove(DEN_CR_DEVERA, "0", TRUE, FALSE, TRUE, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_ALIENAGE_DEVERAS_GROUP, TRUE);
                break;
            }
            case DEN_SLAVE_TRADE_DEVERA_SET_INACTIVE:
            {
                object oDevera = UT_GetNearestObjectByTag(oPC, DEN_CR_DEVERA);
                if (IsDeadOrDying(oDevera))
                {
                    WR_SetObjectActive(oDevera, FALSE);
                }

                break;
            }
            case DEN_SLAVE_TRADE_CALADRIUS_FIRST_WAVE_FIGHT:
            {
                //disable Devera if she is dead so conversation system doesn't revive her
                object oDevera = UT_GetNearestCreatureByTag(oPC, DEN_CR_DEVERA);
                object oCaladriusDoor = UT_GetNearestObjectByTag(oPC, DEN_IP_CALADRIUS_DOOR);
                if (IsDeadOrDying(oDevera))
                {
                    WR_SetObjectActive(oDevera, FALSE);
                }

                UT_TeamGoesHostile(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_1, TRUE);
                UT_LocalJump(oCaladrius, DEN_WP_SLAVE_CALADRIUS);

                SetPlaceableState(oCaladriusDoor, PLC_STATE_DOOR_UNLOCKED);

                break;
            }
            case DEN_SLAVE_TRADE_CALADRIUS_FIRST_WAVE_DEAD:
            {
                break;
            }
            case DEN_SLAVE_TRADE_PC_ATTACKED_CALADRIUS:
            {
                // making doubly sure these teams are deactivated... (conversation system seems to prevent this in certain configurations)
                if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_DEVERA_ESCORTS_TO_CALADRIUS))
                {
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_DEVERAS_GROUP, FALSE);
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_1, FALSE);
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_COMPOUND_GUARDS, FALSE);

                    UT_QuickMove(DEN_CR_DEVERA, "1", TRUE, FALSE, TRUE, TRUE);
                }

                // Disabled, since it seems to cause problems
                //DoAutoSave();


                UT_TeamGoesHostile(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_2, TRUE);
                UT_SetSurrenderFlag(oCaladrius, TRUE, PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_CALADRIUS_GIVES_UP, TRUE);

                // manual perception
                // EV 152256 -- yaron
                object [] arEnemies = GetTeam(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_2);
                int nSize = GetArraySize(arEnemies);
                int i;
                int j;
                object oCurrent;
                object [] arParty = GetPartyList();
                int nPartySize = GetArraySize(arParty);
                for(i = 0; i < nSize; i++)
                {
                    oCurrent = arEnemies[i];
                    for(j = 0; j < nPartySize; j++)
                    {
                        if(GetFollowerState(arParty[j]) == FOLLOWER_STATE_ACTIVE)
                        {
                            WR_TriggerPerception(oCurrent, arParty[j]);
                            WR_TriggerPerception(arParty[j], oCurrent);
                        }
                    }
                }

                break;
            }
            case DEN_SLAVE_TRADE_CALADRIUS_GUARDS_MOVE:
            {
                UT_SetTeamStationary(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_2, AI_STATIONARY_STATE_DISABLED);
                break;
            }

            case DEN_SLAVE_TRADE_CALADRIUS_GIVES_UP:
            {
                CAI_SetCustomAI(oCaladrius, CAI_DISABLED);
                break;
            }
            case DEN_SLAVE_TRADE_CALADRIUS_SACRIFICED_SLAVE:
            {
                break;
            }

            case DEN_SLAVE_TRADE_PC_ATTACKED_CALADRIUS_AGAIN:
            {
                float fHealAmount = 0.1 * GetMaxHealth(oCaladrius);
                UT_SetSurrenderFlag(oCaladrius, FALSE);
                HealCreature(oCaladrius, TRUE, fHealAmount, TRUE);

                HealPartyMembers(TRUE, TRUE);

                UT_TeamGoesHostile(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_2, TRUE);
                break;
            }
            case DEN_SLAVE_TRADE_PC_KILLED_CALADRIUS:
            {
                UT_SetTeamInteractive(DEN_TEAM_ALIENAGE_CALADRIUS_CHEST, TRUE, OBJECT_TYPE_PLACEABLE);

                if (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY))
                {
                    UT_Talk(oFather, oPC);
                }
                else
                {
                    UT_Talk(oValendrian, oPC);
                }
                break;
            }
            case DEN_SLAVE_TRADE_CALADRIUS_BRIBED:
            {
                UT_MoneyTakeFromObject(oPC, 0, 0, DEN_MONEY_CALADRIUS_BRIBE_GOLD);
                UT_AddItemToInventory(DEN_IM_SLAVER_DOCUMENTS);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_2, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_COMPOUND_SLAVES, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_CHEST, FALSE, OBJECT_TYPE_PLACEABLE);

                // making doubly sure these teams are deactivated... (conversation system seems to prevent this in certain configurations)
                if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_DEVERA_ESCORTS_TO_CALADRIUS))
                {
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_DEVERAS_GROUP, FALSE);
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_1, FALSE);
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_COMPOUND_GUARDS, FALSE);
                }
                break;
            }
            case DEN_SLAVE_TRADE_CALADRIUS_LEAVES_WITH_SLAVES_AND_MONEY:
            {
                // making doubly sure these teams are deactivated... (conversation system seems to prevent this in certain configurations)
                if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_DEVERA_ESCORTS_TO_CALADRIUS))
                {
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_DEVERAS_GROUP, FALSE);
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_1, FALSE);
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_COMPOUND_GUARDS, FALSE);
                }

                UT_AddItemToInventory(DEN_IM_SLAVER_DOCUMENTS);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_2, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_COMPOUND_SLAVES, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_CHEST, FALSE, OBJECT_TYPE_PLACEABLE);
                WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_LEFT_SLAVES_WITH_CALADRIUS, TRUE, TRUE);
                break;
            }

            case DEN_SLAVE_TRADE_CALADRIUS_LEAVES_PROFITS:
            {
                // making doubly sure these teams are deactivated... (conversation system seems to prevent this in certain configurations)
                if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_DEVERA_ESCORTS_TO_CALADRIUS))
                {
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_DEVERAS_GROUP, FALSE);
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_1, FALSE);
                    UT_TeamAppears(DEN_TEAM_ALIENAGE_COMPOUND_GUARDS, FALSE);
                }
                UT_AddItemToInventory(DEN_IM_SLAVER_DOCUMENTS);
                UT_SetTeamInteractive(DEN_TEAM_ALIENAGE_CALADRIUS_CHEST, TRUE, OBJECT_TYPE_PLACEABLE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_2, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_COMPOUND_SLAVES, FALSE);

                WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_LEFT_SLAVES_WITH_CALADRIUS, TRUE, TRUE);
                break;
            }
            case DEN_SLAVE_TRADE_CALADRIUS_GIVES_PLAYER_CON_BOOST:
            {
                UT_AddItemToInventory(DEN_IM_SLAVER_DOCUMENTS);
                UT_SetTeamInteractive(DEN_TEAM_ALIENAGE_CALADRIUS_CHEST, TRUE, OBJECT_TYPE_PLACEABLE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_2, FALSE);
                UT_KillTeam(DEN_TEAM_ALIENAGE_COMPOUND_SLAVES, oCaladrius);

                // used with Mike's permission from EV#140467
                IncreaseAttributeScore(oPC, PROPERTY_ATTRIBUTE_CONSTITUTION);

                // Flag name doesn't exactly match the situation, but this is needed in many places.
                WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_LEFT_SLAVES_WITH_CALADRIUS, TRUE, TRUE);

                break;
            }
            case DEN_SLAVE_TRADE_CALADRIUS_LEAVES_DEFEATED:
            {
                UT_AddItemToInventory(DEN_IM_SLAVER_DOCUMENTS);
                UT_SetTeamInteractive(DEN_TEAM_ALIENAGE_CALADRIUS_CHEST, TRUE, OBJECT_TYPE_PLACEABLE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_CALADRIUS_WAVE_2, FALSE);

                if (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY))
                {
                    UT_Talk(oFather, oPC);
                }
                else
                {
                    UT_Talk(oValendrian, oPC);
                }
                break;
            }
            case DEN_SLAVE_TRADE_QUEST_COMPLETE:
            {
                UT_RemoveItemFromInventory(DEN_IM_APARTMENT_KEY);
                UT_RemoveItemFromInventory(DEN_IM_HOSPICE_KEY, 10);
                UT_RemoveItemFromInventory(DEN_IM_SLAVER_NOTE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_3);

                break;
            }
            case DEN_SLAVE_TRADE_PC_FREED_SLAVES_IN_COMPOUND:
            {
                if (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY))
                {
                    WR_SetPlotFlag(PLT_COD_CHA_VALENDRIAN, COD_CHA_VALENDRIAN_POST_LANDSMEET_CITY_ELF, TRUE);
                    //WR_SetObjectActive(oFather, FALSE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_COD_CHA_VALENDRIAN, COD_CHA_VALENDRIAN_POST_LANDSMEET_ALL_OTHERS, TRUE);
                    //WR_SetObjectActive(oValendrian, FALSE);
                }

                UT_TeamAppears(DEN_TEAM_ALIENAGE_COMPOUND_SLAVES, FALSE);

                break;
            }
            case DEN_SLAVE_TRADE_PC_ESCORTS_SLAVES:
            {
                WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_FREED_SLAVES_IN_COMPOUND, TRUE, TRUE);

                if (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY))
                {
                    UT_DoAreaTransition(DEN_AR_CITY_ELF_PC_HOME, DEN_WP_CITY_ELF_PC_HOME);
                }
                else
                {
                    UT_DoAreaTransition(DEN_AR_VALENDRIANS_HOME, DEN_WP_VALENDRIANS_HOME);
                }

                break;
            }

            // Qwinn added to fix HEARD_ABOUT_PLAGUE giving more information than necessary.  We don't want to
            // overwrite entries with more information with entries with less information, so we'll add them prior
            // to the more-information entries being set.
            case DEN_SLAVE_TRADE_PC_HEARD_ABOUT_TEVINTERS:
            {
                if (!WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_PLAGUE))
                     WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_PLAGUE, TRUE);
                break;
            }
            
            case DEN_SLAVE_TRADE_PC_HEARD_ABOUT_MISSING_ELVES:
            {
                if (!WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_PLAGUE))
                     WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_PLAGUE, TRUE);
                if (!WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_TEVINTERS))
                     WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_TEVINTERS, TRUE);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case DEN_SLAVE_TRADE_TEVINTERS_GONE:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_FREED_SLAVES_IN_COMPOUND)
                          || WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_LEFT_SLAVES_WITH_CALADRIUS);
                break;
            }
            case DEN_SLAVE_TRADE_SHIANNI_ALTERNATATIVE_READY:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_TALKED_TO, DEN_TT_VERAS)
                          && !WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_SHIANNI_OFFERED_ALTERNATIVE)
                          && !WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ATTACKED_VERAS);
                break;
            }
            case DEN_SLAVE_TRADE_SORIS_IN_ALIENAGE:
            {
                nResult = WR_GetPlotFlag(PLT_BEC100PT_SORIS, BEC_SORIS_SAVED)
                          || WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_SORIS_LEAVES);
                break;
            }
            case DEN_SLAVE_TRADE_PC_FEMALE_NOT_HEARD_ABOUT_GIRLS:
            {
                nResult = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE)
                          && WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_MISSING_GIRLS);
                break;
            }
            case DEN_SLAVE_TRADE_PC_MALE_NOT_HEARD_ABOUT_GIRLS:
            {
                nResult = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE)
                          && !WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_MISSING_GIRLS);
                break;
            }
            case DEN_SLAVE_TRADE_PC_ELF_HEARD_ABOUT_MISSING_ELVES:
            {
                nResult = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_ELF, TRUE)
                          && WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_MISSING_ELVES);
                break;
            }
            case DEN_SLAVE_TRADE_PC_CITY_ELF_HEARD_ABOUT_MASSACRE:
            {
                nResult = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY, TRUE)
                          && WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_HEARD_ABOUT_MASSACRE);
                break;
            }
            case DEN_SLAVE_TRADE_SIDEGUARD_BRIBE_AFFORDABLE:
            {
                nResult = UT_MoneyCheck(oPC, 0, 0, DEN_MONEY_SIDEGUARD_BRIBE_LARGE_GOLD);
                break;
            }
            case DEN_SLAVE_TRADE_CALADRIUS_BRIBE_AFFORDABLE:
            {
                nResult = UT_MoneyCheck(oPC, 0, 0, DEN_MONEY_CALADRIUS_BRIBE_GOLD);
                break;
            }
            case DEN_SLAVE_TRADE_SIDEGUARD_BRIBE_ATTEMPTED_AND_AFFORDABLE:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_SIDEGUARD_BRIBE_ATTEMPTED)
                          && WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_SIDEGUARD_BRIBE_AFFORDABLE, TRUE);
                break;
            }
            case DEN_SLAVE_TRADE_SORIS_RESCUED_SORIS_DID_NOT_SUPPORT_BRIBE:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_SORIS_LEAVES)
                          && !WR_GetPlotFlag(PLT_BEC100PT_SORIS, BEC_SORIS_URGES_PC_TO_ACCEPT_BRIBE);
                break;
            }
            case DEN_SLAVE_TRADE_SCARED_ELF_BRIBE_AFFORDABLE:
            {
                nResult = UT_MoneyCheck(oPC, 0,0, DEN_MONEY_SCARED_ELF_BRIBE_GOLD);
                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}