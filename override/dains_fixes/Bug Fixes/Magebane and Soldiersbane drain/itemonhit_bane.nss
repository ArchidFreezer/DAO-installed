#include "events_h"
#include "effects_h"
#include "sys_itemprops_h"
#include "eventmanager_h"

void main()
{
    event ev = GetCurrentEvent();
    int nOnHitEffectId = GetEventInteger(ev,0);

    int nForceProc = GetEventInteger(ev,2);
    if (nForceProc > 0 || RandomFloat() < GetM2DAFloat(TABLE_ITEMPRPS, "ProcChance", nOnHitEffectId)) {
        object oAttacker = GetEventCreator(ev);
        // check to see if the character is in a shapeshifted form
        // this prevents a rat from having a huge stack of damage floaties from equipment
        if (!IsShapeShifted(oAttacker)) {
            object oTarget = GetEventTarget(ev);
            // No care about dead targets or non creatures
            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE && !IsDeadOrDying(oTarget)) {
                // Magebane only affects mages, Soldiersbane only affects non-mages
                if ((nOnHitEffectId == 3011) != IsMagicUser(oTarget)) {
                    object oItem = GetEventObject(ev,1);
                    int nPower = IsObjectValid(oItem) ? GetItemPropertyPower(oItem,nOnHitEffectId, TRUE) : 1;
                    float fAmount = nPower * -5.0f;
                    Effect_InstantApplyEffectModifyManaStamina(oTarget, fAmount);
                    UI_DisplayDamageFloaty(oTarget, oAttacker, FloatToInt(fAmount), 1, 0, 0, 1);
                }
            }
        }
    }
}