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

// Qwinn added so can check if Wynne is recruited so her team death doesn't activate her codex death
#include "plt_gen00pt_party"

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

#include "sys_audio_h"

// Qwinn added
#include "plt_arl200pt_remove_demon"

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
            Log_Plot( "You are on the first floor of Circle Tower." );

            // activate world map location
            object oTower = GetObjectByTag(WML_WOW_TOWER);
            object oMap = GetObjectByTag(WM_WOW_TAG);
            WR_SetWorldMapLocationStatus(oTower, WM_LOCATION_ACTIVE, TRUE);
            WR_SetWorldMapPlayerLocation(oMap, oTower);
            
            int nOnce = GetLocalInt(OBJECT_SELF, ENTERED_FOR_THE_FIRST_TIME);
            if(!nOnce)
            {
                UT_Talk(UT_GetNearestCreatureByTag(oPC,CIR_CR_GREAGOIR),oPC);
            }

            // *** AREA JUMP checks ***
            // Cullen and Irving go to Greagoir for the end of the Plot
            if ( WR_GetPlotFlag( PLT_CIR000PT_MAIN,ULDRED_DEAD) )
            {
                //Check to see if the plot should be set to post plot
                CIR_CheckAndSetPostPlot();

                //Disable any hostiles that are still left
                UT_TeamAppears(CIR_TEAM_HOSTILES_DEACTIVATE, FALSE);

                //The random templars have gone.
                UT_TeamAppears(CIR_TEAM_RANDOM_TEMPLARS, FALSE);

                if (!WR_GetPlotFlag( PLT_CIR000PT_MAIN,ULDRED_SITUATION_RESOLVED))
                {
                    //Set the wounded templar to gone
                    WR_SetObjectActive(GetObjectByTag(CIR_CR_WOUNDED_TEMPLAR), FALSE);
                    WR_SetObjectActive(GetObjectByTag(CIR_TR_WOUNDED_AMBIENT_1), FALSE);

                    oTarg = UT_GetNearestObjectByTag(oPC, CIR_IP_GREAGOIR_DOOR);
                    SetPlaceableState(oTarg,PLC_STATE_DOOR_OPEN);

                    //Set up audio in this area (this will only fire once)
                    AudioTriggerPlotEvent(CIR_AUDIO_TOGGLE_ULDRED_DIES_TOWER_LEVEL_1); //Hit this as soon as he has died

                    SetMusicVolumeStateByTag(CIR_MUSIC_ULDRED_DIES, CIR_MUSIC_ULDRED_DIES_STATE);

                }

                //Cullen
                object oCullen;
                oCullen = UT_GetNearestObjectByTag(oPC, CIR_CR_CULLEN);
                WR_SetObjectActive(oCullen, TRUE);

                if (!WR_GetPlotFlag(PLT_CIR000PT_MAIN,ALL_MAGES_DEAD))
                {
                    oTarg = UT_GetNearestObjectByTag(oPC, CIR_CR_IRVING);
                    // Qwinn:  Added condition to this so Irving doesn't reappear when he's
                    // in Redcliffe.
                    // WR_SetObjectActive(oTarg,TRUE);
                    int bIrvingInRedcliffe = 
                        WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_BRING_MAGES_TO_REDCLIFFE) &&
                       !WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_DEMON_DEALT_WITH);
                    WR_SetObjectActive(oTarg, !bIrvingInRedcliffe);

                    //Set up the injured mages here
                    //We have a happy mage ending so enable the mages downstairs.
                    WR_SetObjectActive(GetObjectByTag(CIR_CR_WOUNDED_MAGE), TRUE);
                    WR_SetObjectActive(GetObjectByTag(CIR_TR_WOUNDED_AMBIENT_2), TRUE);

                    WR_SetObjectActive(GetObjectByTag(CIR_CR_THANKFUL_MAGE), TRUE);
                    WR_SetObjectActive(GetObjectByTag(CIR_CR_THANKFUL_MAGE_2), TRUE);

                    //Set the plot flag for Keili being talked to (she doesn't have a plot plot line)
                    WR_SetPlotFlag(PLT_CIR000PT_TALKED_TO, KEILI_TALKED_TO, TRUE);
                }

                if (WR_GetPlotFlag(PLT_CIR000PT_MAIN, POST_PLOT) == TRUE) //If we are in post plot
                {
                    //Jump cullen to his post plot spot
                    UT_LocalJump(oCullen, CIR_WP_CULLEN_POST_PLOT);

                    //Set the wounded to gone.
                    WR_SetObjectActive(GetObjectByTag(CIR_CR_WOUNDED_MAGE), FALSE);

                    // Dead mages, templars, and bloodstains disappear.
                    UT_TeamAppears(CIR_TEAM_DEAD_MAGES_AND_TEMPLAR, FALSE, OBJECT_TYPE_ALL);
                }

                //If the PC killed Wynne then kill all the mages (as everyone has been clensed)
                if(WR_GetPlotFlag(PLT_CIR000PT_MAIN, WYNNE_KILLED) == TRUE)
                {
                    UT_TeamAppears(CIR_TEAM_MAGE_KIDS, FALSE);
                    UT_TeamAppears(CIR_TEAM_WYNNE_HOSTILE, FALSE);
                }

                //Add in templars that are post plot
                UT_TeamAppears(CIR_TEAM_POST_TEMPLAR, TRUE);

                oTarg = UT_GetNearestObjectByTag(oPC, CIR_CR_KEILI);
                UT_LocalJump(oTarg,CIR_WP_KEILI);

                oTarg = UT_GetNearestObjectByTag(oPC, CIR_CR_KINNON);
                UT_LocalJump(oTarg,CIR_WP_KINNON);

                oTarg = UT_GetNearestObjectByTag(oPC, CIR_CR_PETRA);
                UT_LocalJump(oTarg,CIR_WP_PETRA);

                oTarg = UT_GetNearestObjectByTag(oPC, CIR_CR_KID);
                UT_LocalJump(oTarg,CIR_WP_KIDS);

                if ( WR_GetPlotFlag( PLT_CIR_AREA_JUMPS, PC_JUMPS_TO_FIRST))
                {
                    WR_SetPlotFlag( PLT_CIR_AREA_JUMPS, PC_JUMPS_TO_FIRST, FALSE);
                    WR_SetPlotFlag( PLT_CIR000PT_MAIN, ULDRED_SITUATION_RESOLVED,TRUE);

                    // Greagoir then speaks
                    oTarg = GetObjectByTag(CIR_CR_GREAGOIR);
                    UT_Talk(oTarg, oPC);
                }
            }

            // Dagna
            // Qwinn:  This still spawns Dagna if Gregoire refused her
            // if ( WR_GetPlotFlag( PLT_ORZ200PT_DAGNA, ORZ_DAGNA_LEFT_ORZAMMAR_FOR_TOWER) /*|| WR_GetPlotFlag(PLT_ORZ200PT_DAGNA, ORZ_DAGNA___PLOT_02_IRVING_ACCEPTED)*/ )
            if ( WR_GetPlotFlag(PLT_ORZ200PT_DAGNA, ORZ_DAGNA_LEFT_ORZAMMAR_FOR_TOWER) &&
                 WR_GetPlotFlag(PLT_ORZ200PT_DAGNA, ORZ_DAGNA___PLOT_02_IRVING_ACCEPTED) )
            {
                object oDagna =  UT_GetNearestObjectByTag(oPC, ORZ_CR_DAGNA);  //Get Dagna
                WR_SetObjectActive( oDagna, TRUE );
                SetPlotGiver( oDagna, FALSE );
                WR_SetPlotFlag(PLT_ORZ200PT_DAGNA, ORZ_DAGNA___PLOT_03_COMPLETED, TRUE);
            }

            //Light_Mage_Places
            if ( WR_GetPlotFlag( PLT_LITE_MAGE_PLACES, PLACES_QUEST_GIVEN) == TRUE)
            {
                object oPlace = UT_GetNearestObjectByTag(oPC, LITE_IP_MAGE_MYSTICSITE);
                SetObjectInteractive(oPlace, TRUE);
            }

            // Make the kids immortal. Can't have them dying.
            object [] arKids = GetTeam(CIR_TEAM_MAGE_KIDS);
            object oCurrent;

            int nKids   =   GetArraySize(arKids);
            int nIndex;

            for(nIndex = 0; nIndex < nKids; nIndex++)
            {
                oCurrent = arKids[nIndex];

                if(IsObjectValid(oCurrent))
                {
                    SetImmortal(oCurrent, TRUE);
                }
            }

            break;
        }

        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID
            switch (nTeamID)
            {
                //First floor (I assume)
                case CIR_TEAM_GREAGOIR:
                {
                    WR_SetPlotFlag(PLT_COD_CHA_GREAGOIR, COD_CHA_GREAGOIR_DIES, TRUE, TRUE);
                    break;
                }

                // Wynne
                case CIR_TEAM_WYNNE_HOSTILE:
                {
                    // Qwinn:  Her team can be killed by demon during end of "Watchguard of the Reaching"
                    // Making setting her codex death conditional of her not being recruited at this point.
                    // WR_SetPlotFlag(PLT_CIR000PT_MAIN,WYNNE_KILLED, TRUE, TRUE);

                    if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED) == FALSE)
                    {
                       WR_SetPlotFlag(PLT_CIR000PT_MAIN,WYNNE_KILLED, TRUE, TRUE);
                    }
                    break;

                }
            }
            break;
        }

        //First floor only
        case EVENT_TYPE_STEALING_SUCCESS:
        {
            if (!WR_GetPlotFlag(PLT_CIR000PT_MAIN,GREAGOIR_CLOSES_DOOR) || WR_GetPlotFlag(PLT_CIR000PT_MAIN, ULDRED_SITUATION_RESOLVED))
            { //Before the door is closed or after the situation is over
              //Increment counter
              object oModule = GetModule();
              int nStealCount = GetLocalInt(oModule, STEALING_CIR_COUNTER) + 1;
              SetLocalInt(oModule, STEALING_CIR_COUNTER, nStealCount);

              //Major in case we want to do something else
              if(nStealCount >= STEALING_CIR_COUNTER_INFAMY_MAJOR_REQ && !WR_GetPlotFlag(PLT_GEN00PT_STEALING, STEALING_CIR_INFAMY_MAJOR))
              {
                     WR_SetPlotFlag(PLT_GEN00PT_STEALING, STEALING_CIR_INFAMY_MAJOR, TRUE);
              }
            }
            break;
        }

        //First floor only
        case EVENT_TYPE_STEALING_FAILURE:
        {
           if (!WR_GetPlotFlag(PLT_CIR000PT_MAIN,GREAGOIR_CLOSES_DOOR) || WR_GetPlotFlag(PLT_CIR000PT_MAIN, ULDRED_SITUATION_RESOLVED))
           { //Before the door is closed or after the situation is over
               if(!WR_GetPlotFlag(PLT_GEN00PT_STEALING, STEALING_CIR_STEALING_FAIL))
               {
                    object oGreagoir = UT_GetNearestObjectByTag(oPC, CIR_CR_GREAGOIR);
                    WR_SetPlotFlag(PLT_GEN00PT_STEALING, STEALING_CIR_STEALING_FAIL, TRUE);
                    UT_Talk(oGreagoir, oGreagoir);
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