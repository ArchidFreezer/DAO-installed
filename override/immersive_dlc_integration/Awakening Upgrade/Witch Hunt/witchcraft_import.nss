#include "wrappers_h"
#include "utility_h"
#include "plt_dlc_integration"

void main()
{
    object oChar = GetHero();
    object oEquip;
    object oNewEquip;
    string sTag;
    int iCount;

    if ( WR_GetPlotFlag( PLT_DLC_INTEGRATION, DRAGONBONE_CLEAVER_IMPORT ) == FALSE )
    {
        iCount = UT_CountItemInInventory(R"prc_im_reward1.uti");

        if (iCount >= 1)
        {

            oEquip = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oChar, 0);
            sTag = GetTag(oEquip);

            if (sTag == "prc_im_reward1")
            {
                UnequipItem(oChar, oEquip);
                UT_RemoveItemFromInventory(R"prc_im_reward1.uti", 1);
                oNewEquip = CreateItemOnObject(R"prc_im_ep1_reward1.uti", oChar, 1);
                EquipItem(oChar, oNewEquip, INVENTORY_SLOT_MAIN, 0);
            }
            else
            {
                oEquip = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oChar, 1);
                sTag = GetTag(oEquip);

                if (sTag == "prc_im_reward1")
                {
                    UnequipItem(oChar, oEquip);
                    UT_RemoveItemFromInventory(R"prc_im_reward1.uti", 1);
                    oNewEquip = CreateItemOnObject(R"prc_im_ep1_reward1.uti", oChar, 1);
                    EquipItem(oChar, oNewEquip, INVENTORY_SLOT_MAIN, 1);
                }
                else
                {
                    UT_RemoveItemFromInventory(R"prc_im_reward1.uti", 1);
                    UT_AddItemToInventory(R"prc_im_ep1_reward1.uti", 1);
                }
            }
        }

        WR_SetPlotFlag( PLT_DLC_INTEGRATION, DRAGONBONE_CLEAVER_IMPORT, TRUE );
    }

    if ( WR_GetPlotFlag( PLT_DLC_INTEGRATION, SORROWS_ARLATHAN_IMPORT ) == FALSE )
    {
        iCount = UT_CountItemInInventory(R"prc_im_reward2.uti");

        if (iCount >= 1)
        {

            oEquip = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oChar, 0);
            sTag = GetTag(oEquip);

            if (sTag == "prc_im_reward2")
            {
                UnequipItem(oChar, oEquip);
                UT_RemoveItemFromInventory(R"prc_im_reward2.uti", 1);
                oNewEquip = CreateItemOnObject(R"prc_im_ep1_reward2.uti", oChar, 1);
                EquipItem(oChar, oNewEquip, INVENTORY_SLOT_MAIN, 0);
            }
            else
            {
                oEquip = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oChar, 1);
                sTag = GetTag(oEquip);

                if (sTag == "prc_im_reward2")
                {
                    UnequipItem(oChar, oEquip);
                    UT_RemoveItemFromInventory(R"prc_im_reward2.uti", 1);
                    oNewEquip = CreateItemOnObject(R"prc_im_ep1_reward2.uti", oChar, 1);
                    EquipItem(oChar, oNewEquip, INVENTORY_SLOT_MAIN, 1);
                }
                else
                {
                    UT_RemoveItemFromInventory(R"prc_im_reward2.uti", 1);
                    UT_AddItemToInventory(R"prc_im_ep1_reward2.uti", 1);
                }
            }
        }

        WR_SetPlotFlag( PLT_DLC_INTEGRATION, SORROWS_ARLATHAN_IMPORT, TRUE );
    }

    if ( WR_GetPlotFlag( PLT_DLC_INTEGRATION, VESTMENTS_IMPORT ) == FALSE )
    {
        iCount = UT_CountItemInInventory(R"prc_im_reward3.uti");

        if (iCount >= 1)
        {

            oEquip = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oChar);
            sTag = GetTag(oEquip);

            if (sTag == "prc_im_reward3")
            {
                UnequipItem(oChar, oEquip);
                UT_RemoveItemFromInventory(R"prc_im_reward3.uti", 1);
                oNewEquip = CreateItemOnObject(R"prc_im_ep1_reward3.uti", oChar, 1);
                EquipItem(oChar, oNewEquip, INVENTORY_SLOT_CHEST);
            }
            else
            {
                UT_RemoveItemFromInventory(R"prc_im_reward3.uti", 1);
                UT_AddItemToInventory(R"prc_im_ep1_reward3.uti", 1);
            }
        }

        WR_SetPlotFlag( PLT_DLC_INTEGRATION, VESTMENTS_IMPORT, TRUE );
    }

    if ( WR_GetPlotFlag( PLT_DLC_INTEGRATION, CINCH_IMPORT ) == FALSE )
    {
        iCount = UT_CountItemInInventory(R"prc_im_reward4.uti");

        if (iCount >= 1)
        {

            oEquip = GetItemInEquipSlot(INVENTORY_SLOT_BELT, oChar);
            sTag = GetTag(oEquip);

            if (sTag == "prc_im_reward4")
            {
                UnequipItem(oChar, oEquip);
                UT_RemoveItemFromInventory(R"prc_im_reward4.uti", 1);
                oNewEquip = CreateItemOnObject(R"prc_im_ep1_reward4.uti", oChar, 1);
                EquipItem(oChar, oNewEquip, INVENTORY_SLOT_BELT);
            }
            else
            {
                UT_RemoveItemFromInventory(R"prc_im_reward4.uti", 1);
                UT_AddItemToInventory(R"prc_im_ep1_reward4.uti", 1);
            }
        }

        WR_SetPlotFlag( PLT_DLC_INTEGRATION, CINCH_IMPORT, TRUE );
    }
}