//::///////////////////////////////////////////////
//:: Module Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Module events for: Spiders & Knives
*/
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "plt_epipt_main"
#include "plt_bp_spiders_knives" 

void check_main_plot();

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    check_main_plot();
    
    int nEventHandled = FALSE;
    switch(nEventType)
    {

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A player objects enters the module
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {

            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_MODULE_CORE);
    }
}

void check_main_plot()
{
    if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_DARK_TIDE))
        return;                     // Player abandoned quest, so no point going further   
        
    if (WR_GetPlotFlag(PLT_EPIPT_MAIN,EPI_JUMP_TO_SLIDE_SHOW) && !WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_EPI_SLIDESHOW))
    {
        WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_EPI_SLIDESHOW,TRUE);
    }    
}