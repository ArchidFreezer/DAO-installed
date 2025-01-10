//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC item script file for event handling
// Owner: Peter 'weriK' Kovacs
// Date: 11/10/2009 @ 4:31 AM
//
/////////////////////////////////////////////////////////////////

#include "events_h"
#include "wrappers_h"
#include "wrk_respec_utility_h" 
#include "plt_wrk_respec_plot"



void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType)
    {
        // ---------------------------------------------------------------------
        // EVENT_TYPE_ABILITY_CAST_CAST
        // ---------------------------------------------------------------------
        // Fires for the moment of impact for every ability. This is where damage
        // should be applied, fireballs explode, enemies get poisoned etc'.
        // ---------------------------------------------------------------------
        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Retrieve the character who used the item
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);
            object oCharacter = stEvent.oCaster;
            object[] aPartyList = GetPartyList();

            // Store the ID of this character in a module variable
            int i;
            for ( i = 0; i < GetArraySize(aPartyList); i++)
            {
                if ( oCharacter == aPartyList[i] )
                {
                    SetLocalInt(GetModule(), "MODULE_COUNTER_1", i);
                    break;
                }
            }

            // Set the plot flag to indicate our intention of respeccing
            WR_SetPlotFlag( PLT_WRK_RESPEC_PLOT, WRK_PLOT_USE_POTION, TRUE );
            
            // Show a confirmation dialog box to the player
            ShowPopup( 1089623141, WRK_POPUP_MESSAGE_QUESTION, oCharacter);

            break;

        } // ! EVENT_TYPE_SPELLSCRIPT_CAST

    } // ! switch

} // ! main