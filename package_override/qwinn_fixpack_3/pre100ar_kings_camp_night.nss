//::///////////////////////////////////////////////
//:: Area Core
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
// King's camp night area script
*/
//:://////////////////////////////////////////////
//:: Created By: Craig Graff
//:: Created On: July 19th, 2007
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "party_h"

#include "pre_functions_h"
#include "plt_zz_prept_debug"
#include "plt_zz_genpt_char_creation"
#include "plt_gen00pt_party"
#include "plt_pre100pt_light_beacon"
#include "plt_bhn000pt_main"
#include "plt_gen00pt_backgrounds"

#include "pre100_atmosphere_h"
#include "plt_pre100pt_ambient"
#include "plt_pre100pt_prisoner"
#include "plt_pre100pt_mabari"
#include "plt_gen00pt_stealing"

#include "plt_qwinn"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;

    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripting
        // When: Atmosphere needs to fade
        ////////////////////////////////////////////////////////////////////////
        case EVENT_ATM_FADE:
        {
            ATM_HandleEventFade( ev );
            nEventHandled = TRUE;
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        ///////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOADSAVE_POSTLOADEXIT:
        {
            if (WR_GetPlotFlag(PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_CAILAN_CHARGE_CUTSCENE))
            {
                SetAtmosphericConditions( ATM_PRESET_BATTLE );
                SetCloudConditions( ATM_PRESET_CLOUD_BATTLE );
                SetFBSettings( ATM_PRESET_FB_BATTLE );
                SetFogConditions( ATM_PRESET_FOG_BATTLE );
            }

            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: it is for playing things like cutscenes and movies when
        // you enter an area, things that do not involve AI or actual game play
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            object oDog = Party_GetFollowerByTag(GEN_FL_DOG);
            object oSickDog = UT_GetNearestCreatureByTag(oPC, PRE_CR_DOG);
            object oGossip1 = UT_GetNearestCreatureByTag(oPC, PRE_CR_GOSSIP_1);
            object oGossip2 = UT_GetNearestCreatureByTag(oPC, PRE_CR_GOSSIP_2);
            object oEvangelist = UT_GetNearestCreatureByTag(oPC, PRE_CR_EVANGELIST);
            object oPrisoner = UT_GetNearestCreatureByTag(oPC, PRE_CR_PRISONER);
            object oVet = UT_GetNearestCreatureByTag(oPC, PRE_CR_VET);

            object oEvangelistTalkTrig = UT_GetNearestObjectByTag(oPC, PRE_TR_EVANGELIST_TALK);
            object oGossipTalkTrig = UT_GetNearestObjectByTag(oPC, PRE_TR_GOSSIP_TALK);
            object oSergeantTalkTrig = UT_GetNearestObjectByTag(oPC, PRE_TR_SERGEANT_TALK);
            object oStealingTalkTrig = UT_GetNearestObjectByTag(oPC, PRE_TR_STEALING_TALK);

            // @joshua: Setup Teams and Merge them as required for combat tactics
            UT_SetTeamStationary(PRE_TEAM_CAMP_NIGHT_ATTACK_3_DS_DEFEND, AI_STATIONARY_STATE_SOFT);
            UT_SetTeamStationary(PRE_TEAM_CAMP_NIGHT_ATTACK_1_DS_RANGED, AI_STATIONARY_STATE_HARD);
            UT_SetTeamStationary(PRE_TEAM_CAMP_NIGHT_ATTACK_2_DS_RANGED, AI_STATIONARY_STATE_HARD);
            UT_SetTeamStationary(PRE_TEAM_CAMP_NIGHT_ATTACK_3_DS_RANGED, AI_STATIONARY_STATE_HARD);
            UT_SetTeamStationary(PRE_TEAM_CAMP_NIGHT_ATTACK_2_DEFENDERS, AI_STATIONARY_STATE_SOFT);

            UT_TeamMerge(PRE_TEAM_CAMP_NIGHT_ATTACK_1_DS_RANGED, PRE_TEAM_CAMP_NIGHT_ATTACK_1);
            UT_TeamMerge(PRE_TEAM_CAMP_NIGHT_ATTACK_2_DS_RANGED, PRE_TEAM_CAMP_NIGHT_ATTACK_2);
            UT_TeamMerge(PRE_TEAM_CAMP_NIGHT_ATTACK_3_DS_DEFEND, PRE_TEAM_CAMP_NIGHT_ATTACK_3);
            UT_TeamMerge(PRE_TEAM_CAMP_NIGHT_ATTACK_3_DS_RANGED, PRE_TEAM_CAMP_NIGHT_ATTACK_3);

            if (WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_PC_KNOWS_ABOUT_DOG) == TRUE)
            {
                SetPlotGiver(oVet, 0);
            }

            //if player is human noble, put dog by fire
            if (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE)
                && IsObjectValid(oDog) && !WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY))
            {
                WR_SetObjectActive(oDog, TRUE);
                UT_LocalJump(oDog, PRE_WP_DUNCANS_FIRE_DOG);
            }

            if (WR_GetPlotFlag(PLT_GEN00PT_STEALING, STEALING_PRE_DUNCAN_TALKED_TO_PC))
            {
                WR_SetObjectActive(oStealingTalkTrig, FALSE);
            }


            if (WR_GetPlotFlag(PLT_PRE100PT_AMBIENT, PRE_AMBIENT_GOSSIP_END_3))
            {
                WR_SetObjectActive(oGossipTalkTrig, FALSE);
                WR_SetObjectActive(oGossip1, FALSE);
                WR_SetObjectActive(oGossip2, FALSE);
            }
            if (WR_GetPlotFlag(PLT_PRE100PT_AMBIENT, PRE_AMBIENT_EVANGELIST_END_3))
            {
                WR_SetObjectActive(oEvangelistTalkTrig, FALSE);
                UT_LocalJump(oEvangelist, PRE_WP_EVANGELIST_PRAYS);
            }
            if (WR_GetPlotFlag(PLT_PRE100PT_AMBIENT, PRE_AMBIENT_SERGEANT_END_3))
            {
                WR_SetObjectActive(oSergeantTalkTrig, FALSE);
            }
            if (WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_DOG_KILLED)
                && !IsDead(oSickDog))
            {
                KillCreature(oSickDog);
            }
            if (WR_GetPlotFlag(PLT_PRE100PT_PRISONER, PRE_PRISONER_KILLED)
                && GetObjectActive(oPrisoner))//!IsDead(oPrisoner))
            {
                WR_SetObjectActive(oPrisoner, FALSE);
            }
            else
            {
                SetCreatureGoreLevel(oPrisoner, 0.25);
            }
            // Qwinn added
            if (WR_GetPlotFlag(PLT_PRE100PT_PRISONER,PRE_PRISONER_PC_GIVEN_FOOD))
            {
                object oGuard = UT_GetNearestCreatureByTag(oPC, PRE_CR_PRISONER_GUARD);
                UT_RemoveItemFromInventory (PRE_IM_WATER, 1, oGuard);
                UT_RemoveItemFromInventory (PRE_IM_FOOD, 1, oGuard);
            }

            // Qwinn added
            if (WR_GetPlotFlag(PLT_QWINN, PRE_HARDYS_BELT_STOLEN))
            {
                object oQuarter = UT_GetNearestCreatureByTag(oPC, "pre100cr_quarter");
                SetLocalInt(oQuarter, FLAG_STOLEN_FROM, TRUE);
            }



            if (WR_GetPlotFlag(PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_TOWER_REACHED))
            {
                // reapply rain effect as necessary
                RemoveVisualEffect(oPC, VFX_RAIN);
                ApplyEffectOnObject( EFFECT_DURATION_TYPE_PERMANENT, EffectVisualEffect( VFX_RAIN ), oPC );
            }
            else
            {
                // Heal the party on returning to the camp, but not after reaching tower
                PRE_HealParty();
            }

            // DEBUG
            PRE_SetupGroupHostility();
            if (WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_SIGNAL_TOWER)
            || WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_SIGNAL_TOWER_TOP))
            {
               WR_SetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_SIGNAL_TOWER, FALSE);
               WR_SetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_SIGNAL_TOWER_TOP, FALSE);

               WR_SetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_KILL_ALL_HOSTILES, TRUE, TRUE);
            } //END DEBUG

            if (ReadIniEntry("DebugOptions","E3Mode") == "1" ||
                    GetLocalInt(GetModule(), DEMO_ACTIVE) == TRUE)
            {
                object oCutsceneTrig2 = GetObjectByTag("zz_trigger_e3_ds_cutscene");
                WR_SetObjectActive(oCutsceneTrig2, TRUE);
                // Remove darkspawn encounter - first outside tower
                object oTrig1 = GetObjectByTag("5");
                WR_DestroyObject(oTrig1);
                object oTrig2 = GetObjectByTag("pre100tr_campattack1_appear");
                WR_DestroyObject(oTrig2);

                // Kill friendly soldiers
                object oSold1 = GetObjectByTag("pre100cr_soldier_2", 0);
                object oSold2 = GetObjectByTag("pre100cr_soldier_2", 1);
                KillCreature(oSold1, oPC);
                KillCreature(oSold2, oPC);


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
            if (WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_CAMP_NIGHT, TRUE))
            {
                WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_CAMP_NIGHT, FALSE);
                if (WR_GetPlotFlag(PLT_ZZ_GENPT_CHAR_CREATION, DEBUG_START_PRELUDE_NIGHT))
                {
                    WR_SetPlotFlag(PLT_ZZ_GENPT_CHAR_CREATION, DEBUG_START_PRELUDE_NIGHT, FALSE);
                } //don't talk if the player is coming from character creation
                else
                {
                    UT_Talk(oPC, oPC, ZZ_PRE_DEBUG);
                }
            } //END DEBUG
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);
            RevealCurrentMap();

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);

            break;
        }


    }
    if (!nEventHandled)
    {
        HandleEvent(ev, PRE_RS_AREA_CORE);
    }
}