//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC main respecialization function
// Owner: Peter 'weriK' Kovacs
// Date: 11/22/2009 @ 7:04 PM
//
/////////////////////////////////////////////////////////////////

#include "sys_rewards_h"
#include "af_respec_abilities_h"
#include "af_respec_attributes_h"
#include "af_respec_skills_h"
#include "af_respec_utility_h"

void WRK_RespecCharacter(object oCharacter);
void WRK_RespecCharacter(object oCharacter)
{
    // Before anything we must to clear the quickslots
    // This was the cause of mage and Morrigan crashes
    WRK_ClearQuickslots(oCharacter);

    // Respec the spells
    WRK_RESPEC_ABILITIES(oCharacter);

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
    sRPText[0] = GetStringByStringId(6610078);
    sRPText[1] = GetStringByStringId(6610079);
    sRPText[2] = GetStringByStringId(6610080);
    sRPText[3] = GetStringByStringId(6610081);
    sRPText[4] = GetStringByStringId(6610082);
    sRPText[5] = GetStringByStringId(6610083);
    DisplayFloatyMessage(oCharacter, sRPText[Random(6)], FLOATY_MESSAGE, 16777215, 5.0f);

    // Remove a potion from the shared inventory every time we use one.
    UT_RemoveItemFromInventory(AF_ITR_RESPEC_POTION, 1, GetHero());

} // ! WRK_RespecCharacter