#include "wrappers_h"
#include "af_respec_core_h"
#include "af_respec_utility_h"
#include "plt_af_respec"

/**
* @brief Show a popuyp trhe first time the module loads
*/
void RespecTestCharacter() {
    // If this is not the first time the module was loaded
    if (WR_GetPlotFlag(PLT_AF_RESPEC, AF_RESPEC_FIRST_START)) {
        // Show a Welcome Screen to the player so they know the module started correctly
        ShowPopup(6610085, AF_POPUP_MESSAGE);   // Ok button
        WR_SetPlotFlag(PLT_AF_RESPEC, AF_RESPEC_FIRST_START, FALSE);
    }
}

/**
* @brief Handle the respec potion popup event
*
* @return TRUE if the event is handled; FALSE otherwise
*/
int RespecPopupEventHandler(event ev) {

    int nPopupID  = GetEventInteger(ev, 0);  // popup ID (references a row in popups 2da)

    // Check that this is our popup
    if (nPopupID != AF_POPUP_CHAR_RESPEC)
        return FALSE;

    // Only proceed if we want to use the potion now
    // Every other case we ignore
    if (!WR_GetPlotFlag(PLT_AF_RESPEC, AF_RESPEC_USE_POTION))
        return FALSE;

    // Retrieve the object which fired the potion ability
    // We stored this party member in MODULE_COUNTER_1
    object[] aPartyList = GetPartyList();
    int nPartyMember = GetLocalInt(GetModule(), AF_VAR_CHAR_RESPEC);

    // Retrieve the result of the dialog box
    int nResult = GetEventInteger(ev, 1);

    // If the user pressed yes (Button ID: 1) we respec this character
    if ( nResult == 1 )
        WRK_RespecCharacter(aPartyList[nPartyMember]);

    // Either way, we want to reset the flag
    WR_SetPlotFlag(PLT_AF_RESPEC, AF_RESPEC_USE_POTION, FALSE);

    return TRUE;
}