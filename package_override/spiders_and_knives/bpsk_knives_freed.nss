// This script is called in Spider Cave, when the player frees Ser Arbither (aka Knives)
// from her cocoon.
//
#include "utility_h"
#include "wrappers_h"
#include "plt_bp_spiders_knives"
#include "plt_bpsk_rescue_knives"

//--------------------------------------------------------------------------------------------------
// MAIN
//--------------------------------------------------------------------------------------------------

void main()
{
        object oPC = GetHero();
//        DisplayFloatyMessage(oPC,"Knives freed.",FLOATY_MESSAGE,0xff0000,10.0);
        object oCocoon = GetObjectByTag("bpsk_cocoon_knives");
        SetPlotGiver(oCocoon,FALSE);
        SetObjectInteractive(oCocoon, FALSE);
        object oNathan = GetObjectByTag("bpsk_nathan");
        SetPlotGiver(oNathan,TRUE);
        object oKnives = GetObjectByTag("bpsk_knives");
        SetObjectActive(oKnives, TRUE);
        WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_ARBITHER_RESCUED,TRUE);
        UT_Talk(oKnives, oPC);
}