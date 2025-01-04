//==============================================================================
/*

    Paragon of Her Kind
     -> Filda Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: March 1, 2007
//==============================================================================

#include "plt_orz200pt_filda"
#include "plt_orzpt_main"

#include "orz_constants_h"
#include "orz_functions_h"

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


            case ORZ_FILDA___PLOT_01_ACCEPTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC accepted quest
                //--------------------------------------------------------------

                object      oFilda;

                //--------------------------------------------------------------

                oFilda = UT_GetNearestCreatureByTag( oPC, ORZ_CR_FILDA );

                //--------------------------------------------------------------

                SetPlotGiver( oFilda, FALSE );

                break;

            }

            // Qwinn:  This used to do the same as COMPLETED_RUCK_DEAD, but Filda
            // was supposed to leave for the deep roads, instead she'd just stand
            // there praying toward the street.
            case ORZ_FILDA___PLOT_03_COMPLETED_FILDA_GOES_TO_DEEPROADS:
            {
               object oFilda = UT_GetNearestCreatureByTag( oPC, ORZ_CR_FILDA );
               SetPlotGiver( oFilda, FALSE );
               UT_Talk (oFilda, oPC);
               UT_ExitDestroy (oFilda, TRUE, "mn_exit_deep_roads");
               break;
            }



            case ORZ_FILDA___PLOT_03_COMPLETED_RUCK_DEAD:
            {

                //--------------------------------------------------------------
                // PLOT:
                //--------------------------------------------------------------

                object      oFilda;

                //--------------------------------------------------------------

                oFilda = UT_GetNearestCreatureByTag( oPC, ORZ_CR_FILDA );

                //--------------------------------------------------------------

                SetPlotGiver( oFilda, FALSE );

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_10a);
/*
                if(nFlag == ORZ_FILDA___PLOT_03_COMPLETED_FILDA_GOES_TO_DEEPROADS)
                {
                    //percentage complete plot tracking
                    ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_10a);
                }
                else
                {
                    //percentage complete plot tracking
                    ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_10b);
                }
*/
                break;

            }


            case ORZ_FILDA___PLOT_FAILED_KILLED_RUCK:
            case ORZ_FILDA___PLOT_FAILED_DID_NOT_FIND_RUCK:
            {

                //--------------------------------------------------------------
                // PLOT:
                //--------------------------------------------------------------

                object      oFilda;

                //--------------------------------------------------------------

                oFilda = UT_GetNearestCreatureByTag( oPC, ORZ_CR_FILDA );

                //--------------------------------------------------------------

                SetPlotGiver( oFilda, FALSE );

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


            case ORZ_FILDA___PLOT_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    Quest accepted, but not Done
                //--------------------------------------------------------------

                int         bAccepted;
                int         bCompleted_1;
                int         bCompleted_2;
                int         bFailed_1;
                int         bFailed_2;

                //--------------------------------------------------------------

                bAccepted    = WR_GetPlotFlag( sPlot, ORZ_FILDA___PLOT_01_ACCEPTED );
                bCompleted_1 = WR_GetPlotFlag( sPlot, ORZ_FILDA___PLOT_03_COMPLETED_FILDA_GOES_TO_DEEPROADS );
                bCompleted_2 = WR_GetPlotFlag( sPlot, ORZ_FILDA___PLOT_03_COMPLETED_RUCK_DEAD );
                bFailed_1    = WR_GetPlotFlag( sPlot, ORZ_FILDA___PLOT_FAILED_DID_NOT_FIND_RUCK );
                bFailed_2    = WR_GetPlotFlag( sPlot, ORZ_FILDA___PLOT_FAILED_KILLED_RUCK );

                //--------------------------------------------------------------

                if ( bAccepted && !(bCompleted_1||bCompleted_2||bFailed_1||bFailed_2) )
                    bResult = TRUE;

                break;

            }


            case ORZ_FILDA_IS_IN_COMMONS:
            {

                //--------------------------------------------------------------
                // COND:    Quest accepted, but not Done
                //--------------------------------------------------------------

                // Qwinn:  This checked for the main Paragon plot to be done, which makes little sense
                // It should check if HER plot is done.

                //--------------------------------------------------------------

                int bPlotAccepted = WR_GetPlotFlag( sPlot, ORZ_FILDA___PLOT_01_ACCEPTED );
                int bFildaPlotActive  = WR_GetPlotFlag( sPlot, ORZ_FILDA___PLOT_ACTIVE );

                //--------------------------------------------------------------

                if ( (!bPlotAccepted) || bFildaPlotActive )
                    bResult = TRUE;

                break;

            }


        }
    }

    return bResult;

}