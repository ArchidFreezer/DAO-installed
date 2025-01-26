#include "eventmanager_h"
#include "2da_constants_h"

void main()
{
    event ev = GetCurrentEvent();
    int nAbility = GetEventInteger(ev, 1);
    object oDamager = GetEventCreator(ev);

    if ((GetWeaponStyle(oDamager) == WEAPONSTYLE_DUAL && HasAbility(oDamager, ABILITY_TALENT_DUAL_WEAPON_EXPERT)) ||
        (GetHasEffects(OBJECT_SELF, EFFECT_TYPE_SLEEP, nAbility)) ||
        (IsModalAbilityActive(oDamager, ABILITY_TALENT_SUPPRESSING_FIRE))) {
        // non-followers must use default script as on damaged events are common. creature_core will instead redirect the event
        if (IsFollower(OBJECT_SELF))
            HandleEvent(ev, R"af_damaged_rules.ncs");
        else
            HandleEvent(SetEventString(ev, 0, "af_damaged_rules"));
    } else {
        EventManager_ReleaseLock();
    }
}