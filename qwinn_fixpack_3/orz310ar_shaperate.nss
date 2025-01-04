//==============================================================================
/*

    Paragon of Her Kind
     -> Orzammar Shaperate Area Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: March 19, 2007
//==============================================================================

#include "plt_orz310pt_orta"

#include "plt_orz550pt_dead_caste"
#include "plt_cod_hst_orz_shaper"

#include "orz_constants_h"
#include "orz_codex_h"

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

            int         bOrtaActive, bMemoriesActive, bShaper;
            object      oOrta, oMemories;

            //------------------------------------------------------------------

            bOrtaActive     = WR_GetPlotFlag( PLT_ORZ310PT_ORTA, ORZ_ORTA_IS_IN_SHAPERATE );
            // Qwinn fixed:
            // bMemoriesActive = WR_GetPlotFlag( PLT_ORZ550PT_DEAD_CASTE, ORZ_DEAD_CASTE_INSIGNIA_OBTAINED );
            bMemoriesActive = ( WR_GetPlotFlag( PLT_ORZ550PT_DEAD_CASTE, ORZ_DEAD_CASTE_INSIGNIA_OBTAINED ) &&
                                !WR_GetPlotFlag( PLT_ORZ550PT_DEAD_CASTE, ORZ_DEAD_CASTE_COMPLETE ));
            bShaper         = CheckCodexComplete( PLT_COD_HST_ORZ_SHAPER, 4, 1 );

            oOrta           = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ORTA );
            oMemories       = GetObjectByTag( ORZ_IP_MEMORIES );

            //------------------------------------------------------------------

            // ORTA: Check if Orta is still in the area
            WR_SetObjectActive( oOrta, bOrtaActive );
            WR_SetObjectActive( oMemories, bMemoriesActive );

            if ( bShaper )
            {
                WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_4), TRUE  );
                WR_SetObjectActive( GetObjectByTag(ORZ_IP_CODEX_SHAPER_0), FALSE );
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