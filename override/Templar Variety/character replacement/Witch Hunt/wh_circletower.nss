#include "utility_h"
#include "plt_templar_swaps_str"

void main()
{   
    object oTempGen = GetObjectByTag("str200cr_templar");
    object oTempGen1 = GetObjectByTag("str200cr_templar", 1);
    object oTempGen2 = GetObjectByTag("str200cr_templar", 2);
       
    location lTemp = GetLocation(oTempGen); 
    location lTemp1 = GetLocation(oTempGen1);
    location lTemp2 = GetLocation(oTempGen2); 

    int nSwapped = WR_GetPlotFlag("templar_swaps_str", 0);

    if (!nSwapped)
    {
        object oNewTemp = CreateObject(OBJECT_TYPE_CREATURE, R"templar_m_arch_low.utc", lTemp);
        
        if (IsObjectValid(oNewTemp))
        {
            Safe_Destroy_Object(oTempGen);
        }
        
        object oNewTemp1 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_f_heavy.utc", lTemp1);
        object oHelm = GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oNewTemp1);
        UnequipItem(oNewTemp1, oHelm);
        
        if (IsObjectValid(oNewTemp1))
        {
            Safe_Destroy_Object(oTempGen1);
        }  
            
        object oNewTemp2 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_m_med.utc", lTemp2);
        
        if (IsObjectValid(oNewTemp2))
        {
            Safe_Destroy_Object(oTempGen2);
        }
        

        WR_SetPlotFlag("templar_swaps_str", 0, TRUE);
    }
}
