#include "utility_h"
#include "effects_h"

// abilityId 0 is hidden in GUI
const int nAbility = 0;
const int nM2DA = 964994591;

void applyHaste(object oCreature) {
    effect[] effects = GetEffects(oCreature, EFFECT_TYPE_MOVEMENT_RATE, nAbility, oCreature, EFFECT_DURATION_TYPE_PERMANENT);
    int i, nSize = GetArraySize(effects);
    for (i = 0; i < nSize; i++) {
        effect e = effects[i];
        // GetEffects treats an abilityId of 0 as don't filter on it, so we need to check manually
        if (IsEffectValid(e) && GetEffectAbilityID(e) == nAbility)
            return;
    }
    float fSpeed = 1.0 + 0.01*GetM2DAFloat(nM2DA, "speed", 1);
    effect eEffect = EffectModifyMovementSpeed(fSpeed);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oCreature, 0.0f, oCreature, nAbility);
}

void removeHaste(object oCreature) {
    effect[] effects = GetEffects(oCreature, EFFECT_TYPE_MOVEMENT_RATE, nAbility, oCreature, EFFECT_DURATION_TYPE_PERMANENT);
    int i, nSize = GetArraySize(effects);
    for (i = 0; i < nSize; i++) {
        effect e = effects[i];
        // GetEffects treats an abilityId of 0 as don't filter on it, so we need to check manually
        if (IsEffectValid(e) && GetEffectAbilityID(e) == nAbility) {
            RemoveEffect(oCreature, e);
        }
    }
}