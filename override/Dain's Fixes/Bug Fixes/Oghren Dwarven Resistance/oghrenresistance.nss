#include "2da_constants_h"
void main()
{
    object[] arParty = GetPartyPoolList();
    int i;
    for (i = 0; i < GetArraySize(arParty); i++)
        if (GetTag(arParty[i]) == "gen00fl_oghren")
            if (!HasAbility(arParty[i], ABILITY_SKILL_DWARVEN_RESISTANCE))
                AddAbility(arParty[i], ABILITY_SKILL_DWARVEN_RESISTANCE);
}