//==============================================================================
/*

    Paragon of Her Kind
     -> Hall of Heroes Area Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: March 26, 2007
//==============================================================================

#include "plt_orzpt_events"

#include "orz_constants_h"

#include "utility_h"
#include "plt_orz200pt_wrangler"

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent         = GetCurrentEvent();            // Event
    int     nEventType      = GetEventType(evEvent);        // Event Type
    object  oEventCreator   = GetEventCreator(evEvent);     // Event Creator

    // Standard Variables
    object  oPC             = GetHero();
    object  oParty          = GetParty( oPC );
    int     bEventHandled   = FALSE;

    //--------------------------------------------------------------------------
    // Area Events
    //--------------------------------------------------------------------------

    switch ( nEventType )
    {


        case EVENT_TYPE_AREALOAD_SPECIAL:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_SPECIAL:
            // Sent by: The engine
            // When: it is for playing things like cutscenes and movies when
            // you enter an area, things that do not involve AI or actual
            // game play.
            //------------------------------------------------------------------

            break;

        }


        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_PRELOADEXIT:
            // Sent by: The engine
            // When: for things you want to happen while the load screen is
            // still up, things like moving creatures around.
            //------------------------------------------------------------------

            // AREA EVENT: Branka Woman & Daughter
            WR_SetPlotFlag( PLT_ORZPT_EVENTS, ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN__SETUP, TRUE, TRUE );

            // AREA EVENT: Beggar
            WR_SetPlotFlag( PLT_ORZPT_EVENTS, ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__SETUP, TRUE, TRUE );

            // Qwinn:  Added this as cleanup in case player leaves area before beggar finishes leaving
            // Will look for guard closest to the welcome guard, since there are multiple guard_1's.
            int bHermitGone = WR_GetPlotFlag( PLT_ORZPT_EVENTS, ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT_BEGGAR_RUNS_AWAY );
            object oBeggar = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HOH_BEGGAR );
            if (bHermitGone && IsObjectValid(oBeggar))
            {
                WR_SetObjectActive (oBeggar, FALSE);
                object oWelcome = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HOH_GUARD_WELCOME );
                object oGuard   = UT_GetNearestCreatureByTag( oWelcome, "orz110cr_guard_1");
                if (IsObjectValid(oGuard))
                {
                   SetObjectInteractive( oGuard, TRUE );
                   Rubber_GoHome (oGuard);
                }
            }

            // Qwinn added
            if (WR_GetPlotFlag(PLT_ORZ200PT_WRANGLER,ORZ_WRANGLER_PLOT_ACCEPTED))
            {
               UT_TeamAppears( ORZ_TEAM_ESCAPED_NUGS );
            }
            break;

        }


        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_POSTLOADEXIT:
            // Sent by: The engine
            // When: fires at the same time that the load screen is going away,
            // and can be used for things that you want to make sure the player
            // sees.
            //------------------------------------------------------------------

            break;

        }


        case EVENT_TYPE_ENTER:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_ENTER:
            // Sent by: The engine
            // When: A creature enters the area.
            //------------------------------------------------------------------

            break;

        }


        case EVENT_TYPE_EXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_EXIT:
            // Sent by: The engine
            // When: A creature exits the area.
            //------------------------------------------------------------------

            break;

        }

    }

    //--------------------------------------------------------------------------
    // Pass any unhandled events to orzar_core ( Paragon Area Core )
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, ORZ_RESOURCE_SCRIPT_AREA_CORE );

}