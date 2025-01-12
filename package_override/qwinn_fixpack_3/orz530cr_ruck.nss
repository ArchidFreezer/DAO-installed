// Qwinn created this script from her previous Zathrian script and adding
// case EVENT_TYPE_CUSTOM_COMMAND_COMPLETE.

//::///////////////////////////////////////////////
//:: Creature Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature events for Zathrian
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: 17/01/08
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"


#include "plt_orz200pt_filda"
#include "plt_qwinn"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;
    string sTag = GetTag(OBJECT_SELF);

    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creature dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DEATH:
        {
            // If we kill Ruck before finding out who he is, we'll never know.  No Filda plot
            // flags should be set, whether her quest was active or not.  If we do know who he
            // is, then we should set flags based on whether quest was active or not at the time,
            // which we do in our qwinn.nss script.
            if ( ( WR_GetPlotFlag( PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_FOUND ) ||
                 ( WR_GetPlotFlag( PLT_QWINN, ORZ_FOUND_RUCK_QUEST_INACTIVE) )))
                 WR_SetPlotFlag( PLT_QWINN, ORZ_KILLED_RUCK_CHECK_QUEST_STATUS, TRUE, TRUE );
            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}