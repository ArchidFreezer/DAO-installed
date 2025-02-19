//////////////////////////////////////////////////////////////////
//
// Description: Utility functions for WRK_RESPEC
// Owner: Peter 'weriK' Kovacs
// Date: 11/10/2009 @ 4:31 AM
//
/////////////////////////////////////////////////////////////////

#include "attributes_h"

////
//  Popup Window Types
////

const int WRK_POPUP_MESSAGE_INVALID                 = 0;
const int WRK_POPUP_MESSAGE_QUESTION                = 1;
const int WRK_POPUP_MESSAGE_INPUT                   = 2;
const int WRK_POPUP_MESSAGE_BLOCKING_PLACEABLE      = 3;
const int WRK_POPUP_MESSAGE_MESSAGE                 = 4;
const int WRK_POPUP_MESSAGE_PRE_CHARGEN             = 5;

////
//  Shale DLC Ability ID list
////

const int WRK_ABILITY_SHALE_PULVERIZING_BLOWS       = 300100;
const int WRK_ABILITY_SHALE_SLAM                    = 300101;
const int WRK_ABILITY_SHALE_QUAKE                   = 300102;
const int WRK_ABILITY_SHALE_KILLING_BLOW            = 300103;
const int WRK_ABILITY_SHALE_STONEHEART              = 300200;
const int WRK_ABILITY_SHALE_BELLOW                  = 300201;
const int WRK_ABILITY_SHALE_STONE_ROAR              = 300202;
const int WRK_ABILITY_SHALE_REGENERATING_BURST      = 300203;
const int WRK_ABILITY_SHALE_ROCK_MASTERY            = 300300;
const int WRK_ABILITY_SHALE_HURL_ROCK               = 300301;
const int WRK_ABILITY_SHALE_EARTHEN_GRASP           = 300302;
const int WRK_ABILITY_SHALE_ROCK_BARRAGE            = 300303;
const int WRK_ABILITY_SHALE_STONE_AURA              = 300400;
const int WRK_ABILITY_SHALE_INNER_RESERVES          = 300401;
const int WRK_ABILITY_SHALE_RENEWED_ASSAULT         = 300402;
const int WRK_ABILITY_SHALE_SUPERNATURAL_RESILIENCE = 300403;

////
//  Starting attributes
////

const float WRK_START_ATTR_SUM_HUMANOID = 74.0f;
const float WRK_START_ATTR_SUM_QUNARI   = 70.0f;
const float WRK_START_ATTR_SUM_DOG      = 70.0f;
const float WRK_START_ATTR_SUM_SHALE    = 70.0f;

// Human Warrior
const float WRK_HW_STR = 15.0f;
const float WRK_HW_DEX = 14.0f;
const float WRK_HW_WIL = 10.0f;
const float WRK_HW_MAG = 11.0f;
const float WRK_HW_INT = 11.0f;
const float WRK_HW_CON = 13.0f;

// Human Mage
const float WRK_HM_STR = 11.0f;
const float WRK_HM_DEX = 11.0f;
const float WRK_HM_WIL = 14.0f;
const float WRK_HM_MAG = 16.0f;
const float WRK_HM_INT = 12.0f;
const float WRK_HM_CON = 10.0f;

// Human Rogue
const float WRK_HR_STR = 11.0f;
const float WRK_HR_DEX = 15.0f;
const float WRK_HR_WIL = 12.0f;
const float WRK_HR_MAG = 11.0f;
const float WRK_HR_INT = 15.0f;
const float WRK_HR_CON = 10.0f;

// Elf Warrior
const float WRK_EW_STR = 14.0f;
const float WRK_EW_DEX = 13.0f;
const float WRK_EW_WIL = 12.0f;
const float WRK_EW_MAG = 12.0f;
const float WRK_EW_INT = 10.0f;
const float WRK_EW_CON = 13.0f;

// Elf Mage
const float WRK_EM_STR = 10.0f;
const float WRK_EM_DEX = 10.0f;
const float WRK_EM_WIL = 16.0f;
const float WRK_EM_MAG = 17.0f;
const float WRK_EM_INT = 11.0f;
const float WRK_EM_CON = 10.0f;

// Elf Rogue
const float WRK_ER_STR = 10.0f;
const float WRK_ER_DEX = 14.0f;
const float WRK_ER_WIL = 14.0f;
const float WRK_ER_MAG = 12.0f;
const float WRK_ER_INT = 14.0f;
const float WRK_ER_CON = 10.0f;

// Dwarf Warrior
const float WRK_DW_STR = 15.0f;
const float WRK_DW_DEX = 14.0f;
const float WRK_DW_WIL = 10.0f;
const float WRK_DW_MAG = 10.0f;
const float WRK_DW_INT = 10.0f;
const float WRK_DW_CON = 15.0f;

// Dwarf Rogue
const float WRK_DR_STR = 11.0f;
const float WRK_DR_DEX = 15.0f;
const float WRK_DR_WIL = 12.0f;
const float WRK_DR_MAG = 10.0f;
const float WRK_DR_INT = 14.0f;
const float WRK_DR_CON = 12.0f;

// Qunari Warrior
const float WRK_QN_STR = 14.0f;
const float WRK_QN_DEX = 13.0f;
const float WRK_QN_WIL = 10.0f;
const float WRK_QN_MAG = 10.0f;
const float WRK_QN_INT = 10.0f;
const float WRK_QN_CON = 13.0f;

// Mabari Warhound
const float WRK_DG_STR = 12.0f;
const float WRK_DG_DEX = 12.0f;
const float WRK_DG_WIL = 10.0f;
const float WRK_DG_MAG = 10.0f;
const float WRK_DG_INT = 10.0f;
const float WRK_DG_CON = 16.0f;

// Shale DLC extra character
const float WRK_SH_STR = 14.0f;
const float WRK_SH_DEX = 13.0f;
const float WRK_SH_WIL = 10.0f;
const float WRK_SH_MAG = 10.0f;
const float WRK_SH_INT = 10.0f;
const float WRK_SH_CON = 13.0f;


////
// Helper functions to retrieve attributes
////

/** @brief Retrieves the base strength of a creature
* @param oCreature - The creature
* @author weriK
**/
float WRK_GetStr(object oCreature)
{
    return IntToFloat(GetCreatureAttribute(oCreature, PROPERTY_ATTRIBUTE_STRENGTH, PROPERTY_VALUE_BASE));
}

/** @brief Retrieves the base dexterity of a creature
* @param oCreature - The creature
* @author weriK
**/
float WRK_GetDex(object oCreature)
{
    return IntToFloat(GetCreatureAttribute(oCreature, PROPERTY_ATTRIBUTE_DEXTERITY, PROPERTY_VALUE_BASE));
}

/** @brief Retrieves the base willpower of a creature
* @param oCreature - The creature
* @author weriK
**/
float WRK_GetWil(object oCreature)
{
    return IntToFloat(GetCreatureAttribute(oCreature, PROPERTY_ATTRIBUTE_WILLPOWER, PROPERTY_VALUE_BASE));
}

/** @brief Retrieves the base magic of a creature
* @param oCreature - The creature
* @author weriK
**/
float WRK_GetMag(object oCreature)
{
    return IntToFloat(GetCreatureAttribute(oCreature, PROPERTY_ATTRIBUTE_MAGIC, PROPERTY_VALUE_BASE));
}

/** @brief Retrieves the base intellect/cunning of a creature
* @param oCreature - The creature
* @author weriK
**/
float WRK_GetInt(object oCreature)
{
    return IntToFloat(GetCreatureAttribute(oCreature, PROPERTY_ATTRIBUTE_INTELLIGENCE, PROPERTY_VALUE_BASE));
}

/** @brief Retrieves the base constitution of a creature
* @param oCreature - The creature
* @author weriK
**/
float WRK_GetCon(object oCreature)
{
    return IntToFloat(GetCreatureAttribute(oCreature, PROPERTY_ATTRIBUTE_CONSTITUTION, PROPERTY_VALUE_BASE));
}

/** @brief Sets all 6 attributes to the specified value
* @param oCreature - The creature
* @param fStr    - Specifies the strength attribute's value, 1.0f by default.
* @param fDex    - Specifies the dexterity attribute's value, 1.0f by default.
* @param fWil    - Specifies the willpower attribute's value, 1.0f by default.
* @param fMag    - Specifies the magic attribute's value, 1.0f by default.
* @param fInt    - Specifies the intelligence(cunning) attribute's value, 1.0f by default.
* @param fCon    - Specifies the constitution attribute's value, 1.0f by default.
* @author weriK
**/
void WRK_SetAllBaseAttributes(object oCreature,
                              float fStr = 1.0f,
                              float fDex = 1.0f,
                              float fWil = 1.0f,
                              float fMag = 1.0f,
                              float fInt = 1.0f,
                              float fCon = 1.0f)
{
    SetCreatureProperty( oCreature, PROPERTY_ATTRIBUTE_STRENGTH, fStr, PROPERTY_VALUE_BASE);
    SetCreatureProperty( oCreature, PROPERTY_ATTRIBUTE_DEXTERITY, fDex, PROPERTY_VALUE_BASE);
    SetCreatureProperty( oCreature, PROPERTY_ATTRIBUTE_WILLPOWER, fWil, PROPERTY_VALUE_BASE);
    SetCreatureProperty( oCreature, PROPERTY_ATTRIBUTE_MAGIC, fMag, PROPERTY_VALUE_BASE);
    SetCreatureProperty( oCreature, PROPERTY_ATTRIBUTE_INTELLIGENCE, fInt, PROPERTY_VALUE_BASE);
    SetCreatureProperty( oCreature, PROPERTY_ATTRIBUTE_CONSTITUTION, fCon, PROPERTY_VALUE_BASE);
}

/** @brief Sets an attribute to the specified value
* @param oCreature - The creature
* @param nProp     - The ID of the attribute we wish to change
* @param fValue    - Specifies the attribute value, 1.0f by default.
* @author weriK
**/
void WRK_SetBaseAttribute(object oCreature, int nProp, float fValue = 1.0f)
{
    SetCreatureProperty( oCreature, nProp, fValue, PROPERTY_VALUE_BASE);
}

/** @brief Gives a specified amount of attribute points to the creature
* @param oCreature - The creature
* @param fValue    - Specifies the amount, 1.0f by default.
* @author weriK
**/
void WRK_GiveAttributePoints(object oCreature, float fValue = 1.0f)
{
    // First check if the character has unassigned attribute points
    float fUnassigned = IntToFloat(GetCreatureAttribute(oCreature, PROPERTY_SIMPLE_ATTRIBUTE_POINTS, PROPERTY_VALUE_TOTAL));

    // Now we can give attribute points to the character
    SetCreatureProperty(oCreature, PROPERTY_SIMPLE_ATTRIBUTE_POINTS, fValue+fUnassigned);
}

/** @brief Gives a specified amount of skill points to the creature
* @param oCreature - The creature
* @param fValue    - Specifies the amount, 1.0f by default.
* @author weriK
**/
void WRK_GiveSkillPoints(object oCreature, float fValue = 1.0f)
{
    float fUnassigned = IntToFloat(GetCreatureAttribute(oCreature, PROPERTY_SIMPLE_SKILL_POINTS, PROPERTY_VALUE_TOTAL));
    SetCreatureProperty(oCreature, PROPERTY_SIMPLE_SKILL_POINTS, fValue+fUnassigned);
}

/** @brief Gives a specified amount of spell/talent points to the creature
* @param oCreature - The creature
* @param fValue    - Specifies the amount, 1.0f by default.
* @author weriK
**/
void WRK_GiveTalentPoints(object oCreature, float fValue = 1.0f)
{
    float fUnassigned = IntToFloat(GetCreatureAttribute(oCreature, PROPERTY_SIMPLE_TALENT_POINTS, PROPERTY_VALUE_TOTAL));
    SetCreatureProperty(oCreature, PROPERTY_SIMPLE_TALENT_POINTS, fValue+fUnassigned);
}

/** @brief Gives a specified amount of specialization points to the creature
* @param oCreature - The creature
* @param fValue    - Specifies the amount, 1.0f by default.
* @author weriK
**/
void WRK_GiveSpecPoints(object oCreature, float fValue = 1.0f)
{
    float fUnassigned = IntToFloat(GetCreatureAttribute(oCreature, 38, PROPERTY_VALUE_TOTAL));
    SetCreatureProperty(oCreature, 38, fValue+fUnassigned);  // 38 is the spec point ID

}

/** @brief Resets the specified specialization if the creature has it and returns a specialization point
* @param oCreature - The creature
* @param iSpec     - Property ID of the specialization
* @author weriK
**/
void WRK_FreeSpecialization(object oCreature, int iSpec)
{
    // Check whether the creature currently has the specialization learned
    // if it does, we remove it and give one spec point in return
    if ( HasAbility(oCreature, iSpec) )
    {
        RemoveAbility(oCreature, iSpec);
        WRK_GiveSpecPoints(oCreature);
    }
}

/** @brief Clears all abilities in the creatures quickslots
* @param oCreature - The creature
* @author weriK
**/
void WRK_ClearQuickslots(object oCreature)
{
    int i;
    for ( i = 0; i< 256; i++ )
        SetQuickslot(oCreature, i, 0);
}
