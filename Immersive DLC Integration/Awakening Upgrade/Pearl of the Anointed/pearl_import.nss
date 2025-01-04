#include "wrappers_h"
#include "utility_h"
#include "plt_dlc_integration"

void main()
{
    if ( WR_GetPlotFlag( PLT_DLC_INTEGRATION, PEARL_IMPORT ) == FALSE )
    {
        int iCount = UT_CountItemInInventory(R"prm000im_pearlan.uti");

        if (iCount >= 1)
        {
  
            object oChar = GetHero();
            object oEquip = GetItemInEquipSlot(INVENTORY_SLOT_NECK, oChar);
            string sTag = GetTag(oEquip);

            if (sTag == "prm000im_pearlan")
            {
                UnequipItem(oChar, oEquip);
                UT_RemoveItemFromInventory(R"prm000im_pearlan.uti", 1);
                object oNewEquip = CreateItemOnObject(R"prm000im_ep1_pearlan.uti", oChar, 1);
                EquipItem(oChar, oNewEquip, INVENTORY_SLOT_NECK);
            } 
            else
            {
                UT_RemoveItemFromInventory(R"prm000im_pearlan.uti", 1);
                UT_AddItemToInventory(R"prm000im_ep1_pearlan.uti", 1);
            }
        }

        WR_SetPlotFlag( PLT_DLC_INTEGRATION, PEARL_IMPORT, TRUE );
    }
}