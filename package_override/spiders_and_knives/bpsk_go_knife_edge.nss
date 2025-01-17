// This script is to handle a direct transition to Knife Edge, callable from dialogue.
//

//--------------------------------------------------------------------------------------------------
// MAIN
//--------------------------------------------------------------------------------------------------

#include "utility_h"
#include "wrappers_h"
#include "plt_bpsk_retake_manor"

void main()
{
    object oPC = GetHero();
    // Knives is going with us, so remove her from the chantry
    object oKnives = GetObjectByTag("bpsk_knives");
    SetObjectActive(oKnives,FALSE);

    //Activate the map pin and go to Knife Edge
    object oKnifeEdge = GetObjectByTag("bpsk_wow_knife_edge_ds");
    WR_SetWorldMapLocationStatus(oKnifeEdge,WM_LOCATION_ACTIVE);
    object oWMap = GetObjectByTag("bpsk_world_map");
    WR_SetWorldMapPlayerLocation(oWMap,oKnifeEdge);
    UT_DoAreaTransition("bpsk_knife_edge_ds","backway");

    WR_SetPlotFlag(PLT_BPSK_RETAKE_MANOR,MANOR_ENTERED,TRUE,TRUE);

}