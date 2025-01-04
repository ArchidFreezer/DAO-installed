#include "effect_constants_h"
#include "2da_constants_h"

void main() {
    effect[] aEffects = GetEffects(OBJECT_SELF, EFFECT_TYPE_DOT);
    int i, nSize = GetArraySize(aEffects);
    int bFireDot = FALSE;
    for (i = 0; i < nSize; i++) {
        int nDamageType = GetEffectInteger(aEffects[i],1);
        if (nDamageType == DAMAGE_TYPE_FIRE) {
            bFireDot = TRUE;
            break;
        }
    }
    if (bFireDot) {
        RemoveEffectsByParameters(OBJECT_SELF, EFFECT_TYPE_INVALID, ABILITY_SPELL_WINTERS_GRASP);
        RemoveEffectsByParameters(OBJECT_SELF, EFFECT_TYPE_INVALID, ABILITY_SPELL_CONE_OF_COLD);
        RemoveEffectsByParameters(OBJECT_SELF, EFFECT_TYPE_INVALID, ABILITY_SPELL_BLIZZARD);
        RemoveEffectsByParameters(OBJECT_SELF, EFFECT_TYPE_INVALID, 40211 /* Hand of Winter */);
        RemoveEffectsByParameters(OBJECT_SELF, EFFECT_TYPE_INVALID, MONSTER_PRIDE_DEMON_FROST_BLAST);
        RemoveEffectsByParameters(OBJECT_SELF, EFFECT_TYPE_INVALID, MONSTER_PRIDE_DEMON_FROST_BOLT);
    }
}