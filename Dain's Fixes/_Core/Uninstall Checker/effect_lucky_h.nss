#include "sys_resistances_h"

void Lucky_UpdateProps(float fPower, object oTarget = OBJECT_SELF) {
    // Small increase to crit chance, evasion and spell resistance
    UpdateCreatureProperty(oTarget, PROPERTY_ATTRIBUTE_MELEE_CRIT_MODIFIER, fPower, PROPERTY_VALUE_MODIFIER);
    UpdateCreatureProperty(oTarget, PROPERTY_ATTRIBUTE_RANGED_CRIT_MODIFIER, fPower, PROPERTY_VALUE_MODIFIER);
    UpdateCreatureProperty(oTarget, PROPERTY_ATTRIBUTE_DISPLACEMENT, fPower, PROPERTY_VALUE_MODIFIER);
    UpdateCreatureProperty(oTarget, PROPERTY_ATTRIBUTE_SPELLRESISTANCE, fPower, PROPERTY_VALUE_MODIFIER);
}

// If existing Lucky effect not applied by this mod we don't want to handle it or risk permanently affecting attributes -- we set Int1 in itemprps to tell if it's ours
int Lucky_IsEffectValid(effect ef) {
    return GetEffectInteger(ef, 1);
}

void Lucky_HandleApplyEffect(effect ef, object oTarget = OBJECT_SELF) {
    if (Lucky_IsEffectValid(ef)) {
        float fPower = GetEffectFloat(ef, 0);
        Lucky_UpdateProps(fPower, oTarget);
    }

    SetIsCurrentEffectValid();
}

void Lucky_HandleRemoveEffect(effect ef, object oTarget = OBJECT_SELF) {
    if (Lucky_IsEffectValid(ef)) {
        float fPower = GetEffectFloat(ef, 0);
        Lucky_UpdateProps(fPower*-1.0, oTarget);
    }
}