//==============================================================================
/*

    Coronation Funeral
     -> Epilogue Player's Funeral (Plays when area loads)

*/
//------------------------------------------------------------------------------
// Created By: Mark Barazzuol
// Created On: May 27, 2008
//==============================================================================

#include "epi_attendees_h"

const string SHL_MODULE_ID                      = "DAO_PRC_CP_2";

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Constants


    // Load Event Variables
    event   evEvent         = GetCurrentEvent();            // Event
    int     nEventType      = GetEventType(evEvent);        // Event Type
    object  oEventCreatdddor   = GetEventCreator(evEvent);     // Event Creator

    // Standard Stuff
    object  oPC             = GetHero();
    object  oParty          = GetParty( oPC );
    int     bEventHandled   = FALSE;

    int     bAllNPCs        = WR_GetPlotFlag( PLT_ZZ_EPI_DEBUG, ZZ_EPI_DEBUG_SET_FULL_NPCS_ATTENDING );


    //--------------------------------------------------------------------------
    // Area Events
    //--------------------------------------------------------------------------

    switch ( nEventType )
    {


        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            RevealCurrentMap();
            break;
        }


        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {

            // Alistair / Anora appear or not
            SetKingAndQueen();

            // Set proper followers to attend
            SetPartyMembersAttending();

            // Set origin members to attend.
            SetOriginMembersAttending();
            SetOtherNPCsAttending();

            // Remove Party
            EPI_RemoveParty();


            object oShale = UT_GetNearestObjectByTag(oPC, EPI_CR_SHALE);
            if (GetPRCEnabled(SHL_MODULE_ID))
            {
                SetAppearanceType(oShale, 10100);
            }

            break;

        }


        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {

            int         bAreaLoadedOnce;

            //------------------------------------------------------------------
            bAreaLoadedOnce = GetLocalInt( OBJECT_SELF, AREA_COUNTER_1 );
            //------------------------------------------------------------------

            // First time initial coronation scene plays
            if( !bAreaLoadedOnce )
            {
                SetLocalInt( OBJECT_SELF, AREA_COUNTER_1, TRUE );
                UT_Talk( oPC, oPC, TALK_EPI_FUNERAL_START);
            }

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
    // Pass any unhandled events to area_core
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, AREA_CORE );

}