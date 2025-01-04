//==============================================================================
/*

    Urn of Sacred Ashes
        -> Mountain Top area script

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On:  09.18.08
//==============================================================================


#include "wrappers_h"
#include "utility_h"
#include "plot_h"


#include "plt_urnpt_main"
#include "plt_urn200pt_temple"
#include "plt_urn200pt_cult"
#include "plt_urnpt_area_jumps"
#include "urn_constants_h"

#include "cutscenes_h"


void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent         = GetCurrentEvent();              // Event
    int     nEventType      = GetEventType( evEvent );        // Event Type
    object  oEventCreator   = GetEventCreator( evEvent );     // Event Creator

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

            int bKolgrim, bSacredAshes, bCultQuest;

            object oKolgrim, oDragon;

            bKolgrim     = WR_GetPlotFlag( PLT_URNPT_AREA_JUMPS, KOLGRIM_TO_MOUNTAIN_TOP );
            bSacredAshes = WR_GetPlotFlag( PLT_URN200PT_TEMPLE, PC_HAS_ASHES );
            bCultQuest   = WR_GetPlotFlag( PLT_URN200PT_CULT, KOLGRIM_OFFER_TO_TAINT_ASHES_ACCEPTED );

            oKolgrim    = UT_GetNearestObjectByTag( oPC, URN_CR_KOLGRIM );
            oDragon     = GetObjectByTag( URN_CR_DRAGON );

            SetPlotGiver( oKolgrim, FALSE );

            if ( bKolgrim )
            {

                // If Kolgrim is allied he will be here to talk
                WR_SetObjectActive( oKolgrim, TRUE );
                UT_TeamAppears(URN_TEAM_KOLGRIM, TRUE);
                UT_TeamGoesHostile(URN_TEAM_KOLGRIM, FALSE);
                WR_SetPlotFlag( PLT_URNPT_AREA_JUMPS, KOLGRIM_TO_MOUNTAIN_TOP, FALSE );

                // The dragon will be neutral.
                UT_CombatStop( oDragon, oPC );

            }

            // If the player has the ashes the plot is done.
            if ( bSacredAshes )
            {
                // Qwinn: Made this happen only once, otherwise could repeatedly get 750xp reward
                if ( !WR_GetPlotFlag( PLT_URNPT_MAIN, URN_PLOT_DONE ) )
                    WR_SetPlotFlag( PLT_URNPT_MAIN, URN_PLOT_DONE, TRUE, TRUE );

                int bKolgrimRefused = WR_GetPlotFlag( PLT_URN200PT_CULT, KOLGRIM_OFFER_REFUSED );
                int bKolgrimKilled  = WR_GetPlotFlag( PLT_URN200PT_CULT, KOLGRIM_KILLED );

                if ( bCultQuest && !bKolgrimRefused && !bKolgrimKilled )
                {
                    // Kolgrim wants to talk
                    object oTrigger = UT_GetNearestObjectByTag( oPC, URN_TR_KOLGRIM_END );
                    WR_SetObjectActive( oTrigger, TRUE );

                    // Kolgrim is near the exit
                    UT_LocalJump( oKolgrim, URN_WP_KOLGRIM_END );
                    //UT_TeamJump( URN_TEAM_KOLGRIM,  URN_WP_KOLGRIM_END );

                    // Jump over kolgrim's buddies
                    object oKolGaurd1 = UT_GetNearestCreatureByTag( oPC, "urn200cr_cultist_reaver_1" );
                    object oKolGaurd2 = UT_GetNearestCreatureByTag( oPC, "urn200cr_cultist_patrol_1" );

                    UT_LocalJump( oKolGaurd1, "urn220wp_kol_gaurd_1" );
                    UT_LocalJump( oKolGaurd2, "urn220wp_kol_gaurd_2" );

                }

            }

            // There is now a shortcut back to the begining of the temple.
            WR_SetPlotFlag( PLT_URN200PT_TEMPLE, URN_TEMPLE_SHORTCUT_OPEN, TRUE );

            // IF the player hasn't encountered the dragon already.
            int bDragon = WR_GetPlotFlag( PLT_URNPT_MAIN, PC_ENCOUNTERED_DRAGON );

            if ( !bDragon )
            {

                //The player will witness the dragon.
                WR_SetPlotFlag( PLT_URNPT_MAIN, PC_ENCOUNTERED_DRAGON, TRUE );
                CS_LoadCutscene( CUTSCENE_URN_DRAGON, PLT_URN200PT_TEMPLE, URN_TEMPLE_POST_DRAGON_CUTSCENE );

            }
            else
            {
                if ( !IsDead( oDragon ) )
                {
                    SignalEvent( oDragon, Event( EVENT_TYPE_CUSTOM_EVENT_03 ) );
                }
                DoAutoSave();
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

        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(evEvent, 0); // Team ID
            switch (nTeamID)
            {
                case URN_TEAM_KOLGRIM:
                {
                    WR_SetPlotFlag(PLT_URN200PT_TEMPLE, MOUNTAINTOP_KOLGRIM_DEAD, TRUE, TRUE);

                    int bTeamDead = WR_GetPlotFlag(PLT_URN200PT_TEMPLE, MOUNTAINTOP_KOLGRIM_TEAM_DEAD);

                    if(bTeamDead)
                    {
                        if(!WR_GetPlotFlag(PLT_URN200PT_CULT, URN_TAINTED))
                            WR_UnlockAchievement(ACH_DECISIVE_CEREMONIALIST);
                    }

                    break;
                }

                case URN_TEAM_KOLGRIM_MOUNTAINTOP:
                {
                    WR_SetPlotFlag(PLT_URN200PT_TEMPLE, MOUNTAINTOP_KOLGRIM_DEAD, TRUE, TRUE);

                    int bTeamDead = WR_GetPlotFlag(PLT_URN200PT_TEMPLE, MOUNTAINTOP_KOLGRIM_DEAD);

                    if(bTeamDead)
                    {
                        if(!WR_GetPlotFlag(PLT_URN200PT_CULT, URN_TAINTED))
                            WR_UnlockAchievement(ACH_DECISIVE_CEREMONIALIST);
                    }

                    break;
                }
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