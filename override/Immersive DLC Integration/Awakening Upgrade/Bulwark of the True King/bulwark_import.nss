#include "wrappers_h"
#include "utility_h"
#include "plt_dlc_integration"

void main()
{
    object oChar = GetHero();
    object oEquip;
    object oNewEquip;
    string sTag;

    if ( WR_GetPlotFlag( PLT_DLC_INTEGRATION, BULWARK_IMPORT ) == FALSE )
    {
        int iCount = UT_CountItemInInventory(R"prm000im_bulwarktk.uti");

        if (iCount >= 1)
        {

            oEquip = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oChar, 0);
            sTag = GetTag(oEquip);

            if (sTag == "prm000im_bulwarktk")
            {
                UnequipItem(oChar, oEquip);
                UT_RemoveItemFromInventory(R"prm000im_bulwarktk.uti", 1);
                oNewEquip = CreateItemOnObject(R"prm000im_ep1_bulwarktk.uti", oChar, 1);
                EquipItem(oChar, oNewEquip, INVENTORY_SLOT_OFFHAND, 0);
            }
            else
            {
                oEquip = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oChar, 1);
                sTag = GetTag(oEquip);

                if (sTag == "prm000im_bulwarktk")
                {
                    UnequipItem(oChar, oEquip);
                    UT_RemoveItemFromInventory(R"prm000im_bulwarktk.uti", 1);
                    oNewEquip = CreateItemOnObject(R"prm000im_ep1_bulwarktk.uti", oChar, 1);
                    EquipItem(oChar, oNewEquip, INVENTORY_SLOT_OFFHAND, 1);
                }
                else
                {
                    UT_RemoveItemFromInventory(R"prm000im_bulwarktk.uti", 1);
                    UT_AddItemToInventory(R"prm000im_ep1_bulwarktk.uti", 1);
                }
            }
        }

        WR_SetPlotFlag( PLT_DLC_INTEGRATION, BULWARK_IMPORT, TRUE );
    }
}