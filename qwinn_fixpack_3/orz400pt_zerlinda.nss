//==============================================================================
/*

    Paragon of Her Kind
     -> Zerlinda Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 21, 2007
//==============================================================================

#include "plt_orz400pt_zerlinda"

#include "orz_constants_h"

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


            case ORZ_ZERLINDA___PLOT_01_ACCEPTED_BURKEL:
            case ORZ_ZERLINDA___PLOT_01_ACCEPTED_FATHER:
            case ORZ_ZERLINDA_IS_MAD_AT_PC:
            {

                //--------------------------------------------------------------
                // PLOT:    PC Accepted plot
                //--------------------------------------------------------------

                object      oZerlinda;

                //--------------------------------------------------------------

                oZerlinda = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ZERLINDA );

                //--------------------------------------------------------------

                SetPlotGiver( oZerlinda, FALSE );

                break;

            }


            case ORZ_ZERLINDA___PLOT_02_AGREED_FATHER:
            {

                //--------------------------------------------------------------
                // PLOT:    Zerlinda can now return home to her family
                // ACTION:  Zerlinda's father, Ordel, leaves Tapsters
                //--------------------------------------------------------------

                object      oOrdel;

                //--------------------------------------------------------------

                oOrdel = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ORDEL );

                //--------------------------------------------------------------

                WR_SetObjectActive( oOrdel, FALSE );

                break;

            }


            case ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_CHANTRY:
            case ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_FAMILY_HAPPY:
            case ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_SURFACE:
            {

                //--------------------------------------------------------------
                // PLOT:    Zerlinda quest was completed in some fashion.
                //          She will leave and no longer be reachable.
                //--------------------------------------------------------------

                object      oZerlinda;

                //--------------------------------------------------------------

                oZerlinda = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ZERLINDA );

                //--------------------------------------------------------------

                WR_SetObjectActive( oZerlinda, FALSE );

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_25a);
/*
                if(nFlag == ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_CHANTRY)
                    ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_25a);
                if(nFlag == ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_FAMILY_HAPPY)
                    ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_25b);
                if(nFlag == ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_SURFACE)
                    ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_25c);
*/
                break;

            }


            case ORZ_ZERLINDA___PLOT_REFUSED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC REFUSED plot
                //--------------------------------------------------------------

                object      oZerlinda;

                //--------------------------------------------------------------

                oZerlinda = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ZERLINDA );

                //--------------------------------------------------------------

                SetPlotGiver( oZerlinda, FALSE );

                break;

            }


            case ORZ_ZERLINDA___PLOT_FAILED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC FAILED plot
                //--------------------------------------------------------------

                object      oZerlinda;

                //--------------------------------------------------------------

                oZerlinda = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ZERLINDA );

                //--------------------------------------------------------------

                SetPlotGiver( oZerlinda, FALSE );

                break;

            }


            case ORZ_ZERLINDA_PC_GIVES_CASH_HIGH:
            {
                // Qwinn: This was completely empty.
                UT_MoneyTakeFromObject( oPC, 0, ORZ_ZERLINDA_CASH_REQ_HIGH , 0 );
                break;

            }


            case ORZ_ZERLINDA_PC_GIVES_CASH_LOW:
            {
                // Qwinn: This was completely empty.
                UT_MoneyTakeFromObject( oPC, 0, ORZ_ZERLINDA_CASH_REQ_LOW , 0 );
                break;

            }


            case ORZ_ZERLINDA_CONVINCED:
            {

                //--------------------------------------------------------------
                // PLOT:    Zerlinda is convinced to get rid of her child.
                //--------------------------------------------------------------

                object      oZerlinda;

                //--------------------------------------------------------------

                oZerlinda = UT_GetNearestCreatureByTag( oPC, ORZ_CR_ZERLINDA );

                //--------------------------------------------------------------

                WR_SetObjectActive( oZerlinda, FALSE );

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


            case ORZ_ZERLINDA___PLOT_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    PC has accepted, but not completed Zerlinda's quest
                //--------------------------------------------------------------

                int         bPlotAccepted_1;
                int         bPlotAccepted_2;
                int         bPlotCompleted;
                int         bPlotFailed;

                //--------------------------------------------------------------

                bPlotAccepted_1 = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_01_ACCEPTED_BURKEL);
                bPlotAccepted_2 = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_01_ACCEPTED_FATHER );
                bPlotCompleted  = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_03_COMPLETED );
                bPlotFailed     = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_FAILED );

                //--------------------------------------------------------------

                if ( (bPlotAccepted_1||bPlotAccepted_2) && !(bPlotCompleted||bPlotFailed) )
                    bResult = TRUE;

                break;

            }


            case ORZ_ZERLINDA___PLOT_03_COMPLETED:
            {

                //--------------------------------------------------------------
                // COND:    Player Completed Zerlinda's quest in some fasion.
                //--------------------------------------------------------------

                int         bPlotCompleted_1;
                int         bPlotCompleted_2;
                int         bPlotCompleted_3;

                //--------------------------------------------------------------

                bPlotCompleted_1 = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_CHANTRY );
                bPlotCompleted_2 = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_FAMILY_HAPPY );
                bPlotCompleted_3 = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_03_COMPLETED_GONE_TO_SURFACE );

                //--------------------------------------------------------------

                if ( bPlotCompleted_1 || bPlotCompleted_2 || bPlotCompleted_3 )
                    bResult = TRUE;

                break;

            }


            case ORZ_ZERLINDA_PC_CAN_ASK_BURKEL:
            {

                //--------------------------------------------------------------
                // COND:    PC has told zerlinda that she would ask burkel and
                //          hasn't yet. Also, the PC has not ended the quest.
                //--------------------------------------------------------------

                int         bPlotActive;
                int         bBurkelAccept;
                int         bBurkelPromised;
                int         bBurkelRejected;

                //--------------------------------------------------------------

                bPlotActive     = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_ACTIVE );
                bBurkelAccept   = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_01_ACCEPTED_BURKEL );
                bBurkelPromised = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_02_AGREED_BURKEL );
                bBurkelRejected = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA___PLOT_02_REJECTED_BURKEL );

                //--------------------------------------------------------------

                if ( bPlotActive && bBurkelAccept && !(bBurkelPromised||bBurkelRejected) )
                    bResult = TRUE;

                break;

            }


            case ORZ_ZERLINDA_PC_GAVE_MONEY:
            {

                //--------------------------------------------------------------
                // COND:    PC has given Zerlinda some money before
                //--------------------------------------------------------------

                int         bMoneyHigh;
                int         bMoneyLow;

                //--------------------------------------------------------------

                bMoneyHigh = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA_PC_GIVES_CASH_HIGH );
                bMoneyLow  = WR_GetPlotFlag( sPlot, ORZ_ZERLINDA_PC_GIVES_CASH_LOW );

                //--------------------------------------------------------------

                if ( bMoneyHigh || bMoneyLow )
                    bResult = TRUE;

                break;

            }


            case ORZ_ZERLINDA_PC_HAS_CASH_HIGH:
            {
                // Qwinn:  This just returned true.
                // bResult = TRUE;
                if (UT_MoneyCheck(oPC, 0, ORZ_ZERLINDA_CASH_REQ_HIGH , 0) == TRUE )
                {
                    bResult = TRUE;
                }
                break;
            }


            case ORZ_ZERLINDA_PC_HAS_CASH_LOW:
            {
                // Qwinn:  This just returned true.
                // bResult = TRUE;
                if (UT_MoneyCheck(oPC, 0, ORZ_ZERLINDA_CASH_REQ_LOW , 0) == TRUE )
                {
                    bResult = TRUE;
                }
                break;
            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}