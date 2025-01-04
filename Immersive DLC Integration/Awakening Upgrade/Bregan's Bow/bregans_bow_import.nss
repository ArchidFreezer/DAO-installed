#include "wrappers_h"
#include "utility_h"
#include "plt_dlc_integration"

void main()
{
    object oChar = GetHero();
    object oEquip;
    object oNewEquip;
    string sTag;

    if ( WR_GetPlotFlag( PLT_DLC_INTEGRATION, BREGANS_BOW_IMPORT ) == FALSE )
    {
        int iCount = UT_CountItemInInventory(R"prm000im_griffbeak.uti");

        if (iCount >= 1)
        {

            oEquip = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oChar, 0);
            sTag = GetTag(oEquip);

            if (sTag == "prm000im_griffbeak")
            {
                UnequipItem(oChar, oEquip);
                UT_RemoveItemFromInventory(R"prm000im_griffbeak.uti", 1);
                oNewEquip = CreateItemOnObject(R"prm000im_ep1_griffbeak.uti", oChar, 1);
                EquipItem(oChar, oNewEquip, INVENTORY_SLOT_MAIN, 0);
            }
            else
            {
                oEquip = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oChar, 1);
                sTag = GetTag(oEquip);

                if (sTag == "prm000im_griffbeak")
                {
                    UnequipItem(oChar, oEquip);
                    UT_RemoveItemFromInventory(R"prm000im_griffbeak.uti", 1);
                    oNewEquip = CreateItemOnObject(R"prm000im_ep1_griffbeak.uti", oChar, 1);
                    EquipItem(oChar, oNewEquip, INVENTORY_SLOT_MAIN, 1);
                }
                else
                {
                    UT_RemoveItemFromInventory(R"prm000im_griffbeak.uti", 1);
                    UT_AddItemToInventory(R"prm000im_ep1_griffbeak.uti", 1);
                }
            }
        }

        WR_SetPlotFlag( PLT_DLC_INTEGRATION, BREGANS_BOW_IMPORT, TRUE );
    }
}