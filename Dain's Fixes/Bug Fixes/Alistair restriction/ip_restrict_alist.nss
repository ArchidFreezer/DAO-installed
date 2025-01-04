#include "2da_constants_h"
#include "log_h"

void main()
{
    event ev = GetCurrentEvent();

    object oItem = GetEventObject(ev, 0);
    object oTestCreator = GetEventObject(ev, 1);
    Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "oItem = " + ToString(oItem));
    Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName(), "oTestCreator = " + ToString(oTestCreator));

    if(GetFollowerState(oTestCreator) != FOLLOWER_STATE_INVALID)
    {
        SetCanUseItem(oTestCreator, (GetTag(oTestCreator) == "gen00fl_alistair"));
    }
    else
    {
        SetCanUseItem(oTestCreator, 1);
    }
}