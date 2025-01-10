//------------------------------------------------------------------------------
// urn_functions_h
// Copyright © 2008 Bioware Corp.
//------------------------------------------------------------------------------
//
// Functions used in multiple places in the Urn plot.
//
//------------------------------------------------------------------------------
// May 14, 2008 - Owner: Grant Mackay
//------------------------------------------------------------------------------


#include "urn_constants_h"
#include "utility_h"
#include "sys_audio_h"

#include "plt_urnpt_main"
#include "plt_urn100pt_haven"
#include "plt_urn230pt_bridge"

#include "plt_gen00pt_class_race_gend"


//------------------------------------------------------------------------------
// FUNCTION PROTOTYPES
//------------------------------------------------------------------------------


/** @brief Makes all the Ash Wraiths in the Urn plot friendly.
 *
 * Cycles the Ash Wraith team members in the Urn plot assigning them all
 * the the 'Friendly' group.
 *
 * January 8, 2009 -- The wraiths are no longer going to become friendly but
 * instead just die, awarding the player XP.
 *
 * @author Grant Mackay
 **/
void URN_SetWraithsFriendly();


/** @brief Sets up the visions in the Gauntlet area of the Urn plot.
 *
 * Activates a creature appropriate to the player's background and sets up a
 * nearby talk trigger.
 *
 * @param sTag The tag of the creature being set up.
 * @author Grant Mackay
 **/
void URN_VisionSetUp(string sTag);


/** @brief Implements the bridge puzzle state.
 *
 * Checks the state of the bridge puzzle, in the gauntlet area, and activates
 * or de-activates bridge pieces as required.
 *
 * @param oArea The area the puzzle is taking place in.
 * @author Grant Mackay
 **/
void URN_ActivateBridge(object oArea);


/** @brief Activates a section of the bridge.
 *
 * Determines if a bridge section should be activated based on parameters and,
 * if so, activates it. Used by URN_ActivateBridge.
 *
 * @param nSideA1 The first switch number that must be active in order for the section to activate
 * @param nSideA2 An alternate first switch number that must be active in order for the section to activate
 * @param nSideA3 An alternate first switch number that must be active in order for the section to activate
 * @param nSideB1 The second switch number that must be active in order for the section to activate
 * @param nSideB2 An alternate second switch number that must be active in order for the section to activate
 * @param nSideB3 An alternate second switch number that must be active in order for the section to activate
 * @author Grant Mackay
 **/
void URN_ActivateSection(int nSideA1, int nSideA2, int nSideA3, int nSideB1, int nSideB2, int nSideB3, int nSection, object oArea);

/** @brief Disables a section of the bridge puzzle.
 *
 * Disables a section of the bridge puzzle by expelling any creature standing
 * on it and flagging it as inactive.
 *
 * @param oSection The placeble object section to be disabled.
 **/
void URN_DisableSection(object oSection);

/** @brief Checks for nCheckFor on the area counters.
 *
 * Checks AREA_COUNTER_1, AREA_COUNTER_2 and AREA_COUNTER_3 on oArea for
 * nCheckFor. Used to determine which switches are active on bridge puzzle
 * in the Gauntlet area of the Urn of Sacred Ashes plot.
 *
 * @param nCheckFor The number to check for
 * @param oArea The area whose variables should be polled.
 * @returns The counter (1,2 or 3) if the areas counters contains the number, FALSE otherwise
 * @author Grant Mackay
 **/
int URN_CheckBridgeCounters(int nCheckFor, object oArea);

/** @brief Sounds the alarm in the Village of Haven
 *
 * Sets the villagers of Haven into motion should the player be caught doing
 * something he should not be. Most Civilians move to the chantry while the
 * gaurds go hostile.
 *
 * @author Grant Mackay
 **/
void URN_SetVillageAlarm();

/** @brief Removes the villagers of haven from the chantry
 *
 * Collects all the villagers present in the Chantry area of the Village of
 * Haven and disables them.
 *
 * @author Grant Mackay
 **/
void URN_RemoveChantryVillagers();

/** @brief Handles item acquisitions in the Urn of Sacred Ashes plot.
 *
 * Handles plot events related to picking up certain the taper and black
 * pearl in the Urn plot.
 *
 * @author Grant Mackay
 **/
void URN_ItemAcquired();

/** @brief Sets up the Doppelganger fight in the Gauntlet.
 *
 *  Determines which player and party member clones should be activated and
 *  sets their transparency effects.
 *
 * @author Grant Mackay
 **/
void URN_SetupDoppelgangers();

/** @brief Handles riddle solution in the Gauntlet.
 *
 *  Increments the counter representing the number of riddiles answered
 *  correctly, or Ash Wraith's killed, in the riddle section of the Gauntlet.
 *
 * @param oRiddler The object activating the increment.
 *
 * @author Grant Mackay
 **/
void URN_RiddleIncrement(object oRiddler);


//------------------------------------------------------------------------------
// FUNCITON DEFINITIONS
//------------------------------------------------------------------------------


void URN_SetWraithsFriendly()
{

    object [] arAshWraiths = UT_GetTeam(URN_TEAM_ASH_WRAITHS);
    object oPC = GetHero();
    object oAshWraith;

    int nSize = GetArraySize(arAshWraiths);
    int i;

    for (i = 0; i < nSize; ++i)
    {

        oAshWraith = arAshWraiths[i];
        //SetGroupId(oAshWraith, GROUP_FRIENDLY);
        ApplyEffectVisualEffect(oAshWraith, oAshWraith, 1109 , EFFECT_DURATION_TYPE_INSTANT, 0.0);
        WR_SetObjectActive(oAshWraith, TRUE);
        SetImmortal(oAshWraith, FALSE);
        KillCreature(oAshWraith, oPC);

    }

}

void URN_VisionSetUp(string sTag)
{

    object oTarg = GetObjectByTag(sTag);

    WR_SetObjectActive(oTarg, TRUE);

    oTarg = GetObjectByTag(URN_TR_VISION_TALK);

    SetLocalString(oTarg, TRIG_TALK_SPEAKER, sTag);

}

//------------------------------------------------------------------------------
// Bridge Puzzle Functions

void URN_ActivateBridge(object oArea)
{

    // Determine if the first section should be active: 3,8 or 3,9
    URN_ActivateSection(3,-1,-1,8,9,-1,1,oArea);

    // Determine if the second section should be active: 6,8; 6,10 or 6,12
    URN_ActivateSection(6,-1,-1,8,10,12,2,oArea);

    // Determine if the third section should be active: 1,10; 1,11 or 1,7
    URN_ActivateSection(1,-1,-1,10,11,7,3,oArea);

    // Determine if the fourth section should be active: 4,11; 2,11 or 5,11
    URN_ActivateSection(4,2,5,11,-1,-1,4,oArea);

}

void URN_ActivateSection(int nSideA1, int nSideA2, int nSideA3, int nSideB1, int nSideB2, int nSideB3, int nSection, object oArea)
{

    // Check to see if the section in question should be active.
    int bFirst  = URN_CheckBridgeCounters(nSideA1, oArea) || URN_CheckBridgeCounters(nSideA2, oArea) || URN_CheckBridgeCounters(nSideA3, oArea);
    int bSecond = URN_CheckBridgeCounters(nSideB1, oArea) || URN_CheckBridgeCounters(nSideB2, oArea) || URN_CheckBridgeCounters(nSideB3, oArea);

    // Gather the section.
    object oSection = GetObjectByTag(BRIDGE_SECTION_PREFIX + IntToString(nSection));
    object oBlocker = GetObjectByTag(BRIDGE_BLOCKER_PREFIX + IntToString(nSection));

    // Ensure multiple tranperencies aren't stacked.
    effect [] arEffects = GetEffects(oSection);

    RemoveEffectArray(oSection, arEffects);

    // Active
    if (bFirst && bSecond)
    {

        SetObjectActive(oSection, TRUE);
        SetObjectActive(oBlocker, FALSE);

        // If not already active play a visual effect.
        if (!GetLocalInt(oSection, PLC_COUNTER_1))
        {

            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, EffectVisualEffect(1118), oSection);

        }

        // Flag the section as active.
        SetLocalInt(oSection, PLC_COUNTER_1, TRUE);

        if (!WR_GetPlotFlag(PLT_URN230PT_BRIDGE, URN_BRIDGE_SOLID_TILE_APPEARS))
        {
            object oPC = GetHero();

            WR_SetPlotFlag(PLT_URN230PT_BRIDGE, URN_BRIDGE_SOLID_TILE_APPEARS, TRUE);
            UT_Talk(oPC, oPC, URN_DG_PARTY_BRIDGE_HELP);
        }

    }
    // Partially active
    else if (bFirst || bSecond)
    {

        // Visual transparency to represent state.
        effect eTransparent = Effect(EFFECT_TYPE_ALPHA);

        eTransparent = SetEffectEngineFloat(eTransparent, EFFECT_FLOAT_POTENCY, 0.4);

        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eTransparent, oSection, 0.0f, oSection, 0);

        // Section AND blocker become active.
        SetObjectActive(oSection, TRUE);
        SetObjectActive(oBlocker, TRUE);
        SetObjectInteractive(oBlocker, FALSE);

        // Disable the bridge section if active.
        if (GetLocalInt(oSection, PLC_COUNTER_1))
        {
            URN_DisableSection(oSection);
        }
        else if (!WR_GetPlotFlag(PLT_URN230PT_BRIDGE, URN_BRIDGE_GHOST_TILE_APPEARS))
        {
            object oPC = GetHero();

            WR_SetPlotFlag(PLT_URN230PT_BRIDGE, URN_BRIDGE_GHOST_TILE_APPEARS, TRUE);
            UT_Talk(oPC, oPC, URN_DG_PARTY_BRIDGE_HELP);
        }

    }
    // Not active
    else
    {

        SetObjectActive(oSection, FALSE);
        SetObjectActive(oBlocker, TRUE);
        SetObjectInteractive(oBlocker, FALSE);

        // Disable the bridge section if active.
        if (GetLocalInt(oSection, PLC_COUNTER_1))
        {
            URN_DisableSection(oSection);
        }

    }

}

void URN_DisableSection(object oSection)
{

    //Determine if plarty members are standing on the section and expell them
    object [] arNearest = GetNearestObject(oSection, OBJECT_TYPE_CREATURE, 4);

    object oNearest;
    float fDistance;
    int i;

    // Cyrcle the party; they are the only 4 nearby creatures.
    for (i = 0; i < 4; ++i)
    {

        oNearest = arNearest[i];

        fDistance = GetDistanceBetween(oSection, oNearest);

        // Anything within X of the placeable is standing on it?
        if (fDistance < 2.0)
        {

            UT_LocalJump(oNearest, URN_WP_BRIDGE_PUZZLE);

            // Visual
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, EffectVisualEffect(1005), oNearest, 3.0);

            if (!WR_GetPlotFlag(PLT_URN230PT_BRIDGE, URN_BRIDGE_PLAYER_FELL))
            {
                object oPC = GetHero();

                WR_SetPlotFlag(PLT_URN230PT_BRIDGE, URN_BRIDGE_PLAYER_FELL, TRUE);
                UT_Talk(oPC, oPC, URN_DG_PARTY_BRIDGE_HELP);
            }

        }

    }

    // Flag the object as inactive.
    SetLocalInt(oSection, PLC_COUNTER_1, FALSE);

    // Visual
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, EffectVisualEffect(1118), oSection);

}

int URN_CheckBridgeCounters(int nCheckFor, object oArea)
{

    // Area counters holding active switches.
    int nCounter1 = GetLocalInt(oArea, AREA_COUNTER_1);
    int nCounter2 = GetLocalInt(oArea, AREA_COUNTER_2);
    int nCounter3 = GetLocalInt(oArea, AREA_COUNTER_3);

    // If a counter is determined to hold the desired value return the counter's number.
    if (nCounter1 == nCheckFor) return 1;
    if (nCounter2 == nCheckFor) return 2;
    if (nCounter3 == nCheckFor) return 3;

    // No counter contains the value.
    return FALSE;

}

//------------------------------------------------------------------------------
// Haven nonsense.

void URN_SetVillageAlarm()
{

    object oTarg;

    // not combat types no longer active.
    oTarg = GetObjectByTag(URN_CR_HAVEN_CHILD);
    WR_SetObjectActive(oTarg, FALSE);

    oTarg = GetObjectByTag(URN_CR_HAVEN_VILLAGER);
    WR_SetObjectActive(oTarg, FALSE);

    UT_TeamAppears(URN_TEAM_VILLAGE_POST_PLOT, FALSE);

    // Gaurd fights.
    oTarg = GetObjectByTag(URN_CR_HAVEN_GUARD);
    UT_CombatStart(oTarg, GetHero());

    // The shopkeepers talk triggers should be destroyed.
    oTarg = GetObjectByTag(URN_TR_SHOPKEEPER, 0);
    WR_SetObjectActive(oTarg, FALSE);
    oTarg = GetObjectByTag(URN_TR_SHOPKEEPER, 1);
    WR_SetObjectActive(oTarg, FALSE);

    if (!WR_GetPlotFlag(PLT_URN100PT_HAVEN, SHOPKEEPER_KILLED))
    {

        oTarg = GetObjectByTag(URN_CR_SHOPKEEPER);
        WR_SetObjectActive(oTarg, FALSE);

    }

    // Hostile villagers activate!
    UT_TeamAppears(URN_TEAM_VILLAGE_AMBUSH);
    UT_TeamGoesHostile(URN_TEAM_VILLAGE_AMBUSH);

}

void URN_RemoveChantryVillagers()
{

    UT_TeamAppears(URN_TEAM_CHANTRY_VILLAGERS, FALSE);

}

//------------------------------------------------------------------------------
// Universal item acquisition

void URN_ItemAcquired()
{

    int bPearl = UT_CountItemInInventory(URN_IT_PEARL_R);
    int bTaper = UT_CountItemInInventory(URN_IT_TAPER_R);

    if (bPearl && bTaper)
    {

        object oBrazier = GetObjectByTag(URN_IP_WRAITH_BRAZIER);

        SetObjectInteractive(oBrazier, TRUE);

    }

}

//------------------------------------------------------------------------------
// Doppelganger fight set up

void URN_SetupDoppelgangers()
{

    // De-activate anything currently active.
    object [] arTeam = UT_GetTeam(URN_TEAM_DOPPELGANGER);
    int nTeamSize = GetArraySize(arTeam);

    object oTeam;
    int nIndex;

    for (nIndex = 0; nIndex < nTeamSize; ++nIndex)
    {
        object oTeam = arTeam[nIndex];
        SetTeamId(oTeam, -1);
        WR_SetObjectActive(oTeam, FALSE);
    }


    // Determine which player doppelganger to activate.
    object []   arParty;
    object      oPC, oParty, oDplg;
    string      sTag;
    int         nGender, nClass, nRace, nSize, nNth;

    oPC     = GetHero();
    nGender = GetCreatureGender(oPC);
    nClass  = GetCreatureCoreClass(oPC);
    nRace   = GetCreatureRacialType(oPC);


    // Rogue
    if (nClass == CLASS_ROGUE)
    {
        if (nGender == GENDER_FEMALE)
        {
            if (nRace == RACE_DWARF)
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_ROGUE_F_D);
            }
            else if (nRace == RACE_ELF)
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_ROGUE_F_E);
            }
            else
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_ROGUE_F);
            }
        }
        else
        {
            if (nRace == RACE_DWARF)
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_ROGUE_M_D);
            }
            else if (nRace == RACE_ELF)
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_ROGUE_M_E);
            }
            else
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_ROGUE_M);
            }
        }
    }

    // Warrior
    else if (nClass == CLASS_WARRIOR)
    {
        if (nGender == GENDER_FEMALE)
        {
            if (nRace == RACE_DWARF)
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_WARRIOR_F_D);
            }
            else if (nRace == RACE_ELF)
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_WARRIOR_F_E);
            }
            else
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_WARRIOR_F);
            }
        }

        else
        {
            if (nRace == RACE_DWARF)
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_WARRIOR_M_D);
            }
            else if (nRace == RACE_ELF)
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_WARRIOR_M_E);
            }
            else
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_WARRIOR_M);
            }
        }
    }

    // Wizard
    if (nClass == CLASS_WIZARD)
    {
        if (nGender == GENDER_FEMALE)
        {
            if (nRace == RACE_ELF)
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_MAGE_F_E);
            }
            else
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_MAGE_F);
            }
        }

        else
        {
            if (nRace == RACE_ELF)
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_MAGE_M_E);
            }
            else
            {
                oDplg = GetObjectByTag(URN_CR_DPLG_MAGE_M);
            }
        }
    }

    effect eTransparent = Effect( EFFECT_TYPE_ALPHA );
    eTransparent = SetEffectEngineFloat( eTransparent, EFFECT_FLOAT_POTENCY, 0.5 );

    SetObjectActive(oDplg, TRUE);
    AddAbility(oDplg, ABILITY_TRAIT_GHOST);
    SetName(oDplg, GetName(oPC));
    ApplyEffectOnObject( EFFECT_DURATION_TYPE_PERMANENT, eTransparent, oDplg );


    SetTeamId(oDplg, URN_TEAM_DOPPELGANGER);


    // Activate follower clones
    arParty = GetPartyList();
    nSize   = GetArraySize(arParty);

    for (nNth = 0; nNth < nSize; ++nNth)
    {

        oParty  = arParty[nNth];
        sTag    = GetTag(oParty);
        oDplg   = GetObjectByTag(sTag + "_dplg");

        SetObjectActive(oDplg, TRUE);
        AddAbility(oDplg, ABILITY_TRAIT_GHOST);
        SetTeamId(oDplg, URN_TEAM_DOPPELGANGER);
        ApplyEffectOnObject( EFFECT_DURATION_TYPE_PERMANENT, eTransparent, oDplg );

        if (sTag == GEN_FL_DOG)
        {
            SetName(oDplg, GetName(oParty));
        }
        
        if (sTag == GEN_FL_SHALE)
        {
            SetCreatureRank(oDplg, 3);   
        }

    }

}


//------------------------------------------------------------------------------
// Riddle section

void URN_RiddleIncrement(object oRiddler)
{

    object oArea = GetArea(oRiddler);
    object oDoor = GetObjectByTag(URN_IP_RIDDLE_DOOR);
    int nRiddle = GetLocalInt(oArea, AREA_COUNTER_8);

    // Update riddle counter
    nRiddle++;

    SetLocalInt(oArea, AREA_COUNTER_8, nRiddle);

    // If all riddles have been answered open the door
    if (nRiddle == 8)
    {

        AudioTriggerPlotEvent(86);
        UT_OpenDoor(oDoor, oDoor);
        nRiddle = 0;

    }

    // Set the new riddle counter value
    SetLocalInt(oArea, AREA_COUNTER_8, nRiddle);

    // Visual feedback
    vector vSource = GetPosition(oRiddler);
    vector vTarget = GetPosition(oDoor);

    vSource.z += 1.0f;
    vTarget.z += 1.0f;

    FireProjectile(211, vSource, vTarget, 0, TRUE);
    FireProjectile(211, vSource, vTarget, 0, TRUE);

    SetObjectActive(oRiddler, FALSE);

}