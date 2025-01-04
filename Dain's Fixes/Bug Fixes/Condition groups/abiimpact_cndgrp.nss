#include "ability_h"
#include "abi_templates"

void main() {
    event ev = GetCurrentEvent();
    int nAbility = GetEventInteger(ev,0);
    int nConditionGrp = GetM2DAInt(TABLE_ABILITIES_SPELLS, "condition_group", nAbility);
    if (nConditionGrp != 0) {
        object oCaster = GetEventObject(ev,0);
        effect[] arUpkeep = GetEffects(oCaster, EFFECT_TYPE_UPKEEP);
        int nSize = GetArraySize(arUpkeep);
        int i;
        for (i = 0; i < nSize; i++) {
            int nID = GetEffectAbilityID(arUpkeep[i]);
            if (nID != nAbility && GetM2DAInt(TABLE_ABILITIES_SPELLS, "condition_group", nID) == nConditionGrp)
                Effects_RemoveUpkeepEffect(oCaster, nID);
        }
    }
}