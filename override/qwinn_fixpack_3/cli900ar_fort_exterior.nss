// Fort exterior area events

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "cli_constants_h"
#include "cli_functions_h"

// Qwinn added
#include "plt_clipt_general_alienage"
#include "plt_clipt_general_market"

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
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            object [] arDSTeam = GetTeam(CLI_ARMY_DS_FORT_EXTERIOR);

            Cli_SetTeamScript(arDSTeam);
                                          
            // Qwinn added
            object oLocation = GetObjectByTag("wml_cli_elven_market");
            if(!WR_GetPlotFlag(PLT_CLIPT_GENERAL_MARKET, CLIPT_GENERAL_MARKET_KILLED))
            {
                WR_SetPlotFlag(PLT_CLIPT_GENERAL_MARKET, CLIPT_GENERAL_MARKET_LOST, TRUE);
                WR_SetWorldMapLocationStatus(oLocation, WM_LOCATION_DESTROYED);
            }
            oLocation = GetObjectByTag("wml_cli_elven_alienage");
            if(!WR_GetPlotFlag(PLT_CLIPT_GENERAL_ALIENAGE, CLIPT_GENERAL_ALIENAGE_KILLED))
            {
                WR_SetPlotFlag(PLT_CLIPT_GENERAL_ALIENAGE, CLIPT_GENERAL_ALIENAGE_LOST, TRUE);
                WR_SetWorldMapLocationStatus(oLocation, WM_LOCATION_DESTROYED);
            }
            // End Qwinn

            break;
        }
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);
            if(GetPartyLeader() == oCreature)
            {
                object oLocation = GetObjectByTag("wml_cli_fort_drakon");
                WR_SetWorldMapLocationStatus(oLocation, WM_LOCATION_GRAYED_OUT);
            }
            break;
        }
        case EVENT_TYPE_CUSTOM_EVENT_04: // spawn darkspawn soldier
        {
            // bring second dragon evenutally
            string sSpawnWP = GetEventString(ev, 0);
            int nLastCreatureToDie = GetEventInteger(ev, 0); // set only when called from a death event of a creature
            int nArmyTable = GetEventInteger(ev, 1);
            int nArmyID = GetEventInteger(ev, 2);

            string sArmyTotalVar = GetM2DAString(TABLE_CLIMAX_ARMIES, "ArmyTotalVar", nArmyID);
            int nCurrentDSCount = GetLocalInt(OBJECT_SELF, sArmyTotalVar);
            Log_Trace(LOG_CHANNEL_TEMP, "boom", "current ds count: " + IntToString(nCurrentDSCount));

            if(nCurrentDSCount == 25)
                UT_TeamAppears(1003);
            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, CLI_AR_ARMY_SCRIPT);
    }
}