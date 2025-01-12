#include "spell_constants_h"
#include "ability_h"

void _ApplySpellHeartbeatEffects(int nAbility, object oTarget, object oCreator)
{
    // if target is not the caster
    if (oTarget != oCreator)
    {
        // is target friendly
        if (IsObjectHostile(oCreator, oTarget) == FALSE)
        {
            int bHeal = FALSE;
            int bInjury = FALSE;

            // get distance
            float fDistance = GetDistanceBetween(oTarget, oCreator);
            float fHeal;

            if (GetCurrentHealth(oTarget) < GetMaxHealth(oTarget))
            {
                bHeal = TRUE;

                fHeal = (100.0f + GetCreatureSpellPower(oCreator)) * CLEANSING_AURA_PULSE_HEALING_FACTOR;

                if (fDistance > CLEANSING_AURA_PULSE_INNER_RADIUS)
                {
                    // reduce healing based on distance
                    fDistance /= CLEANSING_AURA_PULSE_INNER_RADIUS;
                    fDistance *= 2.0f;
                    fHeal /= fDistance;
                }
            }

            if (fDistance <= CLEANSING_AURA_PULSE_INNER_RADIUS)
            {
                // remove injury
                effect[] eInjuries = Injury_GetInjuryEffects(oTarget);
                if (GetArraySize(eInjuries) > 0)
                {
                    bInjury = TRUE;

                    Injury_RemoveInjury(oTarget, Injury_GetInjuryIdFromEffect(eInjuries[0]));
                }
            }

            if (bHeal == TRUE)
            {
                // heal
                effect eEffect = EffectHeal(fHeal);
                eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(nAbility));
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTarget, 0.0f, oCreator, nAbility);
            } else if (bInjury == TRUE)
            {
                effect eEffect = EffectVisualEffect(Ability_GetImpactObjectVfxId(nAbility));
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTarget, 0.0f, oCreator, nAbility);
            }
        }
    }
}


void main() {
    event ev = GetCurrentEvent();
    if (GetEventType(ev) == EVENT_TYPE_AOE_HEARTBEAT) {
        object oCreator = GetEventCreator(ev);
        int nSlot = GetItemEquipSlot(oCreator);
        if (nSlot == INVENTORY_SLOT_INVALID) {
            Safe_Destroy_Object(OBJECT_SELF);
            return;
        }

        object[] oTargets = GetCreaturesInAOE(OBJECT_SELF);

        int i, nMax = GetArraySize(oTargets);
        object oOwner = OBJECT_INVALID;
        for (i = 0; i < nMax; i++) {
            object oTarget = oTargets[i];
            if (GetItemInEquipSlot(nSlot, oTarget) == oCreator) {
                oOwner = oTarget;
                break;
            }
        }
        if (oOwner == OBJECT_INVALID) {
            Safe_Destroy_Object(OBJECT_SELF);
            return;
        }

        int nAbility = GetEventInteger(ev,0);
        for (i = 0; i < nMax; i++) {
            _ApplySpellHeartbeatEffects(nAbility, oTargets[i], oOwner);
        }

        DelayEvent(CLEANSING_AURA_PULSE_INTERVAL + 0.05f, OBJECT_SELF, SetEventInteger(ev,1,GetGameMode()));
    }
}