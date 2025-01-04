//==============================================================================
/*

    Paragon of Her Kind
     -> Events

     This script covers all events that happen within the city of Orzammar
     during the Paragon plot. It does not include events from the Deep Roads.
     This does not include events that belong to plots.

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: June 12, 2007
//==============================================================================

#include "plt_gen00pt_backgrounds"
#include "plt_gen00pt_party"
#include "plt_cod_cha_bhelen"
#include "plt_cod_cha_harrowmont"
#include "plt_orzpt_anvil"
#include "plt_orzpt_carta"
#include "plt_orzpt_events"
#include "plt_orzpt_main"
#include "cutscenes_h"
#include "wrappers_h"
#include "utility_h"
#include "plot_h"
#include "orz_constants_h"
#include "orz_functions_h"

int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evParms = GetCurrentEvent();            // Contains input parameters
    int     nType   = GetEventType(evParms);        // GET or SET call
    string  sPlot   = GetEventString(evParms, 0);   // Plot GUID
    int     nFlag   = GetEventInteger(evParms, 1);  // The bit flag # affected
    object  oOwner  = GetEventCreator(evParms);     // Script plot table owner

    // Grab Player, Set Default return to FALSE
    object  oPC     = GetHero();
    int     bResult = FALSE;

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evParms);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger(evParms, 3);  // Old flag value
        int nNewValue   = GetEventInteger(evParms, 2);  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {


            //==================================================================
            //------------------------------------------------------------------
            // ORZ_EVENT_ASSEMBLY_FINAL_SCENE
            //------------------------------------------------------------------
            //==================================================================

            case ORZ_EVENT_ASSEMBLY_FINAL_SCENE__SETUP:
            {
                //--------------------------------------------------------------
                // ORZ_EVENT_ASSEMBLY_FINAL_SCENE:
                // _SETUP
                //--------------------------------------------------------------
                int         bEventActive    = WR_GetPlotFlag( sPlot, ORZ_EVENT_ASSEMBLY_FINAL_SCENE__ACTIVE );
                object      oBhelen         = UT_GetNearestCreatureByTag( oPC, ORZ_CR_BHELEN );
                object      oHarrow         = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HARROWMONT );
                object      oCommander      = UT_GetNearestCreatureByTag( oPC, ORZ_CR_COMMANDER );
                object      oSteward        = UT_GetNearestCreatureByTag( oPC, ORZ_CR_STEWARD );
                object      oShaper         = UT_GetNearestCreatureByTag( oPC, ORZ_CR_SHAPER );
                object      oAssemblyDoor   = UT_GetNearestObjectByTag( oPC, ORZ_IP_ASSEMBLY_DOOR );
                object []   arBGuards       = UT_GetAllObjectsInAreaByTag( ORZ_CR_HARROWMONT_GUARD, OBJECT_TYPE_CREATURE );
                object []   arHGuards       = UT_GetAllObjectsInAreaByTag( ORZ_CR_BHELEN_GUARD, OBJECT_TYPE_CREATURE );

                WR_SetObjectActive( oBhelen,      bEventActive );
                WR_SetObjectActive( oHarrow,      bEventActive );
                WR_SetObjectActive( oShaper,      bEventActive );
                WR_SetObjectActive( oCommander,   bEventActive );
                WR_SetObjectActive( arBGuards[0], bEventActive );
                WR_SetObjectActive( arBGuards[1], bEventActive );
                WR_SetObjectActive( arHGuards[0], bEventActive );
                WR_SetObjectActive( arHGuards[1], bEventActive );

                if ( bEventActive )
                    SetPlaceableState( oAssemblyDoor, PLC_STATE_DOOR_LOCKED );

                break;
            }


            case ORZ_EVENT_ASSEMBLY_FINAL_SCENE__TRIGGERED:
            {
                //--------------------------------------------------------------
                // ORZ_EVENT_ASSEMBLY_FINAL_SCENE:
                // _TRIGGERED
                //--------------------------------------------------------------
                object oSteward = UT_GetNearestCreatureByTag( oPC, ORZ_CR_STEWARD );
                UT_Talk( oSteward, oPC );

                break;
            }


            //==================================================================
            //------------------------------------------------------------------
            // ORZ_EVENT_COMMONS_GUARD_FIGHT
            //------------------------------------------------------------------
            //==================================================================

            case ORZ_EVENT_COMMONS_GUARD_FIGHT__SETUP:
            {
                //--------------------------------------------------------------
                // ORZ_EVENT_COMMONS_GUARD_FIGHT_SETUP:
                //--------------------------------------------------------------
                int     bEventActive = WR_GetPlotFlag( sPlot, ORZ_EVENT_COMMONS_GUARD_FIGHT__ACTIVE );
                object  oBhelenGuard = UT_GetNearestObjectByTag( oPC, ORZ_CR_PRO_BHELEN_GUARD );
                object  oHarrowGuard = UT_GetNearestObjectByTag( oPC, ORZ_CR_PRO_HARROW_GUARD );

                WR_SetObjectActive( oBhelenGuard, bEventActive );
                WR_SetObjectActive( oHarrowGuard, bEventActive );

                break;
            }

            case ORZ_EVENT_COMMONS_GUARD_FIGHT__TRIGGERED:
            {
                //--------------------------------------------------------------
                // ORZ_EVENT_COMMONS_GUARD_FIGHT_TRIGGERED:
                //--------------------------------------------------------------
                CS_LoadCutscene( CUTSCENE_ORZ_GUARDSMEN_FIGHT, sPlot, ORZ_EVENT_COMMONS_GUARD_FIGHT_OVER );

                break;
            }

            case ORZ_EVENT_COMMONS_GUARD_FIGHT_OVER:
            {
                //--------------------------------------------------------------
                // ORZ_EVENT_COMMONS_GUARD_FIGHT_OVER:
                //--------------------------------------------------------------
                object oBhelenGuard = UT_GetNearestObjectByTag( oPC, ORZ_CR_PRO_BHELEN_GUARD );
                object oHarrowGuard = UT_GetNearestObjectByTag( oPC, ORZ_CR_PRO_HARROW_GUARD );
                object oGuardsman   = UT_GetNearestObjectByTag( oPC, ORZ_CR_GUARDSMAN );
                object oMoveTo      = UT_GetNearestObjectByTag( oPC, ORZ_WP_GUARDSMAN_MOVETO );

                WR_SetObjectActive( oBhelenGuard, FALSE );
                WR_SetObjectActive( oHarrowGuard, FALSE );

                // Activate Bhelen/Harrowmont codex entries as required.
                if (!WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_DWARF_NOBLE))
                {
                    WR_SetPlotFlag(PLT_COD_CHA_BHELEN,COD_CHA_BHELEN_MAIN_ALL_OTHERS,TRUE);
                    WR_SetPlotFlag(PLT_COD_CHA_BHELEN,COD_CHA_BHELEN_QUOTE_ALL_OTHERS,TRUE);
                }
                WR_SetPlotFlag(PLT_COD_CHA_HARROWMONT,COD_CHA_HARROWMONT_MAIN,TRUE);

                ORZ_UpdateStorySoFar(SSF_ORZ_01_ENTERED_ORZAMMAR);

                // Guardsman moves and then talks
                AddCommand( oGuardsman, CommandMoveToObject(oMoveTo), TRUE );
                UT_Talk( oGuardsman, oGuardsman );

                break;
            }


            //==================================================================
            //------------------------------------------------------------------
            // ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT
            //------------------------------------------------------------------
            //==================================================================

            case ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__SETUP:
            {
                //--------------------------------------------------------------
                // ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__SETUP:
                //--------------------------------------------------------------
                int         bEventActive = WR_GetPlotFlag( sPlot, ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__ACTIVE );
                object      oBeggar      = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HOH_BEGGAR );

                WR_SetObjectActive( oBeggar, bEventActive );

                break;
            }

            case ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__TRIGGERED:
            {

                //--------------------------------------------------------------
                // ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__TRIGGERED:
                //--------------------------------------------------------------

                break;

            }

            case ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT_GUARD_MOVES_CLOSER:
            {

                //--------------------------------------------------------------
                // ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT_GUARD_MOVES_CLOSER:
                //--------------------------------------------------------------

                object      oGuard;

                //--------------------------------------------------------------

                oGuard = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HOH_GUARD_PATROL_2 );

                //--------------------------------------------------------------

                UT_QuickMoveObject( oGuard, "2" );

                break;

            }

            case ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT_BEGGAR_RUNS_AWAY:
            {

                //--------------------------------------------------------------
                // ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT_BEGGAR_RUNS_AWAY:
                //--------------------------------------------------------------

                object      oBeggar;
                object      oGuard;

                //--------------------------------------------------------------

                oBeggar = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HOH_BEGGAR );
                // Qwinn:  Guard_Patrol was never set up
                // oGuard  = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HOH_GUARD_PATROL_2 );
                oGuard  = UT_GetNearestCreatureByTag( oBeggar, "orz110cr_guard_1");

                //--------------------------------------------------------------
                UT_ExitDestroy( oBeggar );
//                SetLocalInt( oGuard, AMBIENT_AI_ACTIVE, TRUE );
//                SetLocalInt( oGuard, AMB_SYSTEM_CURRENT_JOB, 4 );
                WR_ClearAllCommands( oGuard );
                SetObjectInteractive( oGuard, TRUE );
                Rubber_GoHome (oGuard);
                
//                AMB_StartAmbientAI( oGuard );

                break;

            }


            //==================================================================
            //------------------------------------------------------------------
            // ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN
            //------------------------------------------------------------------
            //==================================================================

            case ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN__SETUP:
            {

                //--------------------------------------------------------------
                // ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN_SETUP:
                //--------------------------------------------------------------

                int bEventActive = WR_GetPlotFlag( sPlot, ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN__ACTIVE );

                object oYoungGirl = UT_GetNearestObjectByTag( oPC, ORZ_CR_BRANKA_GIRL );
                object oOldWoman  = UT_GetNearestObjectByTag( oPC, ORZ_CR_BRANKA_WOMAN );

                WR_SetObjectActive( oYoungGirl, bEventActive );
                WR_SetObjectActive( oOldWoman, bEventActive );

                break;

            }

            case ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN__TRIGGERED:
            {

                //--------------------------------------------------------------
                // ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN_TRIGGERED:
                //--------------------------------------------------------------

                object oOldWoman = UT_GetNearestObjectByTag(oPC, ORZ_CR_BRANKA_WOMAN);

                UT_Talk(oOldWoman, oPC);

                break;

            }

            case ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN_LEAVES:
            {

                //--------------------------------------------------------------
                // ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN_LEAVES:
                //--------------------------------------------------------------

                object oYoungGirl = UT_GetNearestObjectByTag( oPC, ORZ_CR_BRANKA_GIRL );
                object oOldWoman  = UT_GetNearestObjectByTag( oPC, ORZ_CR_BRANKA_WOMAN );

                UT_ExitDestroy( oYoungGirl );
                UT_ExitDestroy( oOldWoman );

                break;

            }

            //==================================================================
            //------------------------------------------------------------------
            // ORZ_EVENT_MOUNTAIN_PASS_EXIT_GUARDS
            //------------------------------------------------------------------
            //==================================================================

            case ORZ_EVENT_MOUNTAIN_PASS_EXIT_GUARDS__SETUP:
            {

                //--------------------------------------------------------------
                // ORZ_EVENT_MOUNTAIN_PASS_EXIT_GUARDS__SETUP:
                //--------------------------------------------------------------

                int bEventActive = WR_GetPlotFlag( sPlot, ORZ_EVENT_MOUNTAIN_PASS_EXIT_GUARDS__ACTIVE );

                object [] arGuards = UT_GetAllObjectsInAreaByTag(ORZ_CR_EXIT_GUARD,OBJECT_TYPE_CREATURE);

                int nNumGuards = GetArraySize(arGuards);
                int i;

                for ( i = 0; i < nNumGuards; i++ )
                    WR_SetObjectActive(arGuards[i], bEventActive);

                break;

            }

            case ORZ_EVENT_MOUNTAIN_PASS_EXIT_GUARDS__TRIGGERED:
            {

                //--------------------------------------------------------------
                // ORZ_EVENT_MOUNTAIN_PASS_EXIT_GUARDS__TRIGGERED:
                //--------------------------------------------------------------

                break;

            }



            //==================================================================
            //------------------------------------------------------------------
            // ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT
            //------------------------------------------------------------------
            //==================================================================


            case ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT__SETUP:
            {

                //--------------------------------------------------------------
                // ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT__SETUP:
                //--------------------------------------------------------------

                int nIndex;
                object [] arTeam;

                int bEventActive = WR_GetPlotFlag( sPlot, ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT__ACTIVE );

                arTeam = UT_GetTeam( ORZ_TEAM_PROBHELEN_SUPPORTERS );
                for ( nIndex = 0; nIndex < GetArraySize(arTeam); nIndex++)
                    WR_SetObjectActive( arTeam[nIndex], bEventActive );

                arTeam = UT_GetTeam( ORZ_TEAM_PROHARROW_SUPPORTERS );
                for ( nIndex = 0; nIndex < GetArraySize(arTeam); nIndex++)
                    WR_SetObjectActive( arTeam[nIndex], bEventActive );

                break;

            }

            case ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT__TRIGGERED:
            {

                //--------------------------------------------------------------
                // TRIGGER: The Guards start conversation with the PC
                //--------------------------------------------------------------

                object oBSupport1 = UT_GetNearestCreatureByTag( oPC, ORZ_CR_BHELEN_SUPPORTER_1 );

                UT_Talk( oBSupport1, oPC, R"orz300_supporter_fight.dlg" );

                break;

            }

            case ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT_CANCELED:
            {

                //--------------------------------------------------------------
                // SETUP:   The fight doesn't happen and both groups walk off
                //--------------------------------------------------------------

                UT_TeamExit( ORZ_TEAM_PROBHELEN_SUPPORTERS );
                UT_TeamExit( ORZ_TEAM_PROHARROW_SUPPORTERS );

                break;

            }

            case ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT_OVER_SIDED_BHELEN:
            {

                //--------------------------------------------------------------
                // SIDED_BHELEN: The PC sided with Bhelen during the fight
                //--------------------------------------------------------------

                int         nIndex;
                int         nArraySize;
                object      oCurrent;
                object []   arTeam;

                //--------------------------------------------------------------

                arTeam = UT_GetTeam( ORZ_TEAM_PROBHELEN_SUPPORTERS );

                //--------------------------------------------------------------

                SetGroupHostility( ORZ_GROUP_BHELEN, ORZ_GROUP_HARROWMONT, FALSE );
                SetGroupHostility( GROUP_PC, ORZ_GROUP_HARROWMONT, FALSE );
                SetGroupHostility( GROUP_PC, ORZ_GROUP_BHELEN, FALSE );

                nArraySize = GetArraySize(arTeam);
                for ( nIndex = 0; nIndex < nArraySize; nIndex++)
                {
                    oCurrent = arTeam[nIndex];
                    if ( !IsDead(oCurrent) )
                    {
                        WR_ClearAllCommands(oCurrent,TRUE);
                        UT_Talk(oCurrent,oCurrent);
                        break;
                    }
                }

                break;

            }

            case ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT_OVER_SIDED_HARROWMONT:
            {

                //--------------------------------------------------------------
                // SIDED_HARROWMONT: The PC sided with Harrowmont during the
                //                   fight
                //--------------------------------------------------------------

                int         nIndex;
                int         nArraySize;
                object      oCurrent;
                object []   arTeam;

                //--------------------------------------------------------------

                arTeam = UT_GetTeam( ORZ_TEAM_PROHARROW_SUPPORTERS );

                //--------------------------------------------------------------

                SetGroupHostility( ORZ_GROUP_BHELEN, ORZ_GROUP_HARROWMONT, FALSE );
                SetGroupHostility( GROUP_PC, ORZ_GROUP_HARROWMONT, FALSE );
                SetGroupHostility( GROUP_PC, ORZ_GROUP_BHELEN, FALSE );

                nArraySize = GetArraySize(arTeam);
                for ( nIndex = 0; nIndex < nArraySize; nIndex++)
                {
                    oCurrent = arTeam[nIndex];
                    if ( !IsDead(oCurrent) )
                    {
                        WR_ClearAllCommands(oCurrent,TRUE);
                        UT_Talk(oCurrent,oCurrent);
                        break;
                    }
                }

                break;

            }


            case ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT_START_SIDE_NONE:
            {

                //--------------------------------------------------------------
                // SIDED_HARROWMONT: The PC sided with Harrowmont during the
                //                   fight
                //--------------------------------------------------------------

                int         nIndex;
                int         nArraySize;
                object []   arTeamBhelen;
                object []   arTeamHarrow;

                //--------------------------------------------------------------

                arTeamBhelen = UT_GetTeam( ORZ_TEAM_PROBHELEN_SUPPORTERS );
                arTeamHarrow = UT_GetTeam( ORZ_TEAM_PROHARROW_SUPPORTERS );

                //--------------------------------------------------------------

                SetGroupHostility( ORZ_GROUP_BHELEN, ORZ_GROUP_HARROWMONT, TRUE );

                nArraySize = GetArraySize(arTeamBhelen);
                for ( nIndex = 0; nIndex < nArraySize; nIndex++)
                    UT_CombatStart( arTeamBhelen[nIndex], arTeamHarrow[nIndex], TRUE );

                break;

            }


            case ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT_START_SIDE_HARROWMONT:
            {

                //--------------------------------------------------------------
                // START: The fight begins
                //--------------------------------------------------------------

                int         nIndex;
                int         nArraySize;
                object []   arTeamBhelen;
                object []   arTeamHarrow;

                //--------------------------------------------------------------

                arTeamBhelen = UT_GetTeam( ORZ_TEAM_PROBHELEN_SUPPORTERS );
                arTeamHarrow = UT_GetTeam( ORZ_TEAM_PROHARROW_SUPPORTERS );

                //--------------------------------------------------------------

                SetGroupHostility( ORZ_GROUP_BHELEN, ORZ_GROUP_HARROWMONT, TRUE );
                SetGroupHostility( GROUP_PC, ORZ_GROUP_BHELEN, TRUE );

                nArraySize = GetArraySize(arTeamBhelen);
                for ( nIndex = 0; nIndex < nArraySize; nIndex++)
                    UT_CombatStart( arTeamBhelen[nIndex], arTeamHarrow[nIndex], TRUE );

                break;

            }


            case ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT_START_SIDE_BHELEN:
            {

                //--------------------------------------------------------------
                // START: The fight begins
                //--------------------------------------------------------------

                int         nIndex;
                int         nArraySize;
                object []   arTeamBhelen;
                object []   arTeamHarrow;

                //--------------------------------------------------------------

                arTeamBhelen = UT_GetTeam( ORZ_TEAM_PROBHELEN_SUPPORTERS );
                arTeamHarrow = UT_GetTeam( ORZ_TEAM_PROHARROW_SUPPORTERS );

                //--------------------------------------------------------------


                SetGroupHostility( ORZ_GROUP_BHELEN, ORZ_GROUP_HARROWMONT, TRUE );
                SetGroupHostility( GROUP_PC, ORZ_GROUP_HARROWMONT, TRUE );

                nArraySize = GetArraySize(arTeamBhelen);
                for ( nIndex = 0; nIndex < nArraySize; nIndex++)
                    UT_CombatStart( arTeamBhelen[nIndex], arTeamHarrow[nIndex], TRUE );

                break;

            }


        }

    }

    //--------------------------------------------------------------------------
    // Conditions -> defined flags only (GET DEFINED)
    //--------------------------------------------------------------------------

    else
    {

        // Check for which flag was checked
        switch(nFlag)
        {



            case ORZ_EVENT_ASSEMBLY_FINAL_SCENE__ACTIVE:
            {

                //--------------------------------------------------------------
                // ORZ_EVENT_ASSEMBLY_FINAL_SCENE:
                // _ACTIVE
                // COND:    If the Anvil plot is completed and the player has
                //          not yet triggered this event yet.
                //--------------------------------------------------------------

                int         bAnvilCompleted;
                int         bEventTriggered;

                //--------------------------------------------------------------

                bAnvilCompleted = WR_GetPlotFlag( PLT_ORZPT_ANVIL, ORZ_ANVIL___PLOT_08_COMPLETED );
                bEventTriggered = WR_GetPlotFlag( sPlot, ORZ_EVENT_ASSEMBLY_FINAL_SCENE__TRIGGERED );

                //--------------------------------------------------------------

                if ( !bEventTriggered && bAnvilCompleted )
                    bResult = TRUE;

                break;

            }


            case ORZ_EVENT_COMMONS_GUARD_FIGHT__ACTIVE:
            {

                //--------------------------------------------------------------
                // ACTIVE: if not yet triggered
                //--------------------------------------------------------------

                int bTriggered = WR_GetPlotFlag(sPlot,ORZ_EVENT_COMMONS_GUARD_FIGHT__TRIGGERED);

                if (!bTriggered)
                    bResult = TRUE;

                break;

            }


            case ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN__ACTIVE:
            {
                //--------------------------------------------------------------
                // ACTIVE: if not yet triggered
                //--------------------------------------------------------------

                int bTriggered = WR_GetPlotFlag(sPlot,ORZ_EVENT_HALL_OF_HEROES_BRANKAWOMAN__TRIGGERED);

                if (!bTriggered)
                    bResult = TRUE;

                break;
            }


            case ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__ACTIVE:
            {

                //--------------------------------------------------------------
                // ACTIVE: if not yet triggered
                //--------------------------------------------------------------

                int bTriggered = WR_GetPlotFlag( sPlot, ORZ_EVENT_HALL_OF_HEROES_BEGGAR_KICKED_OUT__TRIGGERED );

                if ( !bTriggered )
                    bResult = TRUE;

                break;

            }


            case ORZ_EVENT_MOUNTAIN_PASS_EXIT_GUARDS__ACTIVE:
            {
                //--------------------------------------------------------------
                // ACTIVE: if Orzammar Completed (King Exists)
                //--------------------------------------------------------------

                int bTriggered = WR_GetPlotFlag(sPlot,ORZ_EVENT_MOUNTAIN_PASS_EXIT_GUARDS__TRIGGERED);
                int bKingExists = WR_GetPlotFlag(PLT_ORZPT_MAIN,ORZ_MAIN___PLOT_DONE);

                if (!bTriggered && bKingExists)
                    bResult = TRUE;

                break;
            }


            case ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT__ACTIVE:
            {
                //--------------------------------------------------------------
                // ACTIVE: if Jarvia was killed.
                //--------------------------------------------------------------

                int bTriggered      = WR_GetPlotFlag(sPlot,ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT__TRIGGERED);
                int bJarviaKilled   = WR_GetPlotFlag(PLT_ORZPT_CARTA,ORZ_CARTA_JARVIA_DEAD);
                int bAnvilComplete  = WR_GetPlotFlag(PLT_ORZPT_ANVIL,ORZ_ANVIL___PLOT_08_COMPLETED);

                if (!bTriggered && bJarviaKilled && !bAnvilComplete )
                    bResult = TRUE;

                break;
            }



        }
    }

    return bResult;

}