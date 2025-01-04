// palace area events

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "cli_constants_h"
#include "cli_functions_h"
#include "cutscenes_h"

#include "plt_cli400pt_city_gates"
#include "plt_mnp000pt_autoss_main2"

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
            int nDoOnce = GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_B);
            if(nDoOnce == 0)
            {
                SetLocalInt(OBJECT_SELF, AREA_DO_ONCE_B, 1);

                //Take an autoscreenshot
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_CLI_RIORDAN_FIGHTS_ARCHDEMON, TRUE, TRUE);

                CS_LoadCutscene(CUTSCENE_CLI_RIORDAN_FIGHTS_ARCHDEMON);

                SetLocalInt(GetModule(), DISABLE_FOLLOWER_DIALOG, 0);
            }
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            object [] arDSTeam1 = GetTeam(CLI_ARMY_DS_PALACE_1);
            object [] arDSTeam2 = GetTeam(CLI_ARMY_DS_PALACE_2);
            object [] arDSTeam3 = GetTeam(CLI_ARMY_DS_PALACE_3);

            Cli_SetTeamScript(arDSTeam1, OBJECT_SELF, 3);
            Cli_SetTeamScript(arDSTeam2, OBJECT_SELF, 0);
            Cli_SetTeamScript(arDSTeam3, OBJECT_SELF, 0);

            // if returning after gate fight -> restore original party
            if(WR_GetPlotFlag(PLT_CLI400PT_CITY_GATES, CLI_CITY_GATES_WIN) ||
                WR_GetPlotFlag(PLT_CLI400PT_CITY_GATES, CLI_CITY_GATES_LOSE))
            {
                int nDoOnce = GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A);
                if(nDoOnce == 0)
                {
                    SetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A, 1);
                    SetLocalInt(GetModule(), DISABLE_FOLLOWER_DIALOG, 0);

                    object oOldLeader = GetPartyLeader();
                    if(oOldLeader != oPC)
                    {
                        WR_SetObjectActive(oPC, TRUE);
                        WR_SetFollowerState(oPC, FOLLOWER_STATE_ACTIVE);
                        SetPartyLeader(oPC);
                        command cJump = CommandJumpToLocation(GetLocation(oOldLeader));
                        WR_ClearAllCommands(oPC);
                        WR_AddCommand(oPC, cJump, TRUE, TRUE);

                        WR_SetFollowerState(oOldLeader, FOLLOWER_STATE_UNAVAILABLE);
                        WR_SetObjectActive(oOldLeader, FALSE);

                        UT_PartyRestore();

                        // Jump party to party leader
                        object [] arParty = GetPartyList();
                        int nSize = GetArraySize(arParty);
                        object oCurrent;
                        int i;
                        location lLoc;
                        for(i = 0; i < nSize; i++)
                        {
                            Log_Trace(LOG_CHANNEL_PLOT, GetCurrentScriptName(), "Setting location of follower: " + GetTag(oCurrent));
                            oCurrent = arParty[i];
                            //lLoc = GetFollowerWouldBeLocation(oCurrent);
                            command cJump = CommandJumpToLocation(GetLocation(oOldLeader));
                            WR_ClearAllCommands(oCurrent);
                            WR_AddCommand(oCurrent, cJump, TRUE, TRUE);
                        }
                    }
                }
            }

            // update world map locations
            // Qwinn:  Market and Alienage weren't being grayed out here.
            object oMarket = GetObjectByTag("wml_cli_market");
            WR_SetWorldMapLocationStatus(oMarket, WM_LOCATION_GRAYED_OUT);
            object oAlienage = GetObjectByTag("wml_cli_elven_alienage");
            WR_SetWorldMapLocationStatus(oAlienage, WM_LOCATION_GRAYED_OUT);            
            object oPalace = GetObjectByTag("wml_cli_palace_district");
            WR_SetWorldMapLocationStatus(oPalace, WM_LOCATION_GRAYED_OUT);

            DoAutoSave();

            break;
        }

        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID

            object oDefender = UT_GetNearestCreatureByTag(OBJECT_SELF, CLI_CR_PALACE_DEFENDER);
            if(IsObjectValid(oDefender))
                UT_Talk(oDefender, oDefender);
            break;
        }
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);
            if(GetPartyLeader() == oCreature)
            {
                object oLocation = GetObjectByTag("wml_cli_palace_district");
                WR_SetWorldMapLocationStatus(oLocation, WM_LOCATION_GRAYED_OUT);
            }
            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, CLI_AR_ARMY_SCRIPT);
    }
}