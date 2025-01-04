//::///////////////////////////////////////////////
//:: Area Core
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events for the castle upstairs
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: May 31/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "arl_constants_h"
#include "arl_functions_h"
#include "party_h"
#include "sys_audio_h"

#include "plt_arl300pt_fade"
#include "plt_arl200pt_remove_demon"
#include "plt_arl000pt_contact_eamon"
#include "plt_gen00pt_stealing"'
#include "plt_gen00pt_party"   

#include "plt_qwinn"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    object oArea = OBJECT_SELF;

    HandleEvent(ev, ARL_R_GENERIC_AREA_SCRIPT);

    switch(nEventType)
    {

        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            object oConnor = UT_GetNearestCreatureByTag(oPC, ARL_CR_CONNOR);
            object oEamon = UT_GetNearestCreatureByTag(oPC, ARL_CR_EAMON);
            object oTeagan = UT_GetNearestCreatureByTag(oPC, ARL_CR_TEAGAN);
            object oDemon = UT_GetNearestCreatureByTag(oPC, ARL_CR_CASTLE_DEMON);
            object oDemon2 = UT_GetNearestCreatureByTag(oPC, ARL_CR_CASTLE_DEMON_2);
            object oDemon3 = UT_GetNearestCreatureByTag(oPC, ARL_CR_CASTLE_DEMON_3);


            int bEamonAwake = WR_GetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_EAMON_REVIVED);
            int bEamonSpokeAfterAwake = WR_GetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_EAMON_UPDATED_ON_SITUATION);
            int bEndCutsceneOver = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_JUMP_FOR_FINAL_CONVERSATION);
            int bCastleNormal = WR_GetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_CASTLE_NORMAL_EAMON_NOT_REVIVED);
            int bDemonGone = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_DEMON_DEALT_WITH);
            // Qwinn Added
            int bVaultLocked = WR_GetPlotFlag(PLT_QWINN, ARL_CONTACT_EAMON_CASTLE_VAULT_LOCKED);


            if ((bEamonAwake == TRUE) && (bEamonSpokeAfterAwake == FALSE))
            {

                UT_Talk(oEamon, oPC);
            }

            //Get rid of all the hostile creatures once the castle is saved.
            if (bDemonGone == TRUE)
            {
                SetMusicVolumeStateByTag("castle_4", 3);

                //Remove the demon's corpse
                WR_SetObjectActive(oDemon, FALSE);
                WR_SetObjectActive(oDemon2, FALSE);
                WR_SetObjectActive(oDemon3, FALSE);

                //Lock the vault (player can still pick)
                object oVaultDoor = UT_GetNearestObjectByTag(oPC, ARL_IP_CASTLE_VAULT_DOOR);
                // SetPlaceableState(oVaultDoor, PLC_STATE_DOOR_LOCKED);

                // Qwinn:  Making sure this only happens once, so it doesn't become source of infinite xp
                if (bVaultLocked == FALSE)
                {
                   WR_SetPlotFlag(PLT_QWINN, ARL_CONTACT_EAMON_CASTLE_VAULT_LOCKED, TRUE);
                   SetPlaceableState(oVaultDoor, PLC_STATE_DOOR_LOCKED);
                }

                //Get rid of the Autosave trigger
                object oConnorSaveTrigger = UT_GetNearestObjectByTag(oPC, ARL_TR_CONNOR_AUTOSAVE);
                DestroyObject(oConnorSaveTrigger);

            }

            if ((bEndCutsceneOver == TRUE) && (bEamonAwake == FALSE) && (bCastleNormal == FALSE))
            {
                object oDoor1 = UT_GetNearestObjectByTag(oPC, ARL_IP_DOOR_DEMON_FIGHT_1);
                object oDoor2 = UT_GetNearestObjectByTag(oPC, ARL_IP_DOOR_DEMON_FIGHT_2);
                object oDoor3 = UT_GetNearestObjectByTag(oPC, ARL_IP_DOOR_DEMON_FIGHT_3);

                SetPlaceableState(oDoor1, PLC_STATE_DOOR_OPEN);
                SetPlaceableState(oDoor2, PLC_STATE_DOOR_OPEN);
                SetPlaceableState(oDoor3, PLC_STATE_DOOR_OPEN);

                //Change the ambient sounds in the castle:
                AudioTriggerPlotEvent(15);

                UT_Talk(oTeagan, oPC);
            }

            int bOnceA = GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A);
            if (bOnceA == FALSE)
            {
                SetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A, TRUE);
                ARL_SetTeamGroup(ARL_TEAM_CASTLE_UPSTAIRS_AMBUSH, GROUP_NEUTRAL);
                ARL_SetTeamGroup(ARL_TEAM_CONNOR_DEMON_CORPSE, GROUP_NEUTRAL);
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
            

        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);

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
        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripting
        // When: The last creature of a team dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID

            if (nTeamID == ARL_TEAM_CONNOR_DEMON_CORPSE)
            {
                object oDemon2 = UT_GetNearestCreatureByTag(oPC, ARL_CR_CASTLE_DEMON_2);

                WR_SetObjectActive(oDemon2, TRUE);
                int nHealth = GetLocalInt(oArea, AREA_COUNTER_1);
                if (nHealth >= 1)
                {
                    SetCurrentHealth(oDemon2, IntToFloat(nHealth));
                }
                object oTarget = CreateObject(OBJECT_TYPE_PLACEABLE, ARL_R_IP_FADE_INVISIBLE_TARGET, GetLocation(oDemon2));
                ApplyEffectVisualEffect(oPC, oDemon2, 1047, EFFECT_DURATION_TYPE_TEMPORARY, 2.5);
                DestroyObject(oTarget, 5000);

                Log_Trace(LOG_CHANNEL_PLOT, "arl230ar_castle_upstairs.nss", "Corpse team destroyed.");

                //Get rid of the corpses with some visual effect.
                object[] oCorpseArray = GetNearestObjectByTag(oPC, ARL_CR_CASTLE_DEMON_CORPSE, OBJECT_TYPE_ALL, 10);
                int nArraysize = GetArraySize(oCorpseArray);
                int nIndex = 0;
                for (nIndex = 0; nIndex < nArraysize; nIndex++)
                {
                    object oCorpse = oCorpseArray[nIndex];
                    ApplyEffectVisualEffect(oArea, oCorpse, 1135, EFFECT_DURATION_TYPE_INSTANT, 0.0);
                    Log_Trace(LOG_CHANNEL_PLOT, "arl230ar_castle_upstairs.nss", "A corpse was visualy effected");
                    DestroyObject(oCorpse, 500);

                }

            }
            else if (nTeamID == ARL_TEAM_CONNOR_DEMON_RAGE_DEMONS)
            {
                object oDemon3 = UT_GetNearestCreatureByTag(oPC, ARL_CR_CASTLE_DEMON_3);
                WR_SetObjectActive(oDemon3, TRUE);
                int nHealth = GetLocalInt(oArea, AREA_COUNTER_1);
                if (nHealth >= 1)
                {
                    SetCurrentHealth(oDemon3, IntToFloat(nHealth));
                }
                object oTarget = CreateObject(OBJECT_TYPE_PLACEABLE, ARL_R_IP_FADE_INVISIBLE_TARGET, GetLocation(oDemon3));
                ApplyEffectVisualEffect(oPC, oDemon3, 1047, EFFECT_DURATION_TYPE_TEMPORARY, 2.5);
                DestroyObject(oTarget, 5000);


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