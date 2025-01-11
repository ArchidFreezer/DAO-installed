#include "utility_h"
#include "plt_templar_swaps"

void main()
{
    object oTempGen1 = GetObjectByTag("ran154cr_templar_a", 1);
    object oTempGen2 = GetObjectByTag("ran154cr_templar_a", 2);
    
    int nDefeated1 = IsDead(oTempGen1);
    int nDefeated2 = IsDead(oTempGen2);
    
    location lTemp1 = GetLocation(oTempGen1);
    location lTemp2 = GetLocation(oTempGen2);
    
    int nSwapped = WR_GetPlotFlag("templar_swaps", 4);

    if (!nSwapped)
    {
        if (!nDefeated1)
        {  
            object oNewTemp1 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_f_heavy.utc", lTemp1);
                
            if (IsObjectValid(oNewTemp1))
            {
                Safe_Destroy_Object(oTempGen1);
            }
        }
        
        if (!nDefeated2)
        {
            object oNewTemp2 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_m_arch.utc", lTemp2);
                
            if (IsObjectValid(oNewTemp2))
            {
                Safe_Destroy_Object(oTempGen2);
            }
        }
        
        WR_SetPlotFlag("templar_swaps", 4, TRUE);
    }
}
            
           
     
  