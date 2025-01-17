// This script is called in Spider Cave, when the player frees Ser Arbither (aka Knives)
// from her cocoon.
//

#include "wrappers_h"
#include "plt_bp_spiders_knives"
#include "plt_bpsk_rescue_knives"

//--------------------------------------------------------------------------------------------------
// MAIN
//--------------------------------------------------------------------------------------------------

void main()
{
        // Sort out journal if Knives freed after father found
        if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_HEIRLOOMS_FOUND))
        {
            WR_SetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_FATHER_FOUND,TRUE);            
        }
        object oKnives = GetObjectByTag("bpsk_knives");
        object oExit = GetObjectByTag("bpsk_cave_exit");
        location lExit = GetLocation(oExit);
        command cExit = CommandMoveToLocation(lExit,FALSE,TRUE);
        AddCommand(oKnives, cExit, TRUE);
}