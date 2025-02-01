//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC Skill respecialization
// Owner: Peter 'weriK' Kovacs
// Date: 11/10/2009 @ 4:31 AM
//
/////////////////////////////////////////////////////////////////

#include "af_respec_utility_h"
#include "af_ability_h" 
#include "af_logging_h"

/** @brief Loops through an ability array and resets skills
*
*   Looping through a given array that
*   contains the id's of every skill Ability a character
*   can have. If the character has an ability, it removes it,
*   and in return grants an extra skill point.
*
* @param arAbilityID - Array of ability IDs we want to test against
* @param oCharacter  - The character
* @author weriK
**/
void WRK_LOOP_SKILL(int[] arAbilityID, object oCharacter){
    int iCount = GetArraySize(arAbilityID);
    afLogInfo("Number of skills: " + IntToString(iCount), AF_LOGGROUP_CHAR_RESPEC);

    int i;
    for (i = 0; i < iCount; i++) {
        afLogDebug("   Checking skill: " + IntToString(arAbilityID[i]), AF_LOGGROUP_CHAR_RESPEC);
        // Check whether the character has the talent
        if ( HasAbility(oCharacter, arAbilityID[i]) ) {
            afLogInfo("   Skill on char: " + IntToString(arAbilityID[i]), AF_LOGGROUP_CHAR_RESPEC);
            // Unlearn the talent
            RemoveAbility(oCharacter, arAbilityID[i]);
            WRK_GiveSkillPoints(oCharacter, 1.0f);
        }
    }
}


/** @brief Resets the skill points on a character
*
*   This is the main function for resetting all skill points
*   on a character. It contains an Array with all the ability
*   ID's it is testing against. More elements can be added to the
*   array every time to extend the list of abilities it checks
*
* @param oCharacter - The character
* @author weriK
**/
void WRK_RESPEC_SKILLS(object oCharacter) {
    // Master list of all available skills ( 8 rows, 4 ranks, 32 skill points max )
    int[] WRK_SKILLLIST;
    int iSkill =0;

    // Coercion (Only the hero has this)
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_PERSUADE_4;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_PERSUADE_3;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_PERSUADE_2;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_PERSUADE_1;

    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_STEALING_4;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_STEALING_3;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_STEALING_2;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_STEALING_1;

    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_TRAPS_4;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_TRAPS_3;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_TRAPS_2;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_TRAPS_1;

    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_SURVIVAL_4;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_SURVIVAL_3;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_SURVIVAL_2;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_SURVIVAL_1;

    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_HERBALISM_4;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_HERBALISM_3;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_HERBALISM_2;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_HERBALISM_1;

    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_POISON_4;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_POISON_3;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_POISON_2;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_POISON_1;

// ----------- THIS CONSTANT HAS WRONG VALUE IN 2da_constants_h.nss ------------
// It should have a value of 100104 but it has 100103
//WRK_SKILLLIST[24] = ABILITY_SKILL_COMBAT_TRAINING_4;
    WRK_SKILLLIST[iSkill++] = 100103;
// -----------------------------------------------------------------------------
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_COMBAT_TRAINING_3;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_COMBAT_TRAINING_2;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_COMBAT_TRAINING_1;

    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_COMBAT_TACTICS_4;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_COMBAT_TACTICS_3;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_COMBAT_TACTICS_2;
    WRK_SKILLLIST[iSkill++] = ABILITY_SKILL_COMBAT_TACTICS_1;

    // From the SpellShaping mod
    WRK_SKILLLIST[iSkill++] = AF_ABI_SPELLSHAPING_4;
    WRK_SKILLLIST[iSkill++] = AF_ABI_SPELLSHAPING_3;
    WRK_SKILLLIST[iSkill++] = AF_ABI_SPELLSHAPING_2;
    WRK_SKILLLIST[iSkill++] = AF_ABI_SPELLSHAPING_1;


    // This will loop through the whole skill list array and free up any skill
    // point that is taken. Shale has no assignable skills even though she does have
    // COMBAT_TACTICS_1 hidden. Because of this we want to skip her.
    if ( GetName(oCharacter) != "Shale"  ) {
        WRK_LOOP_SKILL(WRK_SKILLLIST, oCharacter);

        // Recalculate the amount of available tactics due to the loss of Combat Tactics
        Chargen_SetNumTactics(oCharacter);
    }
}