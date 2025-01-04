#include "effect_enchantment_h"

void main() {
    event ev = GetCurrentEvent();
    effect ef = GetCurrentEffect();
    switch (GetEventType(ev)) {
        case EVENT_TYPE_APPLY_EFFECT: {
            // If temporary remove existing temporary enchantments -- this prevents stacking poisons/coatings
            if (GetEffectDurationType(ef) == EFFECT_DURATION_TYPE_TEMPORARY) {
                effect[] aEnchantments = GetEffects(OBJECT_SELF, EFFECT_TYPE_ENCHANTMENT, 0, OBJECT_INVALID, EFFECT_DURATION_TYPE_TEMPORARY);
                int nEffects = GetArraySize(aEnchantments);
                int i;
                for (i=0; i < nEffects; i++)
                    RemoveEffect(OBJECT_SELF, aEnchantments[i]);
            }

            Effects_HandleApplyEffectEnchantment(ef);
            SetIsCurrentEffectValid(TRUE);
            break;
        }
        case EVENT_TYPE_REMOVE_EFFECT: {
            Effects_HandleRemoveEffectEnchantment(ef);
            break;
        }
    }
}