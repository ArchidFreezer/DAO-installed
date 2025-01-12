//::///////////////////////////////////////////////
//:: Area Core
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events for redcliffe village
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Mar 6/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "cutscenes_h"
#include "party_h"
#include "sys_ambient_h"
#include "sys_audio_h"

#include "arl_constants_h"
#include "arl_functions_h"
#include "lit_functions_h"

#include "plt_cod_hst_redcliffe"

#include "plt_arl000pt_talked_to"
#include "plt_arl000pt_contact_eamon"
#include "plt_arl000pt_ambient"
#include "plt_arl100pt_siege"
#include "plt_arl100pt_after_siege"
#include "plt_arl100pt_enter_castle"
#include "plt_arl100pt_siege_prep"
#include "plt_arl100pt_equip_militia"
#include "plt_arl100pt_holy_amulet"
#include "plt_arl100pt_activate_shale"
#include "plt_arl100pt_oil_stores"
#include "plt_arl100pt_post_plot"
#include "plt_arl110pt_bevin_lost"
#include "plt_arl120pt_find_valena"
#include "plt_arl130pt_recruit_dwyn"
#include "plt_arl150pt_loghain_spy"
#include "plt_arl150pt_tavern_drinks"
#include "plt_arl200pt_remove_demon"
#include "plt_arl200pt_castle_combat"

#include "plt_genpt_alistair_main"
#include "plt_genpt_leliana_main"
#include "plt_gen00pt_party"
#include "plt_gen00pt_backgrounds"
#include "plt_gen00pt_stealing"
#include "plt_lite_fite_blackstone"
#include "plt_lite_mage_collective"
#include "plt_lite_mage_silence"
#include "plt_lite_mage_defending"
#include "plt_lite_rogue_pieces"
#include "plt_lite_mabari_dom"
#include "plt_gen00pt_party"

// Qwinn added
#include "plt_qwinn"
#include "plt_arl150pt_loghain_spy"
#include "plt_den200pt_chanter"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);

    //Generic Arl Eamon area event handling.
    //Mostly activating and deactivating creatures.
    HandleEvent(ev, ARL_R_GENERIC_AREA_SCRIPT);

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: it is for playing things like cutscenes and movies when
        // you enter an area, things that do not involve AI or actual game play
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            int bPlayCutscene = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_START_FUNERAL_CUTSCENE);
            int bCutscenePlayed = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_JUMP_FOR_FINAL_CONVERSATION);

            if ((bPlayCutscene == TRUE) && (bCutscenePlayed == FALSE))
            {
                CS_LoadCutscene(CUTSCENE_ARL_REDCLIFFE_ENDING, PLT_ARL200PT_REMOVE_DEMON,
                    ARL_REMOVE_DEMON_JUMP_FOR_FINAL_CONVERSATION);
            }

            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            Log_Systems("*** AREA FINISHED LOADING", LOG_LEVEL_WARNING);

            object oTeagan = UT_GetNearestCreatureByTag(oPC,ARL_CR_TEAGAN);

            object oScavenger = UT_GetNearestCreatureByTag(oPC, ARL_CR_SCAVENGER);
            object oShale = UT_GetNearestCreatureByTag(oPC, GEN_FL_SHALE);
            object oBlackstone = UT_GetNearestCreatureByTag(oPC, LITE_CR_FITE_BLACKSTONE);
            object oBlackBox = UT_GetNearestObjectByTag(oPC, LITE_IM_BLACKSTONE_BOX_3);
            object oMageCollective = UT_GetNearestCreatureByTag(oPC, LITE_CR_MAGE_COLLECTIVE);
            object oMageBag = UT_GetNearestObjectByTag(oPC, LITE_IP_MAGE_BAG_3);
            object oChanter = UT_GetNearestCreatureByTag(oPC, ARL_CR_CHANTRY_BOARD);
            object oChanterBoard = UT_GetNearestObjectByTag(oPC, ARL_IP_CHANTRY_BOARD);

            // For if these people are fighting with militia
            int bSiegeOver = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OVER, TRUE);

            // For dialogue with alistair.
            int bRedcliffeEntered = WR_GetPlotFlag(PLT_ARL000PT_CONTACT_EAMON,ARL_CONTACT_EAMON_ENTERED_REDCLIFFE, TRUE);

            int bPerthUsingOil = WR_GetPlotFlag(PLT_ARL100PT_OIL_STORES, ARL_OIL_STORES_PERTH_USING_OIL);

            // For Teagan after village was abandoned
            int nTeaganRuns = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_TEAGAN_RUNS_OUT_TO_FIND_VILLAGE_DESTROYED);
            int nOnceB = GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_B);

            // Village was abandoned
            int nAbandoned = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_VILLAGE_ABANDONED);
            int bLeftVillage = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_PC_LEFT_REDCLIFFE_AFTER_TALKING_TO_TEAGAN);

            int bReturnedFromSiege = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_PLAYER_RETURNS_FROM_SIEGE);
            int bCastleRetaken = WR_GetPlotFlag(PLT_ARL100PT_ENTER_CASTLE, ARL_ENTER_CASTLE_CONNOR_HALL_DEFEATED);

            int bToldContactEamon = WR_GetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_TOLD_TO_CONTACT_EAMON, TRUE);

            // If Shale is fighting with Murdock or Perth
            int bShaleActive = WR_GetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_SHALE_REACTIVATED);
            int bShalePerth = WR_GetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_SHALE_HELPING_MILITIA);
            int bShaleMurdock = WR_GetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_SHALE_HELPING_MILITIA);

            //If the militia is ready for battle
            int bMilitiaReady = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_MURDOCK_READY);

            int bOnceA = GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A);
            int bOwenSuicidal = WR_GetPlotFlag(PLT_ARL120PT_FIND_VALENA, ARL_FIND_VALENA_OWEN_SUICIDAL);

            //If the player is on the holy amulets quest.
            int bOnAmuletsQuest = WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PC_KNOWS_PERTH_WANTS_HOLY_PROT);

            //Update codex with information about Redcliffe.
            WR_SetPlotFlag(PLT_COD_HST_REDCLIFFE, COD_HST_REDCLIFFE, TRUE, TRUE);

            //For the courtyard fight, set which area the player is coming from.
            WR_SetPlotFlag(PLT_ARL200PT_CASTLE_COMBAT, ARL_CASTLE_COMBAT_PLAYER_RECENTLY_IN_VILLAGE, TRUE);
            WR_SetPlotFlag(PLT_ARL200PT_CASTLE_COMBAT, ARL_CASTLE_COMBAT_PLAYER_RECENTLY_IN_DUNGEON, FALSE);

            //Clear the lock on the knights ambient trigger.
            WR_SetPlotFlag(PLT_ARL000PT_AMBIENT, ARL_AMBIENT_KNIGHTS_AMBIENT_LOCKED, FALSE);

            if (bToldContactEamon == FALSE)
            {
                WR_SetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, bToldContactEamon, TRUE, TRUE);
            }

            //If the player is on the holy amulets quest, set that some time has passed (exited and re-entered the area)
            if (bOnAmuletsQuest == TRUE)
            {
                WR_SetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_TIME_PASSED_SINCE_QUEST_GIVEN, TRUE);
            }

            //Slowly equip the militia to give the illusion that Owen is doing the work.
            if (bMilitiaReady == TRUE)
            {
                WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_VILLAGE_ENTERED, TRUE, TRUE);
            }

            //Time has passed since the player talked to Murdock.
            WR_SetPlotFlag(PLT_ARL150PT_TAVERN_DRINKS, ARL_TAVERN_DRINKS_MURDOCK_COMMENTED_ON_SOMETHING_RECENTLY, FALSE, TRUE);

            //If Owen is suicidal, lock his door untill an area transition
            if ((bOwenSuicidal == TRUE) && (bOnceA == FALSE))
            {
                object oOwenDoor = UT_GetNearestObjectByTag(oPC, ARL_IP_DOOR_BLACKSMITH);
                if (GetPlaceableState(oOwenDoor) == PLC_STATE_AREA_TRANSITION_UNLOCKED)
                {
                    SetPlaceableState(oOwenDoor, PLC_STATE_AREA_TRANSITION_LOCKED);
                }
                else
                {
                    SetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A, TRUE);
                    SetPlaceableState(oOwenDoor, PLC_STATE_AREA_TRANSITION_UNLOCKED);
                }
            }

            // Qwinn:  Attempt to fix Redcliffe dead drop not appearing... this was near the bottom
            // of this script, perhaps a UT_Talk above it interrupted the script?  This far up
            // nothing should prevent it from running.
            // Light Content: Dead Drops (Box of Certain Interests)
            WR_SetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_PLOT_SETUP,TRUE,TRUE);

            //for alistair dialogue
            if(bRedcliffeEntered == FALSE)
            {
                WR_SetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_ENTERED_REDCLIFFE, TRUE, TRUE);
                int bAlistairInParty = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE);
                int bAlistairToldTruth = WR_GetPlotFlag(PLT_GENPT_ALISTAIR_MAIN, ALISTAIR_MAIN_TOLD_TRUTH);
                if ( (bAlistairInParty == TRUE) && (bAlistairToldTruth == FALSE) )
                {
                    object oAlistair = Party_GetActiveFollowerByTag(GEN_FL_ALISTAIR);
                    UT_Talk(oAlistair, oPC, ARL_R_CONVERSATION_ALISTAIR_INTRO);
                }
                UT_TeamAppears(ARL_TEAM_VILLAGE_BARRICADES, TRUE, OBJECT_TYPE_PLACEABLE);
            }


            //activates Teagan if he has run out of the chantry
            if((nTeaganRuns == TRUE) && (nOnceB == FALSE))
            {
                SetLocalInt(OBJECT_SELF, AREA_DO_ONCE_B, TRUE);
                SetCreatureGoreLevel(oTeagan, 0.4);
                UT_Talk(oTeagan, oPC);

            }



            //If the player is jumping back to the village after fighting the big battle,
            //start the Teagan conversation, and disable the creatures that died.
            if ( (bSiegeOver == FALSE) && (bReturnedFromSiege == TRUE) )
            {
                AudioTriggerPlotEvent(83);
                UT_TeamAppears(ARL_TEAM_VILLAGE_ARCHERY_TARGETS, FALSE, OBJECT_TYPE_PLACEABLE);
                UT_TeamAppears(ARL_TEAM_VILLAGE_BARRICADES, FALSE, OBJECT_TYPE_PLACEABLE);
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OVER, TRUE, TRUE);

            }

            if (bSiegeOver == TRUE)
            {
                //Activate post battle only npcs.
                UT_TeamAppears(ARL_TEAM_VILLAGE_POST_BATTLE, TRUE, OBJECT_TYPE_PLACEABLE);
                UT_SetTeamInteractive(ARL_TEAM_VILLAGE_POST_BATTLE, FALSE, OBJECT_TYPE_PLACEABLE);
                UT_TeamAppears(ARL_TEAM_VILLAGE_POST_BATTLE, TRUE, OBJECT_TYPE_CREATURE);

                // Qwinn:  If Doomsayer has been dealt with, deactivate him.
                if (WR_GetPlotFlag(PLT_ARL100PT_POST_PLOT,ARL_POST_PLOT_DOOMSAYER_RUNS_OFF))
                {
                    object oDoomsayer = UT_GetNearestCreatureByTag(oPC, ARL_CR_DOOMSAYER);
                    WR_SetObjectActive(oDoomsayer, FALSE);
                }


                object oPyre = UT_GetNearestObjectByTag(oPC, ARL_IP_FUNERAL_PYRE_TARGET);
                RemoveAllEffects(oPyre);
                ApplyEffectVisualEffect(oPyre, oPyre, 4014, EFFECT_DURATION_TYPE_PERMANENT, 0.0);

                //Light Content - Blackstone Irregulars
                WR_SetObjectActive(oBlackstone, TRUE);
                WR_SetObjectActive(oBlackBox, TRUE);
                //Light Content - should the blackstone irregular's box be active
                if (WR_GetPlotFlag(PLT_LITE_FITE_BLACKSTONE, FITE_BLACKSTONE_LEARNED_ABOUT) == TRUE)
                {
                    //fighter box is now available
                    SetObjectInteractive(oBlackBox, TRUE);
                    SetPlotGiver(oBlackstone, BlackstoneTurnInPossible());
                }

                //Light Content - Mage Collective
                WR_SetObjectActive(oMageCollective, TRUE);
                WR_SetObjectActive(oMageBag, TRUE);
                //Light Content - should the mages' collective bag be active
                if (WR_GetPlotFlag(PLT_LITE_MAGE_COLLECTIVE, MAGE_COLLECTIVE_LEARNED_ABOUT) == TRUE)
                {
                    //mage bag is now available
                    SetObjectInteractive(oMageBag, TRUE);
                    //should mage collective dude by marked?
                    SetPlotGiver(oMageCollective, MageCollectiveTurnInPossible(oPC));
                }

                //Light content - chanter's board now available
                WR_SetObjectActive(oChanter, TRUE);
                WR_SetObjectActive(oChanterBoard, TRUE);

                // Qwinn:  Keep quest marker on if they've completed all 10 rewards
                // for the grand prize
                SetPlotGiver(oChanter,((ChanterTurnInPossible() == TRUE) ||
                    (WR_GetPlotFlag(PLT_DEN200PT_CHANTER, CHANTER_BOARD_QUESTS_ALL_DONE) &&
                     WR_GetPlotFlag(PLT_DEN200PT_CHANTER, CHANTER_BIG_REWARD_PC) == FALSE)));

                //Light content - lite_mage_silence - templar harrith is now active
                object oHarrith = UT_GetNearestCreatureByTag(oPC, LITE_CR_MAGE_SILENCE_HARRITH);
                WR_SetObjectActive(oHarrith, TRUE);
                SetObjectInteractive(oHarrith, TRUE);


                //lite_mage_silence is on the mage board (if it hasn't been accepted)
                if ( WR_GetPlotFlag(PLT_LITE_MAGE_SILENCE, SILENCE_QUEST_GIVEN) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_MAGE_SILENCE, SILENCE_MAGE_BOARD, TRUE);
                }
            }

            object oCastleTransition = UT_GetNearestObjectByTag(oPC, ARL_IP_DOOR_VILLAGE_TO_CASTLE);
            object oCastleTransitionMap = UT_GetNearestObjectByTag(oPC, ARL_IP_WORLD_MAP_VILLAGE_TO_CASTLE);
            object oWPCastleMapNote = UT_GetNearestObjectByTag(oPC, ARL_WP_MAPNOTE_VILLAGE_TO_CASTLE);
            object oWPWorldMapMapNote = UT_GetNearestObjectByTag(oPC, ARL_WP_MAPNOTE_VILLAGE_TO_WORLD_MAP_2);

            if (bCastleRetaken == TRUE)
            {
                SetObjectActive(oCastleTransition, FALSE);
                SetObjectActive(oCastleTransitionMap, TRUE);
                SetMapPinState(oWPCastleMapNote, FALSE);
                SetMapPinState(oWPWorldMapMapNote, TRUE);
            }
            else
            {
                SetObjectActive(oCastleTransition, TRUE);
                SetObjectActive(oCastleTransitionMap, FALSE);
                SetMapPinState(oWPCastleMapNote, TRUE);
                SetMapPinState(oWPWorldMapMapNote, FALSE);
            }

            //Activate post plot npcs.
            if ((nAbandoned == FALSE) && (bCastleRetaken == TRUE))
            {
                UT_TeamAppears(ARL_TEAM_POST_SPEECH_AMBIENTS, FALSE);
                UT_TeamAppears(ARL_TEAM_VILLAGE_POST_BATTLE, FALSE, OBJECT_TYPE_PLACEABLE);
                UT_TeamAppears(ARL_TEAM_VILLAGE_POST_BATTLE, FALSE, OBJECT_TYPE_CREATURE);

                // Qwinn added to turn off the pyre
                object oPyre = UT_GetNearestObjectByTag(oPC, ARL_IP_FUNERAL_PYRE_TARGET);
                RemoveAllEffects(oPyre);

                UT_TeamAppears(ARL_TEAM_VILLAGE_POST_CASTLE, TRUE, OBJECT_TYPE_PLACEABLE);
                UT_SetTeamInteractive(ARL_TEAM_VILLAGE_POST_CASTLE, FALSE, OBJECT_TYPE_PLACEABLE);
                UT_TeamAppears(ARL_TEAM_VILLAGE_POST_CASTLE, TRUE, OBJECT_TYPE_CREATURE);
            }

            // if village was abandoned, deactivate everyone, activate the scavenger.
            if ((bLeftVillage == TRUE) && (nAbandoned == TRUE))
            {
                //Update the sound.
                AudioTriggerPlotEvent(73);

                UT_TeamAppears(ARL_TEAM_VILLAGERS, FALSE);
                UT_TeamAppears(ARL_TEAM_KNIGHTS, FALSE);
                UT_TeamAppears(ARL_TEAM_DWYN, FALSE);
                UT_TeamAppears(ARL_TEAM_BERWICK, FALSE);
                UT_TeamAppears(ARL_TEAM_LLOYD, FALSE);
                UT_TeamAppears(ARL_TEAM_VILLAGE_ARCHERY_TARGETS, FALSE, OBJECT_TYPE_PLACEABLE);
                if(WR_GetPlotFlag(PLT_ARL000PT_TALKED_TO, ARL_TALKED_TO_SCAVENGER) == FALSE)
                    WR_SetObjectActive(oScavenger, TRUE);

                WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_OWEN_DOOR_UNLOCKED, TRUE, TRUE);
                object oOwenDoor = UT_GetNearestObjectByTag(oPC, ARL_IP_DOOR_BLACKSMITH);
                SetPlaceableState(oOwenDoor, PLC_STATE_AREA_TRANSITION_UNLOCKED);

                WR_SetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_DOOR_IS_UNLOCKED, TRUE, TRUE);
                object oDwynDoor = UT_GetNearestObjectByTag(oPC, ARL_IP_DOOR_DWYN);
                SetPlaceableState(oDwynDoor, PLC_STATE_AREA_TRANSITION_UNLOCKED);

                //If the player is on any quests, they need to be closed off.
                int bKnowAboutBevin = WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_KAITLYN_TOLD_PC_ABOUT_BEVIN);
                int bAcceptedBevinQust = WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_ACCEPTED_QUEST);
                int bFoundBevin = WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_BEVIN_FOUND);

                if ((bKnowAboutBevin == TRUE) || (bAcceptedBevinQust) || (bFoundBevin))
                {
                    WR_SetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_ABANDONED_VILLAGE_WHILE_ON_QUEST, TRUE, TRUE);
                }

                WR_SetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_VILLAGE_ABANDONED, TRUE, TRUE);
                WR_SetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_ABANDONED_VILLAGE_ENTERED, TRUE, TRUE);

                //If Shale was helping Perth or Murdock, deactivate him for good.
                if ((bShalePerth == TRUE) || (bShaleMurdock == TRUE))
                {
                    WR_SetObjectActive(oShale, FALSE);
                }

                //Set Redcliffe Village as world map enabled.
                object oVillage = GetArea(oPC);
                //Safety check, in case the player is using some kind of debugger.
                if (GetTag(oVillage) == ARL_AR_REDCLIFFE_VILLAGE)
                {
                    SetLocalInt(oVillage, AREA_WORLD_MAP_ENABLED, TRUE);
                }

            }

            //Activate post plot (after castle retaken) abandoned village npcs.
            if ((nAbandoned == TRUE) && (bCastleRetaken == TRUE))
            {
                WR_SetObjectActive(oScavenger, FALSE);
                UT_TeamAppears(ARL_TEAM_VILLAGE_BARRICADES, FALSE, OBJECT_TYPE_PLACEABLE);
                UT_TeamAppears(ARL_TEAM_ABANDONED_VILLAGE_POST_CASTLE, TRUE, OBJECT_TYPE_PLACEABLE);
                UT_SetTeamInteractive(ARL_TEAM_ABANDONED_VILLAGE_POST_CASTLE, FALSE, OBJECT_TYPE_PLACEABLE);
                UT_TeamAppears(ARL_TEAM_ABANDONED_VILLAGE_POST_CASTLE, TRUE, OBJECT_TYPE_CREATURE);

            }

            //If Perth is using the oil and the battle hasn't started, activate the oil barrels.
            if ((bSiegeOver == FALSE) && (bPerthUsingOil == TRUE))
            {
                UT_TeamAppears(ARL_TEAM_VILLAGE_OIL_BARRELS, TRUE, OBJECT_TYPE_PLACEABLE);
                if (WR_GetPlotFlag(PLT_QWINN, ARL_KNIGHTS_SENT_FOR_OIL))
                    WR_SetPlotFlag(PLT_QWINN, ARL_KNIGHTS_SENT_FOR_OIL,FALSE,TRUE);
            }
            else
            {
                UT_TeamAppears(ARL_TEAM_VILLAGE_OIL_BARRELS, FALSE, OBJECT_TYPE_PLACEABLE);
            }

            if (WR_GetPlotFlag(PLT_QWINN, ARL_KNIGHTS_SENT_FOR_AMULETS))
                WR_SetPlotFlag(PLT_QWINN, ARL_KNIGHTS_SENT_FOR_AMULETS,FALSE,TRUE);

            // Qwinn:  Remove letter from berwick if we already have it.
            if (WR_GetPlotFlag(PLT_ARL150PT_LOGHAIN_SPY, ARL_LOGHAIN_SPY_PC_HAS_BERWICKS_LETTER))
            {   object oBerwick = UT_GetNearestCreatureByTag(oPC, ARL_CR_BERWICK);
                UT_RemoveItemFromInventory(ARL_R_IT_SPY_LETTER, 1, oBerwick);
            }
            break;

        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: fires at the same time that the load screen is going away,
        // and can be used for things that you want to make sure the player sees.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {

            //Check for Mabari Dominance
            if (WR_GetPlotFlag(PLT_LITE_MABARI_DOM, MABARI_DOM_REDCLIFFE_VILLAGE) == TRUE)
            {
                //if dog is in the party -
                int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
                if (nDog == TRUE)
                {
                    object oDog = Party_GetFollowerByTag("gen00fl_dog");
                    //if this flag has been set - activate the bonus and show the message
                    UI_DisplayMessage(oDog, 4010);

                    //Activate Bonus here
                    effect eDog = EffectMabariDominance();
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eDog, oDog, 0.0f, oDog, 200261);
                }

            }

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {

            //if dog is in the party -
            int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
            if (nDog == TRUE)
            {
                object oDog = Party_GetFollowerByTag("gen00fl_dog");
                //DeActivate Bonus here
                RemoveEffectsByParameters(oDog, EFFECT_TYPE_INVALID, 200261);
            }

            break;
        }

        case EVENT_TYPE_STEALING_FAILURE:
        {
            WR_SetPlotFlag(PLT_GEN00PT_STEALING, STEALING_ARL_INFAMY, TRUE, TRUE);
            break;
        }
    }
    HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
}