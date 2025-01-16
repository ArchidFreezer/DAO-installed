#include "core_h"
#include "2da_constants_h"

const float DESTROYER_ARMOR_PENALTY = -5.0f;
const float DESTROYER_DURATION = 3.0f;
const int DESTROYER_VFX = 90065;

void main()
{
    event  ev = GetCurrentEvent();
    int    nAbility  = GetEventInteger(ev, 1);
    object oAttacker = GetEventCreator(ev);
    object oTarget = OBJECT_SELF;

    if (HasAbility(oAttacker, ABILITY_TALENT_DESTROYER) && IsMeleeWeapon2Handed(GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oAttacker))) {
        // autoattack, or else ability requires melee or 2h weapon
        if (nAbility == 0 || (GetM2DAInt(TABLE_ABILITIES_SPELLS,"conditions",nAbility) & 129) > 0) {
            if (!GetHasEffects(oTarget, EFFECT_TYPE_MODIFY_PROPERTY,ABILITY_TALENT_DESTROYER )) {
                effect eDebuff = EffectModifyProperty(PROPERTY_ATTRIBUTE_ARMOR, DESTROYER_ARMOR_PENALTY);
                eDebuff = SetEffectEngineInteger(eDebuff, EFFECT_INTEGER_VFX, DESTROYER_VFX);
                Engine_ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eDebuff, oTarget, DESTROYER_DURATION, oAttacker, ABILITY_TALENT_DESTROYER);
            }
        }
    }
}