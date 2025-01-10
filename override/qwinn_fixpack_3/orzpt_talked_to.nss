//==============================================================================
/*

    Paragon of Her Kind
     -> Talked To Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 6, 2007
//==============================================================================

#include "plt_orzpt_wfharrow"
#include "plt_orzpt_wfbhelen"
#include "plt_orzpt_talked_to"
#include "plt_orz400pt_leske"
#include "plt_orz200pt_filda"
#include "plt_cod_cha_bhelen"
#include "plt_cod_cha_harrowmont"

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
    event   evParms = GetCurrentEvent();            // Contains input parameters
    int     nType   = GetEventType(evParms);        // GET or SET call
    string  sPlot   = GetEventString(evParms, 0);   // Plot GUID
    int     nFlag   = GetEventInteger(evParms, 1);  // The bit flag # affected
    object  oOwner  = GetEventCreator(evParms);     // Script plot table owner

    // Grab Player, Set Default return to FALSE
    object  oPC     = GetHero();
    int     bResult = FALSE;

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evParms);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger(evParms, 3);  // Old flag value
        int nNewValue   = GetEventInteger(evParms, 2);  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {


            case ORZ_TT_LESKE:
            {

                //--------------------------------------------------------------
                // PLOT:    Player has talked to Leske (Dwarven Commoner)
                //          and learns about an entrance in his old home
                // ACTION:  Leske leaves
                //--------------------------------------------------------------

                object oLeske = UT_GetNearestCreatureByTag(oPC, ORZ_CR_LESKE);

                // Leske leaves
                WR_SetObjectActive(oLeske, FALSE);

                break;

            }


            case ORZ_TT_NADEZDA:
            {

                //--------------------------------------------------------------
                // PLOT:    After the PC talks to Nadezda, if he is a Dwarf
                //          Commoner, Leske will enter the plot
                // ACTION:  Leske shows up and begins conversation with PC
                //--------------------------------------------------------------

                WR_SetPlotFlag(PLT_ORZ400PT_LESKE,ORZ_LESKE_ACTION_LESKE_APPROACHES_PC,TRUE,TRUE);

                break;

            }


            case ORZ_TT_DULIN:
            {

                //--------------------------------------------------------------
                // PLOT:    If the PC accepted the plot to find Dulin, it should
                //          now complete itself.
                //--------------------------------------------------------------

                int         bPlotAccepted, bPlotCompleted;

                //--------------------------------------------------------------

                bPlotAccepted   = WR_GetPlotFlag( PLT_ORZPT_WFHARROW, ORZ_WFH___PLOT_01_ACCEPTED );
                bPlotCompleted  = WR_GetPlotFlag( PLT_ORZPT_WFHARROW, ORZ_WFH___PLOT_02_COMPLETED );

                //--------------------------------------------------------------

                if ( bPlotAccepted && !bPlotCompleted )
                    WR_SetPlotFlag( PLT_ORZPT_WFHARROW, ORZ_WFH___PLOT_02_COMPLETED, TRUE, TRUE );

                break;

            }


            case ORZ_TT_VARTAG:
            {

                //--------------------------------------------------------------
                // PLOT:    If the PC accepted the plot to find Dulin, it should
                //          now complete itself.
                //--------------------------------------------------------------

                int         bPlotAccepted, bPlotCompleted;

                //--------------------------------------------------------------

                bPlotAccepted   = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB___PLOT_01_ACCEPTED );
                bPlotCompleted  = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB___PLOT_02_COMPLETED );

                //--------------------------------------------------------------

                if ( bPlotAccepted && !bPlotCompleted )
                    WR_SetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB___PLOT_02_COMPLETED, TRUE, TRUE );

                break;

            }


            case ORZ_TT_RUCK:
            {

                //--------------------------------------------------------------
                // PLOT:    If the PC accepted the plot to find Dulin, it should
                //          now complete itself.
                //--------------------------------------------------------------

                int         bPlotAccepted;
                int         bPlotRuckFound;
                int         bPlotRuckKilled;
                int         bPlotRuckNotKilled;

                //--------------------------------------------------------------

                bPlotAccepted       = WR_GetPlotFlag( PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_01_ACCEPTED );
                bPlotRuckFound      = WR_GetPlotFlag( PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_FOUND );
                bPlotRuckKilled     = WR_GetPlotFlag( PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_KILLED );
                bPlotRuckNotKilled  = WR_GetPlotFlag( PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_NOT_KILLED );

                //--------------------------------------------------------------

                // Qwinn:  In version 1.0 we moved the ! out of the parentheses
                // This isn't necessary anymore because we're removing Filda after quest completion
                // In v3.0, we only set the Ruck_Found flag if Ruck tells you his name.
                // if ( bPlotAccepted && (!bPlotRuckFound||bPlotRuckKilled||bPlotRuckNotKilled) )
                //    WR_SetPlotFlag( PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_FOUND, TRUE, TRUE );

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

        }
    }

    return bResult;

}