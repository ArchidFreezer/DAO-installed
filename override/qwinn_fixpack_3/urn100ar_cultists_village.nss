//==============================================================================
/*

    Urn of Sacred Ashes
        -> Village of Haven area events

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: 09.18.08
//==============================================================================


#include "wrappers_h"
#include "utility_h"
#include "plot_h"

#include "urn_functions_h"

#include "plt_urnpt_area_jumps"
#include "plt_urn100pt_haven"
#include "plt_urnpt_main"

// Qwinn added
#include "plt_urn200pt_cult"


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

            // Qwinn added
            object oChild = GetObjectByTag(URN_CR_HAVEN_CHILD);
            SetTeamId(oChild,URN_TEAM_VILLAGE_POST_PLOT);


            int bTempleOpen, bAlarmRaised, bUrnDone;

            bTempleOpen  = WR_GetPlotFlag( PLT_URNPT_AREA_JUMPS, TEMPLE_EXIT_OPEN );
            bAlarmRaised = WR_GetPlotFlag( PLT_URN100PT_HAVEN, ALARM_RAISED ) || WR_GetPlotFlag( PLT_URN100PT_HAVEN, VILLAGE_GOES_HOSTILE );
            bUrnDone     = WR_GetPlotFlag( PLT_URNPT_MAIN, URN_PLOT_DONE );


            // Exit to the Ruined Temple is now available
            if ( bTempleOpen )
            {

                object oExit;

                oExit = GetObjectByTag( URN_IP_TEMPLE_EXIT );

                WR_SetObjectActive( oExit, TRUE );
                WR_SetPlotFlag( PLT_URNPT_AREA_JUMPS, TEMPLE_EXIT_OPEN, FALSE );

            }




            // Activity if the alarm has been raised.
            if ( bAlarmRaised && !bUrnDone )
            {
                object oMechantPin = GetObjectByTag("urn100wp_from_shop");
                SetMapPinState(oMechantPin, FALSE);
                URN_SetVillageAlarm();
                WR_SetPlotFlag( PLT_URN100PT_HAVEN, VILLAGE_HOSTILES_ENCOUNTERED, TRUE );
            }

            // Post plot activity
            if ( bUrnDone )
            {
                UT_TeamAppears( URN_TEAM_VILLAGE_AMBUSH, FALSE );
                UT_TeamAppears( URN_TEAM_VILLAGE_POST_PLOT, TRUE );

                // Qwinn added
                object oGuard = GetObjectByTag(URN_CR_HAVEN_GUARD);
                if (WR_GetPlotFlag( PLT_URN200PT_CULT, CULT_QUEST_DONE))
                {
                    UT_CombatStop(oGuard, GetHero());
                    object oMechantPin = GetObjectByTag("urn100wp_from_shop");
                    SetMapPinState(oMechantPin, TRUE);
                }
                else
                    UT_CombatStart(oGuard, GetHero());

                // grave egg
                object oFence;
                oFence = UT_GetNearestObjectByTag( oPC, URN_IP_FENCE );
                WR_SetObjectActive( oFence, FALSE );
                UT_SetTeamInteractive(URN_TEAM_GRAVESTONES, TRUE, OBJECT_TYPE_PLACEABLE);

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

            if ( !GetLocalInt(OBJECT_SELF, AREA_DO_ONCE_A) )
            {

                DoAutoSave();
                SetLocalInt( OBJECT_SELF, AREA_DO_ONCE_A, TRUE );

            }

            break;

        }

    }

    //--------------------------------------------------------------------------
    // Pass any unhandled events to area_core
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, RESOURCE_SCRIPT_AREA_CORE );

}