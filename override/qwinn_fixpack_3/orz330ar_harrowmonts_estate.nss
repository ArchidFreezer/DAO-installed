//==============================================================================
/*

    Paragon of Her Kind
     -> Harrowmont's Estate Area Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: March 6, 2007
//==============================================================================

#include "plt_orzpt_main"
#include "plt_orz330pt_dulin"
#include "plt_orz330pt_harrowmont"
#include "plt_orzpt_defined"
#include "plt_orzpt_wfharrow"

#include "orz_constants_h"

#include "utility_h"

// Qwinn added
#include "orz300pt_nobhunter"

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

            int         bDulinActive;
            int         bDulinByHarrow;
            int         bHarrowActive;
            int         bFindDulinActive;
            int         bEitherTask2;
            int         bEitherDA;
            object      oDulin;
            object      oHarrow;
            object      oHarrowDoor;

            //------------------------------------------------------------------

            bEitherTask2     = WR_GetPlotFlag( PLT_ORZPT_DEFINED, ORZ_DEFINED_EITHER_TASK_2_ACCEPTED );
            bEitherDA        = WR_GetPlotFlag( PLT_ORZPT_DEFINED, ORZ_DEFINED_EITHER_TASK_DA_ACCEPTED );
            bDulinActive     = WR_GetPlotFlag( PLT_ORZ330PT_DULIN, ORZ_DULIN_IS_IN_HARROWMONTS_ESTATE );
            bDulinByHarrow   = WR_GetPlotFlag( PLT_ORZPT_WFHARROW, ORZ_WFH_DULIN_TELEPORTS_PC_TO_HARROWMONT );
            bHarrowActive    = WR_GetPlotFlag( PLT_ORZ330PT_HARROWMONT, ORZ_HARROW_IS_IN_HARROWMONTS_ESTATE );
            oDulin           = UT_GetNearestCreatureByTag( oPC, ORZ_CR_DULIN );
            oHarrow          = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HARROWMONT );
            oHarrowDoor      = UT_GetNearestObjectByTag( oPC, ORZ_IP_HARROW_DOOR );

            //------------------------------------------------------------------

            // Check if Harrowmont is still here
            WR_SetObjectActive( oHarrow, bHarrowActive );
            // Qwinn added to unlock door if king is crowned, since we made his door impossible to pick before this
            if ((bHarrowActive || WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_DONE))
                   && GetPlaceableState(oHarrowDoor) == PLC_STATE_DOOR_LOCKED )
            {
                SetPlaceableState( oHarrowDoor, PLC_STATE_DOOR_UNLOCKED );
            }

            // Check if Dulin is here, and if he needs to be moved
            // Also remove plot giver status
            WR_SetObjectActive( oDulin,  bDulinActive );

            // Dulin should be by harrowmont's study in this case
            if ( bDulinByHarrow )
            {
                UT_LocalJump( oDulin, ORZ_WP_DULIN_MOVETO );
            }

            if (bEitherTask2 || bEitherDA || bHarrowActive)
                SetPlotGiver( oDulin, FALSE );

            // If Bhelen is crowned king remove the bad ambient.
            if ( WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN ) )
                UT_TeamAppears( 200, FALSE );

            // Qwinn:  Add Mardy here if Harrowmont crowned and he accepts her
            if (WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER,ORZ_NOBHUNTER___PLOT_02D_HARROWMONT_AGREED) &&
                WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER,ORZ_NOBHUNTER___PLOT_04_COMPLETED))

            {
                object oMardy = UT_GetNearestCreatureByTag(oPC, ORZ_CR_MARDY);
                WR_SetObjectActive(oMardy,TRUE);
                object oClothes = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oMardy);
                if (GetTag(oClothes) != "gen_im_cth_nob_f03")
                {
                   object oRobes = UT_AddItemToInventory(R"gen_im_cth_nob_f03.uti",1,oMardy,"gen_im_cth_cha_f03");
                   EquipItem(oMardy, oRobes, INVENTORY_SLOT_CHEST);
                }
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