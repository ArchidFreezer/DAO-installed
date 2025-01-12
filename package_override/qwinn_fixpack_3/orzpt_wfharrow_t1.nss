//==============================================================================
/*

    Paragon of Her Kind
     -> Working For Harrowmont (Task 1) Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: March 20, 2008
//==============================================================================

#include "plt_orzpt_wfharrow_t1"
#include "plt_orzpt_wfbhelen_t1"
#include "plt_orz260pt_baizyl"
#include "plt_orz260pt_gwiddon"
#include "plt_orz260pt_harrowproving"

#include "orz_constants_h"
#include "orz_functions_h"

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
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger(evEvent, 3);  // Old flag value
        int nNewValue   = GetEventInteger(evEvent, 2);  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {


            case ORZ_WFHT1___PLOT_01_ACCEPTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has accepted Bhelen's first task to find Lord
                //          Helmi and Lord Dace
                //--------------------------------------------------------------

                int         bBhelenT1;
                object      oDulin, oLoilinar, oOghren;

                //--------------------------------------------------------------

                bBhelenT1 = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_ACTIVE );
                oDulin    = UT_GetNearestCreatureByTag( oPC, ORZ_CR_DULIN );
                oLoilinar = UT_GetNearestCreatureByTag( oPC, ORZ_CR_LOILINAR );
                oOghren   = UT_GetNearestCreatureByTag( oPC, GEN_FL_OGHREN );

                //--------------------------------------------------------------

                // Add the sub-plots to the Journal
                WR_SetPlotFlag( PLT_ORZ260PT_BAIZYL,        ORZ_BAIZYL___PLOT_01_ACCEPTED, TRUE, TRUE );
                WR_SetPlotFlag( PLT_ORZ260PT_GWIDDON,       ORZ_GWIDDON___PLOT_01_ACCEPTED, TRUE, TRUE );
                WR_SetPlotFlag( PLT_ORZ260PT_HARROWPROVING, ORZ_HPROVING___PLOT_01_ACCEPTED, TRUE, TRUE );

                // Dulin Leaves
                WR_SetObjectActive( oDulin, FALSE );

                // If the player is currently in the noble quarter activate Liolinar
                if ( GetTag(GetArea(oPC)) == ORZ_AR_NOBLES_QUARTER )
                {
                    WR_SetObjectActive( oLoilinar, TRUE );
                    WR_SetObjectActive( oOghren, TRUE );
                }

               // Update Story-So-Far
                if ( bBhelenT1 )
                    ORZ_UpdateStorySoFar(SSF_ORZ_02C_BOTH_TASK_1);
                else
                    ORZ_UpdateStorySoFar(SSF_ORZ_02B_HARROWMONT_TASK_1);

                break;

            }


            case ORZ_WFHT1___PLOT_DELAYED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has delayed the First Task of Harrowmont's. He
                //          is no longer working for harrowmont
                //--------------------------------------------------------------

                object      oDulin;

                //--------------------------------------------------------------

                oDulin = UT_GetNearestCreatureByTag( oPC, ORZ_CR_DULIN );

                //--------------------------------------------------------------

                // Remove the sub-plots to the Journal
                WR_SetPlotFlag( PLT_ORZ260PT_BAIZYL,        ORZ_BAIZYL___PLOT_01_ACCEPTED, FALSE );
                WR_SetPlotFlag( PLT_ORZ260PT_GWIDDON,       ORZ_GWIDDON___PLOT_01_ACCEPTED, FALSE );
                WR_SetPlotFlag( PLT_ORZ260PT_HARROWPROVING, ORZ_HPROVING___PLOT_01_ACCEPTED, FALSE );

                break;

            }


            case ORZ_WFHT1___PLOT_02_RETURN:
            {

                //--------------------------------------------------------------
                // PLOT: PC has won the proving.
                //--------------------------------------------------------------

                if ( WR_GetPlotFlag(PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_01_ACCEPTED) )
                    WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_FAILED, TRUE, TRUE );
                // Qwinn added:
                break;
            }

            case ORZ_WFHT1___PLOT_03_COMPLETED:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_2a);

                break;
            }
                            
            // Qwinn:  This entire case was missing.
            case ORZ_WFHT1___PLOT_FAILED:
            {
                int bBayzilActive = WR_GetPlotFlag(PLT_ORZ260PT_BAIZYL, ORZ_BAIZYL___PLOT_ACTIVE);
                int bGwiddonActive = WR_GetPlotFlag(PLT_ORZ260PT_GWIDDON, ORZ_GWIDDON___PLOT_ACTIVE);

                if (bBayzilActive)
                {
                   WR_SetPlotFlag(PLT_ORZ260PT_BAIZYL, ORZ_BAIZYL___PLOT_FAILED, TRUE, TRUE);
                }
                if (bGwiddonActive)
                {
                   WR_SetPlotFlag(PLT_ORZ260PT_GWIDDON, ORZ_GWIDDON___PLOT_FAILED, TRUE, TRUE);
                }
                WR_SetPlotFlag( PLT_ORZ260PT_HARROWPROVING,ORZ_HPROVING___PLOT_FAILED, TRUE, FALSE);
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


            case ORZ_WFHT1___PLOT_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    Plot is Active
                //--------------------------------------------------------------

                int         bPlotAccepted;
                int         bPlotReturn;
                int         bPlotFailed;

                //--------------------------------------------------------------

                bPlotAccepted  = WR_GetPlotFlag( sPlot, ORZ_WFHT1___PLOT_01_ACCEPTED );
                bPlotReturn    = WR_GetPlotFlag( sPlot, ORZ_WFHT1___PLOT_03_COMPLETED );
                bPlotFailed    = WR_GetPlotFlag( sPlot, ORZ_WFHT1___PLOT_FAILED );

                //--------------------------------------------------------------

                if ( bPlotAccepted && !(bPlotReturn||bPlotFailed) )
                    bResult = TRUE;

                break;

            }


            case ORZ_WFHT1_BAIZYL_AND_GWIDDON_COMPLETE:
            {

                //--------------------------------------------------------------
                // COND:    PC has convinced both Baizyl and Gwiddon to fight
                //          in the name of Harrowmont
                //--------------------------------------------------------------

                int         bGwiddonComplete;
                int         bBaizylComplete;

                //--------------------------------------------------------------

                bGwiddonComplete = WR_GetPlotFlag( PLT_ORZ260PT_GWIDDON, ORZ_GWIDDON___PLOT_02_COMPLETED );
                bBaizylComplete  = WR_GetPlotFlag( PLT_ORZ260PT_BAIZYL, ORZ_BAIZYL___PLOT_04_COMPLETED );

                //--------------------------------------------------------------

                if ( bGwiddonComplete && bBaizylComplete )
                    bResult = TRUE;

                break;

            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}