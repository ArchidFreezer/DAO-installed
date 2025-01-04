#include "2da_constants_h"
#include "core_h"
#include "wrappers_h"
#include "plt_gxa_specfix"

const int PROPERTY_SIMPLE_SPECIALIZATION_POINTS = 38;

void AdjustCreatureProperty(object oCreature, int nProperty, float fDelta, int nValueType = PROPERTY_VALUE_TOTAL)
{
    float fOldValue = GetCreatureProperty(oCreature, nProperty, nValueType);
    float fNewValue = fOldValue + fDelta;
    SetCreatureProperty(oCreature, nProperty, fNewValue, nValueType);
}

void main()
{
    if ( WR_GetPlotFlag( PLT_GXA_SPECFIX, FLAG_0 ) == FALSE )
    {
        object oChar = GetHero();
        int iCount = 0;

        if (GetLevel(oChar) >= 22)
        {
            if (
               (HasAbility(oChar, 4012) == TRUE) ||
               (HasAbility(oChar, 4013) == TRUE) ||
               (HasAbility(oChar, 4014) == TRUE)
               )
            {
                iCount = iCount + 1;
            }
            if (
               (HasAbility(oChar, 4015) == TRUE) ||
               (HasAbility(oChar, 4016) == TRUE) ||
               (HasAbility(oChar, 4017) == TRUE)
               )
            {
                iCount = iCount + 1;
            }
            if (
               (HasAbility(oChar, 4018) == TRUE) ||
               (HasAbility(oChar, 4019) == TRUE) ||
               (HasAbility(oChar, 4029) == TRUE)
               )
            {
                iCount = iCount + 1;
            }
            if (
               (HasAbility(oChar, 4025) == TRUE) ||
               (HasAbility(oChar, 4021) == TRUE) ||
               (HasAbility(oChar, 4030) == TRUE)
               )
            {
                iCount = iCount + 1;
            }
            if (
               (HasAbility(oChar, 401000) == TRUE) ||
               (HasAbility(oChar, 401002) == TRUE) ||
               (HasAbility(oChar, 401004) == TRUE)
               )
            {
                iCount = iCount + 1;
            }
            if (
               (HasAbility(oChar, 401001) == TRUE) ||
               (HasAbility(oChar, 401003) == TRUE) ||
               (HasAbility(oChar, 401005) == TRUE)
               )
            {
                iCount = iCount + 1;
            }

            if (iCount >=3)
            {
                SetCreatureProperty(oChar, PROPERTY_SIMPLE_SPECIALIZATION_POINTS, 0.0f, PROPERTY_VALUE_TOTAL);
            }

            else if (iCount >=2)
            {
                SetCreatureProperty(oChar, PROPERTY_SIMPLE_SPECIALIZATION_POINTS, 1.0f, PROPERTY_VALUE_TOTAL);
            }

            else if (iCount >=1)
            {
                SetCreatureProperty(oChar, PROPERTY_SIMPLE_SPECIALIZATION_POINTS, 2.0f, PROPERTY_VALUE_TOTAL);
            }

            else
            {
                SetCreatureProperty(oChar, PROPERTY_SIMPLE_SPECIALIZATION_POINTS, 3.0f, PROPERTY_VALUE_TOTAL);
            }
        }

        WR_SetPlotFlag( PLT_GXA_SPECFIX, FLAG_0, TRUE );

    }

}