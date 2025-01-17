// This script is called on entry to Lothering Chantry, by PRCSCR_bpsk.GDA.
// If Knives has been rescued, it places her in the Chantry, ready to reward
// the player for the first step of the quest, and move them on to the second.
//
#include "wrappers_h"
#include "plt_bp_spiders_knives"
#include "plt_bpsk_rescue_knives"
#include "plt_bpsk_retake_manor"

//--------------------------------------------------------------------------------------------------
// MAIN
//--------------------------------------------------------------------------------------------------

void main()
{
    if (WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_FOUND) &&
       !WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_KNIVES_PLACED))
    {
        // Knives is rescued, so put her in position in the Chantry
        object oPC = GetHero();
        location lKnives = GetLocation(GetObjectByTag("ap_lot100cr_refugee_1_04"));
        object oKnives = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_knives.utc",lKnives);
        SetPlotGiver(oKnives,TRUE);
        WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_KNIVES_PLACED,TRUE);
    }
    if (WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_REWARD_GIVEN) &&
        !WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_READY_MANOR) &&
        !WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_ARBITHER_UNFRIENDLY) &&
        !WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_RESCUE_ONLY))
    {
        // Knives has had time to organise recovery of her father's body, so she is ready for next stage
        object oKnives2 = GetObjectByTag("bpsk_knives");
        SetPlotGiver(oKnives2,TRUE);
        WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_READY_MANOR,TRUE);
    }
}