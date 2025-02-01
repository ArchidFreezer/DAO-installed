//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC item script file for event handling
// Owner: Peter 'weriK' Kovacs
// Date: 11/10/2009 @ 4:31 AM
//
/////////////////////////////////////////////////////////////////

#include "events_h"
#include "wrappers_h"
#include "af_constants_h"
#include "plt_af_respec"



void main() {
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType) {
        // ---------------------------------------------------------------------
        // EVENT_TYPE_ABILITY_CAST_CAST
        // ---------------------------------------------------------------------
        // Fires for the moment of impact for every ability. This is where damage
        // should be applied, fireballs explode, enemies get poisoned etc'.
        // ---------------------------------------------------------------------
        case EVENT_TYPE_SPELLSCRIPT_CAST: {
            // Retrieve the character who used the item
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);
            object oCharacter = stEvent.oCaster;
            object[] aPartyList = GetPartyList();

            // Store the ID of this character in a module variable
            int i;
            for ( i = 0; i < GetArraySize(aPartyList); i++) {
                if ( oCharacter == aPartyList[i] ) {
                    SetLocalInt(GetModule(), "CHAR_RESPEC", i);
                    break;
                }
            }

            // Set the plot flag to indicate our intention of respeccing
            WR_SetPlotFlag( PLT_AF_RESPEC, AF_RESPEC_USE_POTION, TRUE );

            // Show a confirmation dialog box to the player
            ShowPopup(6610084, AF_POPUP_CHAR_RESPEC, oCharacter);

            break;

        } // ! EVENT_TYPE_SPELLSCRIPT_CAST

    } // ! switch

} // ! main