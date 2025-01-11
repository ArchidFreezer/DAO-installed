#include "effect_constants_h"
#include "spell_constants_h"
#include "2da_constants_h"

void main() {
    effect eEffect = GetCurrentEffect();
    object oCreator = GetEffectCreator(eEffect);
    event ev = GetCurrentEvent();
    switch (GetEventType(ev)) {
        case EVENT_TYPE_APPLY_EFFECT: {
            effect eAoE = EffectAreaOfEffect(CLEANSING_AURA_AOE, R"aoe_gca.ncs", CLEANSING_AURA_AOE_VFX);
            eAoE = SetEffectEngineFloat(eAoE, EFFECT_FLOAT_SCALE, GetM2DAFloat(TABLE_VFX_PERSISTENT, "RADIUS", CLEANSING_AURA_AOE));
            Engine_ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eAoE, OBJECT_SELF, 0.0, oCreator, ABILITY_SPELL_CLEANSING_AURA);
            SetIsCurrentEffectValid();
            break;
        }
        case EVENT_TYPE_REMOVE_EFFECT: {
            RemoveEffectsByParameters(OBJECT_SELF, EFFECT_TYPE_AOE, 0, oCreator);
            break;
        }
    }
}