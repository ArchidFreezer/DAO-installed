#include "2da_constants_h"
#include "ai_threat_h"

object[] GetTargetsInAoE(event ev) {
    int nAbility = GetEventInteger(ev,0);
    int nAoEType = GetM2DAInt(TABLE_ABILITIES_SPELLS, "aoe_type", nAbility);
    float fAoEParam1 = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", nAbility);

    int nShape;
    location lTarget;
    float fAoEParam2;
    if (nAoEType == 1) {
        nShape = SHAPE_SPHERE;
        object oTarget = GetEventObject(ev,1);
        lTarget = oTarget == OBJECT_INVALID ? GetEventLocation(ev,0) : GetLocation(oTarget);
        fAoEParam2 = 0.0;
    } else {
        nShape = SHAPE_CONE;
        object oCaster = GetEventObject(ev,0);
        lTarget = GetLocation(oCaster);
        fAoEParam2 = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param2", nAbility);
        if (fAoEParam2 <= 0.0)
            fAoEParam2 = 5.0;
    }
    return GetObjectsInShape(OBJECT_TYPE_CREATURE, nShape, lTarget, fAoEParam1, fAoEParam2);
}

void main() {
    event ev = GetCurrentEvent();
    int nAbility = GetEventInteger(ev, 0);
    float fThreat = GetM2DAFloat(TABLE_ABILITIES_SPELLS,"threat_impact",nAbility);
    if (fThreat == 0.0)
        return;

    fThreat *= AI_THREAT_ABILITY_IMPACT_THREAT_COEFF;
    if ((nAbility == ABILITY_SPELL_WALKING_BOMB || nAbility == ABILITY_SPELL_MASS_CORPSE_DETONATION) && GetGameDifficulty() >= 2)
        fThreat *= 2.0;

    object oCaster;
    object[] arTargets;
    if (GetEventType(ev) == EVENT_TYPE_ENTER) {
        oCaster = GetEventCreator(ev);
        arTargets[0] = GetEventTarget(ev);
    } else {
        oCaster = GetEventObject(ev, 0);
        if (GetM2DAInt(TABLE_ABILITIES_SPELLS, "aoe_type", nAbility) == 0)
            arTargets[0] = GetEventObject(ev, 2);
        else
            arTargets = GetTargetsInAoE(ev);
    }
    int i, nSize = GetArraySize(arTargets);
    for (i = 0; i < nSize; i++)
        AI_Threat_UpdateCreatureThreat(arTargets[i], oCaster, fThreat);
}