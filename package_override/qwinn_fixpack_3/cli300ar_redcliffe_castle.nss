// Climax castle redcliffe main floor script

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "cli_constants_h"
#include "camp_functions_h"
#include "sys_injury"

#include "plt_gen00pt_party"
#include "plt_clipt_main"
#include "plt_arl200pt_messenger"
#include "plt_mnp000pt_generic"
#include "ntb_constants_h"
#include "plt_denpt_main"
// Qwinn fixed
// #include "ntb000pt_main"
#include "plt_ntb000pt_main"

#include "plt_qwinn"

const string CLI_FOLLOWER_SPAWN_PREFIX = "cli300wp_";

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
            RevealCurrentMap();
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            // Remove all party members from the active party.
            // Spawn all party pool party members
            // Spawn Anora if Loghain is in party
            // (Except Alistair, Loghain and Morrigan which will be upstairs)

            object oZath = GetObjectByTag(NTB_CR_ZATHRIAN);
            object oLady = GetObjectByTag(NTB_CR_LADY);

            if(WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ZATHRIAN_KILLED_BY_PC) || WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ZATHRIAN_SACRIFICES_HIMSELF)
                || WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE))
            {
                WR_SetObjectActive(oZath, FALSE);
                // maybe the lady is here
                if(WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE))
                {
                    WR_SetObjectActive(oLady, TRUE);
                    SetGroupId(oLady, GROUP_NEUTRAL);
                }
            }
            else
                SetGroupId(oZath, GROUP_NEUTRAL);

            WR_SetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_START, TRUE);

            // NOT GOOD - can trigger camp-only cutscenes
            //WR_SetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);

            object oAnora = GetObjectByTag(CLI_CR_ANORA);

            // Anora is here only if Alistair is not recruited anymore
            // OR
            // Alistair is still recruited but not king

            if(!WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED)
                || (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED) &&
                    !WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ON_THRONE)))
            {
                WR_SetObjectActive(oAnora, TRUE);
            }
            
            // Qwinn added
            if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_RECRUITED) && 
               WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_RIORDAN_WAITING_IN_ROOM) &&
               !WR_GetPlotFlag(PLT_QWINN, CLI_LOGHAIN_ANORA_DLG_DONE))
            {
                WR_SetObjectActive(oAnora, FALSE);            
            }
            
            object [] arParty = GetPartyPoolList();
            int nSize = GetArraySize(arParty);
            object oCurrent;
            int i;
            object oWP;
            string sTag;
            location lLoc;
            command cJump;
            int bSpawn = TRUE;
            for(i = 0; i < nSize; i++)
            {
                oCurrent = arParty[i];
                bSpawn = TRUE;
                sTag = GetTag(oCurrent);
                Log_Trace(LOG_CHANNEL_PLOT, GetCurrentScriptName(), "******* Got follower: " + sTag);
                if(sTag == GEN_FL_DOG) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
                else if(sTag == GEN_FL_WYNNE) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_CAMP, TRUE, TRUE);
                else if(sTag == GEN_FL_SHALE) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_CAMP, TRUE, TRUE);
                else if(sTag == GEN_FL_STEN) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_CAMP, TRUE, TRUE);
                else if(sTag == GEN_FL_ZEVRAN) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_CAMP, TRUE, TRUE);
                else if(sTag == GEN_FL_OGHREN) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_CAMP, TRUE, TRUE);
                else if(sTag == GEN_FL_LELIANA) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_CAMP, TRUE, TRUE);
                else if(sTag == GEN_FL_MORRIGAN) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_CAMP, TRUE, TRUE);

                // Start the ambient system for the followers
                if(!IsHero(oCurrent) && sTag != GEN_FL_ALISTAIR && sTag != GEN_FL_LOGHAIN && sTag != GEN_FL_MORRIGAN)
                    Camp_FollowerAmbient(oCurrent, TRUE);

                if(sTag == GEN_FL_ALISTAIR || sTag == GEN_FL_LOGHAIN)
                {
                    // Alistair/Loghain will be here only for the initial conversation
                    if(WR_GetPlotFlag(PLT_ARL200PT_MESSENGER, CLI_MESSENGER_JUMP_TO_CASTLE) &&
                        !WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_RIORDAN_WAITING_IN_ROOM))
                    {
                        if(sTag == GEN_FL_ALISTAIR) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                        else if(sTag == GEN_FL_LOGHAIN) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_IN_CAMP, TRUE, TRUE);
                    }
                    else
                        bSpawn = FALSE;
                }


                if(bSpawn)
                {
                    oWP = GetObjectByTag(CLI_FOLLOWER_SPAWN_PREFIX + sTag);
                    Log_Plot("Got follower WP: " + GetTag(oWP));
                    if(IsObjectValid(oWP))
                    {
                        WR_SetObjectActive(oCurrent, TRUE);
                        lLoc = GetLocation(oWP);
                        cJump = CommandJumpToLocation(lLoc);
                        SetMapPinState(oWP, TRUE);
                        WR_AddCommand(oCurrent, cJump, TRUE);
                    }
                }

                if(sTag == GEN_FL_MORRIGAN) // she's hiding somewhere...
                {
                    WR_SetObjectActive(oCurrent, FALSE);
                }

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
            object oPC = GetHero();
            Injury_RemoveAllInjuriesFromParty();
            // Set Riordan to talk
            if(!WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_RIORDAN_WAITING_IN_ROOM))
            {
                object oRiordan = UT_GetNearestObjectByTag(oPC, CLI_CR_RIORDAN);
                UT_Talk(oRiordan, oPC);
            }
            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
    }
}