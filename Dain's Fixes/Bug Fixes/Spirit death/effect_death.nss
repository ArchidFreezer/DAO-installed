#include "effect_death_h"

void main() {
    event ev = GetCurrentEvent();
    if (GetEventType(ev) == EVENT_TYPE_APPLY_EFFECT) {
        effect ef = GetCurrentEffect();
        int nRet = Effects_HandleApplyEffectDeath(ef);
        SetIsCurrentEffectValid(nRet);
    }
}