//==============================================================================
/*

    Paragon of Her Kind
     -> Main Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 5, 2007
//==============================================================================

#include "plt_orzpt_main"
#include "plt_orzpt_wfbhelen"
#include "plt_orzpt_wfbhelen_t2"
#include "plt_orzpt_wfbhelen_t3"
#include "plt_orzpt_wfharrow"
#include "plt_orzpt_wfharrow_t2"
#include "plt_orzpt_wfharrow_t1"
#include "plt_orzpt_wfbhelen_t1"
#include "plt_orzpt_wfharrow_t3"
#include "plt_orzpt_wfbhelen_da"
#include "plt_orzpt_wfharrow_da"
#include "plt_orz340pt_assembly"
#include "plt_mnp000pt_main_events"
#include "plt_cod_cha_bhelen"
#include "plt_cod_cha_harrowmont"
#include "plt_mnp000pt_autoss_main"
#include "plt_ranpt_generic_actions"
#include "plt_orz300pt_nobhunter"

#include "orz_constants_h"
#include "orz_functions_h"

#include "cutscenes_h"
#include "wrappers_h"
#include "utility_h"
#include "plot_h"

#include "achievement_core_h"


void _CleanupParagonPlots()
{
    // Bhelen
    int bWFBT3Active = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T3, ORZ_WFBT3___PLOT_ACTIVE );
    int bWFBT2Active = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T2, ORZ_WFBT2___PLOT_ACTIVE );
    int bWFBDAActive = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_ACTIVE );
    int bWFBT1Active = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_ACTIVE );
    int bWFBAccepted = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB___PLOT_01_ACCEPTED );
    int bWFBComplete = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB___PLOT_02_COMPLETED );
    // Harrowmont
    int bWFHT3Active = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T3, ORZ_WFHT3___PLOT_ACTIVE );
    int bWFHT2Active = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T2, ORZ_WFHT2___PLOT_ACTIVE );
    int bWFHDAActive = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_ACTIVE );
    int bWFHT1Active = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_ACTIVE );
    int bWFHAccepted = WR_GetPlotFlag( PLT_ORZPT_WFHARROW, ORZ_WFH___PLOT_01_ACCEPTED );
    int bWFHComplete = WR_GetPlotFlag( PLT_ORZPT_WFHARROW, ORZ_WFH___PLOT_02_COMPLETED );

    // ** BHELEN ** //
    if ( bWFBT3Active )
        WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_T3, ORZ_WFBT3___PLOT_FAILED, TRUE );
    if ( bWFBDAActive )
        WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_FAILED, TRUE );
    if ( bWFBT2Active )
        WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_T2, ORZ_WFBT2___PLOT_FAILED, TRUE );
    if ( bWFBT1Active )
        WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_FAILED, TRUE );
    if ( bWFBAccepted && !bWFBComplete )
        WR_SetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB___PLOT_FAILED, TRUE );

    // ** HARROWMONT ** //
    if ( bWFHT3Active )
        WR_SetPlotFlag( PLT_ORZPT_WFHARROW_T3, ORZ_WFHT3___PLOT_FAILED, TRUE );
    if ( bWFHDAActive )
        WR_SetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_FAILED, TRUE );
    if ( bWFHT2Active )
        WR_SetPlotFlag( PLT_ORZPT_WFHARROW_T2, ORZ_WFHT2___PLOT_FAILED, TRUE );
    if ( bWFHT1Active )
        WR_SetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_FAILED, TRUE );
    if ( bWFHAccepted && !bWFHComplete )
        WR_SetPlotFlag( PLT_ORZPT_WFHARROW, ORZ_WFH___PLOT_FAILED, TRUE );

    // ** ASSEMBLY ** //
    if ( WR_GetPlotFlag(PLT_ORZ340PT_ASSEMBLY,ORZ_ASSEMBLY___PLOT_ACTIVE) )
        WR_SetPlotFlag( PLT_ORZ340PT_ASSEMBLY, ORZ_ASSEMBLY___PLOT_FAILED, TRUE );

}

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
            case ORZ_ASSEMBLY___PLOT_01_ACCEPTED:
            {
                //Take an automatic screenshot... the player is entering Orzammar
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_ORZ_DEALT_WITH_IMREK, TRUE, TRUE);

                break;
            }

            case ORZ_MAIN___PLOT_02_ORZAMMAR_GATES_OPEN:
            {

                //--------------------------------------------------------------
                // PLOT:    Gates to Orzammar are now Open
                // ACTION:  Play Cutscene
                //--------------------------------------------------------------

                //disabled cutscene as it plays on guards last line - JP
                //CS_LoadCutsceneByIndex( CUTSCENE_ORZ_GATES_OPEN );

                object oDoor;

                oDoor = GetObjectByTag(ORZ_IP_ORZAMMAR_ENTRANCE);

                SetObjectInteractive(oDoor, TRUE);
                SetPlaceableState(oDoor, PLC_STATE_AREA_TRANSITION_UNLOCKED);
                UT_DoAreaTransition(ORZ_AR_HALL_OF_HEROES, ORZ_WP_HALL_ENTRANCE);

                WR_SetPlotFlag(sPlot, ORZ_MAIN___PLOT_03_PC_LEARNS_ABOUT_FACTIONS, TRUE, TRUE );

                break;

            }

            case ORZ_MAIN___PLOT_03_PC_LEARNS_ABOUT_FACTIONS:
            {

                //--------------------------------------------------------------
                // PLOT:    PC discovers city is screwed (after cutscene with
                //          guard fight)
                //--------------------------------------------------------------

                // Update Story-So-Far
                ORZ_UpdateStorySoFar(SSF_ORZ_01_ENTERED_ORZAMMAR);

                break;

            }


            case ORZ_MAIN___PLOT_04_BHELEN_CROWNED:
            {
                //--------------------------------------------------------------
                // PLOT:    PC has completed the Working for Bhelen plot,
                //          with Bhelen becoming the new king of Orzammar.
                // ACTION:  PC teleported to Royal Palace
                //--------------------------------------------------------------
                object      oBhelen         = UT_GetNearestCreatureByTag( oPC, ORZ_CR_BHELEN );
                object      oHarrow         = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HARROWMONT );
                object      oSteward        = UT_GetNearestCreatureByTag( oPC, ORZ_CR_STEWARD );
                object []   oBGuards        = GetNearestObjectByTag( oPC, ORZ_CR_BHELEN_GUARD,OBJECT_TYPE_CREATURE, 2 );
                object []   oHGuards        = GetNearestObjectByTag( oPC, ORZ_CR_HARROWMONT_GUARD,OBJECT_TYPE_CREATURE, 2 );
                object      oAssemblyDoor   = UT_GetNearestObjectByTag( oPC, ORZ_IP_ASSEMBLY_DOOR );

                // Unlock/Open the assembly door
                SetPlaceableState( oAssemblyDoor, PLC_STATE_DOOR_OPEN );

                // Remove Crown
                UT_RemoveItemFromInventory(ORZ_IM_KINGS_CROWN_R);

                // Now jump to the royal palace to finish this plot chain
                UT_DoAreaTransition(ORZ_AR_ROYAL_PALACE,ORZ_WP_ROYAL_PALACE);

                break;
            }

            case ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN:
            {
                //--------------------------------------------------------------
                // PLOT:    PC saw bhelen in the royal palace to completely
                //          close the Paragon Plot
                //--------------------------------------------------------------

                WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_T3, ORZ_WFBT3___PLOT_03_COMPLETE, TRUE );

                // Try to clean up any major Paragon plots
                _CleanupParagonPlots();

                // Global plot flag for finishing Paragon plot
                WR_SetPlotFlag(PLT_MNP000PT_MAIN_EVENTS,PLAYER_FINISHED_A_MAJOR_PLOT,TRUE, TRUE);

                // Update Story-So-Far
                ORZ_UpdateStorySoFar(SSF_ORZ_09A_DONE_BHELEN);

                // Update Bhelen and Harrowmont's codex.
                WR_SetPlotFlag( PLT_COD_CHA_BHELEN, COD_CHA_BHELEN_KING, TRUE );
                WR_SetPlotFlag( PLT_COD_CHA_HARROWMONT, COD_CHA_HARROWMONT_DIES, TRUE );

                // Army will include dwarves
                WR_SetPlotFlag( sPlot, ORZ_MAIN_ARMY_WILL_INCLUDE_DWARFS, TRUE );
                WR_SetPlotFlag(PLT_RANPT_GENERIC_ACTIONS,RAN_ACTIONS_ARMY_DWARVES,TRUE);

                // Grant achievement for siding with Bhelen
                WR_UnlockAchievement(ACH_DECISIVE_BHELEN_S_ALLY);

                UT_QuickMove("orz320cr_amb_m_1",ORZ_WP_PALACE_LINE_AMB_MOVETO);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_4a);

                //Qwinn: The Set here was previously unconditional, showing up in everyone's journal.
                // WR_SetPlotFlag(PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_FAILED, TRUE, TRUE);
                int bNobhunterAccepted = WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_01_ACCEPTED);
                int bBhelenPromised    = WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_02A_BHELEN_PROMISED);
                int bBhelenAgreed      = WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_02B_BHELEN_AGREED);

                if(bNobhunterAccepted && !(bBhelenPromised || bBhelenAgreed))
                {
                    WR_SetPlotFlag(PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_FAILED, TRUE, TRUE);
                }

                break;

            }

            case ORZ_MAIN___PLOT_04_HARROW_CROWNED:
            {
                //--------------------------------------------------------------
                // PLOT:    PC has completed the Paragon plot, with Harrowmont
                //          becoming the new king of Orzammar. Bhelen doesn't
                //          like this and revolts.
                //--------------------------------------------------------------

                WR_SetPlotFlag( PLT_ORZPT_WFHARROW_T3, ORZ_WFHT3___PLOT_03_COMPLETED, TRUE );

                // Try to clean up any major Paragon plots
                _CleanupParagonPlots();

                // Remove Crown
                UT_RemoveItemFromInventory(ORZ_IM_KINGS_CROWN_R);

                break;
            }

            case ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT:
            {
                //--------------------------------------------------------------
                // PLOT:    Bhelen is slain and harrowmont wraps up the
                //          paragon plot
                //--------------------------------------------------------------
                object      oAssemblyDoor   = UT_GetNearestObjectByTag( oPC, ORZ_IP_ASSEMBLY_DOOR );
                object      oHarrow         = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HARROWMONT );
                object      oSteward        = UT_GetNearestCreatureByTag( oPC, ORZ_CR_STEWARD );
                object []   oHGuards        = GetNearestObjectByTag( oPC, ORZ_CR_HARROWMONT_GUARD,OBJECT_TYPE_CREATURE, 2 );
                object []   arDeshyrs       = UT_GetTeam(ORZ_TEAM_ASSEMBLY_DESHYRS_HARROW);
                int         size, i;

                // Deshyrs return to their spots
                size = GetArraySize(arDeshyrs);
                for(i=0;i<size;i++)
                {
                    if (!IsDead(arDeshyrs[i]))
                    {
                        WR_ClearAllCommands(arDeshyrs[i]);
                        if (GetLocalInt(arDeshyrs[i],CREATURE_COUNTER_1)>=0)
                            Rubber_GoHome(arDeshyrs[i]);
                        else
                            UT_ExitDestroy(arDeshyrs[i]);
                    }
                }

                // Steward walks down to center of assembly
                WR_AddCommand(oSteward,CommandMoveToObject(UT_GetNearestObjectByTag(oPC,ORZ_WP_ASSEMBLY_CENTER),FALSE),TRUE);
                UT_Talk(oSteward,oSteward);

                // Unlock/Open the assembly door
                SetPlaceableState( oAssemblyDoor, PLC_STATE_DOOR_OPEN );

                // Global plot flag for finishing Paragon plot
                WR_SetPlotFlag( PLT_MNP000PT_MAIN_EVENTS, PLAYER_FINISHED_A_MAJOR_PLOT, TRUE, TRUE );

                // Update Story-So-Far
                ORZ_UpdateStorySoFar(SSF_ORZ_09B_DONE_HARROWMONT);

                // Update Harrowmont's codex
                WR_SetPlotFlag( PLT_COD_CHA_HARROWMONT, COD_CHA_HARROWMONT_KING, TRUE );
                WR_SetPlotFlag( PLT_COD_CHA_BHELEN, COD_CHA_BHELEN_KILLED, TRUE );

                // Army will include dwarves
                WR_SetPlotFlag( sPlot, ORZ_MAIN_ARMY_WILL_INCLUDE_DWARFS, TRUE);
                WR_SetPlotFlag(PLT_RANPT_GENERIC_ACTIONS,RAN_ACTIONS_ARMY_DWARVES,TRUE);

                // Grant achievement for siding with Harrowmont
                WR_UnlockAchievement(ACH_DECISIVE_HARROWMONT_S_ALLY);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_4b);

                // Harrowmont and his guards go to the throne room
                WR_SetObjectActive( oHarrow, FALSE );
                WR_SetObjectActive( oHGuards[0], FALSE );
                WR_SetObjectActive( oHGuards[1], FALSE );

                // Qwinn: The Set here was previously unconditional, showing up in everyone's journal.
                // WR_SetPlotFlag(PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_FAILED, TRUE, TRUE);
                int bNobhunterAccepted = WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_01_ACCEPTED);
                int bHarrowPromised    = WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_02C_HARROWMONT_PROMISED);
                int bHarrowAgreed      = WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_02D_HARROWMONT_AGREED);

                if(bNobhunterAccepted && !(bHarrowPromised || bHarrowAgreed))
                {
                    WR_SetPlotFlag(PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_FAILED, TRUE, TRUE);
                }


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
            case ORZ_MAIN___PLOT_DONE:
            {
                //--------------------------------------------------------------
                // COND:    PC has completed the Main Orzammar Questline and
                //          a new king has been crowned (ie: no rebellion)
                //--------------------------------------------------------------
                int         bKingBhelen = WR_GetPlotFlag( sPlot, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN );
                int         bKingHarrow = WR_GetPlotFlag( sPlot, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT );

                if ( bKingHarrow || bKingBhelen )
                    bResult = TRUE;

                break;
            }
            case ORZ_MAIN_LOST_BHELEN_PC_SUPPORTED:
            {
                //--------------------------------------------------------------
                // COND:    PC has completed the Main Orzammar Questline and
                //          a new king has been crowned (ie: no rebellion)
                //--------------------------------------------------------------
                int         bKingHarrow = WR_GetPlotFlag( sPlot, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT );
                int         bWFBhelen   = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB_PC_WORKING_FOR_BHELEN );

                if ( bKingHarrow && bWFBhelen )
                    bResult = TRUE;

                break;
            }
            case ORZ_MAIN_LOST_HARROWMONT_PC_SUPPORTED:
            {
                //--------------------------------------------------------------
                // COND:    PC has completed the Main Orzammar Questline and
                //          a new king has been crowned (ie: no rebellion)
                //--------------------------------------------------------------
                int         bKingBhelen = WR_GetPlotFlag( sPlot, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN );
                int         bWFHarrow   = WR_GetPlotFlag( PLT_ORZPT_WFHARROW, ORZ_WFH_PC_WORKING_FOR_HARROWMONT );

                if ( bKingBhelen && bWFHarrow )
                    bResult = TRUE;

                break;
            }
        }
    }

    return bResult;

}