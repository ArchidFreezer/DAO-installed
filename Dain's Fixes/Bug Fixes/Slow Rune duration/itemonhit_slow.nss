#include "effects_h"
#include "sys_resistances_h"

void main()
{
    event ev = GetCurrentEvent();
    int nId = GetEventInteger(ev,0);

    object oTarget = GetEventTarget(ev);
    if (!GetHasEffects(oTarget, EFFECT_TYPE_MOVEMENT_RATE,90028)) {
        object oAttacker = GetEventCreator(ev);
        object oItem = GetEventObject(ev,1);
        int nPower = IsObjectValid(oItem) ? GetItemPropertyPower(oItem,nId,TRUE) : 1;
        float fDuration = GetM2DAFloat(TABLE_ITEMPRPS,"BaseDuration", nId) + 1.0*nPower;
        fDuration = GetRankAdjustedEffectDuration(oTarget, fDuration);
        effect eSlow = EffectModifyMovementSpeed(0.5);
        eSlow = SetEffectEngineInteger(eSlow, EFFECT_INTEGER_VFX, 1105);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eSlow, oTarget, fDuration, oAttacker, 90028);
    }
}