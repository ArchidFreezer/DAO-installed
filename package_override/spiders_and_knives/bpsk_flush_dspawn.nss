//:://////////////////////////////////////////////////////
//:: Called from dialogue to flush out any hidden shriek
//:: remaing from the darkspawn attack on Knife Edge.
//:://////////////////////////////////////////////////////
#include "wrappers_h"
#include "plt_bp_spiders_knives"

const int EVENT_TYPE_CLEANUP_STRAGGLERS = 22055;

void main()
{
    if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_FINAL_WAVE) &&
        !WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_MANOR_DEFENDED))
    {
        object oArea = GetArea(GetHero());
        DelayEvent(1.0,oArea,Event(EVENT_TYPE_CLEANUP_STRAGGLERS));
    }
}