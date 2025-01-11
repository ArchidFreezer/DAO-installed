#include "wrappers_h"

void main()
{
    object[] oPartyPool = GetPartyPoolList();
    int nSize = GetArraySize(oPartyPool);
    int nCount = 0;
    object oSword;
    object oHunter = GetObjectByTag("rxaip_corpse_dragonhunter");
    object oSwordDup = GetItemPossessedBy(oHunter, "gxa_im_wep_mel_gsw_002");
    
    for (nCount = 0; nCount < nSize; nCount++)
    {
        oSword = GetItemPossessedBy(oPartyPool[nCount], "gxa_im_wep_mel_gsw_002");
        if (IsObjectValid(oSword))
        { 
            Safe_Destroy_Object(oSwordDup);
            return;
        }
    }
}
            