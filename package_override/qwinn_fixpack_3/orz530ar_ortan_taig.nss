//==============================================================================
/*

    Paragon of Her Kind
     -> Ortan Taig Area/Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: March 2, 2007
//==============================================================================

#include "orz_constants_h"
#include "orz_functions_h"
#include "lit_constants_h"

#include "utility_h"

#include "plt_genpt_oghren_events"
#include "plt_orz530pt_ortan_taig"
#include "plt_orz510pt_topsider"
#include "plt_orzpt_generic"
#include "plt_cod_lite_multi_assembly"
#include "plt_lite_multi_assembly"
#include "plt_lite_mage_places"

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
            object oPC = GetHero();

            // Set that player has entered Ortan Taig
            WR_SetPlotFlag( PLT_ORZPT_GENERIC, ORZ_GEN_PC_HAS_ENTERED_AREA_ORTAN_TAIG, TRUE );

            // Use the underground map now
            ORZ_ActivateUndergroundMap();

            //Light Content - check Altar of Sundering
            if (WR_GetPlotFlag(PLT_LITE_MULTI_ASSEMBLY, MULTI_ASSEMBLY_ACCEPTED) == TRUE && WR_GetPlotFlag(PLT_COD_LITE_MULTI_ASSEMBLY, ASSEMBLY_FOUND_ALTAR) == FALSE)
            {
                object oAltar = UT_GetNearestObjectByTag(oPC, ORZ_IP_LT_ASSEMBLY_ALTAR);
                SetObjectInteractive(oAltar, TRUE);
            }

            //Light_Mage_Places
            if ( WR_GetPlotFlag( PLT_LITE_MAGE_PLACES, PLACES_QUEST_GIVEN) == TRUE)
            {
                object oPlace = UT_GetNearestObjectByTag(oPC, LITE_IP_MAGE_MYSTICSITE);
                SetObjectInteractive(oPlace, TRUE);
            }

            // Topsider's Honour quest.
            if ( WR_GetPlotFlag( PLT_ORZ510PT_TOPSIDER, ORZ_TOPSIDER_SWORD_COMPLETE ) )
            {

                if ( !WR_GetPlotFlag( PLT_ORZ510PT_TOPSIDER, ORZ_TOPSIDER_SWORD_RETURNED ) )
                {

                    object oGrave = UT_GetNearestObjectByTag( oPC, ORZ_IP_TOPSIDERS_CORPSE );
                    SetObjectInteractive( oGrave, TRUE );

                }

            }
            
            // Qwinn:  Fix incorrect party_bark.dlg variable set.  Was 47, should be 46.
            object oTrigger = UT_GetNearestObjectByTag(oPC,"gentr_party_trigger");
            if(IsObjectValid(oTrigger))
               SetLocalInt(oTrigger,TRIGGER_PARTY_TRIGGER_LOCATION,46);            

            UT_TeamGoesHostile(ORZ_TEAM_OVERRIDE_GROUP_NEUTRAL,FALSE);

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

            DoAutoSave();

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