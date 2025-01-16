#include "fastmove_h"

void main() {
    // No heartbeat for dead people
    if (IsDeadOrDying(OBJECT_SELF))
        return;

    int nGameMode = GetGameMode();
    if(nGameMode == GM_COMBAT)
        removeHaste(OBJECT_SELF);
    else if(nGameMode == GM_EXPLORE)
        applyHaste(OBJECT_SELF);
}