//==============================================================================
/*

    Paragon of Her Kind
     -> Escaped nug creature script.

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: October 30, 2008
//==============================================================================


#include "plt_orz200pt_wrangler"
#include "plt_cod_crt_nug"
#include "orz_constants_h"
#include "utility_h"


void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evCurEvent  = GetCurrentEvent();           // Event parameters
    int     nEventType  = GetEventType(evCurEvent);    // Event type triggered
    object  nEventOwner = GetEventCreator(evCurEvent); // Triggering character
    object  oPC         = GetHero();                   // Player character

    int bEventHandled = FALSE;

    //--------------------------------------------------------------------------
    // Events
    //--------------------------------------------------------------------------

    switch(nEventType)
    {


        case EVENT_TYPE_DIALOGUE:
        {

            //------------------------------------------------------------------
            // Sent by: engine or scripting
            // When: this object is initiating dialog as the main speaker. This can
            //       happen when:
            //       1) (engine) A player object clicked to talk on this object.
            //       2) (scripting) A trigger script or other script used the
            //       utility function UT_Talk to trigger dialog with this object
            //------------------------------------------------------------------

            if(nEventOwner == oPC)
            {
               UT_Talk( OBJECT_SELF, oPC );                
               UT_AddItemToInventory( ORZ_IM_NUG_R );

               WR_SetObjectActive( OBJECT_SELF, FALSE );

               if ( !WR_GetPlotFlag(PLT_ORZ200PT_WRANGLER, ORZ_WRANGLER_PLOT_RETURN) )
                   WR_SetPlotFlag( PLT_ORZ200PT_WRANGLER, ORZ_WRANGLER_PLOT_RETURN, TRUE );

               WR_SetPlotFlag( PLT_COD_CRT_NUG, COD_CRT_NUG_UNLOCKED, TRUE );
   
               Safe_Destroy_Object( OBJECT_SELF );
            }
            bEventHandled = TRUE;            

            break;

        }


    }

    // -------------------------------------------------------------------------
    // Any event not handled is also handled by rules_core:
    // -------------------------------------------------------------------------

    if (!bEventHandled)
        HandleEvent(evCurEvent, RESOURCE_SCRIPT_CREATURE_CORE);

}