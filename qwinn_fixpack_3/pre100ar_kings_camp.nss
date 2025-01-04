//::///////////////////////////////////////////////
//:: pre100ar_kings_camp.nss
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
// King's camp area script
// On enter: King Cailan inits conversation
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 17th, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "cutscenes_h"
#include "pre_objects_h"
#include "pre_functions_h"
#include "sys_ambient_h"

#include "plt_pre100pt_darkspn_blood"
#include "plt_prept_talked_to"
#include "plt_pre100pt_prisoner"
#include "plt_zz_prept_debug"
#include "plt_gen00pt_party"
#include "plt_cod_cha_cailan"
#include "plt_cod_cha_loghain"
#include "plt_mnp00pt_ssf_prelude"     

// Qwinn added
#include "plt_gen00pt_backgrounds"


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
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: it is for playing things like cutscenes and movies when
        // you enter an area, things that do not involve AI or actual game play
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            object oDuncan = UT_GetNearestObjectByTag(oPC, PRE_CR_DUNCAN);
            object oCailan = UT_GetNearestObjectByTag(oPC, PRE_CR_CAILAN);
            object oGuard1 = UT_GetNearestCreatureByTag(oPC, PRE_CR_KINGS_GUARD_1);
            object oGuard2 = UT_GetNearestCreatureByTag(oPC, PRE_CR_KINGS_GUARD_2);
            object oGuardP = UT_GetNearestCreatureByTag(oPC, PRE_CR_PRISONER_GUARD);

            if(!WR_GetPlotFlag(PLT_PRE100PT_DARKSPN_BLOOD, PRE_BLOOD_PLOT_ACCEPTED)
            // DEBUG
            && !WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_CAMP_DAY)
            && !WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_DEMO2))
            // END DEBUG

            // Did not get one of the initial plots -> did not leave the area yet -> this is the first time the player enters
            {
                // JE: Cutscene is now attached to the first line of dialog,
                // so it transitions better to the rest of the dialog.
                //CS_LoadCutscene(CUTSCENE_PRE_INTRO, "", -1, PRE_CR_CAILAN);

                UT_Talk(oCailan, oPC);
                WR_SetPlotFlag(PLT_COD_CHA_CAILAN, COD_CHA_CAILAN_MAIN, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_MAIN, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_LOGHAIN, COD_CHA_LOGHAIN_QUOTE, TRUE);
            }
            else if(WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_DEMO2) == TRUE)
            {
                WR_SetObjectActive(oCailan, FALSE);
                WR_SetObjectActive(oGuard1, FALSE);
                WR_SetObjectActive(oGuard2, FALSE);
                UT_LocalJump(oDuncan, PRE_WP_DUNCANS_FIRE);
            }

            if (ReadIniEntry("DebugOptions","E3Mode") == "1" ||
                    GetLocalInt(GetModule(), DEMO_ACTIVE) == TRUE)
            {
                if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED) == TRUE)
                {
                    // remove dog
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED, FALSE, TRUE);
                    // set loadscreen

                }

                object oChest = GetObjectByTag("zz_e3_camp_chest");
                WR_SetObjectActive(oChest, TRUE);
                // close army gate
                object oGate = GetObjectByTag("pre100ip_camp_gate");
                object oGateOpen = GetObjectByTag("pre100ip_camp_gate_open");
                WR_SetObjectActive(oGate, TRUE);
                WR_SetObjectActive(oGateOpen, FALSE);
                DEBUG_ConsoleCommand("runscript warrior 7");
            }

            SetObjectInteractive(oGuardP, FALSE);



            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            object oDuncan = UT_GetNearestObjectByTag(oPC, PRE_CR_DUNCAN);
            object oCailan = UT_GetNearestObjectByTag(oPC, PRE_CR_CAILAN);
            object oGuard1 = UT_GetNearestCreatureByTag(oPC, PRE_CR_KINGS_GUARD_1);
            object oGuard2 = UT_GetNearestCreatureByTag(oPC, PRE_CR_KINGS_GUARD_2);
            object oPrisoner = UT_GetNearestCreatureByTag(oPC, PRE_CR_PRISONER);
            object oVet = UT_GetNearestCreatureByTag(oPC, PRE_CR_VET);
            object oVetTrig = UT_GetNearestObjectByTag(oPC, PRE_TR_VET);

            if (GetObjectActive(oPrisoner))
            {
                SetCreatureGoreLevel(oPrisoner, 0.25);
            }

            // Qwinn:  Fixed because this triggers for "noble" when it should just be "human noble"
            // if (GetPlayerBackground(oPC) == 5)
            if (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE))
            {
                SetPlotGiver(oVet, FALSE);
                WR_SetObjectActive(oVetTrig, FALSE);
            }

            //DEBUG: if using the debugger, deactivate Cailan and guards
            if (WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_CAMP_DAY))
            {
                WR_SetObjectActive(oCailan, FALSE);
                WR_SetObjectActive(oGuard1, FALSE);
                WR_SetObjectActive(oGuard2, FALSE);
            } // END DEBUG
            else
            {
                if(WR_GetPlotFlag(PLT_PRE100PT_DARKSPN_BLOOD, PRE_BLOOD_PLOT_ACCEPTED))
                // Entering camp AFTER receiving the darkspawn blood plot -> returning from the wilds
                {
                    // RE-setup camp actors
                    UT_LocalJump(oDuncan, PRE_WP_DUNCANS_FIRE);
                    WR_SetObjectActive(oCailan, FALSE);
                    WR_SetObjectActive(oGuard1, FALSE);
                    WR_SetObjectActive(oGuard2, FALSE);

                    // Set triggers inactive
                    object oArgueTalk = UT_GetNearestObjectByTag(oPC, PRE_TR_ARGUE_TALK);
                    WR_SetObjectActive(oArgueTalk, FALSE);

                    if(WR_GetPlotFlag(PLT_PREPT_TALKED_TO, PRE_TT_ASH_WARRIORS))
                    {
                        object oAshWarriorsTalk = UT_GetNearestObjectByTag(oPC, PRE_TR_ASH_WARRIORS);
                        WR_SetObjectActive(oAshWarriorsTalk, FALSE);
                    }
                }
            }

            //WR_SetPlotFlag(PLT_MNP00PT_SSF_PRELUDE, SSF_PRELUDE_START, TRUE);

            // Set up any environmental effects.
            PRE_SetupEnvironmentEffects();

            // Heal the party on returning to the camp
            PRE_HealParty();

            PRE_TeamUnequipSlot(PRE_TEAM_CAMP_CHANTRY_SERVICE, INVENTORY_SLOT_HEAD);


            if (ReadIniEntry("DebugOptions","E3Mode") == "1" ||
                    GetLocalInt(GetModule(), DEMO_ACTIVE) == TRUE)
            {
                // DEMO
                // Give clothes to the poor prisoner
                resource rClothes = R"gen_im_cth_com_d00.uti";
                object oClothes = CreateItemOnObject(rClothes, oPrisoner);
                EquipItem(oPrisoner, oClothes, INVENTORY_SLOT_CHEST);
            }

            //
            // Ambient Behaviour
            //

            // Start archery practice.
            WR_AddCommand(GetObjectByTag("pre100cr_archer1"), CommandWait(RandomFloat()));
            WR_AddCommand(GetObjectByTag("pre100cr_archer2"), CommandWait(RandomFloat()));
            WR_AddCommand(GetObjectByTag("pre100cr_archer3"), CommandWait(RandomFloat()));

            // Guards - stationary
//          Ambient_Start(GetObjectByTag("pre100cr_soldier_road"),  AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, AMBIENT_ANIM_PATTERN_WANDER_R, AMBIENT_ANIM_FREQ_RANDOM);
//          Ambient_Start(GetObjectByTag("pre100cr_soldier_dying"), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, AMBIENT_ANIM_PATTERN_WANDER_LR, AMBIENT_ANIM_FREQ_RANDOM);

            // Guards - wandering
//          Ambient_StartTag("pre100cr_soldier_patrol", AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_RANDOM, AMBIENT_MOVE_PREFIX_NONE, AMBIENT_ANIM_PATTERN_NONE, AMBIENT_ANIM_FREQ_RANDOM);


            // Sleeping dogs
//            Ambient_Start(GetObjectByTag("pre100cr_dog_vet_ambient_1"), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 2, AMBIENT_ANIM_FREQ_ORDERED);
//            Ambient_Start(GetObjectByTag("pre100cr_dog_vet_ambient_2"), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 2, AMBIENT_ANIM_FREQ_ORDERED);

            // Wynne
//            Ambient_Start(GetObjectByTag("pre100cr_wynne"), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 19, AMBIENT_ANIM_FREQ_ORDERED);

            // Barking dogs
//            Ambient_Start(GetObjectByTag("pre100cr_dog_vet_ambient_3"), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 4, AMBIENT_ANIM_FREQ_RANDOM);
//            Ambient_Start(GetObjectByTag("pre100cr_dog_vet_ambient_4"), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 4, AMBIENT_ANIM_FREQ_RANDOM);

            // Knights praying
            Ambient_Start(GetObjectByTag("pre100cr_knight_fem"), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 1, AMBIENT_ANIM_FREQ_ORDERED);
            Ambient_Start(GetObjectByTag("pre100cr_knight_1"), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 1, AMBIENT_ANIM_FREQ_ORDERED);
            Ambient_Start(GetObjectByTag("pre100cr_knight_2"), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE,33, AMBIENT_ANIM_FREQ_ORDERED);

            // Evangelist audience
/*            int i = 0;
            object oCreature = GetObjectByTag("audience", i++);
            while (IsObjectValid(oCreature))
            {
                Ambient_Start(oCreature, AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, (Random(2) ? 11 : 14), AMBIENT_ANIM_FREQ_RANDOM);
                SetLookAtEnabled(oCreature, FALSE);
                oCreature = GetObjectByTag("audience", i++);
            }
*/
            // Captain's audience
//            Ambient_Start(GetObjectByTag("pre100cr_soldier_fem", 0), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 11, AMBIENT_ANIM_FREQ_RANDOM);
//            Ambient_Start(GetObjectByTag("pre100cr_soldier_fem", 1), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 11, AMBIENT_ANIM_FREQ_RANDOM);
//            Ambient_Start(GetObjectByTag("pre100cr_soldier_2", 1), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 11, AMBIENT_ANIM_FREQ_RANDOM);
//            Ambient_Start(GetObjectByTag("pre100cr_soldier_3", 1), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 14, AMBIENT_ANIM_FREQ_RANDOM);
//            Ambient_Start(GetObjectByTag("pre100cr_soldier_chatting", 1), AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 14, AMBIENT_ANIM_FREQ_RANDOM);

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: fires at the same time that the load screen is going away,
        // and can be used for things that you want to make sure the player sees.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            //DEBUG: if using the debugger, reopen debug conversation
            if (WR_GetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_CAMP_DAY))
            {
                WR_SetPlotFlag(PLT_ZZ_PREPT_DEBUG, DEBUG_JUMP_TO_CAMP_DAY, FALSE);
                UT_Talk(oPC, oPC, ZZ_PRE_DEBUG);
            } // END DEBUG

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