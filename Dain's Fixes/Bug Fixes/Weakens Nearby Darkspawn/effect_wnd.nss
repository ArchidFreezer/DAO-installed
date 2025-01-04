#include "effect_constants_h"
#include "monster_constants_h"

const int WND_VFX = 512023516;

void main() {
    effect eEffect = GetCurrentEffect();
    object oCreator = GetEffectCreator(eEffect);
    event ev = GetCurrentEvent();
    switch (GetEventType(ev)) {
        case EVENT_TYPE_APPLY_EFFECT: {
            effect eAoE = EffectAreaOfEffect(313063100, R"aoe_wnd.ncs", WND_VFX);
            eAoE = SetEffectEngineFloat(eAoE, EFFECT_FLOAT_SCALE, 5.0);
            Engine_ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eAoE, OBJECT_SELF, 0.0, oCreator);
            SetIsCurrentEffectValid();
            break;
        }
        case EVENT_TYPE_REMOVE_EFFECT: {
            RemoveEffectsByParameters(OBJECT_SELF, EFFECT_TYPE_AOE, 0, oCreator);
            break;
        }
    }
}