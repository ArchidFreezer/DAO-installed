//==============================================================================
/*

    Paragon of Her Kind

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: October 26, 2007
//==============================================================================

#include "plt_orzpt_events"

#include "orz_constants_h"

#include "utility_h"
#include "events_h"

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evCurEvent  = GetCurrentEvent();           // Event parameters
    int     nEventType  = GetEventType(evCurEvent);    // Event type triggered
    object  oEventOwner = GetEventCreator(evCurEvent); // Triggering character
    object  oPC         = GetHero();                   // Player character

    int bEventHandled = FALSE;

    // Qwinn:  Completely redid this script to restore altercation with the guard
    int bKickOutEventActive = WR_GetPlotFlag( PLT_ORZPT_EVENTS, ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__ACTIVE );

    object oBeggar = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HOH_BEGGAR );
    // In version 3.5, changed this to be nearest to welcome guard, as it was picking the wrong guard sometimes
    //object oGuard  = UT_GetNearestCreatureByTag( oPC, "orz110cr_guard_1");
    object oWelcome = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HOH_GUARD_WELCOME );
    object oGuard   = UT_GetNearestCreatureByTag( oWelcome, "orz110cr_guard_1");

    switch(nEventType)
    {
        case EVENT_TYPE_ENTER:
        {
            if ( IsHero(oEventOwner) && bKickOutEventActive && IsObjectValid(oBeggar) && IsObjectValid(oGuard) )
            {
                UT_Talk( oBeggar, oPC );
            }
            bEventHandled = TRUE;
            break;
        }

        case EVENT_TYPE_EXIT:
        {
            if (GetObjectActive(OBJECT_SELF) && IsObjectValid(oBeggar) && IsObjectValid(oGuard))
            {
                WR_SetPlotFlag( PLT_ORZPT_EVENTS, ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__TRIGGERED, TRUE, TRUE );
                SetObjectInteractive(oBeggar, FALSE);
                SetObjectInteractive(oGuard, FALSE);
                WR_ClearAllCommands( oBeggar );
                WR_ClearAllCommands( oGuard );
                AddCommand(oGuard,CommandMoveToObject(oBeggar,TRUE,3.0),TRUE,TRUE);
                UT_Talk( oGuard, oBeggar );
                WR_SetPlotFlag( PLT_ORZPT_EVENTS, ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__ACTIVE, FALSE );
                WR_SetObjectActive( OBJECT_SELF, FALSE );
            }
            bEventHandled = TRUE;
            break;
        }
    }

    // -------------------------------------------------------------------------
    // Any event not handled is also handled by trigger_core:
    // -------------------------------------------------------------------------

    if (!bEventHandled)
        HandleEvent( evCurEvent, RESOURCE_SCRIPT_TRIGGER_CORE );

}