//==============================================================================
/*
    den200tr_pick3_guard2_timer.ncs

*/
//==============================================================================
//  Created By: Kaelin
//  Created On: 11/26/2008
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "den_lc_constants_h"
#include "den200pt_thief_pick3"

//------------------------------------------------------------------------------

void main()
{
    event   ev              = GetCurrentEvent();

    int     nEventType      = GetEventType(ev);
    int     nEventHandled   = FALSE;

    string  sDebug;

    object  oPC             = GetHero();
    object  oParty          = GetParty(oPC);


    switch(nEventType)
    {

        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: A creature enters the trigger
        //----------------------------------------------------------------------
        case EVENT_TYPE_ENTER:
        {
            object  oCreature       =   GetEventCreator(ev);

            int     bQuestActive    =   WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_ASSIGNED);

            // Qwinn changed
            // if(bQuestActive && (oCreature == oPC))
            if(bQuestActive && (oCreature == GetMainControlled()))
            {

                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK3, PICK3_GUARD_WANDERS, TRUE, TRUE);

            }

            break;
        }
        //----------------------------------------------------------------------
        // Sent by: The engine
        // When: A creature exits the trigger
        //----------------------------------------------------------------------
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);

            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_TRIGGER_CORE);
    }
}