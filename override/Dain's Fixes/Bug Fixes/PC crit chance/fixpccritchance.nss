#include "core_h"
void main()
{
    SetCreatureProperty(GetHero(), CRITICAL_MODIFIER_MELEE, 3.0, PROPERTY_VALUE_BASE);
    SetCreatureProperty(GetHero(), CRITICAL_MODIFIER_RANGED, 3.0, PROPERTY_VALUE_BASE);
}