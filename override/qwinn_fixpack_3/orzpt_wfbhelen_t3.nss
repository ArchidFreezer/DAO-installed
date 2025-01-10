//==============================================================================
/*

    Paragon of Her Kind
     -> Working For Bhelen (Task 3) Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: January 15, 2008
//==============================================================================

#include "plt_orzpt_wfbhelen"
#include "plt_orzpt_wfbhelen_t3"
#include "plt_orzpt_wfharrow_t3"
#include "plt_orzpt_anvil"
#include "plt_mnp000pt_autoss_main"

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


            case ORZ_WFBT3___PLOT_01_ACCEPTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has accepted Bhelen's Third Task
                //--------------------------------------------------------------

                object      oDulin, oVartag;

                int         bHarrowT3;
                int         bAnvilAccepted;

                //--------------------------------------------------------------

                oDulin  = GetObjectByTag( ORZ_CR_DULIN );
                oVartag = GetObjectByTag( ORZ_CR_VARTAG );

                bAnvilAccepted = WR_GetPlotFlag( PLT_ORZPT_ANVIL, ORZ_ANVIL___PLOT_01_ACCEPTED );
                bHarrowT3      = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T3, ORZ_WFHT3___PLOT_01_ACCEPTED );

                //--------------------------------------------------------------

                // Accept Anvil of the Void quest to look for Branka
                if ( !bAnvilAccepted )
                    WR_SetPlotFlag( PLT_ORZPT_ANVIL, ORZ_ANVIL___PLOT_01_ACCEPTED, TRUE, TRUE ) ;

                // Update Story-So-Far
                if ( bHarrowT3 )
                    ORZ_UpdateStorySoFar(SSF_ORZ_04C_BOTH_TASK_3);
                else
                    ORZ_UpdateStorySoFar(SSF_ORZ_04A_BHELEN_TASK_3);

                SetPlotGiver( oDulin, FALSE );
                SetPlotGiver( oVartag, FALSE );

                break;

            }

            case ORZ_WFBT3___PLOT_02_RETURN:
            {
                //--------------------------------------------------------------
                // PLOT:    PC can return Harrowmonts's Second Task
                //--------------------------------------------------------------
                int         bDAPlot = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHT3___PLOT_ACTIVE );

                if ( bDAPlot )
                    WR_SetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_FAILED, TRUE );

                break;
            }

            case ORZ_WFBT3_BHELEN_ASKED_ABOUT_BRANKA:
            {
                //Take an autoscreenshot
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_ORZ_BHELEN_WANTS_BRANKA, TRUE, TRUE);
                break;
            }
            case ORZ_WFBT3___PLOT_03_COMPLETE:
            {
                //percentage complete plot tracking -- CUT
                //ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_8a);

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


            case ORZ_WFBT3___PLOT_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    Plot is Active
                //--------------------------------------------------------------

                int         bPlotAccepted;
                int         bPlotReturn;
                int         bPlotFailed;

                //--------------------------------------------------------------

                bPlotAccepted = WR_GetPlotFlag( sPlot, ORZ_WFBT3___PLOT_01_ACCEPTED );
                // Qwinn: This used to check PLOT_02_RETURN, which will always be set if quest is active, failing to close entries
                // This syncs it up with the flags checked in the mirror Harrowmont script orzpt_wfharrow_t3.nss
                // bPlotReturn   = WR_GetPlotFlag( sPlot, ORZ_WFBT3___PLOT_02_RETURN );
                bPlotReturn   = WR_GetPlotFlag( sPlot, ORZ_WFBT3___PLOT_03_COMPLETE );
                bPlotFailed   = WR_GetPlotFlag( sPlot, ORZ_WFBT3___PLOT_FAILED );

                //--------------------------------------------------------------

                if ( bPlotAccepted && !(bPlotReturn||bPlotFailed) )
                    bResult = TRUE;

                break;

            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}