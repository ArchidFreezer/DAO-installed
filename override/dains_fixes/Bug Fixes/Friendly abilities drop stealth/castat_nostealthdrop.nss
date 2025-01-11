#include "eventmanager_h"

void main() {
    // cast at event's bHostile flag is *incredibly* unreliable, so we hog the event with an empty handler unless caster and recipient are hostile
    // event isn't meant to do anything for non-hostile interactions anyway
    if (GetObjectType(OBJECT_SELF) != OBJECT_TYPE_CREATURE || IsObjectHostile(OBJECT_SELF, GetEventObject(GetCurrentEvent(),0))) {
        EventManager_ReleaseLock();
    }
}