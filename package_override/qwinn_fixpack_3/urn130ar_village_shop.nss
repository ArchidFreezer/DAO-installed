//==============================================================================
/*

    Urn of Sacred Ashes
        -> Village shop area events

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: 09.18.08
//==============================================================================


#include "wrappers_h"
#include "utility_h"
#include "plot_h"

#include "plt_urn100pt_haven"
#include "plt_urn200pt_cult"
#include "urn_constants_h"



void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent         = GetCurrentEvent();            // Event
    int     nEventType      = GetEventType(evEvent);        // Event Type
    object  oEventCreator   = GetEventCreator(evEvent);     // Event Creator

    // Standard Stuff
    object  oPC             = GetHero();
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

            if ( WR_GetPlotFlag( PLT_URN100PT_HAVEN, ALARM_RAISED ) )
            {

                object oChest = GetObjectByTag( "urn130ip_iron_chest" );

                SetPlaceableState( oChest, PLC_STATE_CONTAINER_UNLOCKED );

            }


            // Qwinn added everything else
            if (WR_GetPlotFlag( PLT_URN200PT_CULT, CULT_QUEST_DONE))
            {
                object oTarg = GetObjectByTag(URN_TR_SHOPKEEPER, 0);
                WR_SetObjectActive(oTarg, FALSE);
                oTarg = GetObjectByTag(URN_TR_SHOPKEEPER, 1);
                WR_SetObjectActive(oTarg, FALSE);
                if ( WR_GetPlotFlag( PLT_URN100PT_HAVEN, VILLAGE_HOSTILES_ENCOUNTERED ) ||
                     WR_GetPlotFlag( PLT_URN100PT_HAVEN, SHOPKEEPER_KILLED))
                {
                    object oNewShopkeep = UT_GetNearestCreatureByTag(oPC,"urn130cr_newshopkeep");
                    WR_SetObjectActive(oNewShopkeep,TRUE);
                }
                else
                {
                    object oOldShopkeep = UT_GetNearestCreatureByTag(oPC,"urn130cr_shopkeeper");
                    WR_SetObjectActive(oOldShopkeep,TRUE);
                }
            }

         }
    }

    //--------------------------------------------------------------------------
    // Pass any unhandled events to area_core
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, RESOURCE_SCRIPT_AREA_CORE );

}