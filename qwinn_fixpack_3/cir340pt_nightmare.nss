//==============================================================================
/*

    Broken Circle: Nightmare
     -> Script for the Templar's Nightmare plot and area

*/
//------------------------------------------------------------------------------
// Created By: Ferret Baudoin
// Created On: June 9, 2008
//==============================================================================

#include "plt_cir340pt_nightmare"
#include "plt_cir300pt_shapeshifting"
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
    object  oTarg;

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

            case NIGHTMARE_MOUSE_ROOM_ENTERED:      // Triggered when entering the mousehole room in hub 1
            {
                // If the PC has already been looped by a door, then display the helper message
                // about the mouse form.
                if ( WR_GetPlotFlag(PLT_CIR340PT_NIGHTMARE, NIGHTMARE_QUEST_HELPER) &&
                    !WR_GetPlotFlag(PLT_CIR340PT_NIGHTMARE, NIGHTMARE_MOUSE_CLEARED) )
                    WR_SetPlotFlag(PLT_CIR340PT_NIGHTMARE, NIGHTMARE_MOUSE_BLOCKER, TRUE, TRUE);
                break;
            }

            case NIGHTMARE_QUEST_DONE:              // Trigger the global quest to update
            {

                //--------------------------------------------------------------
                // PLOT:    NIGHTMARE_QUEST_DONE
                // ACTION:  Trigger the global quest to update
                //--------------------------------------------------------------

                WR_SetPlotFlag(PLT_CIR300PT_FADE, FADE_HUB_SOLVED_ONE, TRUE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_CIRCLE_1n);

                break;

            }

            case NIGHTMARE_SUCCUBUS_READY_FIGHT:
            {
                UT_LocalJump(GetObjectByTag(CIR_CR_SUCCUBUS_BOSS) , CIR_WP_FADE_SUCCUBUS_BOSS_JUMP_1, TRUE, TRUE, TRUE);
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