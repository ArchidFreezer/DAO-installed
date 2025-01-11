#include "events_h"
#include "effects_h"
#include "sys_itemprops_h"
#include "eventmanager_h"

void main()
{
    event ev = GetCurrentEvent();
    int nOnHitEffectId = GetEventInteger(ev,0);

    // First determine proc chance. If no proc, no point in wasting cpu time on the rest
    int nForceProc = GetEventInteger(ev,2);
    if (nForceProc > 0 || RandomFloat() < GetM2DAFloat(TABLE_ITEMPRPS, "ProcChance", nOnHitEffectId)) {
        object oAttacker = GetEventCreator(ev);
        // check to see if the character is in a shapeshifted form
        // this prevents a rat from having a huge stack of damage floaties from equipment
        if (!IsShapeShifted(oAttacker)) {
            object oTarget = GetEventTarget(ev);
            // No care about dead targets or non creatures
            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE && !IsDeadOrDying(oTarget)) {
                object oItem = GetEventObject(ev,1);
                int nPower = IsObjectValid(oItem) ? GetItemPropertyPower(oItem,nOnHitEffectId,FALSE) : 1;
                effect eDamage = EffectDamage(nPower*3.0, DAMAGE_TYPE_NATURE);
                Effects_HandleApplyEffectDamage(eDamage, oTarget);

                if (RandomFloat()*100 < (1+nPower) * 5.0f) {
                    float fDuration = GetRankAdjustedEffectDuration(oTarget, IntToFloat(nPower + 5));
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, EffectStun(), oTarget, fDuration, oAttacker, 0);
                }
            }
        }
    }
}