#include "utility_h"
#include "plt_templar_swaps"

void main()
{
    object oTempGen1 = GetObjectByTag("ran800cr_templar", 1);
    object oTempGen3 = GetObjectByTag("ran800cr_templar", 3);
    object oTempGen7 = GetObjectByTag("ran800cr_templar", 7);
    object oTempGen8 = GetObjectByTag("ran800cr_templar", 8);

    int nDefeated1 = IsDead(oTempGen1);
    int nDefeated3 = IsDead(oTempGen3);
    int nDefeated7 = IsDead(oTempGen7);
    int nDefeated8 = IsDead(oTempGen8);


    location lTemp1 = GetLocation(oTempGen1);
    location lTemp3 = GetLocation(oTempGen3);
    location lTemp7 = GetLocation(oTempGen7);
    location lTemp8 = GetLocation(oTempGen8);

    int nSwapped = WR_GetPlotFlag("templar_swaps", 5);

    if (!nSwapped)
    {
        if (!nDefeated1)
        {
            object oNewTemp1 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_f_med_low.utc", lTemp1);
            SetTeamId(oNewTemp1, 5);

            if (IsObjectValid(oNewTemp1))
            {
                Safe_Destroy_Object(oTempGen1);
            }
        }

        if (!nDefeated3)
        {
            object oNewTemp3 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_f_arch_low.utc", lTemp3);
            SetTeamId(oNewTemp3, 5);

            if (IsObjectValid(oNewTemp3))
            {
                Safe_Destroy_Object(oTempGen3);
            }
        }

        if (!nDefeated7)
        {
            object oNewTemp7 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_m_med_low.utc", lTemp7);
            SetTeamId(oNewTemp7, 5);

            if (IsObjectValid(oNewTemp7))
            {
                Safe_Destroy_Object(oTempGen7);
            }
        }

        if (!nDefeated8)
        {
            object oNewTemp8 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_f_heavy_low.utc", lTemp8);
            SetTeamId(oNewTemp8, 5);

            if (IsObjectValid(oNewTemp8))
            {
                Safe_Destroy_Object(oTempGen8);
            }
        }

        WR_SetPlotFlag("templar_swaps", 5, TRUE);
    }
}