//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC mod dialog event script
//              This is the script that is executed when the player picks
//              the dialog choice to take the vial
//
// Owner: Peter `weriK` Kovacs
// Date: 11/10/2009 @ 5:15 PM
//
/////////////////////////////////////////////////////////////////

#include "utility_h"
#include "core_h"
#include "af_respec_utility_h"

void main() {
    object oCharacter = GetMainControlled();

    // Only want to give one potion to the player
    //
    // This is only a sanity check, the dialog option
    // itself should not pop up when the player already has one
    if (!CountItemsByTag(oCharacter, AF_ITM_RESPEC_POTION)) {
        // Add one potion to the character
        UT_AddItemToInventory(AF_ITR_RESPEC_POTION, 1, oCharacter);

        // Pop up a nice floating message about the character's head
        DisplayFloatyMessage(oCharacter, GetStringByStringId(6610087), FLOATY_MESSAGE, 16777215, 3.0f);
    }
}