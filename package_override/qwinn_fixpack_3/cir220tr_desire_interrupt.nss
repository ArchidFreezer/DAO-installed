//::///////////////////////////////////////////////
//:: Trigger Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Trigger events
*/
//:://////////////////////////////////////////////
//:: Created By: Gary Stewart
//:: Created On: Sept 26, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "pre_functions_h"

#include "cir_constants_h"
#include "plt_cir000pt_main"

// Qwinn added
#include "cir000pt_encounters"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;
    int nTeam = GetLocalInt(OBJECT_SELF, TRIGGER_ENCOUNTER_TEAM);
    int nWaypoint = GetLocalInt(OBJECT_SELF, TRIGGER_COUNTER_1);

    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the trigger
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            // Qwinn:  Added condition, changed "GetObjectByTag" to UT_GNCBT.
            object oCreature = GetEventCreator(ev);
            object oDesireDemon = UT_GetNearestCreatureByTag(oPC,CIR_CR_DESIRE_DEMON);
            object oDesireDemonTemp = UT_GetNearestCreatureByTag(oPC,CIR_CR_DESIRE_TEMPLAR);
            // Ensure it's the player that triggered.
            if (!IsPartyMember(oCreature)) break;

            if (!WR_GetPlotFlag(PLT_CIR000PT_ENCOUNTERS,DESIRE_AND_TEMPLAR_ATTACK) &&
                !WR_GetPlotFlag(PLT_CIR000PT_ENCOUNTERS,DESIRE_AND_TEMPLAR_LEAVE))
            {
               WR_ClearAllCommands(oDesireDemon, TRUE);
               WR_ClearAllCommands(oDesireDemonTemp, TRUE);
               UT_Talk(oDesireDemon, oPC);
               DestroyObject(OBJECT_SELF);
            }
            break;
        }

    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_TRIGGER_CORE);
    }
}