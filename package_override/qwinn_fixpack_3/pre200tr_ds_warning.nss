//::///////////////////////////////////////////////
//:: Trigger Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Trigger events
*/
//:://////////////////////////////////////////////
//:: Created By: Craig Graff
//:: Created On: October 30, 2007
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "party_h"

#include "plt_genpt_alistair_events"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;
    object oAlistair = Party_GetActiveFollowerByTag(GEN_FL_ALISTAIR);


    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: The object spawns into the game. This can happen only once,
        //       regardless of save games.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_SPAWN:
        {
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the trigger
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);

            // only trigger once for each group
            if (!GetLocalInt(OBJECT_SELF, TRIGGER_DO_ONCE_A) && (IsPartyMember(oCreature)
                || IsHero(oCreature)))
            {
                SetLocalInt(OBJECT_SELF, TRIGGER_DO_ONCE_A, TRUE);

                // Alistair should only speak up if appropriate
                // Qwinn
                if (IsObjectValid(oAlistair)) // && !GetCombatState(oCreature))
                {
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_DARKSPAWN_NEARBY, TRUE);
                    UT_Talk(oAlistair, oPC);
                }
            }

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the trigger
        ////////////////////////////////////////////////////////////////////////
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