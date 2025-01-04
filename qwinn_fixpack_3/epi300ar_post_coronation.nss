//==============================================================================
/*

    Coronation Post Ceremony
     -> Epilogue Coronation Post Ceremony (Plays when area loads)

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
    object  oEventCreator   = GetEventCreator(evEvent);     // Event Creator

    // Standard Stuff
    object  oPC             = GetHero();
    object  oParty          = GetParty( oPC );
    int     bEventHandled   = FALSE;


    //--------------------------------------------------------------------------
    // Area Events
    //--------------------------------------------------------------------------

    switch ( nEventType )
    {

        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_POSTLOADEXIT:
            // Sent by: The engine
            // When: fires at the same time that the load screen is going away,
            // and can be used for things that you want to make sure the player
            // sees.
            //------------------------------------------------------------------

            int         bAreaLoadedOnce;

            //------------------------------------------------------------------

            bAreaLoadedOnce = GetLocalInt( OBJECT_SELF, AREA_COUNTER_1 );

            //------------------------------------------------------------------

            // These are called from epi_attendees_h
            // Populates the room with the proper NPCs
            SetKingAndQueen();
            SetPartyMembersAttending();
            SetOriginMembersAttending();

            // First time initial coronation scene plays
            if( !bAreaLoadedOnce )
            {
                object oShale = UT_GetNearestObjectByTag(oPC, EPI_CR_SHALE);
                if (GetPRCEnabled(SHL_MODULE_ID))
                {
                    SetAppearanceType(oShale, 10100);
                }
                SetLocalInt( OBJECT_SELF, AREA_COUNTER_1, TRUE );

                // Qwinn added:  Get rid of corpse gall from Fort Drakon
                UT_RemoveItemFromInventory(R"gen_it_corpse_gall.uti",100);
                UT_Talk( oPC, oPC, TALK_EPI_POST_CORONATION_START);
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

            // Added by Qwinn
            object oShale = UT_GetNearestObjectByTag(oPC, EPI_CR_SHALE);
            if (GetPRCEnabled(SHL_MODULE_ID))
                SetAppearanceType(oShale, 10100);

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