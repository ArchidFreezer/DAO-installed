/////////////////////////////////////
// Single Player module events
/////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "campaign_h"

// Story-so-far plots:
#include "plt_mnp00pt_ssf_human_noble"
#include "plt_mnp00pt_ssf_prelude"
#include "plt_mnp00pt_ssf_elf_city"
#include "plt_mnp00pt_ssf_elf_dalish"
#include "plt_mnp00pt_ssf_mage"
#include "plt_mnp00pt_ssf_nature"
#include "plt_mnp000pt_ssf_sacred_urn"
#include "plt_mnp00pt_ssf_climax"
#include "plt_mnp00pt_ssf_circle"
#include "plt_mnp00pt_ssf_critpath"
#include "plt_mnp00pt_ssf_paragon"
#include "plt_mnp00pt_ssf_dwarf_comm"
#include "plt_mnp00pt_ssf_dwarf_noble"
#include "plt_mnp00pt_ssf_epilogue"

#include "plt_pre100pt_find_wardens"
#include "plt_gen00pt_backgrounds"
#include "prept_generic_actions"
#include "plt_clipt_main"

#include "pre_functions_h"
#include "den_functions_h"
#include "orz_functions_h"
#include "arl_ssf_h"
#include "ntb_ssf_h"
#include "urn_ssf_h"
#include "cli_ssf_h"
#include "cir_ssf_h"
#include "bhm_ssf_h"

#include "plt_bhn000pt_main"
#include "plt_bec000pt_main"
#include "plt_bed000pt_main"

#include "plt_ntb000pt_main"
#include "plt_urnpt_main"
#include "plt_clipt_main"
#include "plt_cir000pt_main"
#include "plt_gen00pt_generic_actions"

void SetStorySoFar()
{
    /*
    If epilogue started => show epilogue
    If climax started => show climax
    If in wow areas (random encounters, Lothering, Lake Calenhad) => show wow (TBD by Sheryl) – this will have some generic global plot logic
    If in Broken Circle areas => show Broken Circle
    If in Landsmeet areas => show Landsmeet
    If in Arl Eamon areas => show Arl Eamon
    If in Urn areas => show Urn
    If in Nature of the Beast areas => show NTB
    If in Paragon areas => show Paragon
    If in Prelude => show Prelude
    Otherwise: show origin story
    */
    object oArea = GetArea(GetHero());
    string sAreaCode = StringLeft(GetTag(oArea), 3);

    Log_Trace(LOG_CHANNEL_SYSTEMS, "SetStorySoFar", "START ******** area code: " + sAreaCode);

    if(sAreaCode == "epi")
        WR_SetStoryPlot(PLT_MNP00PT_SSF_EPILOGUE);
    else if(sAreaCode == "cli")
        WR_SetStoryPlot(PLT_MNP00PT_SSF_CLIMAX);
    else if(sAreaCode == "ran" || sAreaCode == "cam" || sAreaCode == "lot" || sAreaCode == "nrd")
        WR_SetStoryPlot(PLT_MNP00PT_SSF_CRITPATH);
    else if(sAreaCode == "cir")
        WR_SetStoryPlot(PLT_MNP00PT_SSF_CIRCLE);
    else if(sAreaCode == "den")
    {
        if(WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLOT_OPENED))
            WR_SetStoryPlot(PLT_MNP00PT_SSF_LANDSMEET);
        else
            WR_SetStoryPlot(PLT_MNP00PT_SSF_CRITPATH);
    }
    else if(sAreaCode == "arl")
        WR_SetStoryPlot(PLT_MNP00PT_SSF_ARL_EAMON);
    else if(sAreaCode == "urn")
        WR_SetStoryPlot(PLT_MNP000PT_SSF_SACRED_URN);
    else if(sAreaCode == "ntb")
        WR_SetStoryPlot(PLT_MNP00PT_SSF_NATURE);
    else if(sAreaCode == "orz")
        WR_SetStoryPlot(PLT_MNP00PT_SSF_PARAGON);
    else if(sAreaCode == "pre")
        WR_SetStoryPlot(PLT_MNP00PT_SSF_PRELUDE);
    else if(WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE))
        WR_SetStoryPlot(PLT_MNP00PT_SSF_HUMAN_NOBLE);
    else if(WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY))
        WR_SetStoryPlot(PLT_MNP00PT_SSF_ELF_CITY);
    else if(WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_DALISH))
        WR_SetStoryPlot(PLT_MNP00PT_SSF_ELF_DALISH);
    else if(sAreaCode == "bhm") //Mage origin
        WR_SetStoryPlot(PLT_MNP00PT_SSF_MAGE);
    else if(WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_COMMONER))
        WR_SetStoryPlot(PLT_MNP00PT_SSF_DWARF_COMM);
    else if(WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE))
        WR_SetStoryPlot(PLT_MNP00PT_SSF_DWARF_NOBLE);

    Log_Trace(LOG_CHANNEL_SYSTEMS, "SetStorySoFar", "END *******************");

}


void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    int bEventHandled = FALSE;
    string sDebug;
    object oPC = GetHero();

    Log_Events("", ev);

    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The module starts. This can happen only once for a single
        //       game instance.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_MODULE_START:
        {
            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_MODULE_START", "Character generation is disabled, runscript chargen to select an origin, etc.");

            SetLoadHint(4);
            if(ReadIniEntry("DebugOptions", "SkipCharGen") != "1")
            {
                CS_LoadCutscene(R"game_intro.cut", PLT_GEN00PT_GENERIC_ACTIONS, GEN_START_CHARGEN);
                PreloadCharGen();
            }
            //StartCharGen(GetHero(),0);
            SetStorySoFar();

            // Allow party picker GUI to pop up for debug-jumps into main plots
            // The origin story jump should disable this same var.
            SetLocalInt(GetModule(), PARTY_PICKER_GUI_ALLOWED_TO_POP_UP, TRUE);

            object oWideOpenWorldMap = GetObjectByTag(WM_WOW_TAG);
            WR_SetWorldMapPrimary(oWideOpenWorldMap);

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The module loads from a save game. This event can fire more than
        //       once for a single module or game instance.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_MODULE_LOAD:
        {
            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_MODULE_LOAD", "Loading singleplayer...");
            SetStorySoFar();

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_MODULE_PRESAVE:
        {
            Log_Trace(LOG_CHANNEL_SYSTEMS, "EVENT_TYPE_MODULE_PRESAVE", "module pre-saving...");

            SetStorySoFar();

            int nPREStart = WR_GetPlotFlag(PLT_PREPT_GENERIC_ACTIONS, PRE_GA_END_CAILAN_CONVERSATION);
            int nPREEnd = WR_GetPlotFlag(PLT_PRE100PT_GENERIC, PRE_GENERIC_PRELUDE_DONE);
            int nBHNStart = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE);
            int nBHNEnd = WR_GetPlotFlag(PLT_BHN000PT_MAIN,BHN_MAIN_START_PRELUDE,TRUE);
            int nBECStart = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY);
            int nBECEnd = WR_GetPlotFlag(PLT_BEC000PT_MAIN,BEC_MAIN_PC_JOINED_GREY_WARDENS,TRUE);
            int nBEDStart = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_DALISH);
            int nBEDEnd = WR_GetPlotFlag(PLT_BED000PT_MAIN,BED_MAIN_PC_LEAVES_FOR_GREY_WARDENS,TRUE);
            int nBHNSiege = WR_GetPlotFlag(PLT_BHN000PT_MAIN, BHN_MAIN_BATTLE_BEGUN, TRUE);
            int nBECKidnapped = WR_GetPlotFlag(PLT_BEC000PT_MAIN,BEC_MAIN_GIRLS_KIDNAPPED,TRUE);
            int nBEDMirror = WR_GetPlotFlag(PLT_BED000PT_MAIN,BED_MAIN_DUNCAN_BRINGS_UNCONSCIOUS_PC_TO_CAMP,TRUE);

            if(WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_ARCHDEMON_DEFEATED))
                WR_SetPlotFlag(PLT_MNP00PT_SSF_EPILOGUE, SSF_EPI_POST_CORONATION, TRUE);
            // if in Prelude
            if (nPREStart && ! nPREEnd)
            {
                PRE_ModulePresave();
            }
            ////////////////////////////////////////////////////////////////////////////////////
            // Human noble has started but before the siege
            ////////////////////////////////////////////////////////////////////////////////////
            if((nBHNStart == TRUE) && (nBHNEnd == FALSE) && (nBHNSiege == FALSE))
            {
                WR_SetPlotFlag(PLT_MNP00PT_SSF_HUMAN_NOBLE, SSF_BHN_START, TRUE, TRUE);
            }
            ////////////////////////////////////////////////////////////////////////////////////
            // after the human noble siege
            ////////////////////////////////////////////////////////////////////////////////////
            else if((nBHNSiege == TRUE) && (nBHNEnd == FALSE))
            {
                WR_SetPlotFlag(PLT_MNP00PT_SSF_HUMAN_NOBLE, SSF_BHN_SIEGE, TRUE, TRUE);
            }
            ////////////////////////////////////////////////////////////////////////////////////
            // after the human noble
            ////////////////////////////////////////////////////////////////////////////////////
            else if((nBHNStart == TRUE) && (nBHNEnd == TRUE))
            {
                WR_SetPlotFlag(PLT_MNP00PT_SSF_HUMAN_NOBLE, SSF_BHN_END, TRUE, TRUE);
            }
            ////////////////////////////////////////////////////////////////////////////////////
            // city elf has started but women not kidnapped
            ////////////////////////////////////////////////////////////////////////////////////
            else if((nBECStart == TRUE) && (nBECEnd == FALSE) && (nBECKidnapped == FALSE))
            {
                WR_SetPlotFlag(PLT_MNP00PT_SSF_ELF_CITY, SSF_BEC_START, TRUE, TRUE);
            }
            ////////////////////////////////////////////////////////////////////////////////////
            // city elf started and women kidnapped
            ////////////////////////////////////////////////////////////////////////////////////
            else if((nBECEnd == FALSE) && (nBECKidnapped == TRUE))
            {
                WR_SetPlotFlag(PLT_MNP00PT_SSF_ELF_CITY, SSF_BEC_WEDDING_DISRUPTED, TRUE, TRUE);
            }
            ////////////////////////////////////////////////////////////////////////////////////
            // city elf ended
            ////////////////////////////////////////////////////////////////////////////////////
            else if((nBECStart == TRUE) && (nBECEnd == TRUE))
            {
                WR_SetPlotFlag(PLT_MNP00PT_SSF_ELF_CITY, SSF_BEC_END, TRUE, TRUE);
            }
            ////////////////////////////////////////////////////////////////////////////////////
            // dalish elf started but before tamlen touches the mirror
            ////////////////////////////////////////////////////////////////////////////////////
            else if((nBEDStart == TRUE) && (nBEDEnd == FALSE) && (nBEDMirror == FALSE))
            {
                WR_SetPlotFlag(PLT_MNP00PT_SSF_ELF_DALISH, SSF_BED_START, TRUE, TRUE);
            }
            ////////////////////////////////////////////////////////////////////////////////////
            // dalish elf started and tamlen touched the mirror
            ////////////////////////////////////////////////////////////////////////////////////
            else if((nBEDEnd == FALSE) && (nBEDMirror == TRUE))
            {
                WR_SetPlotFlag(PLT_MNP00PT_SSF_ELF_DALISH, SSF_BED_TAINTED, TRUE, TRUE);
            }
            ////////////////////////////////////////////////////////////////////////////////////
            // dalish elf ended
            ////////////////////////////////////////////////////////////////////////////////////
            else if((nBEDStart == TRUE) && (nBEDEnd == TRUE))
            {
                WR_SetPlotFlag(PLT_MNP00PT_SSF_ELF_DALISH, SSF_BED_END, TRUE, TRUE);
            }



            ARL_HandleStorySoFar();
            DEN_ModulePresave();
            ORZ_ModulePresave();
            NTB_HandleStorySoFar();
            URN_HandleStorySoFar();
            CIR_HandleStorySoFar(); //Broken Circle story so far
            BHM_HandleStorySoFar(); //Mage Origin story so far
            Campaign_SetStorySoFar();
            CLI_HandleStorySoFar();

            break;
        }

    }

    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_MODULE_CORE);
    }
}