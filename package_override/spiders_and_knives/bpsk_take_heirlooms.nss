// This script is to handle collecting Ser Nathan's equipment, from his body.
//

//--------------------------------------------------------------------------------------------------
// MAIN
//--------------------------------------------------------------------------------------------------

#include "wrappers_h"
#include "utility_h"
#include "plt_bp_spiders_knives"
#include "plt_bpsk_rescue_knives"

void main()
{
    object oPC = GetHero();
//    DisplayFloatyMessage(oPC,"Collecting Ser Nathan's effects.",FLOATY_MESSAGE,0xff0000,10.0);

    UT_AddItemToInventory(R"bpsk_amulet.uti",1);
    UT_AddItemToInventory(R"bpsk_crane_plot.uti",1);
    UT_AddItemToInventory(R"bpsk_crow_plot.uti",1);
    object oNathan = GetObjectByTag("bpsk_nathan");
    UT_UnquipItem(oNathan,INVENTORY_SLOT_MAIN);
    UT_UnquipItem(oNathan,INVENTORY_SLOT_OFFHAND);
    SetPlotGiver(oNathan,FALSE);
    SetObjectInteractive(oNathan,FALSE);
    WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_HEIRLOOMS_FOUND,TRUE,TRUE);
    // Sort out journal (if Knives already freed)
    if (WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_FOUND))
    {
       WR_SetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_FATHER_FOUND,TRUE);
    }
}