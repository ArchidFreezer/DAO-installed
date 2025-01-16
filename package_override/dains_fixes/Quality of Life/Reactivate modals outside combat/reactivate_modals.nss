#include "2da_data_h"
#include "2da_constants_h"
#include "events_h"
#include "ability_h"

void activateAbility(int nAbility) {
    event ev = Event(EVENT_TYPE_ABILITY_CAST_IMPACT);
    ev = SetEventObject(ev, 0, OBJECT_SELF);
    ev = SetEventObject(ev, 1, OBJECT_INVALID);
    ev = SetEventObject(ev, 2, OBJECT_SELF);
    ev = SetEventInteger(ev, 0, nAbility);
    ev = SetEventLocation(ev, 0, GetLocation(OBJECT_SELF));
    HandleEvent(ev, R"eventmanager.ncs");
    SetCooldown(OBJECT_SELF, nAbility, 0.0f);
}

void reactivateAbility(int nAbility) {
    if (HasAbility(OBJECT_SELF, nAbility)) {
        if (!IsModalAbilityActive(OBJECT_SELF,nAbility)) {
            if (CanUseConditionedAbility(OBJECT_SELF, nAbility, 1+2+4+64+128)) {
                float cooldown = GetRemainingCooldown(OBJECT_SELF, nAbility);
                if (cooldown > 0.0f) {
                    // Heartbeat triggers every second, so we only want to see if it was disabled after the previous hb
                    if (GetAbilityBaseCooldown(nAbility) - cooldown < 1.0f) {
                        activateAbility(nAbility);
                    }
                }
            }
        }
    }
}

void reactivateAllAbilities() {
    reactivateAbility(ABILITY_SPELL_BLOOD_MAGIC);
    reactivateAbility(ABILITY_TALENT_PAIN);
    reactivateAbility(ABILITY_TALENT_BERSERK);
}

void checkReactivate() {
    if (GetGameMode() == GM_EXPLORE && GetLocalInt(OBJECT_SELF, "CREATURE_COUNTER_2") != 1)
        reactivateAllAbilities();
    SetLocalInt(OBJECT_SELF, "CREATURE_COUNTER_2", 0);
}

void main() {
    event ev = GetCurrentEvent();
    switch (GetEventType(ev)) {
        case EVENT_TYPE_HEARTBEAT2: {
            checkReactivate();
            break;
        }
        // bonus check on perception appear to account for combat immediately after dialogue
        case EVENT_TYPE_PERCEPTION_APPEAR: {
            if (IsFollower(OBJECT_SELF) && GetGameMode() == GM_EXPLORE) {
                object oAppear = GetEventObject(ev,0);
                int nHostile = GetEventInteger(ev, 0);
                int nHostilityChanged = GetEventInteger(ev, 2);
                // Does this seem dumb? Yes. Is it the same logic the game uses? Also yes.
                if (IsObjectHostile(OBJECT_SELF,oAppear) && (nHostilityChanged || nHostile))
                    checkReactivate();
            }
            break;
        }
        case EVENT_TYPE_COMMAND_PENDING: {
            if (IsFollower(OBJECT_SELF)) {
                event ev = GetCurrentEvent();
                int nCommandId = GetEventInteger(ev, 0);
                if (nCommandId = COMMAND_TYPE_USE_ABILITY) {
                    int nAbility = GetEventInteger(ev, 1);
                    if (nAbility == ABILITY_SPELL_BLOOD_MAGIC || nAbility == ABILITY_TALENT_PAIN || nAbility == ABILITY_TALENT_BERSERK) {
                        SetLocalInt(OBJECT_SELF, "CREATURE_COUNTER_2", 1);
                    }
                }
            }
            break;
        }
    }
}