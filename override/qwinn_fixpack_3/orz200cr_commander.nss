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

#include "orz_constants_h"
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
        case EVENT_TYPE_OBJECT_ACTIVE:
        {
            if (WR_GetPlotFlag(PLT_QWINN,ORZ_NUGBANE_STOLEN))
               SetLocalInt(OBJECT_SELF, FLAG_STOLEN_FROM, TRUE);
            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}