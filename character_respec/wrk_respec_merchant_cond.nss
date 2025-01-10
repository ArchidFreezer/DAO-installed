//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC mod dialog event script
//              This script makes sure the player only has a single
//              potion at a time. This potion is very potent after all :)
//              The dialog line will only show if the StartingConditional()
//              is met (returns true).
//
// Owner: Peter `weriK` Kovacs
// Date: 11/10/2009 @ 5:15 PM
//
/////////////////////////////////////////////////////////////////


int StartingConditional()
{
    object oCharacter = GetMainControlled();
    if (CountItemsByTag(oCharacter, "wrk_potion_respec"))
        return 0;
    else
        return 1;
}