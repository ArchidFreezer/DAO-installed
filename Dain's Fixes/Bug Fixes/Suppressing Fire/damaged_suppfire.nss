#include "eventmanager_h"
#include "2da_constants_h"

void main()
{
    event ev = GetCurrentEvent();
    object oDamager = GetEventCreator(ev);

    if (IsModalAbilityActive(oDamager, ABILITY_TALENT_SUPPRESSING_FIRE)) {
        // non-followers must use default script as on damaged events are common. creature_core will instead redirect the event
        if (IsFollower(OBJECT_SELF))
            HandleEvent(ev, R"rules_damaged.ncs");
        else
            HandleEvent(SetEventString(ev, 0, "rules_damaged"));
    } else {
        EventManager_ReleaseLock();
    }
}