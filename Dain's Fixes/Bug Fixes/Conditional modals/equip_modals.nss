#include "2da_data_h"
#include "2da_constants_h"
#include "ability_h"

// Equipment conditions we want to test
const int conditions = 199; //1+2+4+64+128

void ActivateAbility(int nAbility) {
    int nAbilityType = GetAbilityType(nAbility);
    event ev = Event(EVENT_TYPE_SPELLSCRIPT_IMPACT);
    ev = SetEventObject(ev, 0, OBJECT_SELF);
    ev = SetEventObject(ev, 1, OBJECT_SELF);
    ev = SetEventInteger(ev, 0, nAbility);
    ev = SetEventInteger(ev, 1, nAbilityType);
    ev = SetEventLocation(ev, 0, GetLocation(OBJECT_SELF));
    Ability_DoRunSpellScript(ev, nAbility, nAbilityType);
    SetCooldown(OBJECT_SELF, nAbility, 0.0f);
}

void main() {
    event ev = GetCurrentEvent();
    switch (GetEventType(ev)) {
        case EVENT_TYPE_EQUIP: {
            // Check modal conditions
            int[] abi = GetConditionedAbilities(OBJECT_SELF, conditions);
            int i;
            for (i = 0; i < GetArraySize(abi); i++) {
                Effects_RemoveUpkeepEffect(OBJECT_SELF,abi[i]);
            }

            // Need to delay reactivations due to an engine bug in calculating reserved mana/stamina
            DelayEvent(0.05, OBJECT_SELF, Event(EVENT_TYPE_INVALID), "equip_modals");

            break;
        }

        case EVENT_TYPE_INVALID: {
            // Reactivate any that were deactivated by unequip event but are still valid
            int[] arAbilities = GetAbilityList(OBJECT_SELF, ABILITY_INVALID, TRUE); // n.b. GetAbilityList is from patch 1.03 script.ldf
            int nSize = GetArraySize(arAbilities);
            int i;
            for (i = 0; i < nSize; i++) {
                int nAbility = arAbilities[i];
                if (GetAbilityUseType(nAbility) == 2) {
                    int nCondition = GetM2DAInt(TABLE_ABILITIES_SPELLS, "conditions", nAbility);
                    if ((nCondition & conditions) != 0 && CanUseConditionedAbility(OBJECT_SELF, nAbility, conditions)) {
                        if (GetAbilityBaseCooldown(nAbility) - GetRemainingCooldown(OBJECT_SELF, nAbility) < 0.1) {
                            ActivateAbility(nAbility);
                        }
                    }
                }
            }

            break;
        }
    }
}