//==============================================================================
/*

    Paragon of Her Kind
     -> Working For Bhelen (Task 1) Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: January 15, 2008
//==============================================================================

#include "plt_orzpt_wfharrow_t1"
#include "plt_orzpt_wfbhelen"
#include "plt_orzpt_wfbhelen_t1"
#include "plt_orz340pt_find_lord_dace"
#include "plt_orz340pt_talk_to_helmi"
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
            case ORZ_WFBT1_PC_HEARD_EVIDENCE:
            {
                //Take an autoscreenshot
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_ORZ_MEETING_VARTAG, TRUE, TRUE);
                break;
            }

            case ORZ_WFBT1___PLOT_01_ACCEPTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has accepted Bhelen's first task to find Lord
                //          Helmi and Lord Dace
                //--------------------------------------------------------------

                int         bHarrowT1;
                object      oVartag;

                //--------------------------------------------------------------

                bHarrowT1 = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_ACTIVE );
                oVartag = UT_GetNearestCreatureByTag( oPC, ORZ_CR_VARTAG );

                //--------------------------------------------------------------

                SetPlotGiver( oVartag, FALSE );

                // Add the two sub-plots to the Journal (but make sure we only add this once
                if (WR_GetPlotFlag(PLT_ORZ340PT_FIND_LORD_DACE, ORZ_DACE___PLOT_01_ACCEPTED) == FALSE)
                {
                    WR_SetPlotFlag( PLT_ORZ340PT_FIND_LORD_DACE, ORZ_DACE___PLOT_01_ACCEPTED, TRUE, TRUE );
                    WR_SetPlotFlag( PLT_ORZ340PT_TALK_TO_HELMI, ORZ_HELMI___PLOT_01_ACCEPTED, TRUE, TRUE );
                }
                // Update Story-So-Far
                if ( bHarrowT1 )
                    ORZ_UpdateStorySoFar(SSF_ORZ_02C_BOTH_TASK_1);
                else
                    ORZ_UpdateStorySoFar(SSF_ORZ_02A_BHELEN_TASK_1);

                break;

            }

            case ORZ_WFBT1___PLOT_02_RETURN:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has spoken to Dace and Helmi
                //--------------------------------------------------------------

                WR_SetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_FAILED, TRUE, TRUE );

                break;

            }


            case ORZ_WFBT1___PLOT_DELAYED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has delayed Bhelen's first task to find Lord
                //          Helmi and Lord Dace
                //--------------------------------------------------------------

                object oVartag;

                //--------------------------------------------------------------

                oVartag = UT_GetNearestCreatureByTag( oPC, ORZ_CR_VARTAG );

                //--------------------------------------------------------------

                SetPlotGiver( oVartag, FALSE );

                break;

            }


            case ORZ_WFBT1___PLOT_FAILED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has failed to find Lords Helmi and Dace.
                //--------------------------------------------------------------

                // Qwinn:  Making the two subquest sets conditional, you might have completed one.
                // WR_SetPlotFlag( PLT_ORZ340PT_FIND_LORD_DACE, ORZ_DACE___PLOT_FAILED, TRUE, TRUE );
                // WR_SetPlotFlag( PLT_ORZ340PT_TALK_TO_HELMI, ORZ_HELMI___PLOT_FAILED, TRUE, TRUE );

                int bDaceActive = WR_GetPlotFlag(PLT_ORZ340PT_FIND_LORD_DACE,ORZ_DACE___PLOT_ACTIVE);
                int bHelmiActive = WR_GetPlotFlag(PLT_ORZ340PT_TALK_TO_HELMI,ORZ_HELMI___PLOT_ACTIVE);

                if (bDaceActive)
                {
                   WR_SetPlotFlag( PLT_ORZ340PT_FIND_LORD_DACE, ORZ_DACE___PLOT_FAILED, TRUE, TRUE );
                }
                if (bHelmiActive)
                {
                   WR_SetPlotFlag( PLT_ORZ340PT_TALK_TO_HELMI, ORZ_HELMI___PLOT_FAILED, TRUE, TRUE );
                }
                UT_RemoveItemFromInventory( ORZ_IM_LETTER_DACE_R );
                UT_RemoveItemFromInventory( ORZ_IM_LETTER_HELMI_R );
                break;

            }


            case ORZ_WFBT1___PLOT_REFUSED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has delayed Bhelen's first task to find Lord
                //          Helmi and Lord Dace
                //--------------------------------------------------------------

                object oVartag;

                //--------------------------------------------------------------

                oVartag = UT_GetNearestCreatureByTag( oPC, ORZ_CR_VARTAG );

                //--------------------------------------------------------------

                SetPlotGiver( oVartag, FALSE );

                break;

            }


            case ORZ_WFBT1_BETRAYAL_DISCOVERED_AT_PROVING:
            {

                //--------------------------------------------------------------
                // PLOT:    PC was working for Bhelen, but just fought in the
                //          proving in Harrowmont's Name
                //--------------------------------------------------------------

                object oVartag;

                //--------------------------------------------------------------

                oVartag = UT_GetNearestCreatureByTag( oPC, ORZ_CR_VARTAG );

                SetPlotGiver( oVartag, FALSE );
                WR_SetObjectActive( oVartag, TRUE );
                WR_SetPlotFlag( sPlot, ORZ_WFBT1___PLOT_02_RETURN, FALSE );
                // Qwinn:  The following is flat out wrong, it's the flag for Find Vartag quest
                // Which would create a closed entry if you never accepted it before talking to him
                // Setting task 1 failed is unnecessary because that gets set the instant you declare
                // for Harrowmont.  Will just comment it out.
                // WR_SetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB___PLOT_FAILED, TRUE, TRUE );

                break;

            }

            case ORZ_WFBT1___PLOT_03_COMPLETED:
            {

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_3a);

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


            case ORZ_WFBT1___PLOT_ACCEPTED_OR_DELAYED:
            {

                //--------------------------------------------------------------
                // COND:    Plot was accepted or delayed
                //--------------------------------------------------------------

                int         bPlotAccepted;
                int         bPlotDelayed;

                //--------------------------------------------------------------

                bPlotAccepted  = WR_GetPlotFlag( sPlot, ORZ_WFBT1___PLOT_01_ACCEPTED );
                bPlotDelayed   = WR_GetPlotFlag( sPlot, ORZ_WFBT1___PLOT_DELAYED );

                //--------------------------------------------------------------

                if ( bPlotAccepted || bPlotDelayed )
                    bResult = TRUE;

                break;

            }


            case ORZ_WFBT1___PLOT_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    Plot is Active
                //--------------------------------------------------------------

                int         bPlotAccepted;
                int         bPlotReturn;
                int         bPlotFailed;

                //--------------------------------------------------------------

                bPlotAccepted  = WR_GetPlotFlag( sPlot, ORZ_WFBT1___PLOT_01_ACCEPTED );
                bPlotReturn    = WR_GetPlotFlag( sPlot, ORZ_WFBT1___PLOT_03_COMPLETED );
                bPlotFailed    = WR_GetPlotFlag( sPlot, ORZ_WFBT1___PLOT_FAILED );

                //--------------------------------------------------------------

                if ( bPlotAccepted && !(bPlotReturn||bPlotFailed) )
                    bResult = TRUE;

                break;

            }


            case ORZ_WFBT1_PC_CAN_TELL_VARTAG_ABOUT_HARROWS_FIRST_TASK:
            {

                //--------------------------------------------------------------
                // COND:    PC has heard about Harrowmont wanting to win the
                //          Proving and has not yet told Vartag about it.
                //--------------------------------------------------------------

                int         bWFHT1Accepted;
                int         bWFHT1Delayed;
                int         bToldVartag;

                //--------------------------------------------------------------

                bWFHT1Accepted = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_01_ACCEPTED );
                bWFHT1Delayed  = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_DELAYED );
                bToldVartag    = WR_GetPlotFlag( sPlot, ORZ_WFBT1_PC_TOLD_VARTAG_ABOUT_HARROWS_FIRST_TASK );

                //--------------------------------------------------------------

                if ( (bWFHT1Accepted||bWFHT1Delayed) && !bToldVartag )
                    bResult = TRUE;

                break;

            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}