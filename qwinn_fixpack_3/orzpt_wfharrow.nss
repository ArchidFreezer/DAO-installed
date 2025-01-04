//==============================================================================
/*

    Paragon of Her Kind
     -> Working for Harrowmont Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 8, 2007
//==============================================================================

#include "plt_bdnpt_main"
#include "plt_gen00pt_backgrounds"
#include "plt_orz260pt_baizyl"
#include "plt_orz260pt_gwiddon"
#include "plt_orz260pt_harrowproving"
#include "plt_orzpt_anvil"
#include "plt_orzpt_carta"
#include "plt_orzpt_generic"
#include "plt_orzpt_knows_about"
#include "plt_orzpt_talked_to"
#include "plt_orzpt_wfbhelen"
#include "plt_orzpt_wfbhelen_t1"
#include "plt_orzpt_wfbhelen_t2"
#include "plt_orzpt_wfbhelen_t3"
#include "plt_orzpt_wfharrow"
#include "plt_orzpt_wfharrow_t1"
#include "plt_orzpt_wfharrow_t2"
#include "plt_orzpt_wfharrow_t3"
#include "plt_orzpt_wfharrow_da"

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


            case ORZ_WFH___PLOT_01_ACCEPTED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC is told that he should talk to Dulin if he would
                //          like to support Harrowmont. This should be the
                //          earliestthat the PC can get the Working for
                //          Harrowmont quest in his journal. This also sets that
                //          the PC "knows about" Dulin.
                //--------------------------------------------------------------

                // Set that the PC "knows about" Dulin
                WR_SetPlotFlag(PLT_ORZPT_KNOWS_ABOUT, ORZ_KA_DULIN, TRUE, TRUE);

                break;

            }

            case ORZ_WFH___PLOT_02_COMPLETED:
            {

                //--------------------------------------------------------------

                //WR_SetPlotFlag(PLT_ORZPT_WFHARROW_T3, ORZ_WFHT3___PLOT_03_COMPLETED, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_9);

                break;
            }

            // Qwinn:  Added this entire case.  It gets set in the Steward's dialogue
            // when crowning Harrowmont if you did Shifting Allegiances and got the
            // papers, but because no case for it, no support was actually given.
            case ORZ_WFH_ACTION_SUPPORT_INCREASE_VERY_HIGH:
            {

                //--------------------------------------------------------------
                // ACTION:  Support increased by 3
                //--------------------------------------------------------------

                int nSupport = GetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT);
                SetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT, (nSupport+5));

                // DEBUG
                Log_Trace(LOG_CHANNEL_PLOT,"ORZ_SUPPORT_HARROWMONT",
                    ToString(nSupport)+"->"+ToString(nSupport+5));

                break;

            }


            case ORZ_WFH_ACTION_SUPPORT_INCREASE_HIGH:
            {

                //--------------------------------------------------------------
                // ACTION:  Support increased by 3
                //--------------------------------------------------------------

                int nSupport = GetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT);
                SetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT, (nSupport+3));

                // DEBUG
                Log_Trace(LOG_CHANNEL_PLOT,"ORZ_SUPPORT_HARROWMONT",
                    ToString(nSupport)+"->"+ToString(nSupport+3));

                break;

            }


            case ORZ_WFH_ACTION_SUPPORT_INCREASE_LOW:
            {

                //--------------------------------------------------------------
                // ACTION:  Support increased by 1
                //--------------------------------------------------------------

                int nSupport = GetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT);
                SetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT,(nSupport+1));

                // DEBUG
                Log_Trace(LOG_CHANNEL_PLOT,"ORZ_SUPPORT_HARROWMONT",
                    ToString(nSupport)+"->"+ToString((nSupport+1)));

                break;

            }


            case ORZ_WFH_ACTION_SUPPORT_INCREASE_MED:
            {

                //--------------------------------------------------------------
                // ACTION:  Support increased by 2
                //--------------------------------------------------------------

                int nSupport = GetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT);
                SetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT, (nSupport+2));

                // DEBUG
                Log_Trace(LOG_CHANNEL_PLOT,"ORZ_SUPPORT_HARROWMONT",
                    ToString(nSupport)+"->"+ToString(nSupport+2));

                break;

            }


            case ORZ_WFH_DULIN_TELEPORTS_PC_TO_HARROWMONT:
            {

                //--------------------------------------------------------------
                // PLOT:    PC is brought to Harrowmont for the first time.
                //          From now on, Dulin will appear in Harrowmont's
                //          estate, which is now accessible to the PC.
                // ACTION:  The PC and Dulin are teleported to Harrowmont's
                //          Estate
                //--------------------------------------------------------------

                int         bDoubleAgent;
                object      oDulin;

                //--------------------------------------------------------------

                bDoubleAgent = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_01_ACCEPTED );
                oDulin       = UT_GetNearestCreatureByTag( oPC, ORZ_CR_DULIN );

                //--------------------------------------------------------------

                // Remove him (we don't want him coming back!)
                WR_SetObjectActive( oDulin, FALSE );


                // Accept either the second or third tasks depending on whether
                // the PC was a double agent or not.
                if (bDoubleAgent)
                    WR_SetPlotFlag( PLT_ORZPT_WFHARROW_T3, ORZ_WFHT3___PLOT_00_PRE_PLOT_TELEPORTED, TRUE );
                else
                    WR_SetPlotFlag( PLT_ORZPT_WFHARROW_T2, ORZ_WFHT2___PLOT_00_PRE_PLOT_TELEPORTED, TRUE );

                // Teleport PC to Harrowmont (a new Dulin is waiting)
                UT_PCJumpOrAreaTransition( ORZ_AR_HARROWMONTS_ESTATE, ORZ_WP_TELEPORT_TO_HARROW );

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


            case ORZ_WFH_PC_BETRAYED_HARROWMONT:
            {

                //--------------------------------------------------------------
                // COND:    The player accepted the first task for Harrowmont,
                //          but has also completed the first task for Bhelen.
                //--------------------------------------------------------------

                int         bBhelenT1Complete;
                int         bHarrowT1Accepted;

                //--------------------------------------------------------------

                bBhelenT1Complete = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_02_RETURN );
                // Qwinn:  This should be accepted, not active, as setting the above flag sets the below quest to
                // failed, so this can never be true
                // bHarrowT1Active   = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_ACTIVE );
                bHarrowT1Accepted   = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1,ORZ_WFHT1___PLOT_01_ACCEPTED );

                //--------------------------------------------------------------

                if ( bBhelenT1Complete && bHarrowT1Accepted )
                    bResult = TRUE;

                break;


            }

            // This was set up as a main flag in the plot file, making this option
            // unavailable in game.  HUGE restoration.  Replacing with two new defined
            // flags so the dwarf noble line can only be seen by dwarf nobles.
            // It also didn't even check if you had the papers.
            /*
            case ORZ_WFH_PC_CAN_BRING_UP_EVIDENCE_FOR_TRIAN:
            {

                //--------------------------------------------------------------
                // COND:    The PC is not a dwarf noble, or is a dwarf noble
                //          who did NOT kill Trian
                //--------------------------------------------------------------

                int         bDwarfNoble;
                int         bKilledTrian;

                //--------------------------------------------------------------

                bDwarfNoble  = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE );
                bKilledTrian = WR_GetPlotFlag( PLT_BDNPT_MAIN, BDN_MAIN_PC_PLOTTED_TO_KILL_TRIAN );

                //--------------------------------------------------------------

                if ( !bDwarfNoble || (bDwarfNoble && !bKilledTrian) )
                    bResult = TRUE;

                break;
            }
            */


            case ORZ_WFH_PC_CAN_TELL_DULIN_VARTAG_QUEST:
            {

                //--------------------------------------------------------------
                // COND:    The player has either Accepted or Delayed Bhelen's
                //          first task.
                //--------------------------------------------------------------

                int         bBhelenT1Accepted;
                int         bBhelenT1Delayed;

                //--------------------------------------------------------------

                bBhelenT1Accepted = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_01_ACCEPTED );
                bBhelenT1Delayed  = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T1, ORZ_WFBT1___PLOT_DELAYED );

                //--------------------------------------------------------------

                if ( bBhelenT1Accepted || bBhelenT1Delayed )
                    bResult = TRUE;

                break;


            }

            case ORZ_WFH_PC_KILLED_JARVIA_FOR_BHELEN:
            {

                //--------------------------------------------------------------
                // COND:    Player killed Jarvia and is not doing T2 or DA
                //          for Harrowmont
                //--------------------------------------------------------------

                int         bJarviaKilled;
                int         bHarrowT2Return;
                int         bHarrowDAReturn;

                //--------------------------------------------------------------

                bJarviaKilled   = WR_GetPlotFlag( PLT_ORZPT_CARTA, ORZ_CARTA_JARVIA_DEAD );
                bHarrowT2Return = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T2, ORZ_WFHT2___PLOT_02_RETURN );
                bHarrowDAReturn = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_03_RETURN );

                //--------------------------------------------------------------

                if ( bJarviaKilled && !(bHarrowT2Return||bHarrowDAReturn) )
                    bResult = TRUE;

                break;

            }


            case ORZ_WFH_PC_WORKING_FOR_HARROWMONT:
            {

                //--------------------------------------------------------------
                // COND:    Player is working for Harrowmont legitimately or
                //          is a double agent for Harrowmont.
                //--------------------------------------------------------------

                int         bHarrowT2Accepted;
                int         bHarrowDAAccepted;

                //--------------------------------------------------------------

                bHarrowT2Accepted = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T2, ORZ_WFHT2___PLOT_01_ACCEPTED );
                bHarrowDAAccepted = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_01_ACCEPTED );

                //--------------------------------------------------------------

                if ( bHarrowT2Accepted || bHarrowDAAccepted )
                    bResult = TRUE;

                break;

            }


            case ORZ_WFH_SUPPORT_IS_HIGH:
            {

                //--------------------------------------------------------------
                // COND:    Support is 8 or greater
                //--------------------------------------------------------------

                int nSupport = GetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT);

                if (nSupport >= 8)
                    bResult = TRUE;

                break;

            }


            case ORZ_WFH_SUPPORT_IS_LOW:
            {

                //--------------------------------------------------------------
                // COND:    Support is 3 or greater
                //--------------------------------------------------------------

                int nSupport = GetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT);

                if (nSupport >= 3)
                    bResult = TRUE;

                break;

            }


            case ORZ_WFH_SUPPORT_IS_MED:
            {

                //--------------------------------------------------------------
                // COND:    Support is 6 or greater
                //--------------------------------------------------------------

                int nSupport = GetLocalInt(GetModule(), ORZ_SUPPORT_HARROWMONT);

                if (nSupport >= 6)
                    bResult = TRUE;

                break;

            }


        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}