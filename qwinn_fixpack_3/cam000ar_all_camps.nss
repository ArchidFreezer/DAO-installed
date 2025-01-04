//==============================================================================
/*
    cam000ar_all_camps.nss
    Camp area script - This script should be used for all camp areas.
*/
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"

#include "camp_constants_h"
#include "camp_functions_h"
#include "campaign_h"
#include "cutscenes_h"

#include "global_objects_h"
#include "sys_injury"

#include "party_h"

#include "plt_cod_cha_leliana"
#include "plt_cod_cha_wynne"
#include "plt_cod_mgc_enchantment"

#include "plt_mnp000pt_generic"
#include "plt_mnp000pt_main_rumour"
#include "plt_mnp000pt_camp_events"
#include "plt_mnp000pt_main_events"

#include "plt_gen00pt_party"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_oghren"
#include "plt_genpt_app_wynne"
#include "plt_genpt_leliana_main"
#include "plt_genpt_oghren_main"
#include "plt_genpt_oghren_events"
#include "plt_tut_party_camp"
#include "plt_ntb000pt_main"
#include "plt_orzpt_main"
#include "plt_arl000pt_contact_eamon"
#include "plt_cir000pt_main"
#include "plt_pre100pt_generic"

// Qwinn added
// Hotfix v3.51 - Qwinn changed
// #include "plt_genpt_morrigan_events"
#include "plt_qwinn"

//------------------------------------------------------------------------------

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;

    object oPC = GetHero();

    object  [] arParty  = GetPartyPoolList();
    int     nSize       = GetArraySize(arParty);
    int     nLoop;


    switch(nEventType)
    {
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            // if camp3 (archdemon event) then fire cutscene
            // can be entered only once
            if(GetTag(OBJECT_SELF) == "cam110ar_camp_arch3")
            {
                WR_SetPlotFlag(PLT_MNP000PT_MAIN_EVENTS, ARCHDEMON_EVENT_TWO, TRUE);

                Log_Trace(LOG_CHANNEL_PLOT, GetCurrentScriptName(), "WORLD MAP: triggering Archdemon event II (cutscene) ");
                CS_LoadCutscene(CUTSCENE_ARCHDEMON_EVENT_TWO);

            }
            break;
        }
        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: all game objects in the area have loaded
        //----------------------------------------------------------------------
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            object  oParty          =   GetParty(oPC);
            object  oBodahn         =   UT_GetNearestCreatureByTag(oPC,CAMP_BODAHN);
            object  oSandal         =   UT_GetNearestCreatureByTag(oPC,CAMP_SANDAL);
            object  oWagon          =   UT_GetNearestObjectByTag(oPC, CAMP_PL_WAGON);
            object  oNug            =   UT_GetNearestObjectByTag(oPC, CAMP_NUG);
            object  oEmissaryDalish =   UT_GetNearestCreatureByTag(oPC, CAMP_EMISSARY_DALISH);
            object  oEmissaryDwarf  =   UT_GetNearestCreatureByTag(oPC, CAMP_EMISSARY_DWARF);
            object  oEmissaryEamon  =   UT_GetNearestCreatureByTag(oPC, CAMP_EMISSARY_EAMON);
            object  oEmissaryTranquil = UT_GetNearestCreatureByTag(oPC, CAMP_EMISSARY_TRANQUIL);
            object  oEmissaryWerewolf = UT_GetNearestCreatureByTag(oPC, CAMP_EMISSARY_WEREWOLF);
            object  oSupplyCrate    =   UT_GetNearestObjectByTag(oPC, CAMP_PL_ALLIED_SUPPLIES);

            object  [] arParty  =   GetPartyPoolList();
            int     nSize       =   GetArraySize(arParty);
            int     nLoop;

            string sAreaTag     =   GetTag(OBJECT_SELF);

            Log_Trace(LOG_CHANNEL_SYSTEMS, "cam000ar_all_camps.main", "CAMP AREA FINISHED LOADING");

            InitHeartbeat(oPC, CONFIG_CONSTANT_HEARTBEAT_RATE); // Not really needed. Added as an extra line of defense.

            Camp_PlaceFollowersInCamp();

            object oMap = GetObjectByTag(WM_WOW_TAG);
            object oCampLocation = GetObjectByTag(WML_WOW_CAMP);
            SetWorldMapPlayerLocation(oMap, oCampLocation);

            // If the shriek encounter is going to happen.
            if(sAreaTag == CAM_AR_ARCH3)
            {
                for(nLoop = 0; nLoop < nSize; nLoop++)
                {
                    // This is so the party member will die, but not corpse decay.
                    SetEventScript(arParty[nLoop], RESOURCE_SCRIPT_PLAYER_CORE);

                    // The party cannot be immortal.
                    SetImmortal(arParty[nLoop], FALSE);

                }
            }

            //object oLothering = GetObjectByTag(WML_WOW_LOTHERING);
            //WR_SetWorldMapLocationStatus(oLothering, WM_LOCATION_ACTIVE);

            int nBodahnLeaves   =   WR_GetPlotFlag( PLT_MNP000PT_MAIN_RUMOUR, MAIN_RUMOUR_BODAHN_LEAVES_PERMANENTLY);
            int nBodahnRescued  =   WR_GetPlotFlag( PLT_MNP000PT_MAIN_RUMOUR, MAIN_RUMOUR_BODAHN_RESCUED);
            int nNug            =   WR_GetPlotFlag( PLT_GENPT_LELIANA_MAIN, LELIANA_MIAN_LELIANA_HAS_NUG);


            // Did Leliana recieve her gift Nug
            if (nNug)
                SetObjectActive(oNug, TRUE);

            // Check if Wynne is warm for Codex Entry
            if ((WR_GetPlotFlag(PLT_GENPT_APP_WYNNE, APP_WYNNE_IS_WARM)) &&
                ((WR_GetPlotFlag(PLT_COD_CHA_WYNNE, COD_CHA_WYNNE_QUOTE_2) == FALSE)))
            {
                WR_SetPlotFlag(PLT_COD_CHA_WYNNE, COD_CHA_WYNNE_QUOTE_1, FALSE);
                WR_SetPlotFlag(PLT_COD_CHA_WYNNE, COD_CHA_WYNNE_QUOTE_2, TRUE);

            }

            // Check if Leliana is Adore
            if (WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_ADORE) == TRUE)
            {
                WR_SetPlotFlag(PLT_COD_CHA_LELIANA, COD_CHA_LELIANA_ROMANCE_QUOTE, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_LELIANA, COD_CHA_LELIANA_INITIAL_QUOTE, FALSE);
            }

            if((nBodahnLeaves == FALSE) && (nBodahnRescued == TRUE) && !(sAreaTag == CAM_AR_ARCH3))
            {
                int bSandalTalkedTo =   WR_GetPlotFlag(PLT_COD_MGC_ENCHANTMENT, CAMP_GO_TALK_TO_SANDAL);

                // Check to see if Sandal has been talked to for the Enchantment codex quest.
                if(bSandalTalkedTo == FALSE)
                {

                    WR_SetPlotFlag(PLT_COD_MGC_ENCHANTMENT, CAMP_GO_TALK_TO_SANDAL, TRUE, TRUE);

                }

                WR_SetObjectActive(oWagon, TRUE);

                if(GetObjectActive(oSandal) == FALSE)
                {
                    WR_SetObjectActive(oSandal,TRUE);
                }

                if(GetObjectActive(oBodahn) == FALSE)
                {
                    WR_SetObjectActive(oBodahn,TRUE);
                }
            }
            if(nBodahnLeaves == TRUE)
            {
                WR_SetObjectActive(oWagon, FALSE);

                if(GetObjectActive(oSandal) == TRUE)
                {
                    WR_SetObjectActive(oSandal,FALSE);
                }

                if(GetObjectActive(oBodahn) == TRUE)
                {
                    WR_SetObjectActive(oBodahn,FALSE);
                }
            }

            //Light Content - Stocking the Camp
            //Check for Dalish Emissary or Werewolf Emissary
            if (WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE) == TRUE)
            {
                SetObjectInteractive(oSupplyCrate, TRUE);
                WR_SetObjectActive(oEmissaryDalish, TRUE);
            }
            else if (WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE) == TRUE)
            {
                SetObjectInteractive(oSupplyCrate, TRUE);
                WR_SetObjectActive(oEmissaryWerewolf, TRUE);
            }
            //Check for Dwarf Emissary
            if (WR_GetPlotFlag(PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_DONE, TRUE) == TRUE)
            {
                SetObjectInteractive(oSupplyCrate, TRUE);
                WR_SetObjectActive(oEmissaryDwarf, TRUE);
            }
            //Check for Eamon Emissary
            if (WR_GetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_EAMON_REVIVED) == TRUE)
            {
                SetObjectInteractive(oSupplyCrate, TRUE);
                WR_SetObjectActive(oEmissaryEamon, TRUE);
            }
            //Check for Tranquil Emissary
            if (WR_GetPlotFlag(PLT_CIR000PT_MAIN, MAGES_IN_ARMY) == TRUE || WR_GetPlotFlag(PLT_CIR000PT_MAIN, TEMPLARS_IN_ARMY) == TRUE)
            {
                SetObjectInteractive(oSupplyCrate, TRUE);
                WR_SetObjectActive(oEmissaryTranquil, TRUE);
            }

            // Deset Camp flag for Leliana
            WR_SetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_STILL_IN_CAMP, FALSE);

            //checks if Oghren is in Crisis
            int nOghrenCrisis = WR_GetPlotFlag(PLT_GENPT_APP_OGHREN,APP_OGHREN_IS_CRISIS,TRUE);

            if(nOghrenCrisis == TRUE)
            {
                int nOghrenOnce = WR_GetPlotFlag(PLT_GENPT_OGHREN_MAIN,OGHREN_MAIN_CRISIS_ONCE);
                int nOghrenGone = WR_GetPlotFlag(PLT_GENPT_OGHREN_MAIN,OGHREN_MAIN_LEAVES_FOR_GOOD);
                int nOghrenKilled = WR_GetPlotFlag(PLT_GENPT_OGHREN_MAIN,OGHREN_MAIN_KILLED);

                if(nOghrenOnce == FALSE)
                {
                    WR_SetPlotFlag(PLT_GENPT_OGHREN_EVENTS,OGHREN_EVENT_CRISIS,TRUE);
                }
                else if((nOghrenGone == FALSE) && (nOghrenKilled == FALSE))
                {
                    WR_SetPlotFlag(PLT_GENPT_OGHREN_EVENTS,OGHREN_EVENT_CRISIS_AGAIN,TRUE);
                }
            }


            RevealCurrentMap();


            // Next - dialog events
            // All the logic is inside the 'party_camp' dialog - all this script
            // needs to do is trigger the dialog. If any follower has something to say
            // the dialog will trigger, otherwise - nothing will happen

            // Triggering the camp dialog only if the what-to-do-next dialog already fired in Lothering (by entering it)
            if(GetTag(OBJECT_SELF) == "cam104ar_camp_arch1" &&
                WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_ENTERED_LOTHERING))
            {
                CS_LoadCutscene(CUTSCENE_ARCHDEMON_EVENT_ONE, PLT_MNP000PT_CAMP_EVENTS, CAMP_EVENT_TALK_ABOUT_DREAM);
            }
            // Qwinn added
            // Hotfix v3.51 - Qwinn changed
            // else if((WR_GetPlotFlag( PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_FLEMITH_PLOT_COMPLETED) &&
            else if((WR_GetPlotFlag( PLT_QWINN, MORRIGAN_HAVE_REAL_GRIMOIRE_AND_AT_CAMP) &&
                     WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED)))
            {
                object oMorrigan = UT_GetNearestCreatureByTag(oPC,GEN_FL_MORRIGAN);
                UT_Talk(oMorrigan,oPC);
            }
            else if(WR_GetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_ENTERED_LOTHERING))
                UT_Talk(oPC, oPC, GEN_DL_CAMP_EVENTS);


            break;
        }

        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: fires at the same time that the load screen is going away,
        // and can be used for things that you want to make sure the player sees.
        //----------------------------------------------------------------------
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            Injury_RemoveAllInjuriesFromParty();

            //Activate First Party Camp Tutorial.
            WR_SetPlotFlag(PLT_TUT_PARTY_CAMP, TUT_FIRST_PARTY_CAMP, TRUE);

            break;
        }

        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: A creature enters the area
        //----------------------------------------------------------------------
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_SYSTEMS, "cam000ar_all_camps.main", "OBJECT ENTERING CAMP");

            WR_SetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);

            if (WR_GetPlotFlag(PLT_PRE100PT_GENERIC, PRE_GENERIC_PARTY_LEFT_PRELUDE_AREAS) == FALSE)
            {
                WR_SetPlotFlag(PLT_PRE100PT_GENERIC, PRE_GENERIC_PARTY_LEFT_PRELUDE_AREAS, TRUE);
            }

            break;
        }
        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: A creature exits the area
        //----------------------------------------------------------------------
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_SYSTEMS, "cam000ar_all_camps.main", "OBJECT LEAVING CAMP");

            if(IsFollower(oCreature))
            {
                WR_SetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, FALSE);
                // The party picker GUI is triggered in sp_module just before the area transition call
                // ShowPartyPickerGUI();
            }
            break;
        }

        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID

            switch(nTeamID)
            {
                case CAMP_TEAM_DARKSPAWN_CAMP_ATTACKERS:    // Shrieks
                {

                    Log_Trace(LOG_CHANNEL_PLOT, GetCurrentScriptName(), "Shriek attackers died - triggering Tamlen if present");

                    object oTamlen = GetObjectByTag(CAMP_DARKSPAWN_TAMLEN);

                    for(nLoop = 0; nLoop < nSize; nLoop++)
                    {
                        // If any of the party died, resurrect them.
                        if(IsDeadOrDying(arParty[nLoop]))
                        {
                            ResurrectCreature(arParty[nLoop]);
                        }

                    }

                    if(IsObjectValid(oTamlen) && GetObjectActive(oTamlen) == TRUE)
                    {
                        UT_Talk(oTamlen, oPC);
                    }

                    else
                    {

                        // Trigger the party reactions to having been attacked.
                        object  oAlistair   =   GetObjectByTag(GEN_FL_ALISTAIR);

                        UT_Talk(oAlistair, oPC, CAM_POST_SHRIEK_ATTACK);

                    }

                    break;
                }

                case CAMP_TEAM_TAMLEN:
                {

                    object  oAlistair   =   GetObjectByTag(GEN_FL_ALISTAIR);

                    UT_Talk(oAlistair, oPC, CAM_POST_SHRIEK_ATTACK);

                }

            }

            break;
        }
    }
    HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
}