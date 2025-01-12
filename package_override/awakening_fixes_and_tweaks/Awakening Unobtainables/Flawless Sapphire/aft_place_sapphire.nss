#include "utility_h"
#include "plt_aft_sapphire"

void main()
{
    object oArea = GetArea(GetHero());
    string sArea = GetTag(oArea);
    
    int nPlaced = WR_GetPlotFlag("aft_sapphire", 0);
    object oChest = GetObjectByTag("genip_chest_ornate");
    object oChest2 = GetObjectByTag("genip_chest_wood_1");

    if (!nPlaced && sArea == "coa130ar_smugglers_cove")
    {
        CreateItemOnObject(R"gxa_im_gem_sapphire_flawles.uti", oChest);
        WR_SetPlotFlag("aft_sapphire", 0, 1);
    }
    
    if (!nPlaced && sArea == "aoa130ar_smugglers_cove_sg")
    {
        CreateItemOnObject(R"gxa_im_gem_sapphire_flawles.uti", oChest2);
        WR_SetPlotFlag("aft_sapphire", 0, 1);
    }
}