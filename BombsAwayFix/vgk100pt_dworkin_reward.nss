#include "utility_h"
#include "wrappers_h" 
#include "plt_vgk100pt_dworkin_fix"

void main ()
{       
int cL = UT_CountItemInInventory(R"vgk100im_lyrium_sand.uti");

if (WR_GetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, VGK_DWORKIN_EXPLOSIVES_SAFE_CHOSEN_FIX) == TRUE)
    {
    UT_AddItemToInventory(R"vgk100im_explsv_safe.uti", cL);
    }
if (WR_GetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, VGK_DWORKIN_EXPLOSIVES_MODERATE_CHOSEN_FIX) == TRUE)
    {
    UT_AddItemToInventory(R"vgk100im_explsv_moderate.uti", cL);
    }
if (WR_GetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, VGK_DWORKIN_EXPLOSIVES_HIGH_RISK_CHOSEN_FIX) == TRUE)
    {
    UT_AddItemToInventory(R"vgk100im_explsv_high_risk.uti", cL);
    }

WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_NOT_ALL_SAND, FALSE);
}