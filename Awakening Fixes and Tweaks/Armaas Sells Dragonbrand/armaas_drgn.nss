#include "wrappers_h"
#include "plt_sell_drgn"

void main()
{
    object oArmaas = GetObjectByTag("store_trp200cr_merchant");
    int nSword = WR_GetPlotFlag("sell_drgn", 0);
    object[] oPartyPool = GetPartyPoolList();
    int nSize = GetArraySize(oPartyPool);
    int nCount = 0;
    object oSword;
    if (!nSword)
    {
        for (nCount = 0; nCount < nSize; nCount++)
        {
            oSword = GetItemPossessedBy(oPartyPool[nCount], "gxa_im_wep_mel_gsw_002");
            if (IsObjectValid(oSword))
            {
                WR_SetPlotFlag("sell_drgn", 0, 1);
                return;
            }            
        } 
        
        CreateItemOnObject(R"gxa_im_wep_mel_gsw_002.uti", oArmaas);
        WR_SetPlotFlag("sell_drgn", 0, 1);
    }
}