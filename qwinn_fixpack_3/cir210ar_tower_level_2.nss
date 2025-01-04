//::///////////////////////////////////////////////
//:: Area Core for the Spoiled Princess
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events for Tower Level 2
*/
//:://////////////////////////////////////////////
//:: Created By: Gary
//:: Created On: 2009-01-26
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "cutscenes_h"


#include "cir_constants_h"
#include "cir_functions_h"
#include "cir_mapgui_h"
#include "stealing_h"
#include "lit_constants_h"

//For Dagna
#include "orz_constants_h"

#include "plt_cir_area_jumps"
#include "plt_cir000pt_encounters"
#include "plt_cir000pt_main"
#include "plt_cir300pt_fade"
#include "plt_gen00pt_stealing"
#include "plt_cir000pt_sounds_flags"

#include "plt_cod_cha_greagoir"
#include "plt_cod_lite_tow_regret"

#include "plt_orz200pt_dagna"
#include "plt_lite_mage_places"

// Qwinn added for Bel's Cache fix
#include "plt_qwinn"
// Qwinn added for Godwin/Greagoir check below
#include "plt_orz400pt_rogek"

#include "sys_audio_h"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;

    object oThis = OBJECT_SELF;
    object oTarg, oWP, oDoor;
    object oPC = GetHero();

    int nEventHandled = FALSE;

    switch(nEventType)
    {

        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            Log_Plot( "You are on the second floor of Circle Tower." );

            object oCreature = GetEventCreator(ev);

            object oPC = oCreature;
            object oParty = GetParty(oPC);

            int nOnce = GetLocalInt(OBJECT_SELF, ENTERED_FOR_THE_FIRST_TIME);
            if(!nOnce)
            {
                //Save game
                DoAutoSave(); //Save on first entering the second floor
            }

            //If uldred died but we haven't updated the sounds, do that now
            if(WR_GetPlotFlag(PLT_CIR000PT_SOUNDS_FLAGS, SOUNDS_ON_SECOND_FLOOR_TOGGLED) == FALSE && WR_GetPlotFlag( PLT_CIR000PT_MAIN,ULDRED_DEAD) == TRUE)
            {
                WR_SetPlotFlag(PLT_CIR000PT_SOUNDS_FLAGS, SOUNDS_ON_SECOND_FLOOR_TOGGLED, TRUE); //Set this so it doesn't fire again
                AudioTriggerPlotEvent(CIR_AUDIO_TOGGLE_ULDRED_DIES_TOWER_LEVEL_2);
                SetMusicVolumeStateByTag(CIR_MUSIC_ULDRED_DIES, CIR_MUSIC_ULDRED_DIES_STATE);
            }

            //Toggle creatures if uldred has died
            if(WR_GetPlotFlag(PLT_CIR000PT_MAIN, ULDRED_DEAD) == TRUE)
            {
                //If all the mages were killed then we purge the rest of the mages
                // Qwinn:  This could allow Godwin to respawn after being killed or
                // after you report him to Greagoir.

                object oGodwin = GetObjectByTag(CIR_CR_GODWIN);
                if((WR_GetPlotFlag(PLT_CIR000PT_MAIN, ALL_MAGES_DEAD) == FALSE) &&
                   (WR_GetPlotFlag(PLT_ORZ400PT_ROGEK, ORZ_ROGEK_GREAGOIR_TOLD) == FALSE) &&
                   (WR_GetPlotFlag(PLT_CIR000PT_ENCOUNTERS, GODWIN_KILLED) == FALSE))
                {
                 WR_SetObjectActive(oGodwin, TRUE);
                 SetObjectInteractive(oGodwin, TRUE);
                }
                else
                {
                 WR_SetObjectActive(oGodwin, FALSE);
                }

                //Either way disable the closet
                SetObjectInteractive(GetObjectByTag(CIR_IP_GODWIN_CLOSET), FALSE);

                //Disable Owain (he doesn't have a store anymore and his dialogue is related so he is ditched)
                WR_SetObjectActive(GetObjectByTag(CIR_CR_OWAIN), FALSE);

                //Disable any hostile creatures that are left
                UT_TeamAppears(CIR_TEAM_HOSTILES_DEACTIVATE, FALSE);
            }

            //if player has found the letter - activate the Light Content - Maelefactor Regrets cache
            //Qwinn:  Added CACHE_ACTIVATED flag so cache doesn't get activated after it has been looted
            /*
            if(WR_GetPlotFlag(PLT_COD_LITE_TOW_REGRET, TOW_REGRET_MAIN) == TRUE)
            {
                object oCache = UT_GetNearestObjectByTag(oPC, CIR_IP_REGRET_CACHE);
                SetObjectInteractive(oCache, TRUE);
            }
            */

            if(WR_GetPlotFlag(PLT_COD_LITE_TOW_REGRET, TOW_REGRET_MAIN) == TRUE &&
               WR_GetPlotFlag(PLT_QWINN, LITE_TOW_REGRET_CACHE_ACTIVATED) == FALSE)
            {
                object oCache = UT_GetNearestObjectByTag(oPC, CIR_IP_REGRET_CACHE);
                SetObjectInteractive(oCache, TRUE);
                WR_SetPlotFlag(PLT_QWINN, LITE_TOW_REGRET_CACHE_ACTIVATED, TRUE);
            }


            break;
        }

        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID
            switch (nTeamID)
            {
                case CIR_TEAM_BLOOD_MAGES_L2:
                {
                    if(WR_GetPlotFlag(PLT_CIR000PT_MAIN, BLOOD_MAGE_1_KILLED) == FALSE)
                    {
                        object oBloodMage = GetObjectByTag(CIR_CR_BLOOD_MAGE_1_2);
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, EffectResurrection(), oBloodMage);
                        UT_Talk(oBloodMage, oPC);
                        //Disable the barriers
                        UT_TeamAppears(CIR_BLOOD_MAGE_BARRIER, FALSE, OBJECT_TYPE_PLACEABLE);
                    }
                    break;
                }
            }
            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
    }
}