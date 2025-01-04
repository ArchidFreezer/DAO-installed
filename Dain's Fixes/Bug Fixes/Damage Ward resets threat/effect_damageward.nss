#include "effect_constants_h"
#include "ai_threat_h"

void ResetThreat(object oTarget)
{
    object[] oCreatures = GetNearestObject(oTarget, OBJECT_TYPE_CREATURE, 30, TRUE, TRUE);
    int nSize = GetArraySize(oCreatures);
    int i;
    for (i = 0; i < nSize; i++) {
        if (IsObjectHostile(oCreatures[i], oTarget)) {
            SetLocalInt(oCreatures[i], AI_THREAT_TARGET_SWITCH_COUNTER, 0);
            AI_Threat_UpdateCreatureThreat(oCreatures[i], oTarget, -1.0f * GetThreatValueByObjectID(oCreatures[i], oTarget));
        }
    }
}

void main() {
    event ev = GetCurrentEvent();
    if (GetEventType(ev) == EVENT_TYPE_APPLY_EFFECT) {
        if (!IsDead(OBJECT_SELF)) {
            ResetThreat(OBJECT_SELF);
            SetIsCurrentEffectValid(TRUE);
        }
    }
}
