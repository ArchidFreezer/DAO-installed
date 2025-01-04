#include "events_h"
#include "effects_h"
#include "ability_h"
#include "core_h"

void main() {
    event  ev = GetCurrentEvent();
    int    nAttackResult = GetEventInteger(ev, 0);
    object oAttacker = GetEventObject(ev, 0);
    object oTarget = GetEventObject(ev, 1);

    if (nAttackResult == COMBAT_RESULT_BACKSTAB && HasAbility(oAttacker, ABILITY_TALENT_LACERATE) && CanCreatureBleed(oTarget)) {
        int    nEffectId = GetEventInteger(ev,1);
        effect eImpactEffect = GetAttackImpactDamageEffect(oAttacker,nEffectId);
        float  fDamage = GetEffectFloat(eImpactEffect,0);

        // GetAttackImpactDamageEffect removes the existing attack effect, reset so that the actual event can use it
        SetAttackResult(oAttacker, nAttackResult, eImpactEffect, COMBAT_RESULT_INVALID, Effect());

        if (fDamage>=10.0) {
            // Can not stack temporary effects on hit, might cause runaway memory usage in high speed attack situations
            if (!GetHasEffects(oTarget, EFFECT_TYPE_DOT,ABILITY_TALENT_LACERATE))
                ApplyEffectDamageOverTime(oTarget, oAttacker, ABILITY_TALENT_LACERATE, fDamage*0.25, 4.0f, DAMAGE_TYPE_PHYSICAL);
        }
    }
}