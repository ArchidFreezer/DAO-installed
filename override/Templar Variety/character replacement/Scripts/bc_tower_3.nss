#include "utility_h"
#include "plt_templar_swaps"

void main()
{
    object oTempGen1 = GetObjectByTag("cir230cr_possessed_templar", 1);
    object oTempGen3 = GetObjectByTag("cir230cr_possessed_templar", 3);
    object oTempGen4 = GetObjectByTag("cir230cr_possessed_templar", 4);
    int nDefeated1 = IsDead(oTempGen1);
    int nDefeated3 = IsDead(oTempGen3); 
    int nDefeated4 = IsDead(oTempGen4);

    string sName1 = GetName(oTempGen1);
    string sName3 = GetName(oTempGen3);

    location lTemp1 = GetLocation(oTempGen1);
    location lTemp3 = GetLocation(oTempGen3);

    int nSwapped = WR_GetPlotFlag("templar_swaps", 1);

    if (!nSwapped)
    {
        if (!nDefeated1)
        {
            object oNewTemp1 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_m_med_hos.utc", lTemp1);
            SetTeamId(oNewTemp1, 16);
            SetName(oNewTemp1, sName1);

            if (IsObjectValid(oNewTemp1))
            {
                Safe_Destroy_Object(oTempGen1);
            }
        }

        if (!nDefeated3)
        {
            object oNewTemp3= CreateObject(OBJECT_TYPE_CREATURE, R"templar_f_heavy_hos.utc", lTemp3);
            SetTeamId(oNewTemp3, 16);
            SetName(oNewTemp3, sName3);
            object oHelm3 = GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oNewTemp3);
            UnequipItem(oNewTemp3, oHelm3);

            if (IsObjectValid(oNewTemp3))
            {
                Safe_Destroy_Object(oTempGen3);
            }
        }
        
        if (!nDefeated4)
        {
            object oHelm4 = GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oTempGen4);
            UnequipItem(oTempGen4, oHelm4);
        }

        WR_SetPlotFlag("templar_swaps", 1, TRUE);
    }
}

