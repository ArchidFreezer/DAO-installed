//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC main respecialization function
// Owner: Peter 'weriK' Kovacs
// Date: 11/22/2009 @ 7:04 PM
//
/////////////////////////////////////////////////////////////////

#include "sys_rewards_h"
#include "wrk_respec_attributes_h"
#include "wrk_respec_spells_h"
#include "wrk_respec_skills_h"

void WRK_RespecCharacter(object oCharacter);
void WRK_RespecCharacter(object oCharacter)
{
    // Before anything we must to clear the quickslots
    // This was the cause of mage and Morrigan crashes
    WRK_ClearQuickslots(oCharacter);

    // Respec the spells
    WRK_RESPEC_SPELLS(oCharacter);

    // Respec the skills
    WRK_RESPEC_SKILLS(oCharacter);

    // Respec the attributes
    WRK_RESPEC_ATTRIBUTES(oCharacter);

    // Notify the GUI that we have free points to spend and
    // play the level up animation
    SetCanLevelUp(oCharacter, Chargen_HasPointsToSpend(oCharacter));
    ApplyEffectVisualEffect(oCharacter, oCharacter, 30023, EFFECT_DURATION_TYPE_INSTANT, 0.0f, 0);

    // Add a bit of random RP
    string[] sRPText;
    sRPText[0] = "Ugh.. Where am I?!";
    sRPText[1] = "Ooh! I feel... different!";
    sRPText[2] = "Something is strange...";
    sRPText[3] = "This isn't right! No, no, nono!";
    sRPText[4] = "What... Who the... What just happened?!";
    sRPText[5] = "Hamsters and rangers everywhere!";
    DisplayFloatyMessage(oCharacter, sRPText[Random(6)], FLOATY_MESSAGE, 16777215, 5.0f);

    // Remove a potion from the shared inventory every time we use one.
    UT_RemoveItemFromInventory(R"wrk_potion_respec.uti", 1, GetHero());

} // ! WRK_RespecCharacter