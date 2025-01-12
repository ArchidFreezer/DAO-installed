//==============================================================================
/*

    Paragon of Her Kind
     -> Orzammar Chantry Area Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: March 15, 2007
//==============================================================================

#include "plt_orz400pt_zerlinda"

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
    object  oParty          = GetParty( oPC );
    int     bEventHandled   = FALSE;

    //--------------------------------------------------------------------------
    // Area Events
    //--------------------------------------------------------------------------

    switch ( nEventType )
    {

        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_PRELOADEXIT:
            // Sent by: The engine
            // When: for things you want to happen while the load screen is
            // still up, things like moving creatures around.
            //------------------------------------------------------------------

            int         bZerlindaActive;
            object      oZerlinda, oBurkel;

            //------------------------------------------------------------------

            bZerlindaActive = WR_GetPlotFlag( PLT_ORZ400PT_ZERLINDA, ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_CHANTRY );
            oZerlinda       = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ZERLINDA );
            oBurkel         = UT_GetNearestCreatureByTag( oPC, ORZ_CR_BURKEL );

            //------------------------------------------------------------------

            // Check if Zerlinda should be in the chantry
            WR_SetObjectActive( oZerlinda, bZerlindaActive );
            // Qwinn:  Added this to remove quest flag from Zerlinda.
            if(bZerlindaActive) SetPlotGiver( oZerlinda, FALSE );
            SetPlotGiver( oBurkel, FALSE );

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
            object oBurkel = UT_GetNearestCreatureByTag(oPC, ORZ_CR_BURKEL);
            SetPlotGiver(oBurkel, FALSE);

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