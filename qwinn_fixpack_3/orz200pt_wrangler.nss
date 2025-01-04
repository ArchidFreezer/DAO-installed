//==============================================================================
/*

    Nug Wrangler plot script.
        -> orz200pt_wrangler.nss

    NOTE: The nug wrangler's CREATURE_COUNTER_1 variable contains the number
          of nugs returned.

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: October 30, 2008
//==============================================================================

#include "utility_h"
#include "plot_h"
#include "plt_orz200pt_wrangler"
#include "orz_constants_h"

const int ORZ_N_TOTAL_ESCAPED_NUGS = 10;

int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evParms = GetCurrentEvent();              // Contains input parameters
    int     nType   = GetEventType( evParms );        // GET or SET call
    int     nFlag   = GetEventInteger( evParms, 1 );  // The bit flag # affected
    string  sPlot   = GetEventString( evParms, 0 );   // Plot GUID

    // Set Default return to FALSE
    int     bResult = FALSE;

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evParms);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue = GetEventInteger( evParms, 3 );  // Old flag value
        int nNewValue = GetEventInteger( evParms, 2 );  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {

            case ORZ_WRANGLER_PLOT_ACCEPTED:
            {

                //--------------------------------------------------------------
                // PLOT: The player has heard the nug wrangler's sad tale.
                // ACTION: All the escpaed nugs become available.
                //--------------------------------------------------------------

                object oWrangler = GetObjectByTag( ORZ_CR_NUG_WRANGLER );
                SetPlotGiver( oWrangler, FALSE );
                UT_TeamAppears( ORZ_TEAM_ESCAPED_NUGS );
                break;

            }

            case ORZ_WRANGLER_EVENT_TRIGGERED:
            {

                //--------------------------------------------------------------
                // ACTION: A Bronto busts out in downtown orzammar. Several
                //  nugs escape in the confusion.
                //--------------------------------------------------------------

                object oBronto, oNug_1, oNug_2, oNug_3, oWrangler;
                object oBrontoWP, oNugWP_1, oNugWP_2, oNugWP_3;

                oBronto     = GetObjectByTag( ORZ_CR_ESCAPED_BRONTO     );
                oNug_1      = GetObjectByTag( ORZ_CR_ESCAPED_NUG + "_0" );
                oNug_2      = GetObjectByTag( ORZ_CR_ESCAPED_NUG + "_1" );
                oNug_3      = GetObjectByTag( ORZ_CR_ESCAPED_NUG + "_2" );
                oBrontoWP   = GetObjectByTag( ORZ_WP_ESCAPED_BRONTO     );

                // Several nugs escape.
                UT_ExitDestroy( oNug_1, TRUE, ORZ_WP_ESCAPED_NUG + "_0" );
                UT_ExitDestroy( oNug_2, TRUE, ORZ_WP_ESCAPED_NUG + "_1" );
                UT_ExitDestroy( oNug_3, TRUE, ORZ_WP_ESCAPED_NUG + "_2" );

                // Bronto runs out into the shops
                WR_SetObjectActive( oBronto, TRUE );
                AddCommand( oBronto, CommandMoveToObject( oBrontoWP, TRUE ), TRUE, TRUE );
                // Play an animation?

                break;

            }

            case ORZ_WRANGLER_NUG_RETURNED:
            {

                //--------------------------------------------------------------
                // PLOT: The player is returning a nug.
                //--------------------------------------------------------------

                object  oWrangler;
                int     nNugs;

                oWrangler   = GetObjectByTag( ORZ_CR_NUG_WRANGLER );
                nNugs       = GetLocalInt( oWrangler, CREATURE_COUNTER_1 );

                ++nNugs;

                SetLocalInt( oWrangler, CREATURE_COUNTER_1, nNugs );


                if ( !WR_GetPlotFlag(sPlot, ORZ_WRANGLER_PLOT_COMPLETED) )
                    WR_SetPlotFlag( sPlot, ORZ_WRANGLER_PLOT_COMPLETED, TRUE, TRUE );

                UT_RemoveItemFromInventory( ORZ_IM_NUG_R );

                if (nNugs == ORZ_N_TOTAL_ESCAPED_NUGS)
                   UT_AddItemToInventory(R"gen_im_arm_hel_men.uti");

                break;

            }

            case ORZ_WRANGLER_PLOT_COMPLETED:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_15);

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

            case ORZ_WRANGLER_NUG_FOUND:
            {

                //--------------------------------------------------------------
                // CONDITION: The player has a nug in their inventory.
                //--------------------------------------------------------------

                if ( UT_CountItemInInventory(ORZ_IM_NUG_R) )
                    bResult = TRUE;

                break;

            }

            case ORZ_WRANGLER_ALL_NUGS_FOUND:
            {
                //--------------------------------------------------------------
                // CONDITION: The player has the final nug in their inventory.
                //--------------------------------------------------------------

                object oWrangler;

                int nNugs, bHasNug, bLast;

                oWrangler = GetObjectByTag( ORZ_CR_NUG_WRANGLER );

                nNugs   = GetLocalInt( oWrangler, CREATURE_COUNTER_1 );
                bHasNug = UT_CountItemInInventory( ORZ_IM_NUG_R );
                bLast   = nNugs == (ORZ_N_TOTAL_ESCAPED_NUGS - 1);

                if ( bHasNug && bLast )
                    bResult = TRUE;

                break;

            }
        }

    }

    return bResult;

}