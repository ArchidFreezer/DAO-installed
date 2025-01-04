#include "combat_h"
#include "events_h"
#include "ai_main_h_2"
#include "sys_soundset_h"
#include "eventmanager_h"
// primarily taken from rules_core
void main() {
    event ev = GetCurrentEvent();
    object oCommandOwner = GetEventObject(ev, 0);
    object oTarget       = GetEventObject(ev, 1);
    int nCommandId       = GetEventInteger(ev, 0);
    int nCommandSubType  = GetEventInteger(ev, 1);

    if (Events_ValidateCommandPending(oCommandOwner, oTarget, nCommandId, nCommandSubType) && nCommandId == COMMAND_TYPE_ATTACK) {
        // Flagging party as clear to attack (if controlled follower)
        if(IsControlled(OBJECT_SELF) && IsObjectValid(oTarget) && IsObjectHostile(OBJECT_SELF, oTarget))
            AI_SetPartyAllowedToAttack(TRUE);

        int nCommandResult = Combat_HandleCommandAttack(oCommandOwner, oTarget, nCommandSubType);

        // Trigger a battle cry
        if (nCommandResult == COMMAND_RESULT_SUCCESS)
           SSPlaySituationalSound(OBJECT_SELF, SOUND_SITUATION_COMBAT_BATTLECRY);

        SetCommandResult(oCommandOwner, nCommandResult);
    }
    else
        EventManager_ReleaseLock();
}