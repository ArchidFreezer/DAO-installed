#include "core_h"
#include "monster_constants_h"
#include "ability_h"

void _ApplyEffects(object oCreator, object oTarget, int nAbility) {
    // physical resistance
    if (ResistanceCheck(oCreator, oTarget, PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
    {
        // speed
        effect eSpeed = EffectModifyMovementSpeed(AURA_WEAKNESS_MOVEMENT_RATE, TRUE);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eSpeed, oTarget, 0.0, oCreator, nAbility);
    }

    // attack and defense penalty
    effect eEffect = EffectModifyPropertyHostile(PROPERTY_ATTRIBUTE_ATTACK, AURA_WEAKNESS_ATTACK_PENALTY, PROPERTY_ATTRIBUTE_DEFENSE, AURA_WEAKNESS_DEFENSE_PENALTY);
    eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(nAbility));
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oTarget, 0.0, oCreator, nAbility);
}

void main() {
    event ev = GetCurrentEvent();
    object oTarget = GetEventTarget(ev);
    object oCreator = GetEventCreator(ev);
    if (GetM2DAInt(TABLE_APPEARANCE,"creature_type",GetAppearanceType(oTarget)) == CREATURE_TYPE_DARKSPAWN) {
        // Both EVENT_TYPE_ENTER and EVENT_TYPE_EXIT are directed to this script.
        // On exit we just want to remove the effect, on enter we also want to apply it.
        RemoveStackingEffects(oTarget, oCreator, ABILITY_TALENT_MONSTER_AURA_WEAKNESS);
        if (GetEventType(ev) == EVENT_TYPE_ENTER)
            _ApplyEffects(oCreator, oTarget, ABILITY_TALENT_MONSTER_AURA_WEAKNESS);
    }
}