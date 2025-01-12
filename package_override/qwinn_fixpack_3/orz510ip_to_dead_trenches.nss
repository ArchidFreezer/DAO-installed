//==============================================================================
/*

    Paragon of Her Kind
     -> Dead Trenches Transition Placeable Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: July 21, 2008
//==============================================================================

#include "orzpt_generic"
#include "orz_functions_h"
#include "orz_constants_h"
#include "utility_h"

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
    int     bEventHandled   = FALSE;

    //--------------------------------------------------------------------------
    // Events
    //--------------------------------------------------------------------------
    
    // Qwinn:  Added these two lines to disable wide world map from underground
    object oInvalid = OBJECT_INVALID;
    WR_SetWorldMapSecondary( oInvalid );

    switch ( nEventType )
    {


        case EVENT_TYPE_USE:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_USE
            //------------------------------------------------------------------

            int         bDeadTrenchesOpen;

            //------------------------------------------------------------------

            bDeadTrenchesOpen = WR_GetPlotFlag(PLT_ORZPT_GENERIC,ORZ_GEN_OPEN_DEAD_TRENCHES);

            //------------------------------------------------------------------


            if (GetGameMode() != GM_COMBAT)
            {
                // Set that the player has been here;
                // This is checked when the PC gets Branka's Journal. If the PC has
                // been here before at that point, this transition is available
                // immediately since he/she has been here already.
                WR_SetPlotFlag(PLT_ORZPT_GENERIC,ORZ_GEN_PC_VISITED_DEAD_TRENCHES_ENTRANCE,TRUE);

                if ( bDeadTrenchesOpen )
                    ORZ_ActivatePinDeadTrenches();
            }

            break;

        }


        case EVENT_TYPE_PLACEABLE_COLLISION:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_PLACEABLE_COLLISION
            //------------------------------------------------------------------

            int         bDeadTrenchesOpen;

            //------------------------------------------------------------------

            bDeadTrenchesOpen = WR_GetPlotFlag(PLT_ORZPT_GENERIC,ORZ_GEN_OPEN_DEAD_TRENCHES);

            //------------------------------------------------------------------

            if (GetGameMode() != GM_COMBAT)
            {
                // Set that the player has been here;
                // This is checked when the PC gets Branka's Journal. If the PC has
                // been here before at that point, this transition is available
                // immediately since he/she has been here already.
                WR_SetPlotFlag(PLT_ORZPT_GENERIC,ORZ_GEN_PC_VISITED_DEAD_TRENCHES_ENTRANCE,TRUE);

                if ( bDeadTrenchesOpen )
                    ORZ_ActivatePinDeadTrenches();
            }

            break;

        }


    }

    //--------------------------------------------------------------------------
    // Pass any unhandled events to placeable_core
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, RESOURCE_SCRIPT_PLACEABLE_CORE );

}