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
#include "wrk_respec_utility_h"

void main()
{
    object oCharacter = GetMainControlled();

    // Only want to give one potion to the player
    //
    // This is only a sanity check, the dialog option
    // itself should not pop up when the player already has one
    if (!CountItemsByTag(oCharacter, "wrk_potion_respec"))
    {
        // Add one potion to the character
        UT_AddItemToInventory(R"wrk_potion_respec.uti", 1, oCharacter);

        // Pop up a nice floating message about the character's head
        DisplayFloatyMessage(oCharacter, "You have received a Potion of Respecialization!", FLOATY_MESSAGE, 16777215, 3.0f);
    }
}