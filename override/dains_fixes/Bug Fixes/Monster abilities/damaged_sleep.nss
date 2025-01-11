#include "eventmanager_h"
#include "effect_constants_h"

void main()
{
    event ev = GetCurrentEvent();
    int nAbility = GetEventInteger(ev, 1);
    
    if (GetHasEffects(OBJECT_SELF, EFFECT_TYPE_SLEEP, nAbility)) {
        if (IsFollower(OBJECT_SELF))
            HandleEvent(ev, R"rules_damaged.ncs");
        else
            HandleEvent(SetEventString(ev, 0, "rules_damaged"));
    } else {
        EventManager_ReleaseLock();
    }
}