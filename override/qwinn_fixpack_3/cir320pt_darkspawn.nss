//==============================================================================
/*

    Broken Circle: Darkspawn Invasion

*/
//------------------------------------------------------------------------------
// Created By: Ferret Baudoin
// Created On: June 10, 2008
//==============================================================================

#include "plt_cir310pt_burning_tower"
#include "plt_cir320pt_darkspawn"
#include "plt_cir300pt_fade"

#include "cir_constants_h"
#include "cir_functions_h"

#include "cutscenes_h"
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
        switch(nFlag)
        {
            case DARKSPAWN_QUEST_DONE:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_CIRCLE_1l);

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

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}