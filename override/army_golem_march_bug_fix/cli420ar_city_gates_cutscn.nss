// Denerim city gates area event script

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "cli_constants_h"
#include "cutscenes_h"
#include "party_h"

#include "plt_clipt_generic_actions"
// 13 - werewolves, 0 - elvels
#include "plt_ntb000pt_main"

// 15 - dwarves, 16 - golems, 13 - legion
#include "plt_orzpt_main"

// 4 - templars, 5 - mages
#include "plt_cir000pt_main"

#include "ai_constants_h"
#include "plt_tut_army_picker"

/*
Dwarves, Elfs, Mages: arl200cs_army_march_d_e_m.cut
Dwarves, Werewolves, Mages: arl200cs_army_march_d_w_m.cut
Dwarves, Elfs, Templars: arl200cs_army_march_d_e_t.cut
Dwarves, Werewolves, Templars: arl200cs_army_march_d_w_t.cut
Golems, Elfs, Mages: arl200cs_army_march_g_e_m.cut
Golems, Werewolves, Mages: arl200cs_army_march_g_w_m.cut
Golems, Elfs, Templars: arl200cs_army_march_g_e_t.cut
Golems, Werewolves, Templars: arl200cs_army_march_g_w_t.cut
*/

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
            resource rCut;
            if(WR_GetPlotFlag(PLT_ORZPT_MAIN, ORZ_MAIN_ARMY_WILL_INCLUDE_GOLEMS) &&
                WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE) &&
                WR_GetPlotFlag(PLT_CIR000PT_MAIN, MAGES_IN_ARMY))
                    rCut = R"arl200cs_army_march_g_e_m.cut";
            else if(WR_GetPlotFlag(PLT_ORZPT_MAIN, ORZ_MAIN_ARMY_WILL_INCLUDE_GOLEMS) &&
                WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE) &&
                WR_GetPlotFlag(PLT_CIR000PT_MAIN, MAGES_IN_ARMY))
                    rCut = R"arl200cs_army_march_g_w_m.cut";
            else if(WR_GetPlotFlag(PLT_ORZPT_MAIN, ORZ_MAIN_ARMY_WILL_INCLUDE_GOLEMS) &&
                WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE) &&
                WR_GetPlotFlag(PLT_CIR000PT_MAIN, TEMPLARS_IN_ARMY))
                    rCut = R"arl200cs_army_march_g_e_t.cut";
            else if (WR_GetPlotFlag(PLT_ORZPT_MAIN, ORZ_MAIN_ARMY_WILL_INCLUDE_GOLEMS) &&
                WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE) &&
                WR_GetPlotFlag(PLT_CIR000PT_MAIN, TEMPLARS_IN_ARMY))
                rCut = R"arl200cs_army_march_g_w_t.cut";
            else if(WR_GetPlotFlag(PLT_ORZPT_MAIN, ORZ_MAIN_ARMY_WILL_INCLUDE_DWARFS) &&
                WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE) &&
                WR_GetPlotFlag(PLT_CIR000PT_MAIN, MAGES_IN_ARMY))
                    rCut = R"arl200cs_army_march_d_e_m.cut";
            else if(WR_GetPlotFlag(PLT_ORZPT_MAIN, ORZ_MAIN_ARMY_WILL_INCLUDE_DWARFS) &&
                WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE) &&
                WR_GetPlotFlag(PLT_CIR000PT_MAIN, MAGES_IN_ARMY))
                    rCut = R"arl200cs_army_march_d_w_m.cut";
            else if(WR_GetPlotFlag(PLT_ORZPT_MAIN, ORZ_MAIN_ARMY_WILL_INCLUDE_DWARFS) &&
                WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE) &&
                WR_GetPlotFlag(PLT_CIR000PT_MAIN, TEMPLARS_IN_ARMY))
                    rCut = R"arl200cs_army_march_d_e_t.cut";
            else //Dwarves, Werewolves, Templars
                    rCut = R"arl200cs_army_march_d_w_t.cut";
            

            CS_LoadCutscene(rCut, PLT_CLIPT_GENERIC_ACTIONS,
                    CLI_ACTIONS_ARMY_MARCH_CUTSCENE_DONE);
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: fires at the same time that the load screen is going away,
        // and can be used for things that you want to make sure the player sees.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {

            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
    }
}