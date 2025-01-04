#include "events_h"
#include "effects_h"
#include "sys_itemprops_h"

int nAbilityId = 400202;
int nOnHitEffectId = 401010;

// Since it all has to be implemented bespokely anyway, just hardcoding the itemprps entries for simplicity and performance.
// Itemprps has int0 12, float0 0.05, baseDuration 4, scales with float0. The talent seems to always have a power of 5.
// This means +25% damage scale and 9s duration. Probably overpowered, but then again so is everything else in awakening.
void main()
{
    event ev = GetCurrentEvent();
    object oAttacker = GetEventCreator(ev);
    object oTarget = GetEventTarget(ev);
    // Only care about living creatures
    if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE && !IsDeadOrDying(oTarget)) {
        // Remove existing effects
        effect[] fx = GetEffects(oTarget, EFFECT_TYPE_MODIFY_PROPERTY, nAbilityId, oAttacker);
        int i, nCount = GetArraySize(fx);
        for (i = 0; i < nCount; i++)
            RemoveEffect(oTarget, fx[i]);
        
        int nPower = GetItemPropertyPower(GetEventObject(ev,1), nOnHitEffectId, FALSE);
        float fPower = 0.05*IntToFloat(nPower);
        float fDuration = GetRankAdjustedEffectDuration(oTarget, 4.0 + IntToFloat(nPower));
        
        effect ef = Effect(EFFECT_TYPE_MODIFY_PROPERTY);
        ef = SetEffectCreator(ef, oAttacker);
        ef = SetEffectInteger(ef, 0, PROPERTY_ATTRIBUTE_DAMAGE_SCALE);
        ef = SetEffectFloat(ef, 0, 0.05);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, ef, oTarget, fDuration, oAttacker, nAbilityId);        
    }
}