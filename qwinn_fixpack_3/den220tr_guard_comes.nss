//:://////////////////////////////////////////////
//:: Created By: Qwinn (Paul Escalona)
//:: Created On: 03/23/2017
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "den200pt_thief_sneak1"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;

    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the trigger
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            if (!WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, SOPHIE_GUARD_ARRIVES))
            {
               object oCreature = GetEventCreator(ev);
               int nSophieGuardHears = TRUE;
               object oFollower;
               object [] oParty = GetPartyList();
               int nIndex, nSize = GetArraySize(oParty);
               for ( nIndex = 0; nIndex < nSize; ++nIndex )
               {   oFollower = oParty[ nIndex ];
                   if (IsStealthy(oFollower))
                      nSophieGuardHears = FALSE;
                   if ((oCreature != oFollower) && (GetDistanceBetween(oCreature,oFollower) > 11.0f))
                      nSophieGuardHears = FALSE;
               }
               if (nSophieGuardHears && (!WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, SOPHIE_GUARD_ARRIVES)))
               {  WR_SetObjectActive(OBJECT_SELF,FALSE);
                  WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, SOPHIE_GUARD_ARRIVES, TRUE, TRUE);    
               }
            }
            break;
        }
    }
}
