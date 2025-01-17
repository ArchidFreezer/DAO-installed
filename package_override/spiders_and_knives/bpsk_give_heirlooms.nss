// This script is to handle giving of rewards by Ser Arbither, callable from dialogue.
//

//--------------------------------------------------------------------------------------------------
// MAIN
//--------------------------------------------------------------------------------------------------

#include "utility_h"
#include "wrappers_h"

#include "plt_bp_spiders_knives"

void main()
{
    object oPC = GetHero();

    // Always return the medallion
    object oKnives = GetObjectByTag("bpsk_knives");
    UT_RemoveItemFromInventory(R"bpsk_amulet.uti",1);

    // Player has option of returning Crow & Crane or keeping them
    if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BLADES_RETURNED))
    {
        UT_RemoveItemFromInventory(R"bpsk_crow_plot.uti",1);
        UT_RemoveItemFromInventory(R"bpsk_crane_plot.uti",1);
        object oCrane = CreateItemOnObject(R"bpsk_crane_low.uti",oKnives);
        object oCrow = CreateItemOnObject(R"bpsk_crow_low.uti",oKnives);
        EquipItem(oKnives,oCrane,INVENTORY_SLOT_MAIN);
        EquipItem(oKnives,oCrow,INVENTORY_SLOT_OFFHAND);
    }else{
        UT_RemoveItemFromInventory(R"bpsk_crow_plot.uti",1);
        UT_RemoveItemFromInventory(R"bpsk_crane_plot.uti",1);
        object oCrane = UT_AddItemToInventory(R"bpsk_crane_low.uti");
        object oCrow = UT_AddItemToInventory(R"bpsk_crow_low.uti");
    }

}