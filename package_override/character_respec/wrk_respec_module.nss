//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC module core script. This is pretty much empty
//              but without this, the attribute points double on the
//              level up screen.
// Owner: Peter `weriK` Kovacs
// Date: 11/11/2009 @ 3:47 AM
//
/////////////////////////////////////////////////////////////////

#include "wrappers_h"
#include "wrk_respec_utility_h"
#include "plt_wrk_respec_plot"
#include "wrk_respec_core"

void main()
{
    event   ev = GetCurrentEvent();
    int     nEventType = GetEventType(ev);

    switch(nEventType)
    {
        case EVENT_TYPE_MODULE_LOAD:
        {
            // If this is not the first time the module was loaded
            if ( WR_GetPlotFlag( PLT_WRK_RESPEC_PLOT, WRK_PLOT_FIRST_START_16 ) == TRUE )
            {
                // Show a Welcome Screen to the player so he knows the module
                // started properly.
                ShowPopup( 1089623140, WRK_POPUP_MESSAGE_MESSAGE);

                // Make sure this popup will not appear anymore
                WR_SetPlotFlag( PLT_WRK_RESPEC_PLOT, WRK_PLOT_FIRST_START_16, FALSE );
            }
            break;
        } // ! EVENT_TYPE_MODULE_LOAD

        case EVENT_TYPE_POPUP_RESULT:
        {
            // Only proceed if we want to use the potion now
            // Every other case we ignore
            if ( WR_GetPlotFlag( PLT_WRK_RESPEC_PLOT, WRK_PLOT_USE_POTION ) == FALSE )
                return;

            // Retrieve the object which fired the potion ability
            // We stored this party member in MODULE_COUNTER_1
            object[] aPartyList = GetPartyList();
            int nPartyMember = GetLocalInt(GetModule(), "MODULE_COUNTER_1");

            // Retrieve the result of the dialog box
            int nResult = GetEventInteger(ev, 1);

            // If the user pressed yes (Button ID: 1) we respec this character
            if ( nResult == 1 )
                WRK_RespecCharacter(aPartyList[nPartyMember]);

            // Either way, we want to reset the flag
            WR_SetPlotFlag( PLT_WRK_RESPEC_PLOT, WRK_PLOT_USE_POTION, FALSE );
            break;

        } // ! EVENT_TYPE_POPUP_RESULT
    } // ! switch
} // ! main


