//==============================================================================
/*

    The Topsider's Remains placeable script.
        -> orz510ip_topsiders_corpse.nss

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: October 28, 2008
//==============================================================================

#include "utility_h"
#include "plt_cod_hst_orz_topsider"
#include "plt_orz510pt_topsider"

void main ()
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
    int     bEventHandled   = TRUE;

    //--------------------------------------------------------------------------
    // Events
    //--------------------------------------------------------------------------

    switch ( nEventType )
    {


        case EVENT_TYPE_USE:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_USE
            //------------------------------------------------------------------

            // Returning the pieces of the sword.
            if ( WR_GetPlotFlag( PLT_ORZ510PT_TOPSIDER, ORZ_TOPSIDER_SWORD_COMPLETE ) )
            {
                // Qwinn:  Preventing exploit of getting multiple swords
                if (WR_GetPlotFlag( PLT_ORZ510PT_TOPSIDER, ORZ_TOPSIDER_SWORD_RETURNED) == FALSE)
                { 
                   // Qwinn:  Removing blade, hilt and pommel when sword reconstructed.
                   RemoveItemsByTag(oPC,"orz510im_topsider_blade");
                   RemoveItemsByTag(oPC,"orz510im_topsider_hilt");
                   RemoveItemsByTag(oPC,"orz510im_topsider_pommel");

                   //UT_AddItemToInventory( R"gen_im_wep_mel_lsw_hon.uti" );
  
                   WR_SetPlotFlag( PLT_COD_HST_ORZ_TOPSIDER, COD_HST_ORZ_TOPSIDER_3, TRUE );
                   WR_SetPlotFlag( PLT_ORZ510PT_TOPSIDER, ORZ_TOPSIDER_SWORD_RETURNED, TRUE, TRUE );

                   SetObjectInteractive( OBJECT_SELF, FALSE );
                }

            }

            // Discovering for the first time.
            else if ( !WR_GetPlotFlag(PLT_COD_HST_ORZ_TOPSIDER, COD_HST_ORZ_TOPSIDER_2) )
            {

                WR_SetPlotFlag( PLT_COD_HST_ORZ_TOPSIDER, COD_HST_ORZ_TOPSIDER_2, TRUE, TRUE );
                SetObjectInteractive( OBJECT_SELF, FALSE );

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