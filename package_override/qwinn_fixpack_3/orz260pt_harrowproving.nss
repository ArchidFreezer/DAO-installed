//==============================================================================
/*

    Paragon of Her Kind
     -> Fighting for Harrowmont Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 8, 2007
//==============================================================================

#include "plt_orzpt_wfharrow"
#include "plt_orzpt_wfharrow_t1"
#include "plt_orzpt_wfbhelen"
#include "plt_orzpt_wfbhelen_t1"
#include "plt_orz260pt_harrowproving"
#include "plt_orz340pt_find_lord_dace"
#include "plt_orz260pt_proving"
#include "plt_orz260pt_baizyl"
#include "plt_orz260pt_gwiddon"
#include "plt_orzpt_main"
#include "plt_gen00pt_proving"
#include "plt_mnp000pt_autoss_main"

#include "orz_constants_h"
#include "orz_functions_h"
#include "proving_h"

#include "wrappers_h"
#include "utility_h"
#include "plot_h"

int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent = GetCurrentEvent();            // Contains input parameters
    int     nType   = GetEventType(evEvent);        // GET or SET call
    string  sPlot   = GetEventString(evEvent, 0);   // Plot GUID
    int     nFlag   = GetEventInteger(evEvent, 1);  // The bit flag # affected
    object  oOwner  = GetEventCreator(evEvent);     // Script plot table owner

    // Grab Player, Set Default return to FALSE
    object  oPC     = GetHero();
    object  oParty  = GetParty( oPC );
    int     bResult = FALSE;

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evEvent);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    // IMPORTANT:   The flag value on a SET event is set only AFTER this script
    //              finishes running!
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger(evEvent, 3);  // Old flag value
        int nNewValue   = GetEventInteger(evEvent, 2);  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {

            case ORZ_HPROVING_FIGHT_FOR_HARROWMONT:
            {
                WR_SetPlotFlag(PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_FAILED, TRUE, TRUE);
                break;
            }
            case ORZ_HPROVING_ROUND_4_BAIZYL:
            case ORZ_HPROVING_ROUND_4_GWIDDON:
            {

                //--------------------------------------------------------------
                // In these two fights, the Player must chose someone to be his
                // Second. This is where we actually put the second into play
                //--------------------------------------------------------------

                int         nFightID;   // Arena Fight ID (13 or 14)
                string      sPCSecond;  // Tag of the Second
                object      oPCSecond;

                //--------------------------------------------------------------

                nFightID  = Proving_GetCurrentFightId();
                sPCSecond = "";

                //--------------------------------------------------------------

                if (nFlag == ORZ_HPROVING_ROUND_4_BAIZYL)
                {
                    oPCSecond = UT_GetNearestCreatureByTag( oPC, ORZ_CR_BAIZYL );
                    if (GetTeamId(oPCSecond)==PROVING_TEAM_NON_COMBATANT)
                        oPCSecond = UT_GetNearestCreatureByTag(oPCSecond, ORZ_CR_BAIZYL);
                }
                else
                {
                    oPCSecond = UT_GetNearestCreatureByTag( oPC, ORZ_CR_GWIDDON );
                    if (GetTeamId(oPCSecond)==PROVING_TEAM_NON_COMBATANT)
                        oPCSecond = UT_GetNearestCreatureByTag(oPCSecond, ORZ_CR_GWIDDON);
                }

                // Activate party memeber and move to arena
                SetGroupId( oPCSecond, GROUP_FRIENDLY );
                WR_ClearAllCommands( oPCSecond );
                UT_LocalJump( oPCSecond, PROVING_WP_ALLY_ENTER_PREFIX+"00", TRUE );
                WR_SetObjectActive( oPCSecond, TRUE );

                break;

            }


            case ORZ_HPROVING_ROUND_5_BAIZYL_GWIDDON:
            {

                //--------------------------------------------------------------
                // In this fight, both Baizyl and Gwiddon join the PC to
                // battle for the title
                //--------------------------------------------------------------

                int         nFightID;
                object      oBaizyl;
                object      oGwiddon;

                //--------------------------------------------------------------

                nFightID = Proving_GetCurrentFightId();
                oBaizyl  = UT_GetNearestCreatureByTag( oPC, ORZ_CR_BAIZYL );
                oGwiddon = UT_GetNearestCreatureByTag( oPC, ORZ_CR_GWIDDON );

                //--------------------------------------------------------------

                if (GetTeamId(oBaizyl)==PROVING_TEAM_NON_COMBATANT)
                    oBaizyl = UT_GetNearestCreatureByTag(oBaizyl, ORZ_CR_BAIZYL);
                if (GetTeamId(oGwiddon)==PROVING_TEAM_NON_COMBATANT)
                    oGwiddon = UT_GetNearestCreatureByTag(oGwiddon, ORZ_CR_GWIDDON);

                SetGroupId( oBaizyl, GROUP_FRIENDLY );
                WR_ClearAllCommands( oBaizyl );
                UT_LocalJump( oBaizyl, PROVING_WP_ALLY_ENTER_PREFIX+"00", TRUE );
                WR_SetObjectActive( oBaizyl, TRUE );

                SetGroupId( oGwiddon, GROUP_FRIENDLY );
                WR_ClearAllCommands( oGwiddon );
                UT_LocalJump( oGwiddon, PROVING_WP_ALLY_ENTER_PREFIX+"01", TRUE );
                WR_SetObjectActive( oGwiddon, TRUE );

                break;

            }

            case ORZ_HPROVING___PLOT_02_COMPLETED_PROVING_LOST:
            case ORZ_HPROVING___PLOT_02_COMPLETED_PROVING_WON:
            {

                //--------------------------------------------------------------
                //  The player has won/lost the proving in Harrowmont's name.
                //--------------------------------------------------------------

                WR_SetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_02_RETURN, TRUE, TRUE );

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_2d);

                break;

            }

            case ORZ_HPROVING___PLOT_FAILED:
            {

                //--------------------------------------------------------------
                //  The player did not fight as harrowmont's champion
                //--------------------------------------------------------------

                WR_SetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_FAILED, TRUE, TRUE );
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


            case ORZ_HPROVING_BHELEN_LOSES_PC_FOUGHT_FOR_HARROWMONT:
            {

                //--------------------------------------------------------------
                // COND:    Either Harrowmont became the king or there is no
                //          king, and the PC fought for Harrowmont.
                //--------------------------------------------------------------

                int bKingHarrowmont;
                int bFightForHarrow;

                //--------------------------------------------------------------

                bKingHarrowmont = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT );
                bFightForHarrow = WR_GetPlotFlag( sPlot, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );

                //--------------------------------------------------------------

                if ( bKingHarrowmont && bFightForHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_HPROVING_PC_CAN_STILL_FIGHT_FOR_HARROWMONT:
            {

                //--------------------------------------------------------------
                // COND:    PC has accepted Harrowmont's first task and
                //          has not yet finished the proving or shown
                //          that he is fighting for Harrowmont.
                //--------------------------------------------------------------

                int         bFirstTask;
                int         bFightForHarrow;
                int         bProvingDone;
                int         bBhelenT1;

                //--------------------------------------------------------------

                bFirstTask      = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_ACTIVE );
                bFightForHarrow = WR_GetPlotFlag( PLT_ORZ260PT_HARROWPROVING, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );
                bProvingDone    = WR_GetPlotFlag( PLT_ORZ260PT_PROVING, ORZ_PROVING_DONE );
                bBhelenT1       = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_02_RETURN );

                //--------------------------------------------------------------

                if ( bFirstTask && !bProvingDone && !bBhelenT1 && !bFightForHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_HPROVING_PC_NOT_YET_HARROWS_CHAMP:
            {

                //--------------------------------------------------------------
                // COND:    Harrowmont's First task was accepted and PC has
                //          not fought for Harrowmont yet.
                //--------------------------------------------------------------

                int         bFirstTask;
                int         bFightForHarrow;

                //--------------------------------------------------------------

                bFirstTask      = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_ACTIVE );
                bFightForHarrow = WR_GetPlotFlag( sPlot, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );

                //--------------------------------------------------------------

                if ( bFirstTask && !bFightForHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_HPROVING_PC_WON_FOR_HARROWMONT:
            {

                //--------------------------------------------------------------
                // COND:    PC won the proving and did it for Harrowmont
                //--------------------------------------------------------------

                int         bPCWonProving;
                int         bFightForHarrow;

                //--------------------------------------------------------------

                bPCWonProving   = WR_GetPlotFlag( PLT_ORZ260PT_PROVING, ORZ_PROVING_PC_WON );
                bFightForHarrow = WR_GetPlotFlag( sPlot, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );

                //--------------------------------------------------------------

                if ( bPCWonProving && bFightForHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_HPROVING_PC_WON_ROUND_1_FOR_HARROWMONT:
            {

                //--------------------------------------------------------------
                // COND:    PC won round 1 and did it for Harrowmont
                //--------------------------------------------------------------

                int         bPCWonRoundOne;
                int         bFightForHarrow;

                //--------------------------------------------------------------

                bPCWonRoundOne  = WR_GetPlotFlag( PLT_ORZ260PT_PROVING, ORZ_PROVING_PC_WON_ROUND_1 );
                bFightForHarrow = WR_GetPlotFlag( sPlot, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );

                //--------------------------------------------------------------

                if ( bPCWonRoundOne && bFightForHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_HPROVING_PC_WON_ROUND_4_FOR_HARROWMONT:
            {

                //--------------------------------------------------------------
                // COND:    PC won round 4 and did it for Harrowmont
                //--------------------------------------------------------------

                int         bPCWonRoundFour;
                int         bFightForHarrow;

                //--------------------------------------------------------------

                bPCWonRoundFour = WR_GetPlotFlag( PLT_ORZ260PT_PROVING, ORZ_PROVING_PC_WON_ROUND_4 );
                bFightForHarrow = WR_GetPlotFlag( sPlot, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );

                //--------------------------------------------------------------

                if ( bPCWonRoundFour && bFightForHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_HPROVING_PC_WON_ROUND_4_NOT_FOR_HARROWMONT:
            {

                //--------------------------------------------------------------
                // COND:    PC won round four and didn't do it for Harrowmont
                //--------------------------------------------------------------

                int         bPCWonRoundFour;
                int         bFightForHarrow;

                //--------------------------------------------------------------

                bPCWonRoundFour = WR_GetPlotFlag( PLT_ORZ260PT_PROVING, ORZ_PROVING_PC_WON_ROUND_4 );
                bFightForHarrow = WR_GetPlotFlag( sPlot, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );

                //--------------------------------------------------------------

                if ( bPCWonRoundFour && !bFightForHarrow )
                    bResult = TRUE;

                break;

            }


            case ORZ_HPROVING_PC_WON_ROUND_3_NOT_FOR_HARROWMONT:
            {

                //--------------------------------------------------------------
                // COND:    PC won round three and didn't do it for Harrowmont
                //--------------------------------------------------------------

                int         bPCWonRoundThree;
                int         bFightForHarrow;

                //--------------------------------------------------------------

                bPCWonRoundThree = WR_GetPlotFlag( PLT_ORZ260PT_PROVING, ORZ_PROVING_PC_WON_ROUND_3 );
                bFightForHarrow  = WR_GetPlotFlag( sPlot, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );

                //--------------------------------------------------------------

                if ( bPCWonRoundThree && !bFightForHarrow )
                    bResult = TRUE;

                break;

            }

            case ORZ_HPROVING_PC_HASNT_FOUGHT_HANASHAN_YET:
            {
                //--------------------------------------------------------------
                // COND:    PC hasn't fought Hanashan yet, but will do so
                //          eventually.
                //--------------------------------------------------------------
                int bFoughtHanashan = WR_GetPlotFlag(PLT_GEN00PT_PROVING,PROVING_FIGHT_012_ORZ_HANASHAN);
                int bFightForHarrow = WR_GetPlotFlag( sPlot, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );
                // Qwinn:  This is actually checking Bhelen's ORZPT_WHBHELEN_PC_HEARD_EVIDENCE flag
                // int bTask1Failed = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFHT1___PLOT_FAILED );
                int bTask1Failed = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_FAILED );

                if (!bFoughtHanashan && bFightForHarrow && !bTask1Failed)
                    bResult = TRUE;

                break;
            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}