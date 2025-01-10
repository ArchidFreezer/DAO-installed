//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC mod dialog event script
//              This is the script that is executed when the player picks
//              the dialog choice to learn one of the class specializations
//
// Owner: Peter `weriK` Kovacs
// Date: 11/12/2009 @ 9:22 PM
//
/////////////////////////////////////////////////////////////////

#include "utility_h"

void main()
{
    object oCharacter = GetHero();

    // Only want to give the spec book once to the player
    //
    // This is only a sanity check, the dialog option
    // itself should not pop up when the player already has one
    if (!CountItemsByTag(oCharacter, "gen_im_manual_spirithealer"))
    {
        // Give the manual to the hero
        UT_AddItemToInventory(R"gen_im_manual_spirithealer.uti", 1, oCharacter);
    }
}