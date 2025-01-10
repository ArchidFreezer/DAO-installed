#include "utility_h"
#include "wrappers_h" 
#include "plt_vgk100pt_dworkin_fix"

void main ()
{       
int cL = UT_CountItemInInventory(R"vgk100im_lyrium_sand.uti");

if (WR_GetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_ALL_SAND) == FALSE)
    {
    if (cL == 1) 
        {
        if (WR_GetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_3_SAND) == FALSE)
            {
            if (WR_GetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_2_SAND) == FALSE)
                {
                if (WR_GetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_1_SAND) == FALSE)
                    {
                    WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_1_SAND, TRUE);
                    WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_NOT_ALL_SAND, TRUE);
                    }
                else
                    {
                    WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_1_SAND, FALSE);
                    WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_2_SAND, TRUE);
                    WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_NOT_ALL_SAND, TRUE);
                    }
                }
            else
                {
                WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_2_SAND, FALSE);
                WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_3_SAND, TRUE);
                WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_NOT_ALL_SAND, TRUE);
                }
            }
        else
            {
            WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_3_SAND, FALSE);
            WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_ALL_SAND, TRUE);
            }
        }
    if (cL == 2)
        {
        if (WR_GetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_2_SAND) == FALSE)
            {
            if (WR_GetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_1_SAND) == FALSE)
                {
                WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_2_SAND, TRUE);
                WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_NOT_ALL_SAND, TRUE);
                }
            else
                {
                WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_1_SAND, FALSE);
                WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_3_SAND, TRUE);
                WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_NOT_ALL_SAND, TRUE);
                }
            }
        else
            {
            WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_2_SAND, FALSE);
            WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_ALL_SAND, TRUE);
            }
        }
    if (cL == 3)
        {
        if (WR_GetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_1_SAND) == FALSE)
            {
            WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_3_SAND, TRUE);
            WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_NOT_ALL_SAND, TRUE);
            }
        else
            {
            WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_1_SAND, FALSE);
            WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_ALL_SAND, TRUE);
            }
        }
    if (cL == 4)
        {
        WR_SetPlotFlag(PLT_VGK100PT_DWORKIN_FIX, GIVEN_ALL_SAND, TRUE);
        }
    }
}