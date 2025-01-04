#include "eventmanager_h"
#include "events_h"
#include "sys_stealth_h"

void main() {
    struct EventOnCastAtParamStruct stEvent = GetEventOnCastAtParams(GetCurrentEvent());
    // only want to affect hostile events and the bHostile flag isn't reliable
    if (!IsObjectHostile(OBJECT_SELF, stEvent.oCaster)) {
        EventManager_ReleaseLock();
        return;
    }

    if (stEvent.bHostile)
    {
        if(!IsPerceiving(OBJECT_SELF, stEvent.oCaster))
        {
            WR_TriggerPerception(OBJECT_SELF, stEvent.oCaster);
            WR_TriggerPerception(stEvent.oCaster, OBJECT_SELF);
        }
        // Default handler adds impact threat here. The cast at event is inconsistently called, though, so in lieu of
        // overriding every ability we nuke it here and apply it instead via the ability cast impact event
    }
}