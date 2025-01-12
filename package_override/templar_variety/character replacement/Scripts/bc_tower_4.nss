#include "utility_h"                                                                                                                                                                   #include "utility_h"
#include "plt_templar_swaps"

void main()
{
    object oTempGen1 = GetObjectByTag("cir220cr_possessedtemplar", 1);

    int nDefeated1 = IsDead(oTempGen1);

    string sName1 = GetName(oTempGen1);

    location lTemp1 = GetLocation(oTempGen1);

    int nSwapped = WR_GetPlotFlag("templar_swaps", 2);

    if (!nSwapped)
    {
        if (!nDefeated1)
        {
            object oNewTemp1 = CreateObject(OBJECT_TYPE_CREATURE, R"templar_m_arch_hos.utc", lTemp1);
            SetTeamId(oNewTemp1, 126);
            SetName(oNewTemp1, sName1);

            if (IsObjectValid(oNewTemp1))
            {
                Safe_Destroy_Object(oTempGen1);
            }
        }

        WR_SetPlotFlag("templar_swaps", 2, TRUE);
    }
}
