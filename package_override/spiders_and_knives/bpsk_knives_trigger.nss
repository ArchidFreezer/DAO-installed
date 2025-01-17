//==============================================================================
/*
    Trigger events for Knife Edge
*/
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

//------------------------------------------------------------------------------

void main()
{
    event   ev              =   GetCurrentEvent();

    int     nEventType      =   GetEventType(ev);
    int     nEventHandled   =   FALSE;

    string  sDebug;

    object  oPC             =   GetHero();
    object  oParty          =   GetParty(oPC);


    switch(nEventType)
    {
        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: A creature enters the trigger
        //----------------------------------------------------------------------
        case EVENT_TYPE_ENTER:
        {

            //  Get Knives to follow party
            object  oKnives = UT_GetNearestCreatureByTag(oPC,"bpsk_knives");
            AddNonPartyFollower(oKnives);
//            WR_SetObjectActive(OBJECT_SELF,FALSE);
            WR_DestroyObject(OBJECT_SELF);

            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_TRIGGER_CORE);
    }
}