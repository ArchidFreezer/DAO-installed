#include "sys_itemprops_h"

void main() {
    if (GetGameMode() == GM_COMBAT)
    {
        event ev = GetCurrentEvent();
        int nOnHitEffectId = GetEventInteger(ev,0);
        int nForceProc = GetEventInteger(ev,2);

        string sScript = GetM2DAString(611660526, "Script", nOnHitEffectId);
        // default behaviour
        if (sScript == "") {
            // First determine proc chance. If no proc, no point in wasting cpu time on the rest
            if (GetEventInteger(ev,2) > 0 || RandomFloat() < GetM2DAFloat(TABLE_ITEMPRPS, "ProcChance", nOnHitEffectId)) {
                object oAttacker = GetEventCreator(ev);
                // check to see if the character is in a shapeshifted form
                // this prevents a rat from having a huge stack of damage floaties from equipment
                if (!IsShapeShifted(oAttacker)) {
                    object oTarget = GetEventTarget(ev);
                    // We don't care about dead targets or non creatures
                    if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE && !IsDeadOrDying(oTarget)) {
                        object oItem = GetEventObject(ev,1);
                        int nPower = IsObjectValid(oItem) ? GetItemPropertyPower(oItem,nOnHitEffectId,!GetM2DAInt(453215378, "enabled", 7)) : 1;
                        ItemProp_DoEffect(oAttacker,oTarget,nOnHitEffectId,nPower);
                    }
                }
            }
        // 'null' = swallow event
        } else if (sScript != "null") {
            HandleEvent_String(ev, sScript);
        }
    }
}