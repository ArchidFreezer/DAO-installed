#include "talent_constants_h"
#include "2da_constants_h"
#include "ai_threat_h"

void main()
{
    event  ev = GetCurrentEvent();
    object oAttacker = GetEventCreator(ev);
    object oTarget = OBJECT_SELF;

    if (!IsFollower(oTarget) && HasAbility(oAttacker, ABILITY_TALENT_FRIGHTENING) && IsModalAbilityActive(oAttacker, ABILITY_TALENT_THREATEN) && IsObjectValid(oTarget) && !IsDead(oTarget) && IsObjectHostile(oAttacker, oTarget)) {
        float fDamage = GetEventFloat(ev, 0);
        float fMaxHealth = GetMaxHealth(oTarget);
        if (fMaxHealth == 0.0)
            return;

        float fThreatChange = fDamage / fMaxHealth * 100.0 * AI_THREAT_VALUE_DIRECT_DAMAGE * FRIGHTENING_THREATEN_BONUS;
        // this is run as a pre-event listener - not using AI_Threat_UpdateCreatureThreat as we don't want to recalculate targets yet - the main damaged handler will do that
        fThreatChange = AI_Threat_GetHatedThreat(oTarget, oAttacker, fThreatChange);

        if(fThreatChange < AI_THREAT_MIN_CHANGE)
            return;

        float fCurrentThreat = GetThreatValueByObjectID(oTarget, oAttacker);
        if(fThreatChange > 0.0 && fCurrentThreat + fThreatChange > AI_THREAT_MAX)
            fThreatChange = AI_THREAT_MAX - fCurrentThreat;

        UpdateThreatTable(oTarget, oAttacker, fThreatChange);
    }
}