//==============================================================================
/*

    Paragon of Her Kind
     -> Working For Bhelen (Double Agent) Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: January 15, 2008
//==============================================================================

#include "plt_orzpt_wfbhelen"
#include "plt_orzpt_wfbhelen_da"
#include "plt_orzpt_carta"

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


            case ORZ_WFBDA___PLOT_01_ACCEPTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has accepted Bhelens's Double Agent Task
                //--------------------------------------------------------------

                int         bCartaAccepted;
                int         bPCHasPapers;

                //--------------------------------------------------------------

                bCartaAccepted = WR_GetPlotFlag( PLT_ORZPT_CARTA, ORZ_CARTA___PLOT_01_ACCEPTED );
                bPCHasPapers   = UT_CountItemInInventory( ORZ_IM_PLANTED_PAPERS_R );

                //--------------------------------------------------------------

                // If the player does not have the papers to plant yet,
                // place them in his inventory
                if ( !bPCHasPapers )
                    UT_AddItemToInventory( ORZ_IM_PLANTED_PAPERS_R );

                // If the player has not already accepted the carta quest from
                // Harrowmont, accepted it now.
                if ( !bCartaAccepted )
                    WR_SetPlotFlag( PLT_ORZPT_CARTA, ORZ_CARTA___PLOT_01_ACCEPTED, TRUE, TRUE );

                // Update Story-So-Far
                ORZ_UpdateStorySoFar(SSF_ORZ_03C_BHELEN_TASK_DA);

                break;

            }


            case ORZ_WFBDA___PLOT_03_PAPERS_PLANTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has planted the papers on Jarvia's body
                // ACTION:  Remove papers from inventory
                //--------------------------------------------------------------

                object      oJarvia;

                //--------------------------------------------------------------

                oJarvia = UT_GetNearestCreatureByTag( oPC, ORZ_CR_JARVIA );

                //--------------------------------------------------------------

                // Remove the papers from the players Inventory that he
                // just planted
                UT_RemoveItemFromInventory( ORZ_IM_PLANTED_PAPERS_R );
                KillCreature( oJarvia );

                break;

            }

            case ORZ_WFBDA___PLOT_04_COMPLETED:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_22);

                break;
            }

            case ORZ_WFBDA_MISSED_CHANCE:
            {
                if (GetTag(GetArea(oPC))==ORZ_AR_PROVING)
                    UT_ExitDestroy(GetObjectByTag(ORZ_CR_VARTAG));
                break;
            }
            
            // Qwinn added:
            case ORZ_WFBDA___PLOT_FAILED:
            {
                UT_RemoveItemFromInventory( ORZ_IM_PLANTED_PAPERS_R );
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


            case ORZ_WFBDA___PLOT_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    Plot is Active
                //--------------------------------------------------------------

                int         bPlotAccepted;
                int         bPlotReturn;
                int         bPlotFailed;
                int         bPrePlot;
                int         bPrePlotReturn;

                //--------------------------------------------------------------

                bPlotAccepted = WR_GetPlotFlag( sPlot, ORZ_WFBDA___PLOT_01_ACCEPTED );
                bPlotReturn   = WR_GetPlotFlag( sPlot, ORZ_WFBDA___PLOT_03_PAPERS_PLANTED );
                bPlotFailed   = WR_GetPlotFlag( sPlot, ORZ_WFBDA___PLOT_FAILED );
                bPrePlot      = WR_GetPlotFlag( sPlot, ORZ_WFBDA___PLOT_PRE_PLOT_01_TT_HARROW );
                bPrePlotReturn= WR_GetPlotFlag( sPlot, ORZ_WFBDA___PLOT_PRE_PLOT_02_RETURN_TO_VARTAG );

                //--------------------------------------------------------------

                if ( (bPlotAccepted||bPrePlot||bPrePlotReturn) && !(bPlotReturn||bPlotFailed) )
                    bResult = TRUE;

                break;

            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}