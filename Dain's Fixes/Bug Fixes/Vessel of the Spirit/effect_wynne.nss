#include "effects_h"

void main() {
    event ev = GetCurrentEvent();
    effect eEffect = GetCurrentEffect();
    if (GetEventType(ev) == EVENT_TYPE_APPLY_EFFECT) {
        SetIsCurrentEffectValid(TRUE);
    } else {
        int nAbility = GetEffectAbilityID(eEffect);
        if (IsModalAbilityActive(OBJECT_SELF, nAbility)) {
            Effects_RemoveUpkeepEffect(OBJECT_SELF, nAbility);

            // add weakness effect
            effect eEffect = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_ATTACK, WYNNE_ATTACK_PENALTY, PROPERTY_ATTRIBUTE_DEFENSE, WYNNE_DEFENSE_PENALTY);
            eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, WYNNE_WEAKNESS_VFX);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, OBJECT_SELF, WYNNE_WEAKNESS_DURATION, OBJECT_SELF, nAbility);
            eEffect = EffectModifyMovementSpeed(WYNNE_SPEED_PENALTY);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, OBJECT_SELF, WYNNE_WEAKNESS_DURATION, OBJECT_SELF, nAbility);

            // stun if trinket not equipped
            if (GetTag(GetItemInEquipSlot(INVENTORY_SLOT_NECK)) != "gen_im_acc_amu_am11")
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, EffectStun(), OBJECT_SELF, WYNNE_STUN_DURATION, OBJECT_SELF, nAbility);
        }
    }
}