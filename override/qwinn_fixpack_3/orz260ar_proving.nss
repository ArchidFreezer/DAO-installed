//==============================================================================
/*

    Paragon of Her Kind
     -> Proving Area Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 15, 2007
//==============================================================================

#include "plt_orzpt_generic"
#include "plt_orzpt_defined"
#include "plt_orzpt_main"

#include "orz_constants_h"
#include "orz_functions_h"

#include "plt_gen00pt_proving"
#include "plt_orz310pt_thief"
// Qwinn added
#include "plt_orz260pt_baizyl"
#include "plt_orz200pt_wrangler"

#include "wrappers_h"
#include "utility_h"
#include "plot_h"
#include "proving_h"

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

            WR_SetPlotFlag( PLT_GEN00PT_PROVING, PROVING__CLEAR_STATES, TRUE, TRUE );

            break;

        }


        case EVENT_TYPE_TEAM_DESTROYED:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_TEAM_DESTROYED:
            // Sent by: creature_core
            // When: all members of a team are dead
            //------------------------------------------------------------------

            int nTeamID = GetEventInteger(evEvent,0);
            if ( nTeamID == PROVING_TEAM_OPPONENTS )
            {
                WR_SetPlotFlag(PLT_GEN00PT_PROVING,PROVING__WIN,TRUE,TRUE);
            }

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

            int         bParagonCompleted;
            int         bProvingActive;
            int         bIrritatedDwarfLeaves;
            int         bChampionshipDeclined;
            int         bChampionshipDone;
            int         bSuvrekLeft;
            int         bThiefBoss;

            object      oVartag;
            object      oGwiddon;
            object      oBaizyl;
            object      oVarick;
            object      oFightFan;
            object      oFence;

            object      oDoor1;
            object      oDoor2;

            //------------------------------------------------------------------

            bParagonCompleted       = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_DONE );
            bProvingActive          = WR_GetPlotFlag( PLT_ORZPT_DEFINED, ORZ_DEFINED_EITHER_TASK_1_ACCEPTED );
            bThiefBoss              = WR_GetPlotFlag( PLT_ORZ310PT_THIEF, ORZ_THIEF_FOUND_PROVING_RECEIPT );

            oVartag                 = UT_GetNearestCreatureByTag( oPC, ORZ_CR_VARTAG );
            oGwiddon                = UT_GetNearestCreatureByTag( oPC, ORZ_CR_GWIDDON );
            oBaizyl                 = UT_GetNearestCreatureByTag( oPC, ORZ_CR_BAIZYL );
            oVarick                 = UT_GetNearestCreatureByTag( oPC, ORZ_CR_VARICK );
            oFightFan               = UT_GetNearestCreatureByTag( oPC, ORZ_CR_FIGHTFAN );
            oFence                  = UT_GetNearestCreatureByTag( oPC, ORZ_CR_FENCE );

            oDoor1                  = UT_GetNearestObjectByTag( oPC, ORZ_IP_TO_FIGHTERS_1 );
            oDoor2                  = UT_GetNearestObjectByTag( oPC, ORZ_IP_TO_FIGHTERS_2 );

            // Qwinn added per scripting comments in Hanashan's dialogue
            object oHanashan        = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HANASHAN );
            object oFarinden        = UT_GetNearestCreatureByTag( oPC, ORZ_CR_FARINDEN );
            WR_SetObjectActive( oHanashan, !bParagonCompleted);
            WR_SetObjectActive( oFarinden, !bParagonCompleted);


            //------------------------------------------------------------------

           if (bProvingActive && GetPlaceableState(oDoor1) == PLC_STATE_DOOR_LOCKED)
           {
                SetPlaceableState(oDoor1,PLC_STATE_DOOR_UNLOCKED);
                SetPlaceableState(oDoor2,PLC_STATE_DOOR_UNLOCKED);
           }

            WR_SetObjectActive( oGwiddon,  bProvingActive );

            // Qwinn added so Baizyl doesn't respawn if his quest failed until king is crowned
            // WR_SetObjectActive( oBaizyl, bProvingActive ) ;
            int bBaizylQuestFailed = WR_GetPlotFlag( PLT_ORZ260PT_BAIZYL, ORZ_BAIZYL___PLOT_FAILED) ;
            int bBaizylActive = ((bProvingActive && !bBaizylQuestFailed) || bParagonCompleted );
            WR_SetObjectActive( oBaizyl, bBaizylActive ) ;

            WR_SetObjectActive( oVarick,   bProvingActive );
            WR_SetObjectActive( oFightFan, bProvingActive );
            WR_SetObjectActive( oVartag, FALSE );

            WR_SetObjectActive( oFence, bThiefBoss );
            UT_TeamAppears( ORZ_TEAM_SHAPERATE_THIEF_BOSS, bThiefBoss );

            // Qwinn added to move Myaja and Lucjan back to their original spots, otherwise
            // their later dialogue stages teleport them back there anyway.
            if (WR_GetPlotFlag( PLT_ORZ260PT_BAIZYL, ORZ_BAIZYL__EVENT_TWINS_LEAVE_CHAMBER))
            {
                object oMyaja = UT_GetNearestCreatureByTag( oPC, ORZ_CR_MARJA );
                object oLucjan = UT_GetNearestCreatureByTag( oPC, ORZ_CR_LUCJAN );
                UT_LocalJump ( oMyaja, ORZ_WP_MYAJA_HOME, TRUE, TRUE, FALSE, FALSE );
                UT_LocalJump ( oLucjan, ORZ_WP_LUCJAN_HOME, TRUE, TRUE, FALSE, FALSE );
            }
            
            // Qwinn added
            if (WR_GetPlotFlag(PLT_ORZ200PT_WRANGLER,ORZ_WRANGLER_PLOT_ACCEPTED))
            {
               UT_TeamAppears( ORZ_TEAM_ESCAPED_NUGS );
            }               

            //------------------------------------------------------------------


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


    }

    //--------------------------------------------------------------------------
    // Pass any unhandled events to orzar_core ( Paragon Area Core )
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, ORZ_RESOURCE_SCRIPT_AREA_CORE );

}