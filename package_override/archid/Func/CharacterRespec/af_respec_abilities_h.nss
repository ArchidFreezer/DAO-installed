//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC Spell and Talent respecialization
// Owner: Peter 'weriK' Kovacs
// Date: 11/10/2009 @ 4:31 AM
//
/////////////////////////////////////////////////////////////////
#include "2da_constants_h"
#include "af_respec_utility_h"
#include "af_ability_h"
#include "ability_h"
#include "af_logging_h"


/** @brief Loops through an ability array and resets spells and talents
*
*   Looping through a given array that
*   contains the id's of every spell and talent ability a character
*   can have. If the character has an abbility, it removes that,
*   and in return grants an extra /talent point.
*
* @param arAbilityID - Array of ability IDs we want to test against
* @param oCharacter  - The character
* @author weriK
**/
void WRK_LOOP_ABILITY(int[] arAbilityID, object oCharacter) {
    int iCount = GetArraySize(arAbilityID);
    afLogInfo("Number of skills: " + IntToString(iCount), AF_LOGGROUP_CHAR_RESPEC);

    int i;
    for (i = 0; i < iCount; i++) {
        afLogDebug("   Checking ability: " + IntToString(arAbilityID[i]), AF_LOGGROUP_CHAR_RESPEC);
        // Check whether the character has the talent
        if ( HasAbility(oCharacter, arAbilityID[i]) ) {
            afLogInfo("   Ability on char: " + IntToString(arAbilityID[i]), AF_LOGGROUP_CHAR_RESPEC);
           // Check whether it's a modal ability
            // If it is true, then disable it prior to removing
            if (Ability_IsModalAbility(arAbilityID[i]))
                Ability_DeactivateModalAbility(oCharacter, arAbilityID[i], GetAbilityType(arAbilityID[i]));

            // Unlearn the talent
            RemoveAbility(oCharacter, arAbilityID[i]);
            WRK_GiveTalentPoints(oCharacter, 1.0f);
        } // ! if
    } // ! for
}


/** @brief Resets the spell & talent points on a character
*
*   This is the main function for resetting all spell & talent points
*   on a character. It contains arrays with all the ability
*   ID's it is testing against. More elements can be added to the
*   array every time to extend the list of abilities it checks
*
* @param oCharacter - The character
* @author weriK
**/
void WRK_RESPEC_ABILITIES(object oCharacter) {
    // Ok this part is well *cough* not very fun
    // *wave* to bioware for a GetLearnedAbilitiesArray() function

    ////
    // WARRIOR TALENTS master table
    ////

    int[] WRK_ABILITIES_WARRIOR;
    int iWarr = 0;

    // Champion
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SUPERIORITY;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_MOTIVATE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_RALLY;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_WAR_CRY;

    // Berserker
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_FINAL_BLOW;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_CONSTRAINT;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_RESILIENCE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_BERSERK;

    // Templar
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_HOLY_SMITE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_RESIST_DECEPTION; // This is Mental Fortress
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_CLEANSE_AREA;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_RIGHTEOUS_STRIKE;

    // Reaver
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_BLOOD_FRENZY;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_PAIN;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_FRIGHTENING;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DEVOUR;

    // Warrior
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DEATH_BLOW;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_BRAVERY;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_THREATEN;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_POWERFUL;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_PERFECT_STRIKING;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DISENGAGE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_TAUNT;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_PRECISE_STRIKING;

    // Dual Weapon
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_MASTER;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_EXPERT;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_TBD;   // This is Dual-Weapon Finesse
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_TRAINING;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_PUNISHER;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_CRIPPLE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_RIPOSTE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_DOUBLE_STRIKE ;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_WHIRLWIND;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_MOMENTUM;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_FLURRY;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DUAL_WEAPON_SWEEP;

    // Archery
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_MASTER_ARCHER;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DEFENSIVE_FIRE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_AIM;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_MELEE_ARCHER;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_ARROW_OF_SLAYING;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_CRITICAL_SHOT;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_CRIPPLING_SHOT;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_PINNING_SHOT;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SCATTERSHOT;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SUPPRESSING_FIRE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHATTERING_SHOT;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_RAPIDSHOT;

    // Weapon and Shield
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_ASSAULT;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_OVERPOWER;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHIELD_PUMMEL;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHIELD_BASH;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHIELD_EXPERTISE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHIELD_WALL;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHIELD_BALANCE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHIELD_DEFENSE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHIELD_MASTERY;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHIELD_TACTICS;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHIELD_COVER;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHIELD_BLOCK;

    // Two-Handed
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_CRITICAL_STRIKE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_STUNNING_BLOWS;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_INDOMITABLE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_POMMEL_STRIKE;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_DESTROYER;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SUNDER_ARMOR;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SHATTERING_BLOWS;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_SUNDER_WEAPON; // This is Sunder Arms
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_WEAPON_SWEEP;  // This is Two-Handed Sweep
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_STRONG;        // This is Two-Handed Strength
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_POWERFUL_SWINGS;
    WRK_ABILITIES_WARRIOR[iWarr++] = ABILITY_TALENT_MIGHTY_BLOW;

    ////
    // ROGUE TALENTS master table
    ////

    int[] WRK_ABILITIES_ROGUE;
    int iRogue = 0;

    // Assassin
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_FEAST_OF_THE_FALLEN;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_LACERATE;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_EXPLOIT_WEAKNESS;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_MARK_OF_DEATH;

    // Bard
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_CAPTIVATE;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DEMORALIZE;   // This is Song of Courage
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DISTRACTION;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_CRY_OF_VALOR;

    // Ranger
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_MASTER_RANGER;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_SUMMON_SPIDER;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_NATURE_II_HARDINESS_OF_THE_BEAR; // This is Summon Bear
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_NATURE_I_COURAGE_OF_THE_PACK;    // This is Summon Wolf

    // Duelist
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_PINPOINT_STRIKE;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_KEEN_DEFENSE;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_UPSET_BALANCE;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUELING;

    // Rogue Part 1
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_FEIGN_DEATH;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_BACKSTAB;    // This is Coup De Grace
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_COMBAT_MOVEMENT;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DIRTY_FIGHTING;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_EVASION;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_LETHALITY;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DEADLY_STRIKE;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_BELOW_THE_BELT;


    // Dual Weapon
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_MASTER;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_EXPERT;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_TBD;   // This is Dual-Weapon Finesse
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_TRAINING;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_PUNISHER;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_CRIPPLE;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_RIPOSTE;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_DOUBLE_STRIKE ;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_WHIRLWIND;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_MOMENTUM;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_FLURRY;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DUAL_WEAPON_SWEEP;

    // Archery
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_MASTER_ARCHER;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_DEFENSIVE_FIRE;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_AIM;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_MELEE_ARCHER;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_ARROW_OF_SLAYING;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_CRITICAL_SHOT;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_CRIPPLING_SHOT;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_PINNING_SHOT;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_SCATTERSHOT;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_SUPPRESSING_FIRE;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_SHATTERING_SHOT;
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_TALENT_RAPIDSHOT;

    // Rogue - Part 2
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_SKILL_LOCKPICKING_4;    // THis is Device Mastery
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_SKILL_LOCKPICKING_3;    // Mechanical Expertise
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_SKILL_LOCKPICKING_2;    // Improved Tools
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_SKILL_LOCKPICKING_1;    // Deft Hands
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_SKILL_STEALTH_4;        // Master Stealth
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_SKILL_STEALTH_3;        // Combat Stealth
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_SKILL_STEALTH_2;        // Stealthy Item Use
    WRK_ABILITIES_ROGUE[iRogue++] = ABILITY_SKILL_STEALTH_1;        // Stealth

    ////
    // MAGE TALENTS master table
    ////

    int[] WRK_ABILITIES_MAGE;
    int iMage = 0;

    // Arcane Warrior
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_FADE_SHROUD;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SHIMMERING_SHIELD;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_AURA_OF_MIGHT;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_COMBAT_MAGIC;


    // Blood Mage
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_BLOOD_CONTROL;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_BLOOD_WOUND;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_BLOOD_SACRIFICE;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_BLOOD_MAGIC;


    // Shapeshifter
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SHAPESHIFTER;   // Master Shapeshifter
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_FLYING_SWARM;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_BEAR;          // Bear Shape
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SPIDER_SHAPE;

    // Spirit Healer
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_CLEANSING_AURA; // Cleansing Aura
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_LIFEWARD;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_REVIVAL;
    WRK_ABILITIES_MAGE[iMage++] = 10509;          // Group Heal

    // Mage
    WRK_ABILITIES_MAGE[iMage++] = 200257;                      // Arcane Mastery
    WRK_ABILITIES_MAGE[iMage++] = 200256;                      // Staff Focus
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_ARCANE_SHIELD;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_ARCANE_BOLT;

    // Primal
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_INFERNO;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_FIREBALL;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_FLAMING_WEAPONS;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_FLAME_BLAST;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_PETRIFY;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_EARTHQUAKE;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_STONEFIST;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_WALL_OF_STONE; // Rock Armor
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_BLIZZARD;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_CONE_OF_COLD;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_FROSTWALL;     // Frost Weapons
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_WINTERS_GRASP;
    WRK_ABILITIES_MAGE[iMage++] = 10211;                       // Chain Lightning
// ---------- TEMPEST (14002) CRASHES WHEN CALLING RemoveAbility() -------------
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_TEMPEST;
// -----------------------------------------------------------------------------
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SHOCK;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_LIGHTNING;

    // Creation
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_PURIFY;        // Mass Rejuvination
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_REGENERATION;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_CURE;          // Rejuvenate
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_HEAL;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_ARCANE_MIGHT;  // Haste
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_HEROIC_DEFENSE;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_HEROS_ARMOR;   // Heroic Defense
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_HEROIC_OFFENSE;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_GLYPH_OF_NEUTRALIZATION;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_GLYPH_OF_REPULSION;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_GLYPH_OF_WARDING;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_GLYPH_OF_PARALYSIS;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_STINGING_SWARM;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SPELLBLOOM;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_GREASE;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SPELL_WISP;

    // Spirit
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_ANTIMAGIC_BURST;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_ANTIMAGIC_WARD;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SHIELD_PARTY;  // Dispell Magic
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SPELL_SHIELD;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_MANA_CLASH;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SPELL_MIGHT;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_MANA_CLEANSE;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_WYNNES_SEAL_PORTAL;// Mana Drain 10704
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_ANIMATE_DEAD;
// ----- VIRULENT WALKING BOMB (12011) CRASHES WHEN CALLING RemoveAbility() ----
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_MASS_CORPSE_DETONATION;    // Virulent Walking Boms 12011
// -----------------------------------------------------------------------------
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_REANIMATE;         // Death Syphon 10500
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_WALKING_BOMB;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_CRUSHING_PRISON;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_MIND_FOCUS;        // Telekinetic Weapons 10209
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_WALL_OF_FORCE;     // Force Field 17019
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_MIND_BLAST;

    // Entropy
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_MASS_PARALYSIS;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_TBD_WAS_DANCE_OF_MADNESS;  // Miasma 11122
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_PARALYZE;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_WEAKNESS;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_IMMOBILIZE;                // Death Hex 11100
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_ROOT;                      // Misdirection hex 11114
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SLOW;                      // Affliction Hex 11111
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_MASS_SLOW;                 // Vulnerability Hex 11112
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_MIND_ROT;                  // Waking Nightmare 11109
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SLEEP;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_HORROR;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_DAZE;                      // Disorient 11115
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_DEATH_CLOUD;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_SHARED_FATE;               // Curse of Mortality 11101
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_DEATH_MAGIC;
    WRK_ABILITIES_MAGE[iMage++] = ABILITY_SPELL_DRAIN_LIFE;

    WRK_ABILITIES_MAGE[iMage++] = AF_ABI_SPELL_UNLOCK_1;
    WRK_ABILITIES_MAGE[iMage++] = AF_ABI_SPELL_UNLOCK_2;
    WRK_ABILITIES_MAGE[iMage++] = AF_ABI_SPELL_UNLOCK_3;


    ////
    // DOG TALENTS master table
    ////

    int[] WRK_ABILITIES_DOG;
    int iDog = 0;

    WRK_ABILITIES_DOG[iDog++] = ABILITY_TALENT_MONSTER_DOG_OVERWHELM;
    WRK_ABILITIES_DOG[iDog++] = ABILITY_TALENT_MONSTER_DOG_COMBAT_TRAINING;
    WRK_ABILITIES_DOG[iDog++] = ABILITY_TALENT_MONSTER_MABARI_HOWL;
    WRK_ABILITIES_DOG[iDog++] = ABILITY_TALENT_MONSTER_DOG_GROWL;
    WRK_ABILITIES_DOG[iDog++] = ABILITY_TALENT_MONSTER_DOG_NEMESIS;
    WRK_ABILITIES_DOG[iDog++] = ABILITY_TALENT_MONSTER_DOG_SHRED;
    WRK_ABILITIES_DOG[iDog++] = ABILITY_TALENT_MONSTER_DOG_CHARGE;
    WRK_ABILITIES_DOG[iDog++] = ABILITY_TALENT_MONSTER_DOG_FORTITUDE;
    WRK_ABILITIES_DOG[iDog++] = AF_ABI_DOG_ENDURANCE;
    WRK_ABILITIES_DOG[iDog++] = AF_ABI_DOG_BOND;
    WRK_ABILITIES_DOG[iDog++] = AF_ABI_DOG_FRIGHTEN;
    WRK_ABILITIES_DOG[iDog++] = AF_ABI_DOG_LEAP;

    ////
    // SHALE TALENTS master table
    // Shale has both the generic warrior and his own set of talents
    ////

    int[] WRK_ABILITIES_SHALE;
    int iShale = 0;

    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_KILLING_BLOW;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_QUAKE;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_SLAM;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_PULVERIZING_BLOWS;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_REGENERATING_BURST;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_STONE_ROAR;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_BELLOW;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_STONEHEART;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_ROCK_BARRAGE;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_EARTHEN_GRASP;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_HURL_ROCK;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_ROCK_MASTERY;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_SUPERNATURAL_RESILIENCE;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_RENEWED_ASSAULT;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_INNER_RESERVES;
    WRK_ABILITIES_SHALE[iShale++] = WRK_ABILITY_SHALE_STONE_AURA;
    WRK_ABILITIES_SHALE[iShale++] = ABILITY_TALENT_DEATH_BLOW;
    WRK_ABILITIES_SHALE[iShale++] = ABILITY_TALENT_BRAVERY;
    WRK_ABILITIES_SHALE[iShale++] = ABILITY_TALENT_THREATEN;
    WRK_ABILITIES_SHALE[iShale++] = ABILITY_TALENT_POWERFUL;
    WRK_ABILITIES_SHALE[iShale++] = ABILITY_TALENT_PERFECT_STRIKING;
    WRK_ABILITIES_SHALE[iShale++] = ABILITY_TALENT_DISENGAGE;
    WRK_ABILITIES_SHALE[iShale++] = ABILITY_TALENT_TAUNT;
    WRK_ABILITIES_SHALE[iShale++] = ABILITY_TALENT_PRECISE_STRIKING;

    ////
    //  SPECIALIZATION
    ////

    // Remove all the effects so they won't get stuck on
    // the character due to an activated ability that gets
    // removed. Injuries should remain.
    RemoveAllEffects(oCharacter);

    if ( GetCreatureCoreClass(oCharacter) == CLASS_WIZARD ) {
        // Free up the mage talents
        WRK_LOOP_ABILITY(WRK_ABILITIES_MAGE, oCharacter);

        // Specializations
        WRK_FreeSpecialization(oCharacter, ABILITY_SPELL_HIDDEN_ARCANE_WARRIOR);
        WRK_FreeSpecialization(oCharacter, ABILITY_SPELL_HIDDEN_BLOODMAGE);
        WRK_FreeSpecialization(oCharacter, ABILITY_SPELL_HIDDEN_SHAPESHIFTER);
        WRK_FreeSpecialization(oCharacter, ABILITY_SPELL_HIDDEN_SPIRIT_HEALER);
    } else if ( GetCreatureCoreClass(oCharacter) == CLASS_ROGUE ) {
        // Free up the rogue talents
        WRK_LOOP_ABILITY(WRK_ABILITIES_ROGUE, oCharacter);

        // Specializations
        WRK_FreeSpecialization(oCharacter, ABILITY_TALENT_HIDDEN_ASSASSIN);
        WRK_FreeSpecialization(oCharacter, ABILITY_SPELL_HIDDEN_BARD);
        WRK_FreeSpecialization(oCharacter, ABILITY_TALENT_HIDDEN_DUELIST);
        WRK_FreeSpecialization(oCharacter, ABILITY_TALENT_HIDDEN_RANGER);

        // Let's make sure we are not stuck in stealth
        if (IsStealthy(oCharacter) == TRUE)
            DropStealth(oCharacter);
    } else if ( GetCreatureCoreClass(oCharacter) == CLASS_WARRIOR ) {
        // Shale is a warrior too, could check for race too,
        // but this is more specific. Shale has no specialization
        if ( GetName(oCharacter) == "Shale" ) {
            WRK_LOOP_ABILITY(WRK_ABILITIES_SHALE, oCharacter);
        } else {
            // Free up the warrior talents
            WRK_LOOP_ABILITY(WRK_ABILITIES_WARRIOR, oCharacter);

            // Specializations
            WRK_FreeSpecialization(oCharacter, ABILITY_TALENT_HIDDEN_CHAMPION);
            WRK_FreeSpecialization(oCharacter, ABILITY_TALENT_HIDDEN_TEMPLAR);
            WRK_FreeSpecialization(oCharacter, ABILITY_TALENT_HIDDEN_BERSERKER);
            WRK_FreeSpecialization(oCharacter, ABILITY_TALENT_HIDDEN_REAVER);
        }
    } else if ( GetCreatureCoreClass(oCharacter) == CLASS_DOG ) {
        // Free up the dog talents
        WRK_LOOP_ABILITY(WRK_ABILITIES_DOG, oCharacter);
    } else if ( GetCreatureCoreClass(oCharacter) == CLASS_SHALE ) {
        // Free up shale's talents
        WRK_LOOP_ABILITY(WRK_ABILITIES_SHALE, oCharacter);
    }

} // ! WRK_RESPEC_ABILITIES
