//::///////////////////////////////////////////////
//:: Area Core
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events for the chantry
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
#include "sys_ambient_h"
#include "sys_audio_h"

#include "arl_constants_h"
#include "lit_constants_h"

#include "plt_arl100pt_siege_prep"
#include "plt_arl100pt_siege"
#include "plt_arl100pt_after_siege"
#include "plt_arl100pt_enter_castle"
#include "plt_arl110pt_bevin_lost"
#include "plt_gen00pt_stealing"
#include "plt_arl000pt_contact_eamon"
#include "plt_lite_fite_condolences"
#include "plt_lite_fite_conscripts"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);

    HandleEvent(ev, ARL_R_GENERIC_AREA_SCRIPT);

    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            Log_Systems("*** AREA FINISHED LOADING", LOG_LEVEL_WARNING);

            int bMurdockChantry = WR_GetPlotFlag(PLT_ARL100PT_AFTER_SIEGE, ARL_AFTER_SIEGE_MURDOCK_IN_CHANTRY, TRUE);
            int bBevinChantry = WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_BEVIN_FOUND, TRUE);
            int bMurdockDead = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_MURDOCK_DIED_IN_SIEGE, TRUE);
            int bBattleOver = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OVER, TRUE);
            int bAbandoned = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_VILLAGE_ABANDONED);
            int bArlSaved = WR_GetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_SAVED_CASTLE_WAITING_ON_CURE);
            int bKaitlynLeft = WR_GetPlotFlag(PLT_ARL110PT_BEVIN_LOST, ARL_BEVIN_LOST_KAITLYN_LEFT_WITH_BEVIN);

            object oJetta = UT_GetNearestCreatureByTag(oPC, LITE_CR_RED_JETTA);
            object oIrenia = UT_GetNearestCreatureByTag(oPC, LITE_CR_CONDOLENCES_WIDOW1);
            object oTeagan = UT_GetNearestCreatureByTag(oPC, ARL_CR_TEAGAN);
            object oBevin = UT_GetNearestCreatureByTag(oPC, ARL_CR_BEVIN);
            object oHannah = UT_GetNearestCreatureByTag(oPC, ARL_CR_HANNAH);
            object oKaitlyn = UT_GetNearestCreatureByTag(oPC, ARL_CR_KAITLYN);

            if (bBattleOver == TRUE)
            {
                // Qwinn:  There is no ARL_TEAM_VILLAGE_POST_BATTLE in the chantry, leaving it very empty
                // 3 villagers aren't moved outside.  Preventing them from being removed.
                if (bAbandoned == FALSE)
                {
                    object oVillager = UT_GetNearestCreatureByTag(oPC,"arl110cr_old_m_ambient1");
                    SetTeamId(oVillager,-1);
                    oVillager = UT_GetNearestCreatureByTag(oPC,"arl110cr_villager_ambient2");
                    SetTeamId(oVillager,-1);
                    oVillager = UT_GetNearestCreatureByTag(oPC,"arl110cr_child_f_2");
                    SetTeamId(oVillager,-1);
                    // Stop her praying
                    Ambient_Start(oVillager, AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_NONE, AMBIENT_MOVE_PREFIX_NONE, 67, AMBIENT_ANIM_FREQ_ORDERED);
                }                    

                UT_TeamAppears(ARL_TEAM_VILLAGERS, FALSE);
                UT_TeamAppears(ARL_TEAM_VILLAGE_POST_BATTLE, TRUE);
            }

            if((bBevinChantry == TRUE) && (bAbandoned == FALSE) && (bKaitlynLeft == FALSE))
            {
                //if Bevin is found and returned to sister, activate him.
                WR_SetObjectActive(oBevin,TRUE);
            }
            else
            {
                WR_SetObjectActive(oBevin,FALSE);
            }

            if ((bBattleOver == TRUE) && (bBevinChantry == FALSE))
            {
                //If Bevin was not found before the siege, Kaitlyn is gone.
                WR_SetObjectActive(oKaitlyn, FALSE);
            }

            //If Bevin has been found, Kaitlyn is no longer a plot giver.
            if (bBevinChantry == TRUE)
            {
                SetPlotGiver(oKaitlyn, FALSE);
                Ambient_Start(oKaitlyn, AMBIENT_SYSTEM_ENABLED | AMBIENT_SYSTEM_SPAWNSTART, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 1);

            }

            // if village was abandoned, deactivate everyone
            if ((bAbandoned == TRUE))
            {
                AudioTriggerPlotEvent(74);

                UT_TeamAppears(ARL_TEAM_VILLAGERS, FALSE);
                WR_SetObjectActive(oKaitlyn, FALSE);
                WR_SetObjectActive(oBevin, FALSE);

                UT_LocalJump(oTeagan, ARL_WP_TEAGAN_UNCONSCIOUS, TRUE);
                SetCreatureGoreLevel(oTeagan, 0.4);
                WR_ClearAllCommands(oTeagan, TRUE);
                Ambient_Start(oTeagan, AMBIENT_SYSTEM_ENABLED | AMBIENT_SYSTEM_SPAWNSTART, AMBIENT_MOVE_INVALID, AMBIENT_MOVE_PREFIX_NONE, 101);

                //Light Content
               //if the Arl has been saved - the light content two can still be here - Jetta and Irenia
               if (bArlSaved == TRUE)
               {
                    WR_SetObjectActive(oJetta, TRUE);
                    WR_SetObjectActive(oIrenia, TRUE);
               }
               else
               {
                    WR_SetObjectActive(oJetta, FALSE);
                    WR_SetObjectActive(oIrenia, FALSE);
               }
            }
            //Light content
            //should the widow have a plot assist
            if (WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_QUEST_GIVEN) == TRUE &&
                WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_1) == FALSE)
            {
                object oWidow = UT_GetNearestCreatureByTag(oPC, LITE_CR_CONDOLENCES_WIDOW1);
                SetPlotGiver(oWidow, TRUE);
            }

            int bOnceB = GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_B);
            if ((bOnceB == FALSE) && (bAbandoned == FALSE))
            {
                SetLocalInt(OBJECT_SELF, AREA_DO_ONCE_B, TRUE);
                //have Lord Teagan initiate dialogue
                UT_Talk(oTeagan, oPC);
            }
            //should conscript have plot assist
            if (WR_GetPlotFlag(PLT_LITE_FITE_CONSCRIPTS, CONSCRIPTS_QUEST_GIVEN) == TRUE &&
                WR_GetPlotFlag(PLT_LITE_FITE_CONSCRIPTS, CONSCRIPTS_RECRUITED_ONE) == FALSE)
            {
                object oConscript = UT_GetNearestCreatureByTag(oPC, LITE_CR_FITE_CONSCRIPT_PATTER);
                SetPlotGiver(oConscript, TRUE);
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

            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);
            Log_Systems("*** Object entered area: " + GetTag(oCreature));

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

        case EVENT_TYPE_STEALING_FAILURE:
        {
            WR_SetPlotFlag(PLT_GEN00PT_STEALING, STEALING_ARL_INFAMY, TRUE, TRUE);
            break;
        }

    }
    HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
}