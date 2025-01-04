#include "utility_h"
#include "plt_blackblade_AFT"

int nMinePlaced = WR_GetPlotFlag("blackblade_AFT", 0);
int nWoodsPlaced = WR_GetPlotFlag("blackbladeAFT", 1);
object oSecretChest = GetObjectByTag("trp200ip_secret_room_chest");
object oCocoon = GetObjectByTag("genip_cocoon");
object oArea = GetArea(GetHero());
string sArea = GetTag(oArea);

void main()
{
    if (sArea == "trp200ar_silverite_mine" && !nMinePlaced)
    {
        CreateItemOnObject(R"gxa_im_glv_lgt_003.uti", oSecretChest); 
        WR_SetPlotFlag("blackblade_AFT", 0, 1);
    }
    
    if (sArea == "trp100ar_wending_wood" && !nWoodsPlaced)
    {
        CreateItemOnObject(R"gxa_im_arm_bot_lgt_003.uti", oCocoon);
        WR_SetPlotFlag("blackblade_AFT", 1, 1);
    }
}
        
    