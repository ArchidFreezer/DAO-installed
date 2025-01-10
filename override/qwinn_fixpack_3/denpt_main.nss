//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Landsmeet plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Craig
//:: Created On: February 20, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "plt_denpt_map"

#include "plt_denpt_main"
#include "plt_mnp000pt_main_events"
#include "plt_denpt_slave_trade"
#include "plt_denpt_rescue_the_queen"
#include "plt_gen00pt_party"
#include "plt_denpt_anora"
#include "plt_den600pt_bigfight"
#include "plt_genpt_party_events"
#include "plt_cod_cha_anora"
#include "plt_cod_cha_alistair"
#include "plt_cod_cha_eamon"
#include "plt_cod_cha_cauthrien"
#include "plt_cod_cha_loghain"
#include "plt_gen00pt_class_race_gend"
#include "plt_mnp000pt_main_events"
#include "plt_clipt_main"
#include "plt_denpt_oswyn"
#include "plt_denpt_irminric"
#include "plt_denpt_alistair"
#include "plt_genpt_app_alistair"
#include "plt_lite_chant_rand_civil"
#include "plt_mnp000pt_autoss_main2"

//#include "den_constants_h"
#include "party_h"
#include "cutscenes_h"
#include "den_functions_h"
#include "ran_constants_h"

#include "achievement_core_h"



void DEN_TeamFaceTarget(int nTeamID, object oTarget, int nMembersType = OBJECT_TYPE_CREATURE)
{
    object[]arrTeam = GetTeam(nTeamID, nMembersType);
    int nTeamSize = GetArraySize(arrTeam);

    int n;
    for (n = 0; n < nTeamSize; n++)
    {
        SetFacingObject(arrTeam[n], oTarget);
    }
}

void DEN_AdjustLandsmeetApproval(int nValue);
void DEN_AdjustLandsmeetApproval(int nValue)
{
    object oPC      = GetHero();
    object oArea    = GetArea(oPC);
    int nOldValue   = GetLocalInt(oArea, AREA_COUNTER_1);
    int nNewValue   = nOldValue + nValue;
    SetLocalInt(oArea, AREA_COUNTER_1, nNewValue);
    Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName() + ".DEN_AdjustLandsmeetApproval", "Setting Landsmeet approval to: " + IntToString(nNewValue));
}

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

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    object oEamon           = UT_GetNearestCreatureByTag(oPC,  DEN_CR_ARL_EAMON);
    object oCM_Landsmeet    = GetObjectByTag(WML_DEN_PALACE);
    object oArea            = GetArea(oPC);
    object oCauthrien       = UT_GetNearestCreatureByTag(oPC, DEN_CR_SER_CAUTHRIEN);
    int nCauthrienConvinced = GetLocalInt(oCauthrien, CREATURE_COUNTER_1);



    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case LANDSMEET_OPENING_DONE:
            {
                // Closing gather-army quest --yaron
                WR_SetPlotFlag(PLT_MNP000PT_MAIN_EVENTS, WIDE_OPEN_WORLD_DONE, TRUE);

                //Gather Army quest complete, grant achievements
                WR_UnlockAchievement(ACH_ADVANCE_STANDARD_BEARER);

                break;
            }
            case LANDSMEET_PLAYER_ARGUMENT_MINUS_1:
            {
                DEN_AdjustLandsmeetApproval(-1);
                break;
            }
            case LANDSMEET_PLAYER_ARGUMENT_MINUS_2:
            {
                DEN_AdjustLandsmeetApproval(-2);
                break;
            }
            case LANDSMEET_PLAYER_ARGUMENT_MINUS_3:
            {
                //take auto screenshot. The only thing that gives -3 is Anora speaking
                //out against the player. If something else gets added that gives -3,
                //this will need to be reworked.
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_ANORA_BETRAYS, TRUE, TRUE );
                DEN_AdjustLandsmeetApproval(-3);
                break;
            }
            case LANDSMEET_PLAYER_ARGUMENT_PLUS_1:
            {
                DEN_AdjustLandsmeetApproval(1);
                break;
            }
            case LANDSMEET_PLAYER_ARGUMENT_PLUS_2:
            {
                DEN_AdjustLandsmeetApproval(2);
                break;
            }
            case LANDSMEET_PLAYER_ARGUMENT_PLUS_3:
            {
                //take auto screenshot. The only thing that gives +3 is Anora speaking
                //out in favor of the player. If something else gets added that gives +3,
                //this will need to be reworked.
                WR_SetPlotFlag( PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_ANORA_SUPPORTS, TRUE, TRUE );
                DEN_AdjustLandsmeetApproval(3);
                break;
            }

            case LANDSMEET_JUMP_TO_EAMONS_ESTATE:
            {
                object oCM_EamonsEstate = GetObjectByTag(WML_DEN_EAMON);
                object oCityMap         = GetObjectByTag(WM_DEN_TAG);
                WR_SetPlotFlag(PLT_DENPT_MAP, DEN_MAP__ACTIVATE_CITY_MAP, TRUE, TRUE);

                WR_SetWorldMapLocationStatus(oCM_EamonsEstate, WM_LOCATION_ACTIVE);
                WR_SetWorldMapPlayerLocation(oCityMap, oCM_EamonsEstate);

                UT_DoAreaTransition(DEN_AR_EAMON_ESTATE_1, DEN_WP_EAMON_FIRST_FLOOR);
                break;
            }
            /*case LANDSMEET_PLOT_OPENED:
            {
                //UT_Talk(oEamon, oPC);
                break;
            }         */
            case LANDSMEET_EAMON_GOES_WITH_OR_WITHOUT_ALISTAIR:
            {
                WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_QUEST_COMPLETE, TRUE, TRUE);
                WR_SetWorldMapLocationStatus(oCM_Landsmeet, WM_LOCATION_ACTIVE);
                WR_SetObjectActive(oEamon, FALSE);
                //SetFollowerLocked(oAlistair, TRUE);
                break;
            }
            case LANDSMEET_ANORA_QUEEN_LOGHAIN_LIVES:
            {
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ANORA_IS_QUEEN, TRUE);
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_LIVES, TRUE);
                break;
            }
            case LANDSMEET_ALISTAIR_LEAVES_PARTY_AFTER_LANDSMEET_ALISTAIR_KING:
            {
                object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                object oAlistairWP = UT_GetNearestObjectByTag(oPC, DEN_WP_EAMON_ALISTAIR);

                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED, FALSE, TRUE);
                WR_SetObjectActive(oAlistair, FALSE);

                SetMapPinState(oAlistairWP, FALSE);

                DoAutoSave();
                break;
            }
            case LANDSMEET_ALISTAIR_KILLED:
            {
                object oAlistair    = Party_GetFollowerByTag(GEN_FL_ALISTAIR);

                //Auto screenshot flag
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_ALISTAIR_EXECUTED, TRUE);

                // Temporarily place in camp until LANDSMEET_WRAP_UP (to take his belongings)
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);

                WR_SetObjectActive(oAlistair, FALSE);
                break;
            }
            case LANDSMEET_ALISTAIR_LEAVES_FOREVER:
            {
                object oAlistair    = Party_GetFollowerByTag(GEN_FL_ALISTAIR);

                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED, FALSE, TRUE);
                WR_SetObjectActive(oAlistair, FALSE);
                break;
            }
            case LANDSMEET_ALISTAIR_AND_ANORA_ENGAGED_LOGHAIN_LIVES:
            {
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA, TRUE);
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_LIVES, TRUE);
                break;
            }
            case LANDSMEET_ALISTAIR_KING_NOT_ANORA_QUEEN_NOT_LOGHAIN_LIVES:
            {
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ANORA_IS_QUEEN, FALSE);
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_LIVES, FALSE);
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ANORA_QUEEN_LOGHAIN_LIVES, FALSE);
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_IS_KING, TRUE);
                break;
            }
            case LANDSMEET_ANORA_IMPRISONED:
            {
                //Signal automatic screenshot (pre-rendered)
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_ANORA_LOCKED_AWAY, TRUE);
                break;
            }
            case LANDSMEET_LOGHAIN_LIVES:
            {
                //Signal auto screenshot (pre-rendered) of Loghain's Joining
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_LOGHAINS_JOINING, TRUE, TRUE );
                break;
            }
            case LANDSMEET_CAUTHRIEN_CONVINCED_PLUS_1:
            {
                nCauthrienConvinced++;
                SetLocalInt(oCauthrien, CREATURE_COUNTER_1, nCauthrienConvinced);
                break;
            }
            case LANDSMEET_CAUTHRIEN_CONVINCED_PLUS_2:
            {
                nCauthrienConvinced += 2;
                SetLocalInt(oCauthrien, CREATURE_COUNTER_1, nCauthrienConvinced);
                break;
            }
            case LANDSMEET_CAUTHRIEN_CONVINCED_PLUS_3:
            {
                nCauthrienConvinced += 3;
                SetLocalInt(oCauthrien, CREATURE_COUNTER_1, nCauthrienConvinced);
                break;
            }
            case LANDSMEET_CAUTHRIEN_ATTACKS:
            {
                UT_TeamGoesHostile(DEN_TEAM_LANDSMEET_CAUTHRIEN, TRUE);

                DoAutoSave();
                break;
            }
            case LANDSMEET_CAUTHRIEN_BETRAYS:
            {
                object oLandsmeetDoors  = UT_GetNearestObjectByTag(oPC, DEN_IP_LANDSMEET_CHAMBER_DOORS);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_CAUTHRIEN, FALSE);
                SetPlaceableState(oLandsmeetDoors, PLC_STATE_DOOR_UNLOCKED);

                DoAutoSave();

                break;
            }
            case LANDSMEET_CAUTHRIEN_KILLED:
            {
                object oLandsmeetDoors  = UT_GetNearestObjectByTag(oPC, DEN_IP_LANDSMEET_CHAMBER_DOORS);
                SetPlaceableState(oLandsmeetDoors, PLC_STATE_DOOR_UNLOCKED);
                WR_SetPlotFlag(PLT_COD_CHA_CAUTHRIEN, COD_CHA_CAUTHRIEN_KILLED_LANDSMEET, TRUE, TRUE);

                break;
            }
            case LANDSMEET_BEGINS:
            {
                // SPECIAL HACK
                // REMOVE MODAL AOES AS THEY CAUSE MASSIVE EVENTS QUEUE BURSTS DURING THE DIALOG
                object [] arParty = GetPartyList();
                int nSize = GetArraySize(arParty);
                int i;
                object oCurrent;
                for(i = 0; i < nSize; i++)
                {
                    oCurrent = arParty[i];
                    if(IsModalAbilityActive(oCurrent, 10500)) // death syphon
                    {
                        Ability_DeactivateModalAbility(oCurrent, 10500);
                        SetCooldown(oCurrent, 10500, 0.0);
                    }
                    if(IsModalAbilityActive(oCurrent, ABILITY_SPELL_CLEANSING_AURA))
                    {
                        Ability_DeactivateModalAbility(oCurrent, ABILITY_SPELL_CLEANSING_AURA);
                        SetCooldown(oCurrent, ABILITY_SPELL_CLEANSING_AURA, 0.0);
                    }
                    if(IsModalAbilityActive(oCurrent, ABILITY_SPELL_TBD_WAS_DANCE_OF_MADNESS))  // miasma
                    {
                        Ability_DeactivateModalAbility(oCurrent, ABILITY_SPELL_TBD_WAS_DANCE_OF_MADNESS);
                        SetCooldown(oCurrent, ABILITY_SPELL_TBD_WAS_DANCE_OF_MADNESS, 0.0);
                    }
                    if(IsModalAbilityActive(oCurrent, ABILITY_SPELL_DEATH_MAGIC))
                    {
                        Ability_DeactivateModalAbility(oCurrent, ABILITY_SPELL_DEATH_MAGIC);
                        SetCooldown(oCurrent, ABILITY_SPELL_DEATH_MAGIC, 0.0);
                    }
                }


                // END OF SPECIAL HACK
                object oExit = UT_GetNearestObjectByTag(oPC, DEN_IP_LANDSMEET_EXIT);

                int bIrminricStarted = WR_GetPlotFlag(PLT_DENPT_IRMINRIC, DEN_IRMINRIC_GAVE_RING);
                int bIrminricFinished = WR_GetPlotFlag(PLT_DENPT_IRMINRIC, DEN_IRMINRIC_OFFER_REFUSED)
                                        || WR_GetPlotFlag(PLT_DENPT_IRMINRIC, DEN_IRMINRIC_REWARD_GIVEN);

                int bOsywnStarted = WR_GetPlotFlag(PLT_DENPT_OSWYN, DEN_OSWYN_FREED);
                int bOswynFinished = WR_GetPlotFlag(PLT_DENPT_OSWYN, DEN_OSWYN_ASKED_FOR_NO_REWARD)
                                        || WR_GetPlotFlag(PLT_DENPT_OSWYN, DEN_OSWYN_REWARD_GIVEN);

                SetObjectInteractive(oExit, FALSE);

                if (bIrminricStarted && !bIrminricFinished)
                {
                    WR_SetPlotFlag(PLT_DENPT_IRMINRIC, DEN_IRMINRIC_ABANDONED_QUEST, TRUE);
                }
                if (bOsywnStarted && !bOswynFinished)
                {
                    WR_SetPlotFlag(PLT_DENPT_OSWYN, DEN_OSWYN_ABANDONED_QUEST, TRUE);
                }

                if (!WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_CAUTHRIEN_KILLED))
                {
                    UT_TeamAppears(DEN_TEAM_LANDSMEET_CAUTHRIEN, FALSE);
                }

                CS_LoadCutscene(CUTSCENE_DEN_LANDSMEET_OPENING, PLT_DENPT_MAIN,
                    LANDSMEET_BEGINS_CUTSCENE_END);
                break;
            }
            case LANDSMEET_BEGINS_CUTSCENE_END:
            {
                UT_Talk(oEamon, oPC, DEN_CONV_LANDSMEET);
                break;
            }

            case LANDSMEET_BIG_FIGHT:
            {
                object oLoghain     = UT_GetNearestCreatureByTag(oPC, GEN_FL_LOGHAIN);
                object oLoghainBoss = UT_GetNearestCreatureByTag(oPC, DEN_CR_LOGHAIN_BOSS);
                object oAlfstanna   = UT_GetNearestCreatureByTag(oPC, DEN_CR_ALFSTANNA);
                object oBryland     = UT_GetNearestCreatureByTag(oPC, DEN_CR_ARL_BRYLAND);
                WR_SetObjectActive(oLoghain, FALSE);
                WR_SetObjectActive(oLoghainBoss, TRUE);

                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_BIG_FIGHT, TRUE, FALSE);
                UT_Talk(oLoghainBoss, oPC,  DEN_CONV_LANDSMEET, FALSE);

                DoAutoSave();

                UT_TeamAppears(DEN_TEAM_LANDSMEET_NONCOMBATANTS, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_1, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_2, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_3, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_4, FALSE);

                UT_TeamAppears(DEN_TEAM_LANDSMEET_ALFSTANNA, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_BRYLAND, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_WULFF, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_CEORLIC, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_SIGHARD, FALSE);


                if (WR_GetPlotFlag(PLT_DENPT_ANORA, DEN_ANORA_WILL_SUPPORT_PC, TRUE))
                {
                    WR_SetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_ROYAL_GUARD_ON_PLAYER_SIDE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_SIGHARD_SIDES_WITH_PLAYER, TRUE))
                {
                    WR_SetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_SIGHARD_ON_PLAYER_SIDE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALFSTANNA_SIDES_WITH_PLAYER, TRUE))
                {
                    WR_SetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_ALFSTANNA_ON_PLAYER_SIDE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PERSUADED_WULFF))
                {
                    WR_SetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_WULFF_ON_PLAYER_SIDE, TRUE);
                }
                WR_SetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_BRYLAND_ON_PLAYER_SIDE, TRUE);
                WR_SetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_CEORLIC_ON_PLAYER_SIDE, FALSE);

                WR_SetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_LOGHAIN_JOINS, TRUE, TRUE);
                WR_SetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_ROYAL_GUARD_JOINS, TRUE, TRUE);
                WR_SetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_EAMON_JOINS, TRUE, TRUE);


                WR_SetObjectActive(oAlfstanna, FALSE);
                WR_SetObjectActive(oBryland, FALSE);

                break;
            }
            case LANDSMEET_BIG_FIGHT_OVER:
            {
                object oLoghain     = UT_GetNearestCreatureByTag(oPC, GEN_FL_LOGHAIN);
                object oLoghainBoss = UT_GetNearestCreatureByTag(oPC, DEN_CR_LOGHAIN_BOSS);
                object oAlfstanna   = UT_GetNearestCreatureByTag(oPC, DEN_CR_ALFSTANNA);
                object oBryland     = UT_GetNearestCreatureByTag(oPC, DEN_CR_ARL_BRYLAND);
                object oCeorlic     = UT_GetNearestCreatureByTag(oPC, DEN_CR_CEORLIC);
                object oSighard     = UT_GetNearestCreatureByTag(oPC, DEN_CR_SIGHARD);
                object oWulff       = UT_GetNearestCreatureByTag(oPC, DEN_CR_ARL_WULFF);

                WR_SetObjectActive(oLoghain, TRUE);
                WR_SetObjectActive(oLoghainBoss, FALSE);

                UT_TeamAppears(DEN_TEAM_LANDSMEET_ALFSTANNA, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_BRYLAND, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_CEORLIC, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_EAMON, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_BOSS, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_BOSS_RANGED, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_MAGES, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_1, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_2, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_3, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_4, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_ROYAL_GUARD, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_SIGHARD, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_WULFF, FALSE);
                UT_TeamAppears(DEN_TEAM_LANDSMEET_NONCOMBATANTS, TRUE);

/*
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_ROYAL_GUARD, GROUP_NEUTRAL);
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_ALFSTANNA, GROUP_NEUTRAL);
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_BRYLAND, GROUP_NEUTRAL);
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_CEORLIC, GROUP_NEUTRAL);
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_LOGHAIN_BOSS, GROUP_NEUTRAL);
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_1, GROUP_NEUTRAL);
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_2, GROUP_NEUTRAL);
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_3, GROUP_NEUTRAL);
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_LOGHAIN_REINFORCMENTS_4, GROUP_NEUTRAL);
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_SIGHARD, GROUP_NEUTRAL);
                DEN_SetTeamGroup(DEN_TEAM_LANDSMEET_NONCOMBATANTS, GROUP_NEUTRAL);
                */

                SetGroupId(oEamon, GROUP_NEUTRAL);
                WR_SetObjectActive(oEamon, TRUE);
                Gore_RemoveAllGore(oEamon);
                Effects_RemoveUpkeepEffect(oEamon, 0);
                RemoveEffectsDueToPlotEvent(oEamon);
                ShowAsAllyOnMap(oEamon, FALSE);

                SetGroupId(oAlfstanna, GROUP_NEUTRAL);
                WR_SetObjectActive(oAlfstanna, TRUE);
                Effects_RemoveUpkeepEffect(oAlfstanna, 0);
                RemoveEffectsDueToPlotEvent(oAlfstanna);
                Gore_RemoveAllGore(oAlfstanna);
                ShowAsAllyOnMap(oAlfstanna, FALSE);

                SetGroupId(oBryland, GROUP_NEUTRAL);
                WR_SetObjectActive(oBryland, TRUE);
                ShowAsAllyOnMap(oBryland, FALSE);

                SetGroupId(oCeorlic, GROUP_NEUTRAL);
                WR_SetObjectActive(oCeorlic, TRUE);
                ShowAsAllyOnMap(oCeorlic, FALSE);

                SetGroupId(oSighard, GROUP_NEUTRAL);
                WR_SetObjectActive(oSighard, TRUE);
                ShowAsAllyOnMap(oSighard, FALSE);

                SetGroupId(oWulff, GROUP_NEUTRAL);
                WR_SetObjectActive(oWulff, TRUE);
                ShowAsAllyOnMap(oWulff, FALSE);

                UT_Talk(oLoghain, oPC, DEN_CONV_LANDSMEET);
                break;
            }
            /* case LANDSMEET_PC_CHALLENGES_LOGHAIN:
            {
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PC_FIGHTS_LOGHAIN, TRUE);
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_DUEL, TRUE, TRUE);
                break;
            }    */
            case LANDSMEET_DUEL:
            {
                object oLoghain     = UT_GetNearestCreatureByTag(oPC, GEN_FL_LOGHAIN);
                object oLoghainDuel = UT_GetNearestCreatureByTag(oPC, DEN_CR_LOGHAIN_DUEL);
                object oAlistair    = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                int nAlistairFights = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_FIGHTS_LOGHAIN);
                int nLelianaFights = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LELIANA_FIGHTS_LOGHAIN);
                int nMorriganFights = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_MORRIGAN_FIGHTS_LOGHAIN);
                int nOghrenFights = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_OGHREN_FIGHTS_LOGHAIN);
                int nStenFights = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_STEN_FIGHTS_LOGHAIN);
                int nWynneFights = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_WYNNE_FIGHTS_LOGHAIN);
                int nZevranFights = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ZEVRAN_FIGHTS_LOGHAIN);
                int nShaleFights = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_SHALE_FIGHTS_LOGHAIN);
                int nPlayerIsDwarf = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_DWARF);
                int nPlayerIsElf = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_ELF);
                string [] arActors;
                object [] arReplacements;
                resource rCutscene;

                WR_SetObjectActive(oLoghain, FALSE);
                WR_SetObjectActive(oLoghainDuel, TRUE);

                Injury_RemoveAllInjuriesFromParty();
                HealPartyMembers(TRUE, TRUE);

                //********Let Alistair be added or removed again************//
                WR_SetFollowerState(oAlistair, FOLLOWER_STATE_AVAILABLE);
                WR_SetFollowerState(oAlistair, FOLLOWER_STATE_ACTIVE);
                //********Let Alistair be added or removed again************//

                UT_SetSurrenderFlag(oLoghainDuel, TRUE, PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_DEFEATED, FALSE);


                // jump everyone else to the right waypoints
                object oEamon       = UT_GetNearestCreatureByTag(oPC, DEN_CR_ARL_EAMON);
                object oAlfstanna   = UT_GetNearestCreatureByTag(oPC, DEN_CR_ALFSTANNA);
                object oBryland     = UT_GetNearestCreatureByTag(oPC, DEN_CR_ARL_BRYLAND);
                object oCeorlic     = UT_GetNearestCreatureByTag(oPC, DEN_CR_CEORLIC);
                object oSighard     = UT_GetNearestCreatureByTag(oPC, DEN_CR_SIGHARD);
                object oWulff       = UT_GetNearestCreatureByTag(oPC, DEN_CR_ARL_WULFF);
                object oElemena     = UT_GetNearestCreatureByTag(oPC, DEN_CR_ELEMENA);
                object oRiordan     = UT_GetNearestCreatureByTag(oPC, DEN_CR_RIORDAN);
                object oAnora       = UT_GetNearestCreatureByTag(oPC, DEN_CR_ANORA);

                UT_LocalJump(oEamon);
                UT_LocalJump(oAlfstanna);
                UT_LocalJump(oBryland);
                UT_LocalJump(oCeorlic);
                UT_LocalJump(oSighard);
                UT_LocalJump(oWulff);
                UT_LocalJump(oElemena);
                UT_LocalJump(oRiordan);
                UT_LocalJump(oAnora);

                //Put everyone in one cheering section or the other

                SetTeamId(oEamon, DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD);
                SetTeamId(oRiordan, DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD);

                if (WR_GetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_ROYAL_GUARD_ON_PLAYER_SIDE))
                {
                    SetTeamId(oAnora, DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD);
                }
                else
                {
                    SetTeamId(oAnora, DEN_TEAM_LANDSMEET_DUEL_LOGHAIN_CROWD);
                }

                if (WR_GetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_ALFSTANNA_ON_PLAYER_SIDE))
                {
                    SetTeamId(oAlfstanna, DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD);
                }
                else
                {
                    SetTeamId(oAlfstanna, DEN_TEAM_LANDSMEET_DUEL_LOGHAIN_CROWD);
                }

                if (WR_GetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_BRYLAND_ON_PLAYER_SIDE))
                {
                    SetTeamId(oBryland, DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD);
                }
                else
                {
                    SetTeamId(oBryland, DEN_TEAM_LANDSMEET_DUEL_LOGHAIN_CROWD);
                }

                if (WR_GetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_CEORLIC_ON_PLAYER_SIDE))
                {
                    SetTeamId(oCeorlic, DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD);
                }
                else
                {
                    SetTeamId(oCeorlic, DEN_TEAM_LANDSMEET_DUEL_LOGHAIN_CROWD);
                }

                if (WR_GetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_SIGHARD_ON_PLAYER_SIDE))
                {
                    SetTeamId(oSighard, DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD);
                }
                else
                {
                    SetTeamId(oSighard, DEN_TEAM_LANDSMEET_DUEL_LOGHAIN_CROWD);
                }

                if (WR_GetPlotFlag(PLT_DEN600PT_BIGFIGHT, DEN_BIGFIGHT_WULFF_ON_PLAYER_SIDE))
                {
                    SetTeamId(oWulff, DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD);
                }
                else
                {
                    SetTeamId(oWulff, DEN_TEAM_LANDSMEET_DUEL_LOGHAIN_CROWD);
                }



                // ************************************************
                // This big mess figures out 1) who is fighting and therefore
                // which object needs to be passed into the cutscene, and
                // 2) which cutscene variant we need to call
                // ************************************************

                arActors[0] = "duel";

                // Default values (human PC)
                arReplacements[0] = oPC;
                rCutscene = CUTSCENE_DEN_LOGHAINS_DUEL_HUMAN;

                if( nAlistairFights == TRUE)
                {
                    arReplacements[0] = UT_GetNearestCreatureByTag(oPC, GEN_FL_ALISTAIR);
                    rCutscene = CUTSCENE_DEN_LOGHAINS_DUEL_HUMAN;
                }
                else if( nLelianaFights == TRUE)
                {
                    arReplacements[0] = UT_GetNearestCreatureByTag(oPC, GEN_FL_LELIANA);
                    rCutscene = CUTSCENE_DEN_LOGHAINS_DUEL_HUMAN;
                }
                else if( nMorriganFights == TRUE)
                {
                    arReplacements[0] = UT_GetNearestCreatureByTag(oPC, GEN_FL_MORRIGAN);
                    rCutscene = CUTSCENE_DEN_LOGHAINS_DUEL_HUMAN;
                }
                else if( nOghrenFights == TRUE)
                {
                    arReplacements[0] = UT_GetNearestCreatureByTag(oPC, GEN_FL_OGHREN);
                    rCutscene = CUTSCENE_DEN_LOGHAINS_DUEL_DWARF;
                }
                else if( nStenFights == TRUE)
                {
                    arReplacements[0] = UT_GetNearestCreatureByTag(oPC, GEN_FL_STEN);
                    rCutscene = CUTSCENE_DEN_LOGHAINS_DUEL_QUNARI;
                }
                else if( nWynneFights == TRUE)
                {
                    arReplacements[0] = UT_GetNearestCreatureByTag(oPC, GEN_FL_WYNNE);
                    rCutscene = CUTSCENE_DEN_LOGHAINS_DUEL_HUMAN;
                }
                else if( nZevranFights == TRUE)
                {
                    arReplacements[0] = UT_GetNearestCreatureByTag(oPC, GEN_FL_ZEVRAN);
                    rCutscene = CUTSCENE_DEN_LOGHAINS_DUEL_ELF;
                }
                else if( nShaleFights == TRUE)
                {
                    // Cutscene does not work well with Shale, so skip it.
                    WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_DUEL_CUTSCENE_END, TRUE, TRUE);
                    break;
                }
                else if( nPlayerIsDwarf == TRUE)
                {
                    arReplacements[0] = oPC;
                    rCutscene = CUTSCENE_DEN_LOGHAINS_DUEL_DWARF;
                }
                else if( nPlayerIsElf == TRUE)
                {
                    arReplacements[0] = oPC;
                    rCutscene = CUTSCENE_DEN_LOGHAINS_DUEL_ELF;
                }

                CS_LoadCutsceneWithReplacements(rCutscene,
                    arActors, arReplacements,
                    PLT_DENPT_MAIN, LANDSMEET_DUEL_CUTSCENE_END);
                break;
            }
            case LANDSMEET_DUEL_CUTSCENE_END:
            {
                object oPartyLeader = oPC;
                object oLoghainDuel = UT_GetNearestCreatureByTag(oPC, DEN_CR_LOGHAIN_DUEL);


                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_FIGHTS_LOGHAIN))
                {
                    oPartyLeader = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                }
                else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_SHALE_FIGHTS_LOGHAIN))
                {
                    oPartyLeader = Party_GetFollowerByTag(GEN_FL_SHALE);
                }
                else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_OGHREN_FIGHTS_LOGHAIN))
                {
                    oPartyLeader = Party_GetFollowerByTag(GEN_FL_OGHREN);
                }
                else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LELIANA_FIGHTS_LOGHAIN))
                {
                    oPartyLeader = Party_GetFollowerByTag(GEN_FL_LELIANA);
                }
                else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_MORRIGAN_FIGHTS_LOGHAIN))
                {
                    oPartyLeader = Party_GetFollowerByTag(GEN_FL_MORRIGAN);
                }
                else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_STEN_FIGHTS_LOGHAIN))
                {
                    oPartyLeader = Party_GetFollowerByTag(GEN_FL_STEN);
                }
                else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_WYNNE_FIGHTS_LOGHAIN))
                {
                    oPartyLeader = Party_GetFollowerByTag(GEN_FL_WYNNE);
                }
                else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ZEVRAN_FIGHTS_LOGHAIN))
                {
                    oPartyLeader = Party_GetFollowerByTag(GEN_FL_ZEVRAN);
                }
                UT_PartyStore(TRUE);


                WR_SetObjectActive(oPartyLeader, TRUE);
                WR_SetFollowerState(oPartyLeader, FOLLOWER_STATE_ACTIVE);
                SetPartyLeader(oPartyLeader);

                // jump the party to the right waypoints
                object    oPartyMember;
                object [] arParty    = GetPartyList(GetPartyLeader());
                int       nLoop;
                int       nPartySize = GetArraySize(arParty);

                for (nLoop = 0; nLoop < nPartySize; nLoop++)
                {
                    oPartyMember = arParty[nLoop];

                    if ( oPartyMember == GetPartyLeader() )
                    {
                        UT_LocalJump(oPartyMember, DEN_WP_LANDSMEET_DUELIST);
                    }
                    else
                    {
                        UT_LocalJump(oPartyMember);
                        SetTeamId(oPartyMember, DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD);
                    }
                }

                DEN_TeamFaceTarget(DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD, oLoghainDuel);
                DEN_TeamFaceTarget(DEN_TEAM_LANDSMEET_DUEL_LOGHAIN_CROWD, oLoghainDuel);
                DEN_TeamFaceTarget(DEN_TEAM_LANDSMEET_NONCOMBATANTS, oLoghainDuel);


                if (!WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PC_FIGHTS_LOGHAIN))
                {
                    WR_SetFollowerState(oPC, FOLLOWER_STATE_UNAVAILABLE);
                    SetGroupId(oPC, GROUP_NEUTRAL);
                }

                UT_TeamAppears(DEN_TEAM_LANDSMEET_DUEL_WALLS, TRUE, OBJECT_TYPE_PLACEABLE);




                UT_CombatStart(oLoghainDuel, oPartyLeader, TRUE, TRUE);

                break;
            }
            case LANDSMEET_LOGHAIN_DEFEATED:
            {
                object oLoghain     = UT_GetNearestCreatureByTag(oPC, GEN_FL_LOGHAIN);
                object oLoghainDuel = UT_GetNearestCreatureByTag(oPC, DEN_CR_LOGHAIN_DUEL);
                object oOldLeader   = GetPartyLeader();
                WR_SetObjectActive(oLoghain, TRUE);
                WR_SetObjectActive(oLoghainDuel, FALSE);

                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_DEFEATED, TRUE);

                // activate/deactivate everyone and jump them to appropriate places
                /*
                    Nobles and soldiers (other than royal guard) inactive
                    Eamon active and standing near the dais
                    Anora active if she is queen
                */
                WR_SetObjectActive(oPC, TRUE);
                WR_SetFollowerState(oPC, FOLLOWER_STATE_ACTIVE);
                SetPartyLeader(oPC);

                if (!IsHero(oOldLeader))
                {
                    WR_SetFollowerState(oOldLeader, FOLLOWER_STATE_UNAVAILABLE);
                    WR_SetObjectActive(oOldLeader, FALSE);
                }

                UT_PartyRestore();

                WR_SetObjectActive(oEamon, TRUE);

                DEN_TeamStopAmbient(DEN_TEAM_LANDSMEET_DUEL_LOGHAIN_CROWD);
                DEN_TeamStopAmbient(DEN_TEAM_LANDSMEET_DUEL_PLAYER_CROWD);
                DEN_TeamStopAmbient(DEN_TEAM_LANDSMEET_NONCOMBATANTS);


                UT_Talk(oLoghain, oPC, DEN_CONV_LANDSMEET);
                break;
            }
            case LANDSMEET_QUEST_DONE:
            {
                // Grant achievement for completing Landsmeet
                WR_UnlockAchievement(ACH_ADVANCE_RABBLE_ROUSER);
                // If the Player hasn't died, grant achievement: General
                ACH_CheckForSurvivalAchievement(ACH_FEAT_GENERAL);

                if(nOldValue == 0)
                    WR_SetPlotFlag(PLT_MNP000PT_MAIN_EVENTS, PLAYER_FINISHED_A_MAJOR_PLOT, TRUE, TRUE);

                WR_SetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_START, TRUE, TRUE);

                // ********** AUTO SCREENSHOTS ******** //

                //Automatic screenshots. These proved impossible to cleanly
                //insert into the conversation directly, the question of who
                //gets to be king or queen can flip flop around quite a lot.
                //By putting the screenshot logic here we get two results; one,
                //a very clean implementation with little room for error, and
                //two, the need to make all of these screenshots "canned".
                //This is unfortunate in the case of shots involving the
                //player marrying someone but there doesn't seem to be a
                //better solution available.

                //First, check whether Alistair or Anora will be king/queen. These screenshots are mutually exclusive.
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA))
                {
                    WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_ALISTAIR_AND_ANORA_TO_MARRY, TRUE);
                } else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_IS_KING))
                {
                    WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_ALISTAIR_IS_KING, TRUE);
                } else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ANORA_IS_QUEEN))
                {
                    WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_ANORA_IS_QUEEN, TRUE);
                }

                //Next, check if the player will be marrying into royalty. These screenshots are mutually exclusive.
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLAYER_IS_KING))
                {
                    WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_ANORA_AND_PLAYER_TO_MARRY, TRUE);
                }
                else if (
                        WR_GetPlotFlag(PLT_DENPT_ALISTAIR, DEN_ALISTAIR_MARRYING_PLAYER)
                        && WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_IS_KING)
                    )
                {
                    WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_ALISTAIR_AND_PLAYER_TO_MARRY, TRUE);
                }

                // ********** LOGHAIN'S FATE ********** //

                // This hack shouldn't be necessary when not using cheats, but it also doesn't hurt anything
                if (!WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_LIVES)
                    && !WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_KILLED)
                    && !WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED))
                {
                    WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_LIVES, TRUE, FALSE);
                }

                int nRandCivilFlag;
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_LIVES))
                {
                    //equip loghain's weapon and shield
                    object oLoghain = Party_GetFollowerByTag(GEN_FL_LOGHAIN);
                    object oLoghainSword    = GetItemPossessedBy(oLoghain, DEN_IT_LOGHAIN_SWORD);
                    object oLoghainShield   = GetItemPossessedBy(oLoghain, DEN_IT_LOGHAIN_SHIELD);
                    EquipItem(oLoghain, oLoghainSword);
                    EquipItem(oLoghain, oLoghainShield);

                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_RECRUITED, TRUE, TRUE);

                    nRandCivilFlag = CIVIL_PLOT_NOT_COMPLETED_LOGHAIN_JOINED;
                }
                else
                {
                    nRandCivilFlag = CIVIL_PLOT_NOT_COMPLETED_LOGHAIN_DEAD;
                }
                // ********** LOGHAIN'S FATE ********** //

                //BEGIN Ran260 is no longer available *** //
                object oLocation = GetObjectByTag(WML_LC_CIVIL);
                if (WR_GetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_PLOT_ACCEPTED) == TRUE)
                {
                    //if accepted but not completed - close it off
                    if (WR_GetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_PLOT_COMPLETED) == FALSE)
                    {
                        WR_SetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, nRandCivilFlag, TRUE);
                        //close the map
                        WR_SetWorldMapLocationStatus(oLocation, WM_LOCATION_INACTIVE);
                    }
                }
                else
                {
                    //if the quest hasn't been started - just close the map
                    WR_SetWorldMapLocationStatus(oLocation, WM_LOCATION_INACTIVE);
                    //remove from the chanter board
                    WR_SetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_CHANTER_BOARD, FALSE);
                }


                WR_SetWorldMapLocationStatus(oCM_Landsmeet, WM_LOCATION_COMPLETE);



                //SetLocalString(GetModule(), WM_STORED_AREA, DEN_AR_EAMON_ESTATE_1);
                //SetLocalString(GetModule(), WM_STORED_WP, DEN_WP_EAMON_PLAYER_DOWNSTAIRS);

                //WorldMapStartTravelling("", "", GetArea(oPC));

                UT_DoAreaTransition(DEN_AR_EAMON_ESTATE_1, DEN_WP_EAMON_PLAYER_DOWNSTAIRS);
                break;
            }
            case LANDSMEET_PC_EXECUTES_LOGHAIN:
            {

                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_PLAYER_EXECUTES_LOGHAIN, TRUE, TRUE); // Auto screenshot
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_KILLED, TRUE, TRUE);
                break;
            }
            case LANDSMEET_ALISTAIR_EXECUTES_LOGHAIN:
            {
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_DEN_ALISTAIR_EXECUTES_LOGHAIN, TRUE, TRUE); // Auto screenshot
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_KILLED, TRUE, TRUE);
                break;
            }
            case LANDSMEET_WRAP_UP:
            {
                //UT_LocalJump(oPC, DEN_WP_EAMON_PLAYER_DOWNSTAIRS);
                object oAnora       = UT_GetNearestCreatureByTag(oPC, DEN_CR_ANORA);
                object oErlina      = UT_GetNearestCreatureByTag(oPC, DEN_CR_ERLINA);
                object oAlistair    = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                object oRiordan     = UT_GetNearestCreatureByTag(oPC, DEN_CR_RIORDAN);
                object oMaid1       = UT_GetNearestCreatureByTag(oPC, DEN_CR_MAID_1);
                object oMaid2       = UT_GetNearestCreatureByTag(oPC, DEN_CR_MAID_2);

                int bAlistairSpeaks = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_SPEAKS_AFTER_LANDSMEET, TRUE);

                // if Alistair was killed give player his stuff, then remove him from the party pool

                int bAlistairKilled = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_KILLED);
                if (bAlistairKilled)
                {
                    object oAlistairChest = UT_GetNearestObjectByTag(oPC, DEN_IP_EAMON_ALISTAIR_CHEST);
                    StoreFollowerInventory(oAlistair, oAlistairChest);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED, FALSE, TRUE);
                    WR_SetObjectActive(oAlistair, FALSE);
                }

                // Riordan and maids always leaves.
                WR_SetObjectActive(oRiordan, FALSE);
                WR_SetObjectActive(oMaid1, FALSE);
                WR_SetObjectActive(oMaid2, FALSE);

                // Start conversation with Anora or Alistair

                if (bAlistairSpeaks)
                {
                    WR_SetObjectActive(oAnora, FALSE);
                    WR_SetObjectActive(oErlina, FALSE);

                    //UT_LocalJump(oAlistair, DEN_WP_EAMON_ALISTAIR_DOWNSTAIRS);
                    WR_SetPlotFlag(PLT_GENPT_PARTY_EVENTS, PARTY_EVENT_LANDSMEET_DONE, TRUE);
                    UT_Talk(oAlistair, oPC, GEN_DL_PARTY_EVENTS);
                }
                else
                {
                    //UT_LocalJump(oAnora, DEN_WP_EAMON_ANORA_DOWNSTAIRS);
                    UT_Talk(oAnora, oPC);
                }

                //---------------begin CODEX HANDLING-------------------//

                int bLandsmeetWon   = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_WON);
                int bLoghainLives   = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_LIVES);

                // Eamon
                WR_SetPlotFlag(PLT_COD_CHA_EAMON, COD_CHA_EAMON_LANDSMEET_OVER, TRUE, TRUE);



                WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_SECOND_QUOTE, FALSE, TRUE);
                if (bLoghainLives)
                {
                    WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_LANDSMEET_JOINING, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_FINAL_QUOTE, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_LANDSMEET_DEATH, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_THIRD_QUOTE, TRUE, TRUE);
                }

                // Landsmeet won/lost
                if (bLandsmeetWon)
                {
                    // Qwinn:  Added NOFIGHT variant
                    if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_BIG_FIGHT))
                       WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_PC_WINS_LANDSMEET, TRUE, TRUE);
                    else   
                       WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_PC_WINS_LANDSMEET_NOFIGHT, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_PC_LOSES_LANDSMEET, TRUE, TRUE);
                }

                if (WR_GetPlotFlag(PLT_DENPT_ANORA, DEN_ANORA_WILL_SUPPORT_PC))
                {
                    if (bLandsmeetWon)
                    {
                        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_SUPPORTS_PC_VICTORY, TRUE, TRUE);
                    }
                    else
                    {
                        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_SUPPORTS_PC_FAILURE, TRUE, TRUE);
                    }
                }
                else
                {
                    WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_BETRAYS_PC, TRUE, TRUE);
                }


                // results of Landsmeet
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA))
                {
                    WR_SetPlotFlag(PLT_COD_CHA_ALISTAIR, COD_CHA_ALISTAIR_KING, TRUE, TRUE);
                    if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PC_EXECUTES_LOGHAIN))
                    {
                        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_MARRIES_ALISTAIR_AL_STAYS, TRUE, TRUE);
                    }
                    else
                    {
                        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_MARRIES_ALISTAIR_AL_LEAVES, TRUE, TRUE);
                    }
                }
                else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLAYER_IS_KING))
                {
                    if (bAlistairKilled)
                    {
                        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_MARRIES_PC_ALISTAIR_DEAD, TRUE, TRUE);
                        WR_SetPlotFlag(PLT_COD_CHA_ALISTAIR, COD_CHA_ALISTAIR_DEAD, TRUE, TRUE);
                    }
                    else if(bLoghainLives)
                    {
                        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_MARRIES_PC_ALISTAIR_LEAVES, TRUE, TRUE);
                        WR_SetPlotFlag(PLT_COD_CHA_ALISTAIR, COD_CHA_ALISTAIR_LEFT, TRUE, TRUE);
                    }
                    else
                    {
                        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_MARRIES_PC_ALISTAIR_STAYS, TRUE, TRUE);
                    }
                }
                else if ( WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ANORA_IS_QUEEN))
                {
                    if (bAlistairKilled)
                    {
                        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_QUEEN_ALISTAIR_DEAD, TRUE, TRUE);
                        WR_SetPlotFlag(PLT_COD_CHA_ALISTAIR, COD_CHA_ALISTAIR_DEAD, TRUE, TRUE);
                    }
                    else if(bLoghainLives)
                    {
                        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_QUEEN_ALISTAIR_LEAVES, TRUE, TRUE);
                        WR_SetPlotFlag(PLT_COD_CHA_ALISTAIR, COD_CHA_ALISTAIR_LEFT, TRUE, TRUE);
                    }
                    else
                    {
                        WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_QUEEN_ALISTAIR_STAYS, TRUE, TRUE);
                    }
                }
                else // if Alistair is king alone
                {
                    WR_SetPlotFlag(PLT_COD_CHA_ALISTAIR, COD_CHA_ALISTAIR_KING, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_DEPOSED, TRUE, TRUE);
                }

                //--------------- end CODEX HANDLING-------------------//

                break;
            }

            case LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_7a);

                break;
            }

            case LANDSMEET_ALISTAIR_ENGAGED_TO_PLAYER:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_7b);

                break;
            }

            case LANDSMEET_ALISTAIR_IS_KING:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_7c);

                break;
            }

            case LANDSMEET_ANORA_IS_QUEEN:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_7d);

                break;
            }

            case LANDSMEET_PLAYER_IS_KING:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_7e);

                break;
            }
        }
    }
    else // EVENT_TYPE_GET_PLOT -> defined conditions only
    {

        switch(nFlag)
        {
            case LANDSMEET_ALFSTANNA_SIDES_WITH_PLAYER:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_IRMINRIC_REWARD)
                          || WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PERSUADED_ALFSTANNA);
                break;
            }
            case LANDSMEET_SIGHARD_SIDES_WITH_PLAYER:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_OSWYN_SAVED)
                          || WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PERSUADED_SIGHARD);
                break;
            }
            case LANDSMEET_FIND_QUEEN_DONE_NO_EVIDENCE:
            {
                if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_QUEST_COMPLETE)
                    && !WR_GetPlotFlag(strPlot, LANDSMEET_EVIDENCE_FOUND, TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LANDSMEET_EVIDENCE_FOUND:
            {
                if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ACQUIRED_EVIDENCE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LANDSMEET_QUESTS_OPEN:
            {
                if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_QUEST_COMPLETE)
                    && !WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLAYER_GOES))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LANDSMEET_LOST_WITHOUT_ANORA_SUPPORT:
            {
                if (!WR_GetPlotFlag(PLT_DENPT_ANORA, DEN_ANORA_WILL_SUPPORT_PC, TRUE)
                    && WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOST))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LANDSMEET_ANORA_ON_THRONE:
            {
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA)
                    || WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ANORA_IS_QUEEN)
                    || WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLAYER_IS_KING))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LANDSMEET_ALISTAIR_ON_THRONE:
            {
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA)
                    || WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_IS_KING)
                    || WR_GetPlotFlag(PLT_DENPT_ALISTAIR, DEN_ALISTAIR_MARRYING_PLAYER))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LANDSMEET__ALISTAIR_ANORA_ENGAGED_LOGHAIN_ALIVE:
            {
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA)
                    && !WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_KILLED))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LANDSMEET_READY_PLAYER_HAS_NOT_GONE:
            {
                if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_EAMON_GOES_WITH_OR_WITHOUT_ALISTAIR)
                    && !WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLAYER_GOES))
                {
                    nResult = TRUE;
                }
                break;
            }
            case LANDSMEET_PLAYER_ARGUMENT_GREATER_THAN_5:
            {
                int nArgument = GetLocalInt(oArea, AREA_COUNTER_1);
                nResult = nArgument > 5;

                Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName() + ".LANDSMEET_PLAYER_ARGUMENT_GREATER_THAN_5", "Landsmeet approval value is: " + IntToString(nArgument));

                break;
            }
            case LANDSMEET_CAUTHRIEN_CONVINCED_5_PLUS:
            {
                nResult = nCauthrienConvinced >= 5;
                break;
            }
            case LANDSMEET_ALISTAIR_SPEAKS_AFTER_LANDSMEET:
            {
                //int bLoveTriangle   = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA)
                //                      && WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE);

                int bAlistairSpeaks = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ON_THRONE, TRUE)
                                      && WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_LOGHAIN_KILLED);
                                      //WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_IS_KING)
                                      //|| WR_GetPlotFlag(PLT_DENPT_ALISTAIR, DEN_ALISTAIR_MARRYING_PLAYER)
                                      //|| bLoveTriangle;



                nResult = bAlistairSpeaks;
                break;
            }
            case LANDSMEET_ANORA_QUEEN_OR_PLAYER_KING:
            {
                int bQueen = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ANORA_IS_QUEEN);
                int bKing = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_PLAYER_IS_KING);
                if((bQueen == TRUE) || (bKing == TRUE))
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