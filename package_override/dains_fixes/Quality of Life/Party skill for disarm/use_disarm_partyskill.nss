#include "eventmanager_h"
#include "placeable_h"

void main() {
    event ev = GetCurrentEvent();
    int nEvent = GetEventType(ev);
    object oUser = GetEventCreator(ev);
    int nAction = GetPlaceableAction(OBJECT_SELF);
    if (nAction != PLACEABLE_ACTION_DISARM || GetGameMode() != GM_EXPLORE || !(IsFollower(oUser)) || !GetObjectActive(OBJECT_SELF)) {
        EventManager_ReleaseLock();
        return;
    }

    int nActionResult = FALSE;
    int bCanUnlock = FALSE;
    int bOwned = FALSE;
    int nTargetScore = GetTrapDisarmDifficulty(OBJECT_SELF);

    float fPlayerScore = 0.0;
    object[] arParty = GetPartyList(oUser);
    int nSize = GetArraySize(arParty);
    int i;
    for (i = 0; i < nSize; i++) {
        if (Trap_GetOwner(OBJECT_SELF) == arParty[i]) {
            bOwned = TRUE;
        } else if (HasAbility(arParty[i], ABILITY_TALENT_HIDDEN_ROGUE)) {
            bCanUnlock = TRUE;
            fPlayerScore = MaxF(fPlayerScore, GetDisableDeviceLevel(arParty[i]));
        }
    }

    if (bOwned) {
        nActionResult = TRUE;
    } else if (bCanUnlock) {
        nActionResult = FloatToInt(fPlayerScore) >= nTargetScore;
    }

    if (nActionResult) {
        // Can only disarm a trap once.
        if (!GetLocalInt(OBJECT_SELF, PLC_DO_ONCE_A)) {
            SetLocalInt(OBJECT_SELF, PLC_DO_ONCE_A, TRUE);
            // Slight delay to account for disarm animation.
            Trap_SignalDisarmEvent(OBJECT_SELF, oUser, 0.1f);
        }
    } else {
        UI_DisplayMessage(oUser, nTargetScore >= DEVICE_DIFFICULTY_IMPOSSIBLE ? UI_MESSAGE_DISARM_NOT_POSSIBLE : TRAP_DISARM_FAILED);
        Trap_SignalTeam(OBJECT_SELF);
        PlaySound(OBJECT_SELF, SOUND_TRAP_DISARM_FAILURE);
    }

    SetPlaceableActionResult(OBJECT_SELF, nAction, nActionResult);
}