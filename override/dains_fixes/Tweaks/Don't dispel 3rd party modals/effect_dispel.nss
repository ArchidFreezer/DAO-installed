#include "effect_dispel_magic_h"
#include "effect_constants_h"

void main() {
    effect ef = GetCurrentEffect();
    int nEffectType = GetEffectType(ef);
    if (!IsDead(OBJECT_SELF) && nEffectType == EFFECT_TYPE_DISPEL_MAGIC) {
        Effects_HandleApplyEffectDispelMagic(ef);
        SetIsCurrentEffectValid(TRUE);
    } else
        SetIsCurrentEffectValid(FALSE);
}