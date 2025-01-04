#include "wrappers_h"
#include "utility_h"
#include "plt_dlc_integration"

void main()
{
    object oChar = GetHero();
    object oEquip;
    object oNewEquip;
    string sTag;

    if ( WR_GetPlotFlag( PLT_DLC_INTEGRATION, BLIGHTBLOOD_IMPORT ) == FALSE )
    {
        int iCount = UT_CountItemInInventory(R"prc_im_wep_mel_lsw_drk_dao.uti");

        if (iCount >= 1)
        {

            oEquip = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oChar, 0);
            sTag = GetTag(oEquip);

            if (sTag == "prc_im_wep_mel_lsw_drk_dao")
            {
                UnequipItem(oChar, oEquip);
                UT_RemoveItemFromInventory(R"prc_im_wep_mel_lsw_drk_dao.uti", 1);
                oNewEquip = CreateItemOnObject(R"prc_im_wep_mel_lsw_drk_ep1.uti", oChar, 1);
                EquipItem(oChar, oNewEquip, INVENTORY_SLOT_MAIN, 0);
            }
            else
            {
                oEquip = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oChar, 0);
                sTag = GetTag(oEquip);

                if (sTag == "prc_im_wep_mel_lsw_drk_dao")
                {
                    UnequipItem(oChar, oEquip);
                    UT_RemoveItemFromInventory(R"prc_im_wep_mel_lsw_drk_dao.uti", 1);
                    oNewEquip = CreateItemOnObject(R"prc_im_wep_mel_lsw_drk_ep1.uti", oChar, 1);
                    EquipItem(oChar, oNewEquip, INVENTORY_SLOT_OFFHAND, 0);
                }
                else
                {
                    oEquip = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oChar, 1);
                    sTag = GetTag(oEquip);

                    if (sTag == "prc_im_wep_mel_lsw_drk_dao")
                    {
                        UnequipItem(oChar, oEquip);
                        UT_RemoveItemFromInventory(R"prc_im_wep_mel_lsw_drk_dao.uti", 1);
                        oNewEquip = CreateItemOnObject(R"prc_im_wep_mel_lsw_drk_ep1.uti", oChar, 1);
                        EquipItem(oChar, oNewEquip, INVENTORY_SLOT_MAIN, 1);
                    }
                    else
                    {
                        oEquip = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oChar, 1);
                        sTag = GetTag(oEquip);

                        if (sTag == "prc_im_wep_mel_lsw_drk_dao")
                        {
                            UnequipItem(oChar, oEquip);
                            UT_RemoveItemFromInventory(R"prc_im_wep_mel_lsw_drk_dao.uti", 1);
                            oNewEquip = CreateItemOnObject(R"prc_im_wep_mel_lsw_drk_ep1.uti", oChar, 1);
                            EquipItem(oChar, oNewEquip, INVENTORY_SLOT_OFFHAND, 1);
                        }
                        else
                        {
                            UT_RemoveItemFromInventory(R"prc_im_wep_mel_lsw_drk_dao.uti", 1);
                            UT_AddItemToInventory(R"prc_im_wep_mel_lsw_drk_ep1.uti", 1);
                        }
                    }
                }
            }
        }

        WR_SetPlotFlag( PLT_DLC_INTEGRATION, BLIGHTBLOOD_IMPORT, TRUE );
    }
}