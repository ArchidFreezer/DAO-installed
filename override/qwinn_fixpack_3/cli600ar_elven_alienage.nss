// Alienage area events

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "cli_constants_h"
#include "cli_functions_h"
#include "party_h"

#include "plt_cli600pt_elves"
#include "plt_lite_mabari_dom"
#include "plt_gen00pt_party"
// Qwinn
// #include "plt_clipt_general_market"
#include "plt_clipt_general_alienage"


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

        ////////////////////////////////////////////////////////////////////////
        // Sent by: Scripting
        // When: The last creature of a team dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_CUSTOM_EVENT_05:
        {
            int nArmy = GetEventInteger(ev, 0);

            WR_SetPlotFlag(PLT_CLI600PT_ELVES, CLI_ELVES_WAVE_DARKSPAWN_KILLED, TRUE, TRUE);
            WR_SetPlotFlag(PLT_CLI600PT_ELVES, CLI_ELVES_DARKSPAWN_DEFEATED, TRUE, TRUE);
            SetPlotActionsEnabled(FALSE);
            break;
        }
        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: all game objects in the area have loaded
        //----------------------------------------------------------------------
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            //Check for Mabari Dominance
            if (WR_GetPlotFlag(PLT_LITE_MABARI_DOM, MABARI_DOM_CLI_ALIENAGE) == TRUE)
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
            // update world map locations
            //object oMarket = GetObjectByTag("wml_cli_market");
            object oAlienage = GetObjectByTag("wml_cli_elven_alienage");
            object oPalace = GetObjectByTag("wml_cli_palace_district");
            //WR_SetWorldMapLocationStatus(oMarket, WM_LOCATION_DESTROYED);
            WR_SetWorldMapLocationStatus(oAlienage, WM_LOCATION_GRAYED_OUT);
            WR_SetWorldMapLocationStatus(oPalace, WM_LOCATION_ACTIVE);

            object [] arDSTeam1 = GetTeam(1);

            Cli_SetTeamScript(arDSTeam1);

            object oGeneral = GetObjectByTag("cli600cr_alien_ds_leader");
            float fStamina = GetCreatureProperty(oGeneral, PROPERTY_DEPLETABLE_MANA_STAMINA);
            fStamina += 200.0;
            SetCreatureProperty(oGeneral, PROPERTY_DEPLETABLE_MANA_STAMINA, fStamina, PROPERTY_VALUE_TOTAL);

            break;
        }
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);
            if(GetPartyLeader() == oCreature)
            {
                object oLocation = GetObjectByTag("wml_cli_elven_alienage");
                WR_SetWorldMapLocationStatus(oLocation, WM_LOCATION_GRAYED_OUT);
                // Qwinn
                // WR_SetPlotFlag(PLT_CLIPT_GENERAL_MARKET, CLIPT_GENERAL_MARKET_LOST, TRUE);
                if(!WR_GetPlotFlag(PLT_CLIPT_GENERAL_ALIENAGE, CLIPT_GENERAL_ALIENAGE_KILLED))
                {
                   WR_SetPlotFlag(PLT_CLIPT_GENERAL_ALIENAGE, CLIPT_GENERAL_ALIENAGE_LOST, TRUE);
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