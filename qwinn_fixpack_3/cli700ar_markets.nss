// Climax markets area script
// On-enter - set hostile creature script to the generic ds army script

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "cli_constants_h"
#include "cli_functions_h"
#include "party_h"
// #include "plt_clipt_general_alienage"
#include "plt_clipt_general_market"

#include "plt_lite_mabari_dom"
#include "plt_gen00pt_party"

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
        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: all game objects in the area have loaded
        //----------------------------------------------------------------------
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            //Check for Mabari Dominance
            if (WR_GetPlotFlag(PLT_LITE_MABARI_DOM, MABARI_DOM_CLI_MARKETS) == TRUE)
            {
                //if dog is in the party -
                int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
                if (nDog == TRUE)
                {
                    object oDog = Party_GetFollowerByTag("gen00fl_dog");
                    //if this flag has been set - activate the bonus and show the message
                    UI_DisplayMessage(oDog, 4010);

                    //Activate Bonus here
                    effect eDog = EffectMabariDominance();
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eDog, oDog, 0.0f, oDog, 200261);
                }

            }
            object [] arDSTeam1 = GetTeam(CLI_ARMY_ID_DS_MARKET_1);
            object [] arDSTeam2 = GetTeam(CLI_ARMY_ID_DS_MARKET_2);
            object [] arDSTeam3 = GetTeam(CLI_ARMY_ID_DS_MARKET_3);
            object [] arDSTeam4 = GetTeam(CLI_ARMY_ID_DS_MARKET_4);

            Cli_SetTeamScript(arDSTeam1, OBJECT_SELF, 2);
            Cli_SetTeamScript(arDSTeam2, OBJECT_SELF, 0);
            Cli_SetTeamScript(arDSTeam3, OBJECT_SELF, 0); // not placed
            Cli_SetTeamScript(arDSTeam4, OBJECT_SELF, 0); // not placed

            // update world map locations
            object oMarket = GetObjectByTag("wml_cli_market");
            //object oAlienage = GetObjectByTag("wml_cli_elven_alienage");
            object oPalace = GetObjectByTag("wml_cli_palace_district");
            WR_SetWorldMapLocationStatus(oMarket, WM_LOCATION_GRAYED_OUT);
            //WR_SetWorldMapLocationStatus(oAlienage, WM_LOCATION_DESTROYED);
            WR_SetWorldMapLocationStatus(oPalace, WM_LOCATION_ACTIVE);

            object oGeneral = GetObjectByTag("cli700cr_market_ds_leader");
            float fStamina = GetCreatureProperty(oGeneral, PROPERTY_DEPLETABLE_MANA_STAMINA);
            fStamina += 300.0;
            SetCreatureProperty(oGeneral, PROPERTY_DEPLETABLE_MANA_STAMINA, fStamina, PROPERTY_VALUE_TOTAL);

            float fStr = GetCreatureProperty(oGeneral, PROPERTY_ATTRIBUTE_STRENGTH);
            fStr += 10.0;
            SetCreatureProperty(oGeneral, PROPERTY_ATTRIBUTE_STRENGTH, fStr, PROPERTY_VALUE_TOTAL);

            DoAutoSave();

            break;
        }
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);
            if(GetPartyLeader() == oCreature)
            {
                object oLocation = GetObjectByTag("wml_cli_market");
                WR_SetWorldMapLocationStatus(oLocation, WM_LOCATION_GRAYED_OUT);
                // Qwinn:
                // WR_SetPlotFlag(PLT_CLIPT_GENERAL_ALIENAGE, CLIPT_GENERAL_ALIENAGE_LOST, TRUE);
                if(!WR_GetPlotFlag(PLT_CLIPT_GENERAL_MARKET, CLIPT_GENERAL_MARKET_KILLED))
                {
                   WR_SetPlotFlag(PLT_CLIPT_GENERAL_MARKET, CLIPT_GENERAL_MARKET_LOST, TRUE);
                   WR_SetWorldMapLocationStatus(oLocation, WM_LOCATION_DESTROYED);
                }
            }
            //if dog is in the party -
            int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
            if (nDog == TRUE)
            {
                object oDog = Party_GetFollowerByTag("gen00fl_dog");
                //DeActivate Bonus here
                RemoveEffectsByParameters(oDog, EFFECT_TYPE_INVALID, 200261);
            }
            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, CLI_AR_ARMY_SCRIPT);
    }
}