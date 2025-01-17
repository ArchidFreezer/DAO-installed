//::///////////////////////////////////////////////
//:: Creature Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature events for: Ser Nathan
*/
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "plt_bp_spiders_knives"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    int nEventHandled = FALSE;

    switch(nEventType)
    {

        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: Ser Nathan's body is looted
        ////////////////////////////////////////////////////////////////////////

        case EVENT_TYPE_DIALOGUE:
        {

            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}