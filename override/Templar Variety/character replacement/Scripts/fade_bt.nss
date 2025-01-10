#include "utility_h"
#include "plt_templar_swaps"

void main()
{
    object oTempGen1 = GetObjectByTag("cir310cr_burning_templar", 1);
    object oTempGen2 = GetObjectByTag("cir310cr_burning_templar", 2);
    object oTempGen3 = GetObjectByTag("cir310cr_burning_templar_2", 0);
    int nDefeated1 = IsDead(oTempGen1);
    int nDefeated2 = IsDead(oTempGen2);
    int nDefeated3 = IsDead(oTempGen3);

    string sName1 = GetName(oTempGen1);
    string sName2 = GetName(oTempGen2);
    string sName3 = GetName(oTempGen3);

    location lTemp1 = GetLocation(oTempGen1);
    location lTemp2 = GetLocation(oTempGen2);
    location lTemp3 = GetLocation(oTempGen3);

    int nSwapped = WR_GetPlotFlag("templar_swaps", 3);

    if (!nSwapped)
    {
        if (!nDefeated1)
        {
            object oNewTemp1 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_m_med_low_hos.utc", lTemp1, "cir310cr_burning_effect");
            SetName(oNewTemp1, sName1);

            if (IsObjectValid(oNewTemp1))
            {
                Safe_Destroy_Object(oTempGen1);
            }
        }

        if (!nDefeated2)
        {

            object oNewTemp2 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_f_heavy_low_hos.utc", lTemp2, "cir310cr_burning_effect");
            SetName(oNewTemp2, sName2);

            if (IsObjectValid(oNewTemp2))
            {
                Safe_Destroy_Object(oTempGen2);
            }
        }

        if (!nDefeated3)
        {

            object oNewTemp3 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_f_arch_low_hos.utc", lTemp3, "cir310cr_burning_effect");
            SetName(oNewTemp3, sName3);

            if (IsObjectValid(oNewTemp3))
            {
                Safe_Destroy_Object(oTempGen3);
            }
        }
        WR_SetPlotFlag("templar_swaps", 2, TRUE);
    }
}


