#include "wrappers_h"
#include "utility_h"
#include "plt_dlc_integration"

void main()
{
    if ( WR_GetPlotFlag( PLT_DLC_INTEGRATION, BATTLEDRESS_IMPORT ) == FALSE )
    {
        
        int iCount = UT_CountItemInInventory(R"prc_dao_lel_im_arm_cht_01.uti");
        PrintToLog("iCount: " + IntToString(iCount));
        
        if (iCount >= 1)
        {

            object oChar = GetHero();
            object oEquip = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oChar, 0);
            string sTag = GetTag(oEquip);
       
            if (sTag == "prc_dao_lel_im_arm_cht_01")
            {
                UnequipItem(oChar, oEquip);
                UT_RemoveItemFromInventory(R"prc_dao_lel_im_arm_cht_01.uti", 1);
                object oNewEquip = CreateItemOnObject(R"prc_daep1_lel_im_arm_cht_01.uti", oChar, 1);
                EquipItem(oChar, oNewEquip, INVENTORY_SLOT_CHEST);
            }
            else
            {
                UT_RemoveItemFromInventory(R"prc_dao_lel_im_arm_cht_01.uti", 1);
                UT_AddItemToInventory(R"prc_daep1_lel_im_arm_cht_01.uti", 1);
            }  
            
        }
              
        WR_SetPlotFlag( PLT_DLC_INTEGRATION, BATTLEDRESS_IMPORT, TRUE );
    }
}