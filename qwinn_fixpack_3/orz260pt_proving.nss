//==============================================================================
/*

    Paragon of Her Kind
     -> Proving Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 9, 2007
//==============================================================================

#include "plt_orz260pt_proving"
#include "plt_orz260pt_harrowproving"
#include "plt_orz260pt_baizyl"
#include "plt_orz260pt_gwiddon"
#include "plt_orzpt_wfharrow_t1"
#include "plt_orzpt_wfbhelen_t1"

#include "proving_h"
#include "orz_constants_h"
#include "orz_functions_h"

#include "wrappers_h"
#include "utility_h"
#include "plot_h"
#include "proving_h"

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


            case ORZ_PROVING_STARTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC is now in the Proving, any pre-proving stuff
                //          should be nixxed if it has not been done yet.
                //--------------------------------------------------------------

                int         bBaizylActive;
                int         bGwiddonActive;

                //--------------------------------------------------------------

                bBaizylActive   = WR_GetPlotFlag( PLT_ORZ260PT_BAIZYL, ORZ_BAIZYL___PLOT_ACTIVE, TRUE );
                bGwiddonActive  = WR_GetPlotFlag( PLT_ORZ260PT_GWIDDON, ORZ_GWIDDON___PLOT_ACTIVE, TRUE );

                //--------------------------------------------------------------

                if ( bBaizylActive )
                    WR_SetPlotFlag( PLT_ORZ260PT_BAIZYL, ORZ_BAIZYL___PLOT_FAILED, TRUE, TRUE );

                if ( bGwiddonActive )
                    WR_SetPlotFlag( PLT_ORZ260PT_GWIDDON, ORZ_GWIDDON___PLOT_FAILED, TRUE, TRUE );
                    
                // Qwinn added to move Myaja and Lucjan back to their original spots, otherwise
                // their later dialogue stages teleport them back there anyway.
                if (WR_GetPlotFlag( PLT_ORZ260PT_BAIZYL, ORZ_BAIZYL__EVENT_TWINS_LEAVE_CHAMBER))
                {
                    object oMyaja = UT_GetNearestCreatureByTag( oPC, ORZ_CR_MARJA );
                    object oLucjan = UT_GetNearestCreatureByTag( oPC, ORZ_CR_LUCJAN );
                    UT_LocalJump ( oMyaja, ORZ_WP_MYAJA_HOME, TRUE, TRUE, FALSE, FALSE );
                    UT_LocalJump ( oLucjan, ORZ_WP_LUCJAN_HOME, TRUE, TRUE, FALSE, FALSE );
                }
                    

                break;

            }


            case ORZ_PROVING_DELAY:
            {

                //--------------------------------------------------------------
                // PLOT:    PC is now in the Proving, any pre-proving stuff
                //          should be nixxed if it has not been done yet.
                //--------------------------------------------------------------

                object      oProvMaster;

                //--------------------------------------------------------------

                oProvMaster = UT_GetNearestCreatureByTag(oPC,ORZ_CR_PROVMASTER);

                //--------------------------------------------------------------

                // Move the Proving Master back outside the arena
                //WR_ClearAllCommands(oProvMaster);
                UT_LocalJump(oProvMaster, ORZ_WP_PROVMASTER_1,TRUE);

                break;

            }


            case ORZ_PROVING_PC_LOST:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has lost a match in the Proving
                //--------------------------------------------------------------

                int         bHarrowTaskOne;
                int         bBhelenTaskOne;
                int         bFightForHarrow;

                //--------------------------------------------------------------

                bHarrowTaskOne  = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_ACTIVE );
                // Qwinn:  This can never be true, because declaring for Harrowmont immediately fails his quest
                // Setting to ACCEPTED his quest instead.
                // bBhelenTaskOne  = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_ACTIVE );
                bBhelenTaskOne  = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_01_ACCEPTED );
                bFightForHarrow = WR_GetPlotFlag( PLT_ORZ260PT_HARROWPROVING, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );

                //--------------------------------------------------------------

                // If we were on Harrowmont's First Task, update journal
                if ( bHarrowTaskOne )
                {
                    if ( bFightForHarrow )
                    {
                        WR_SetPlotFlag( PLT_ORZ260PT_HARROWPROVING, ORZ_HPROVING___PLOT_02_COMPLETED_PROVING_LOST, TRUE, TRUE );
                        // If we were working for Bhelen, Vartag really doesn't like this
                        // he spawns at the proving entrance
                        if ( bBhelenTaskOne )
                        {
                            WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1_BETRAYAL_DISCOVERED_AT_PROVING, TRUE, TRUE );
                        }
                    }
                    else
                    {
                        WR_SetPlotFlag( PLT_ORZ260PT_HARROWPROVING, ORZ_HPROVING___PLOT_FAILED, TRUE, TRUE );
                    }
                }

                // 09.18.08 -- Roshen should dissappear whenthe proving ends
                object oRoshen = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ROSHEN );

                WR_SetObjectActive( oRoshen, FALSE );
                SetTeamId( oRoshen, -1 ); // To avoid being re-activated.

                break;

            }


            case ORZ_PROVING_PC_WON:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has won the entire Proving
                // ACTION:  Setup post-match creatures, maybe a celebration?
                //--------------------------------------------------------------

                int         bHarrowTaskOne;
                int         bBhelenTaskOne;
                int         bFightForHarrow;

                //--------------------------------------------------------------

                bHarrowTaskOne  = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_ACTIVE );
               //  bBhelenTaskOne  = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_ACTIVE );
               // Qwinn:  This can never be true, because declaring for Harrowmont immediately fails his quest
               // Setting to ACCEPTED his quest instead.
               // bBhelenTaskOne  = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_ACTIVE );
               bBhelenTaskOne  = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_01_ACCEPTED );
               bFightForHarrow = WR_GetPlotFlag( PLT_ORZ260PT_HARROWPROVING, ORZ_HPROVING_FIGHT_FOR_HARROWMONT );

                //--------------------------------------------------------------

                // If we were on Harrowmont's First Task, update journal
                if (bHarrowTaskOne)
                {

                    // The PC won the Proving for Harrowmont
                    if (bFightForHarrow)
                    {
                        WR_SetPlotFlag( PLT_ORZ260PT_HARROWPROVING, ORZ_HPROVING___PLOT_02_COMPLETED_PROVING_WON, TRUE, TRUE );
                        // If we were working for Bhelen, Vartag really doesn't like this
                        // he spawns at the proving entrance
                        if ( bBhelenTaskOne )
                        {
                            WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1_BETRAYAL_DISCOVERED_AT_PROVING, TRUE, TRUE );
                        }
                    }
                    // The PC did not win the Proving in Harrowmont's name
                    else
                    {
                        WR_SetPlotFlag( PLT_ORZ260PT_HARROWPROVING, ORZ_HPROVING___PLOT_FAILED, TRUE, TRUE );

                    }
                }

                // 09.18.08 -- Roshen should dissappear whenthe proving ends
                object oRoshen = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ROSHEN );

                WR_SetObjectActive( oRoshen, FALSE );
                SetTeamId( oRoshen, -1 ); // To avoid being re-activated.

                break;

            }


            case ORZ_PROVING_ROUND_4_ALISTAIR:
            case ORZ_PROVING_ROUND_4_DOG:
            case ORZ_PROVING_ROUND_4_LELIANA:
            case ORZ_PROVING_ROUND_4_MORRIGAN:
            case ORZ_PROVING_ROUND_4_STEN:
            case ORZ_PROVING_ROUND_4_WYNNE:
            case ORZ_PROVING_ROUND_4_ZEVRAN:
            case ORZ_PROVING_ROUND_4_LOGHAIN:
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

                switch(nFlag)
                {
                    case ORZ_PROVING_ROUND_4_ALISTAIR:  sPCSecond = GEN_FL_ALISTAIR;    break;
                    case ORZ_PROVING_ROUND_4_DOG:       sPCSecond = GEN_FL_DOG;         break;
                    case ORZ_PROVING_ROUND_4_LELIANA:   sPCSecond = GEN_FL_LELIANA;     break;
                    case ORZ_PROVING_ROUND_4_MORRIGAN:  sPCSecond = GEN_FL_MORRIGAN;    break;
                    case ORZ_PROVING_ROUND_4_STEN:      sPCSecond = GEN_FL_STEN;        break;
                    case ORZ_PROVING_ROUND_4_WYNNE:     sPCSecond = GEN_FL_WYNNE;       break;
                    case ORZ_PROVING_ROUND_4_ZEVRAN:    sPCSecond = GEN_FL_ZEVRAN;      break;
                    case ORZ_PROVING_ROUND_4_LOGHAIN:   sPCSecond = GEN_FL_LOGHAIN;     break;
                }

                oPCSecond = UT_GetNearestCreatureByTag( oPC, sPCSecond );

                // Activate party memeber and move to arena
                WR_SetFollowerState( oPCSecond, FOLLOWER_STATE_ACTIVE );
                WR_ClearAllCommands( oPCSecond );
                UT_LocalJump( oPCSecond, PROVING_WP_ALLY_ENTER_PREFIX+"00", TRUE );
                WR_SetObjectActive( oPCSecond, TRUE );

                break;

            }


            case ORZ_PROVING_ROUND_5_PARTY:
            {

                //--------------------------------------------------------------
                // In this fight, the players entire party is used in the
                // arena.
                //--------------------------------------------------------------

                int         nFightID;
                int         nIndex;
                object[]    arParty;

                //--------------------------------------------------------------

                nFightID = Proving_GetCurrentFightId();

                //--------------------------------------------------------------

                UT_PartyRestore();
                arParty  = GetPartyList( oPC );
                for ( nIndex=0; nIndex<GetArraySize(arParty); nIndex++ )
                    UT_LocalJump( arParty[nIndex], PROVING_WP_ALLY_ENTER_PREFIX+"0"+ToString(nIndex), TRUE );

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


            case ORZ_PROVING_DONE:
            {

                //--------------------------------------------------------------
                // COND:    PC has either Won or Lost the Proving
                //--------------------------------------------------------------

                int         bWonProving;
                int         bLostProving;

                //--------------------------------------------------------------

                bWonProving  = WR_GetPlotFlag( sPlot, ORZ_PROVING_PC_WON );
                bLostProving = WR_GetPlotFlag( sPlot, ORZ_PROVING_PC_LOST );

                //--------------------------------------------------------------

                if ( bWonProving || bLostProving )
                    bResult = TRUE;

                break;

            }


            case ORZ_PROVING_PC_IS_FIGHTER:
            {

                //--------------------------------------------------------------
                // COND:    PC is a Fighter in the Proving if he joined the
                //          Proving (is on the schedule.)
                //--------------------------------------------------------------

                int         bProvingJoined;

                //--------------------------------------------------------------

                bProvingJoined = WR_GetPlotFlag( sPlot, ORZ_PROVING_PC_IN_SCHEDULE );

                //--------------------------------------------------------------

                if ( bProvingJoined )
                    bResult = TRUE;

                break;

            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}