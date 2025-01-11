#include "effect_constants_h"
#include "eventmanager_h"

void main() {
    event ev = GetCurrentEvent();
    int nAbility = GetEventInteger(ev, 0);
    // Rock mastery is special (stone aura is too but you can't transistion areas with it active so...)
    if (nAbility == 300300)
        nAbility = 300310;
    object oTarget = GetEventTarget(ev);
    object oCaster = GetEventCreator(ev);
    if (nAbility != 0 && oTarget != oCaster) {
        effect[] arEffects = GetEffects(oTarget, EFFECT_TYPE_INVALID, nAbility, oCaster);
        int nSize = GetArraySize(arEffects);
        int i;
        for (i = 0;i < nSize;i++) {
            effect ef = arEffects[i];
            if (GetEffectType(ef) != EFFECT_TYPE_AOE)
                RemoveEffect(oTarget, ef);
        }
    }
}