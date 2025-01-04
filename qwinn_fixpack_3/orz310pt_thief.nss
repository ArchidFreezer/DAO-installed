//==============================================================================
/*

    Paragon of Her Kind
        -> Thief in the house of learning plot script.

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: November 3, 2008
//==============================================================================

#include "wrappers_h"
#include "utility_h"
#include "plot_h"
#include "plt_orz310pt_thief"
#include "orz_constants_h"

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

        int nOldValue   = GetEventInteger( evParms, 3 );  // Old flag value
        int nNewValue   = GetEventInteger( evParms, 2 );  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {

            case ORZ_THIEF_PLOT_ACCEPTED:
            {
                //turn off the plot giver flag
                object oPC = GetHero();
                object oShaper = UT_GetNearestCreatureByTag(oPC, "orz310cr_liteshaper");
                SetPlotGiver(oShaper, FALSE);

                break;

            }
            case ORZ_THIEF_PLOT_COMPLETED_TOME_RETURNED:
            case ORZ_THIEF_PLOT_COMPLETED_TOME_SOLD:
            {

                //--------------------------------------------------------------
                // ACTION: Remove extraneous plot items from player.
                //--------------------------------------------------------------

                UT_RemoveItemFromInventory( ORZ_IM_PROVING_RECEIPT_R );
                UT_RemoveItemFromInventory( ORZ_IM_STOLEN_TOME_R );

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_18);

                break;

            }

            case ORZ_THIEF_BOSS_ATTACKS:
            {

                object oBoss = GetObjectByTag( ORZ_CR_THIEF_BOSS );

                SetPlotGiver( oBoss, FALSE );

                UT_TeamAppears( ORZ_TEAM_SHAPERATE_THIEF_BOSS );
                UT_TeamGoesHostile( ORZ_TEAM_SHAPERATE_THIEF_BOSS );

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

            case ORZ_THIEF_PC_HAS_STOLEN_TOME:
            {

                //--------------------------------------------------------------
                // CONDITION: The player is possession of the stolen tome.
                //--------------------------------------------------------------

                if ( UT_CountItemInInventory( ORZ_IM_STOLEN_TOME_R ) )
                    bResult = TRUE;

                break;

            }

        }

    }

    return bResult;

}