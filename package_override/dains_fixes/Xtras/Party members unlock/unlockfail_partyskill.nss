#include "2da_constants_h"
#include "wrappers_h"
#include "sys_traps_h"

void main() {
    event ev = GetCurrentEvent();
    object oUser = GetEventObject(ev, 0);
    int bKeyRequired = GetPlaceableKeyRequired(OBJECT_SELF);
    int nLockLevel = GetPlaceablePickLockLevel(OBJECT_SELF);
    int bLockPickable = (nLockLevel < DEVICE_DIFFICULTY_IMPOSSIBLE);
    if (bKeyRequired || !bLockPickable || !IsFollower(oUser)) {
        return;
    }
    float fLockLevel = IntToFloat(nLockLevel);

    object[] arParty = GetPartyList(oUser);
    int nSize = GetArraySize(arParty);
    int i;
    for (i = 0; i < nSize; i++) {
        object oChar = arParty[i];
        if (oChar == oUser)
            continue;
        else if (HasAbility(oChar, ABILITY_TALENT_HIDDEN_ROGUE)) {
            if (GetDisableDeviceLevel(oChar) >= fLockLevel) {
                WR_AddCommand(oChar, CommandUseObject(OBJECT_SELF, PLACEABLE_ACTION_UNLOCK));
                break;
            }
        }
    }
}