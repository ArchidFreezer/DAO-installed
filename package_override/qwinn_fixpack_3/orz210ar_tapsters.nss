//==============================================================================
/*

    Paragon of Her Kind
     -> Tapster's Tavern Area Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 15, 2007
//==============================================================================

#include "plt_genpt_oghren_defined"

#include "plt_gen00pt_party"
#include "plt_orz330pt_dulin"
#include "plt_orz400pt_zerlinda"
#include "plt_orzpt_main"
#include "plt_orzpt_wfharrow"
#include "plt_orzpt_wfbhelen_t1"
#include "plt_orzpt_wfbhelen_da"
#include "plt_orzpt_wfharrow_da"

#include "orz_constants_h"

#include "utility_h"

// Qwinn added
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

            int         bBhelenKing;
            int         bHarrowKing;
            int         bParagonFailed;
            int         bDulinActive;
            int         bOghrenActive;
            int         bOghrenInParty;
            int         bOrdelActive;
            object      oDulin;
            object      oOghren;
            object      oOrdel;

            //------------------------------------------------------------------

            bBhelenKing     = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN );
            bHarrowKing     = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT );
            bDulinActive    = WR_GetPlotFlag( PLT_ORZ330PT_DULIN, ORZ_DULIN_IS_IN_TAPSTERS );
            bOghrenActive   = WR_GetPlotFlag( PLT_GENPT_OGHREN_DEFINED, OGHREN_DEFINED_PARAGON_OGHREN_IS_IN_TAPSTERS );
            bOghrenInParty  = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED );
            bOrdelActive    = WR_GetPlotFlag( PLT_ORZ400PT_ZERLINDA, ORZ_ZERLINDA___PLOT_ACTIVE ) &&
                              !WR_GetPlotFlag ( PLT_ORZ400PT_ZERLINDA, ORZ_ZERLINDA___PLOT_02_AGREED_FATHER);

            oDulin          = UT_GetNearestCreatureByTag( oPC, ORZ_CR_DULIN );
            oOghren         = UT_GetNearestCreatureByTag( oPC, ORZ_CR_OGHREN );
            oOrdel          = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ORDEL );

            // QUICK FIX START
            // Make sure main plot can't be locked down by double-crossing
            if(WR_GetPlotFlag(PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_PRE_PLOT_01_TT_HARROW)
                && WR_GetPlotFlag(PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_PRE_PLOT_01_TT_BHELEN))
            {
                // clear some of Vartag's flags
                WR_SetPlotFlag(PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_PRE_PLOT_01_TT_BHELEN, FALSE);
                WR_SetPlotFlag(PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_02_RETURN, FALSE);
            }


            // QUICK FIX END

            //------------------------------------------------------------------

            // Check if Dulin should be in Tapster's or at the Noble's Quarter
            WR_SetObjectActive( oDulin, bDulinActive );
            SetPlotGiver( oDulin, FALSE );

            // Make sure we are grabbing the proper Oghren
            if (bOghrenInParty && IsPartyMember(oOghren))
                oOghren = UT_GetNearestCreatureByTag(oOghren,ORZ_CR_OGHREN);

            // Check if Ogrhen should be in Tapster's
            WR_SetObjectActive( oOghren, bOghrenActive );
            UnequipItem(oOghren,GetItemInEquipSlot(INVENTORY_SLOT_MAIN,oOghren));

            // Check if Ordel should be in Tapster's
            WR_SetObjectActive( oOrdel, bOrdelActive );

            //------------------------------------------------------------------

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