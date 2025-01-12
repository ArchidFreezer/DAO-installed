//==============================================================================
/*

    Paragon of Her Kind
     -> Working For Harrowmont (Task 2) Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: March 20, 2008
//==============================================================================

#include "plt_orzpt_carta"
#include "plt_orzpt_wfbhelen"
#include "plt_orzpt_wfbhelen_da"
#include "plt_orzpt_wfharrow_t2"

#include "orz_constants_h"
#include "orz_functions_h"

#include "utility_h"
#include "plot_h"

// Qwinn added:
#include "plt_orzpt_wfharrow"

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


            case ORZ_WFHT2___PLOT_01_ACCEPTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has accepted Bhelen's first task to find Lord
                //          Helmi and Lord Dace
                //--------------------------------------------------------------

                int         bCartaAccepted;
                int         bDAPrePlot_1;
                int         bDAPrePlot_2;

                //--------------------------------------------------------------

                bCartaAccepted = WR_GetPlotFlag( PLT_ORZPT_CARTA, ORZ_CARTA___PLOT_01_ACCEPTED );
                bDAPrePlot_1   = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_PRE_PLOT_01_TT_HARROW );
                bDAPrePlot_2   = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_PRE_PLOT_02_RETURN_TO_VARTAG );

                //--------------------------------------------------------------

                if ( bDAPrePlot_1 && !bDAPrePlot_2 )
                    WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_PRE_PLOT_02_RETURN_TO_VARTAG, TRUE );

                if ( !bCartaAccepted )
                    WR_SetPlotFlag( PLT_ORZPT_CARTA, ORZ_CARTA___PLOT_01_ACCEPTED, TRUE, TRUE );

                // Update Story-So-Far
                ORZ_UpdateStorySoFar(SSF_ORZ_03B_HARROWMONT_TASK_2);

                break;

            }

            case ORZ_WFHT2___PLOT_02_RETURN:
            {
                //--------------------------------------------------------------
                // PLOT:    PC can return Harrowmonts's Second Task
                //--------------------------------------------------------------
                int         bDAPrePlot_1 = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_PRE_PLOT_01_TT_HARROW );
                int         bDAPrePlot_2 = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_PRE_PLOT_02_RETURN_TO_VARTAG );

                if ( bDAPrePlot_1 && !bDAPrePlot_2 )
                    WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_FAILED, TRUE );

                break;
            }


            case ORZ_WFHT2___PLOT_03_COMPLETED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has completed Harrowmont's second task
                // ACTION:  Harrowmont support increase
                //--------------------------------------------------------------
                // Qwinn (v1.0): This was not set when you planted the papers for Bhelen, which would leave
                // journal open and no XP reward. However, it makes sense that Harrowmont's support
                // would not actually increase in that circumstance, so making that conditional.

                // Qwinn (v3.0):  I can't believe I didn't notice this the first time - this increases
                // BHELEN'S support instead of Harrowmont's!  After further review, believe that's 
                // only supposed to be if papers were planted, otherwise, Harrowmont gets +3.

                // The original:
                // WR_SetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB__ACTION_SUPPORT_INCREASE_03_HIGH, TRUE, TRUE );

                /* Qwinn fix in v1.0:
                if(!WR_GetPlotFlag (PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_03_PAPERS_PLANTED))
                {
                   WR_SetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB__ACTION_SUPPORT_INCREASE_03_HIGH, TRUE, TRUE );
                }*/

                // Qwinn fix in v3.0:
                if(WR_GetPlotFlag (PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_03_PAPERS_PLANTED))
                {
                   WR_SetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB__ACTION_SUPPORT_INCREASE_03_HIGH, TRUE, TRUE );
                }
                else
                {
                   WR_SetPlotFlag( PLT_ORZPT_WFHARROW, ORZ_WFH_ACTION_SUPPORT_INCREASE_HIGH, TRUE, TRUE );
                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_14);

                break;

            }


            case ORZ_WFHT2___PLOT_DELAYED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has delayed Bhelens's Second Task
                //--------------------------------------------------------------

                int         bDAPrePlot_1;
                int         bDAPrePlot_2;

                //--------------------------------------------------------------

                bDAPrePlot_1   = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_PRE_PLOT_01_TT_HARROW );
                bDAPrePlot_2   = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_PRE_PLOT_02_RETURN_TO_VARTAG );

                //--------------------------------------------------------------

                if ( bDAPrePlot_1 && !bDAPrePlot_2 )
                // Qwinn:  Should have been a Set, not a Get (see similar code under ACCEPTED)
                // This made the journal not update properly.
                // WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_PRE_PLOT_02_RETURN_TO_VARTAG, TRUE );
                   WR_SetPlotFlag( PLT_ORZPT_WFBHELEN_DA, ORZ_WFBDA___PLOT_PRE_PLOT_02_RETURN_TO_VARTAG, TRUE );

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


            case ORZ_WFHT2___PLOT_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    Plot is Active
                //--------------------------------------------------------------

                int         bPlotAccepted;
                int         bPlotReturn;
                int         bPlotFailed;

                //--------------------------------------------------------------

                bPlotAccepted  = WR_GetPlotFlag( sPlot, ORZ_WFHT2___PLOT_01_ACCEPTED );
                bPlotReturn    = WR_GetPlotFlag( sPlot, ORZ_WFHT2___PLOT_03_COMPLETED );
                bPlotFailed    = WR_GetPlotFlag( sPlot, ORZ_WFHT2___PLOT_FAILED );

                //--------------------------------------------------------------

                if ( bPlotAccepted && !(bPlotReturn||bPlotFailed) )
                    bResult = TRUE;

                break;

            }


            case ORZ_WFHT2___PLOT_ACCEPTED_OR_DELAYED:
            {

                //--------------------------------------------------------------
                // COND:    PC has accepted or delayed task 2
                //--------------------------------------------------------------

                int         bHarrowT2Accepted;
                int         bHarrowT2Delayed;

                //--------------------------------------------------------------

                bHarrowT2Accepted = WR_GetPlotFlag( sPlot, ORZ_WFHT2___PLOT_01_ACCEPTED );
                bHarrowT2Delayed  = WR_GetPlotFlag( sPlot, ORZ_WFHT2___PLOT_DELAYED );

                //--------------------------------------------------------------

                if ( bHarrowT2Accepted || bHarrowT2Delayed )
                    bResult = TRUE;

                break;

            }


            case ORZ_WFHT2_PC_IS_DWARF_COMMONER_WITHOUT_TASK_2:
            {

                //--------------------------------------------------------------
                // COND:    The PC is a dwarf commoner who has not yet accepted
                //          Harrowmont's second task
                //--------------------------------------------------------------

                // Grab required plot flags
                int bDwarfCommoner;
                int bHarrowT2Accepted;

                //--------------------------------------------------------------

                bDwarfCommoner    = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_COMMONER );
                bHarrowT2Accepted = WR_GetPlotFlag( sPlot, ORZ_WFHT2___PLOT_01_ACCEPTED );

                //--------------------------------------------------------------

                if (bDwarfCommoner && !bHarrowT2Accepted )
                    bResult = TRUE;

                break;


            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}