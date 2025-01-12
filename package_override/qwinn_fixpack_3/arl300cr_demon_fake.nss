//::///////////////////////////////////////////////
//:: Creature Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Events script for the 3 "fake" versions of the desire demon fought in the Arl
    Eamon fade area. The demons disapear when close to death and activate portals
    for the player to continue.
*/
//:://////////////////////////////////////////////
//:: Created By: David Sims
//:: Created On: January 8th, 2009
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "arl_constants_h"

#include "plt_arl300pt_fade"
#include "plt_arl200pt_remove_demon"
                
// Qwinn added, used below.
vector QwConvToVector(float x, float y, float z)
  { return Vector(x,y,z);     }

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;
    object oThis = OBJECT_SELF;


    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creatures suffered 1 or more points of damage in a
        //       single attack
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DAMAGED:
        {
            object oDamager = GetEventCreator(ev);
            int nDamage = GetEventInteger(ev, 0);
            int nDamageType = GetEventInteger(ev, 1);

            int nHealthLeft = GetHealth(oThis);

            if (nHealthLeft <= 1)
            {
                object oConnor = UT_GetNearestCreatureByTag(oPC, ARL_CR_FAKE_CONNOR);

                if (WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_DEMON_FIGHT_3) == TRUE)
                {
                    UT_TeamGoesHostile(ARL_TEAM_DEMON_4, FALSE);
                    UT_TeamAppears(ARL_TEAM_DEMON_4, TRUE);
                    // (v3.4) Qwinn added next two lines, fixes demon randomly buried to her waist in the ground. RE3242
                    object oRealDemon = UT_GetNearestCreatureByTag(oPC,ARL_CR_DEMON);
                    SetPosition(oRealDemon,QwConvToVector(31.4947,42.3776,57.3335),FALSE);
                    object[] oDoorArray = GetTeam(ARL_TEAM_DEMON_4, OBJECT_TYPE_PLACEABLE);
                    object oDoor = oDoorArray[0];
                    SetObjectInteractive(oDoor, TRUE);
                    RemoveEffectsByParameters(oDoor, EFFECT_TYPE_VISUAL_EFFECT);
                    ApplyEffectVisualEffect(oPC, oDoor, ARL_VFX_FADE_ACTIVE_PORTAL, EFFECT_DURATION_TYPE_PERMANENT, 0.0);
                    object oWP = UT_GetNearestObjectByTag(oPC, ARL_WP_MAPNOTE_FADE_PORTAL_4);
                    SetMapPinState(oWP, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_DEMON_FIGHT_2) == TRUE)
                {
                    object[] oDoorArray = GetTeam(ARL_TEAM_DEMON_3, OBJECT_TYPE_PLACEABLE);
                    object oDoor = oDoorArray[0];
                    SetObjectInteractive(oDoor, TRUE);
                    RemoveEffectsByParameters(oDoor, EFFECT_TYPE_VISUAL_EFFECT);
                    ApplyEffectVisualEffect(oPC, oDoor, ARL_VFX_FADE_ACTIVE_PORTAL, EFFECT_DURATION_TYPE_PERMANENT, 0.0);
                    WR_SetObjectActive(oConnor, TRUE);
                    object oWP = UT_GetNearestObjectByTag(oPC, ARL_WP_MAPNOTE_FADE_PORTAL_3);
                    SetMapPinState(oWP, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_DEMON_FIGHT_1) == TRUE)
                {
                    object[] oDoorArray = GetTeam(ARL_TEAM_DEMON_2, OBJECT_TYPE_PLACEABLE);
                    object oDoor = oDoorArray[0];
                    SetObjectInteractive(oDoor, TRUE);
                    RemoveEffectsByParameters(oDoor, EFFECT_TYPE_VISUAL_EFFECT);
                    ApplyEffectVisualEffect(oPC, oDoor, ARL_VFX_FADE_ACTIVE_PORTAL, EFFECT_DURATION_TYPE_PERMANENT, 0.0);
                    WR_SetObjectActive(oConnor, TRUE);
                    object oWP = UT_GetNearestObjectByTag(oPC, ARL_WP_MAPNOTE_FADE_PORTAL_2);
                    SetMapPinState(oWP, TRUE);
                }

                //Apply some cool visual effects and make the demon disapear.
                ApplyEffectVisualEffect(oThis, oThis, 1005, EFFECT_DURATION_TYPE_PERMANENT, 0.0);
                UT_CombatStop(oThis, oPC);

                event evDeathSequenceMiddle = Event(ARL_EVENT_DEMON_DEATH_SEQUENCE_MIDDLE);

                DelayEvent(1.0, oThis, evDeathSequenceMiddle);

            }

            break;
        }

        case ARL_EVENT_DEMON_DEATH_SEQUENCE_MIDDLE:
        {


            //SetAppearanceType(oThis, 0);
            object oTarget = CreateObject(OBJECT_TYPE_PLACEABLE, ARL_R_IP_FADE_INVISIBLE_TARGET, GetLocation(oThis));
            ApplyEffectVisualEffect(oPC, oTarget, 1047, EFFECT_DURATION_TYPE_TEMPORARY, 2.5);
            DestroyObject(oTarget, 5000);

            event evDeathSequenceEnd = Event(ARL_EVENT_DEMON_DEATH_SEQUENCE_END);
            DelayEvent(0.3, oThis, evDeathSequenceEnd);
        }
        break;

        case ARL_EVENT_DEMON_DEATH_SEQUENCE_END:
        {
            DestroyObject(oThis);
        }
        break;

        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creature dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DEATH:
        {
            object oKiller = GetEventCreator(ev);
            object oConnor = UT_GetNearestCreatureByTag(oPC, ARL_CR_FAKE_CONNOR);

            Log_Trace(LOG_CHANNEL_PLOT, "arl300cr_demon", "One of the demons has died.");

            if (WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_DEMON_FIGHT_FINAL) == TRUE)
            {
                //jumps the player out of the fade.
                WR_SetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_RESOLVED, TRUE, TRUE);
            }
            else

            break;

        }


    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}