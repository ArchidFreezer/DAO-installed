//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 21st, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "cli_constants_h"
#include "cutscenes_h"
#include "arl_constants_h"
#include "sys_audio_h"
#include "campaign_h"

#include "plt_clipt_main"
#include "plt_genpt_alistair_events"
#include "plt_genpt_loghain_events"
#include "plt_genpt_morrigan_events"
#include "plt_genpt_party_events"
#include "plt_gen00pt_party"
#include "plt_cod_crt_archdemon"
#include "plt_mnp000pt_autoss_main2"
#include "plt_clipt_general_alienage"
#include "plt_clipt_general_market"

#include "cli_functions_h"

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

    object oRiordan = UT_GetNearestCreatureByTag(oPC, CLI_CR_RIORDAN);
    object oTeagan = UT_GetNearestCreatureByTag(oPC, ARL_CR_TEAGAN);
    object oAnora = UT_GetNearestCreatureByTag(oPC, CLI_CR_ANORA);
    object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
    object oLoghain = Party_GetFollowerByTag(GEN_FL_LOGHAIN);

    object oMorriganWait = UT_GetNearestObjectByTag(oPC, CLI_WP_MORRIGAN_WAIT);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case CLI_MAIN_START:
            {
                 // Switch redcliffe locations to new ones
                object oOldVillage = GetObjectByTag(WML_WOW_REDCLIFFE);
                object oOldCastle = GetObjectByTag(WML_WOW_RED_CASTLE);
                object oNewVillage = GetObjectByTag(WML_WOW_REDCLIFFE_VILLAGE_CLIMAX);
                object oNewCastle = GetObjectByTag(WML_WOW_REDCLIFFE_CASTLE_CLIMAX);

                WR_SetWorldMapLocationStatus(oOldVillage, WM_LOCATION_INACTIVE);
                WR_SetWorldMapLocationStatus(oOldCastle, WM_LOCATION_INACTIVE);
                WR_SetWorldMapLocationStatus(oNewVillage, WM_LOCATION_ACTIVE);
                WR_SetWorldMapLocationStatus(oNewCastle, WM_LOCATION_GRAYED_OUT, TRUE);
                break;
            }
            case CLI_MAIN_RIORDAN_GAVE_ARCHDEMON_INFO:
            {
                WR_SetPlotFlag(PLT_COD_CRT_ARCHDEMON, COD_CRT_ARCHDEMON_SECRET_REVEALED, TRUE);
                break;
            }
            case CLI_MAIN_SAVE_REDCLIFFE:
            {
                object oSurvivor = GetObjectByTag(CLI_CR_SURVIVOR);
                WR_SetObjectActive(oSurvivor, FALSE);
                break;
            }
            case CLI_MAIN_SET_CITY_GATES_LEADER_ALISTAIR:
            {
                SetLocalObject(GetModule(), PARTY_LEADER_STORE, oAlistair);
                break;
            }
            case CLI_MAIN_SET_CITY_GATES_LEADER_LELIANA:
            {
                object oLeliana = Party_GetFollowerByTag(GEN_FL_LELIANA);

                SetLocalObject(GetModule(), PARTY_LEADER_STORE, oLeliana);
                break;
            }
            case CLI_MAIN_SET_CITY_GATES_LEADER_LOGHAIN:
            {

                SetLocalObject(GetModule(), PARTY_LEADER_STORE, oLoghain);
                break;
            }
            case CLI_MAIN_SET_CITY_GATES_LEADER_OGHREN:
            {
                object oOghren = Party_GetFollowerByTag(GEN_FL_OGHREN);

                SetLocalObject(GetModule(), PARTY_LEADER_STORE, oOghren);
                break;
            }
            case CLI_MAIN_SET_CITY_GATES_LEADER_SHALE:
            {
                object oShale = Party_GetFollowerByTag(GEN_FL_SHALE);

                SetLocalObject(GetModule(), PARTY_LEADER_STORE, oShale);
                break;
            }
            case CLI_MAIN_SET_CITY_GATES_LEADER_STEN:
            {
                object oSten = Party_GetFollowerByTag(GEN_FL_STEN);

                SetLocalObject(GetModule(), PARTY_LEADER_STORE, oSten);
                break;
            }
            case CLI_MAIN_SET_CITY_GATES_LEADER_WYNNE:
            {
                object oWynne = Party_GetFollowerByTag(GEN_FL_WYNNE);

                SetLocalObject(GetModule(), PARTY_LEADER_STORE, oWynne);
                break;
            }
            case CLI_MAIN_SET_CITY_GATES_LEADER_ZEVRAN:
            {
                object oZevran = Party_GetFollowerByTag(GEN_FL_ZEVRAN);

                SetLocalObject(GetModule(), PARTY_LEADER_STORE, oZevran);
                break;
            }
            case CLI_MAIN_SET_CITY_GATES_LEADER_MORRIGAN:
            {
                object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);

                SetLocalObject(GetModule(), PARTY_LEADER_STORE, oMorrigan);
                break;
            }
            case CLI_MAIN_PC_SELECT_PARTY_AT_CITY_GATES:
            {
                // Trigger party selection screen
                SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);
                ShowPartyPickerGUI();
                break;
            }
            case CLI_MAIN_SPEECH_OVER:
            {
                WR_SetPlotFlag(strPlot, CLI_MAIN_AT_CITY_GATES, TRUE);

                // Tajke an autoscreenshot
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_CLI_THE_CHARGE, TRUE, TRUE);

                // play big charge cutscene
                CS_LoadCutscene(CUTSCENE_CLI_ENEMY_AT_GATES, strPlot, CLI_MAIN_ENEMY_AT_GATES_CUTSCENE_OVER);
                break;
            }
            case CLI_MAIN_ENEMY_AT_GATES_CUTSCENE_OVER:
            {
                // Jump to gameplay area
                UT_DoAreaTransition(CLI_CITY_GATES, CLI_WP_CITY_GATES_START_FIGHT);

                break;
            }
            case CLI_MAIN_PC_FINISHED_SETTING_FINAL_PARTY:
            {
                UT_Talk(oRiordan, oPC);
                // Reactivate party members that were not chosen

                object [] arParty = GetPartyPoolList();
                int nSize = GetArraySize(arParty);
                int i;
                object oCurrent;
                for(i = 0; i < nSize; i++)
                {
                    oCurrent = arParty[i];
                    if(!IsHero(oCurrent))
                    {
                        if(GetFollowerState(oCurrent) != FOLLOWER_STATE_ACTIVE)
                        {
                            WR_SetObjectActive(oCurrent, TRUE);
                            //UT_LocalJump(oCurrent, CLI_WP_CITY_GATES_FOLLOWER_PREFIX + IntToString(i));
                            SetGroupId(oCurrent, GROUP_PC);
                            SetImmortal(oCurrent, TRUE);
                        }
                    }
                }

                // bring lots of soldiers, set talk triggers active
                UT_TeamAppears(100);
                object oTrig1 = GetObjectByTag("gen00tr_cheer1");
                object oTrig2 = GetObjectByTag("gen00tr_cheer2");
                object oTrig3 = GetObjectByTag("gen00tr_cheer3");
                WR_SetObjectActive(oTrig1, TRUE);
                WR_SetObjectActive(oTrig2, TRUE);
                WR_SetObjectActive(oTrig3, TRUE);

                break;
            }
            case CLI_MAIN_RIORDAN_FINISHED_TALKING_IN_REDCLIFFE:
            {
                // Alistair/Loghain go back to their quarters, which is on the same level
                UT_LocalJump(oAlistair, CLI_WP_ALISTAIR_IN_ROOM);
                UT_LocalJump(oLoghain, CLI_WP_LOGHAIN_IN_ROOM);

                // Have Morrigan wait at the player's room (even if she left the party before)

                WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_WAITING_AT_PLAYERS_ROOM, TRUE, TRUE);
                WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_ON, TRUE, TRUE);

                if(!WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED)) // Morrigan has left
                {
                    // find fake Morrigan
                    object oFakeMorrigan = GetObjectByTag("cli310cr_morrigan_fake");
                    // Activate the placed Morrigan object
                    WR_SetObjectActive(oFakeMorrigan, TRUE);
                    // set her tag to match the party Morrigan
                    SetTag(oFakeMorrigan, GEN_FL_MORRIGAN);

                }
                else // Morrigan is still in party -> activate the stored party object
                {
                    object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);
                    string sWP = "cli310wp_" + GetTag(oMorrigan);
                    WR_SetObjectActive(oMorrigan, TRUE);
                    UT_LocalJump(oMorrigan, sWP);
                }
                // Autosave here made Morrigan not turn active on some machines
                //DoAutoSave();

                break;
            }
            case CLI_MAIN_RIORDAN_LEAVES_AT_DENERIM_GATES:
            {
                // Fires once the player exits the party selection screen for the last time
                // global event "entering Denerim at Climax" should start-- this begins a dialogue with
                // all the characters in your party and those not in the party who are your friends/romances.
                // VERY IMPORTANT
                WR_SetObjectActive(oRiordan, FALSE);
                WR_SetPlotFlag(PLT_GENPT_PARTY_EVENTS, PARTY_EVENT_ENTERING_DENERIM_AT_CLIMAX , TRUE, TRUE);

                UT_Talk(oPC, oPC, GEN_DL_PARTY_EVENTS);

                WR_SetPlotFlag(PLT_CLIPT_GENERAL_ALIENAGE, CLIPT_GENERAL_ALIENAGE_FIND, TRUE);
                WR_SetPlotFlag(PLT_CLIPT_GENERAL_MARKET, CLIPT_GENERAL_MARKET_FIND, TRUE);

                AudioTriggerPlotEvent(27);

                break;
            }
            case CLI_MAIN_RIORDAN_WAITING_IN_ROOM:
            {
                if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                    WR_SetObjectActive(oAlistair, FALSE);
                }
                else if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_RECRUITED))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_IN_CAMP, TRUE, TRUE);
                    WR_SetObjectActive(oLoghain, FALSE);
                }

                // Set Alistair/Loghain special event dialog. The second's floor on-enter script will place Alistair near the door
                WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_RIORDAN_WAITING_AT_ROOM, TRUE);
                WR_SetPlotFlag(PLT_GENPT_LOGHAIN_EVENTS, LOGHAIN_EVENT_RIORDAN_WAITING_AT_ROOM, TRUE);

                WR_SetObjectActive(oRiordan, FALSE);
                WR_SetObjectActive(oTeagan, FALSE);
                WR_SetObjectActive(oAnora, FALSE);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case CLI_MAIN_NOT_ENOUGH_FOLLOWERS_TO_DEFEND_GATES:
            {
                // There were no followers left in the party pool to defend the gates after the player picked his
                // party for the climax
                // Qwinn:  Added fix to not count Dog since he can't defend

                int nNum = 0;
                object [] arParty = GetPartyPoolList();
                int nSize = GetArraySize(arParty);
                int i;
                object oCurrent;
                Log_Trace(LOG_CHANNEL_TEMP, "BOOM", "Number of party members: " + IntToString(nSize));

                for(i = 0; i < nSize; i++)
                {
                    oCurrent = arParty[i];
                    Log_Trace(LOG_CHANNEL_TEMP, "BOOM", "follower: " + GetTag(oCurrent) + ", state: " + IntToString(GetFollowerState(oCurrent)));
                    if(GetFollowerState(oCurrent) == FOLLOWER_STATE_AVAILABLE &&
                       !(GetTag(oCurrent) == GEN_FL_DOG))
                        nNum++;
                    Log_Trace(LOG_CHANNEL_TEMP, "BOOM", "available=" + IntToString(nNum));

                }

                if(nNum == 0)
                    nResult = TRUE;
                break;
            }

            case CLI_MAIN_RIORDAN_WAITING_NOT_FINISHED_TALKING:
            {
                if( WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_RIORDAN_WAITING_IN_ROOM) &&
                   !WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_RIORDAN_FINISHED_TALKING_IN_REDCLIFFE) )
                {
                    nResult = TRUE;
                }
                break;
            }
            case CLI_MAIN_ALISTAIR_RECRUITED_AND_KING:
            {
                if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED) &&
                    WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ON_THRONE))
                    nResult = TRUE;
                break;
            }
        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}