//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC Attribute respecialization
// Owner: Peter 'weriK' Kovacs
// Date: 11/10/2009 @ 4:31 AM
//
/////////////////////////////////////////////////////////////////

#include "af_respec_utility_h"

/** @brief Resets the attribute points
*
*   This function frees the previous allocated attribute
*   points. It sets every attribute to fValue ( must be between 1.0f
*   and SumOfAllAttributePoints/6) and allows the player to reassign
*   the rest of the points.
*
* @param oCharacter - Character
* @param fValue     - Starting value of every attribute after reset
* @author weriK
**/
void WRK_RESPEC_ATTRIBUTES(object oCharacter, float fValue = 1.0f)
{
    // Retrieve the base attribute values and
    // calculate the total amount we will have to give back to the player.
    float fStr = WRK_GetStr(oCharacter);
    float fDex = WRK_GetDex(oCharacter);
    float fWil = WRK_GetWil(oCharacter);
    float fMag = WRK_GetMag(oCharacter);
    float fInt = WRK_GetInt(oCharacter);
    float fCon = WRK_GetCon(oCharacter);
    float fSum = fStr+fDex+fWil+fMag+fInt+fCon;

    // Retrieve the character's race and core class
    int iRace  = GetCreatureRacialType(oCharacter);

    // Retrieve the character's core class
    int iClass = GetCreatureCurrentClass(oCharacter);

    ////
    //  HUMANOIDS
    ////
    switch (iRace) {
        // Humans
        case RACE_HUMAN: {
            switch (iClass) {
                case CLASS_ROGUE: {
                    WRK_SetAllBaseAttributes(oCharacter, WRK_HR_STR, WRK_HR_DEX, WRK_HR_WIL, WRK_HR_MAG, WRK_HR_INT, WRK_HR_CON);
                    // Return the rest of the attribute points to the characters.
                    // Every character has WRK_START_ATTR_SUM points spent by default
                    // at character generation (excluding the extra 5 you can choose)
                    WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_HUMANOID);
                    break;
                }
                case CLASS_WARRIOR: {
                    WRK_SetAllBaseAttributes(oCharacter, WRK_HW_STR, WRK_HW_DEX, WRK_HW_WIL, WRK_HW_MAG, WRK_HW_INT, WRK_HW_CON);
                    WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_HUMANOID);
                    break;
                }
                case CLASS_WIZARD: {
                    WRK_SetAllBaseAttributes(oCharacter, WRK_HM_STR, WRK_HM_DEX, WRK_HM_WIL, WRK_HM_MAG, WRK_HM_INT, WRK_HM_CON);
                    WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_HUMANOID);
                    break;
                }
            } // ! switch class
            break;
        } // ! case human

        // Elves
        case RACE_ELF: {
            switch (iClass) {
                case CLASS_ROGUE: {
                    WRK_SetAllBaseAttributes(oCharacter, WRK_ER_STR, WRK_ER_DEX, WRK_ER_WIL, WRK_ER_MAG, WRK_ER_INT, WRK_ER_CON);
                    WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_HUMANOID);
                    break;
                }
                case CLASS_WARRIOR: {
                    WRK_SetAllBaseAttributes(oCharacter, WRK_EW_STR, WRK_EW_DEX, WRK_EW_WIL, WRK_EW_MAG, WRK_EW_INT, WRK_EW_CON);
                    WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_HUMANOID);
                    break;
                }
                case CLASS_WIZARD: {
                    WRK_SetAllBaseAttributes(oCharacter, WRK_EM_STR, WRK_EM_DEX, WRK_EM_WIL, WRK_EM_MAG, WRK_EM_INT, WRK_EM_CON);
                    WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_HUMANOID);
                    break;
                }
            } // ! switch class
            break;
        } // ! case elf

        // Dwarves
        case RACE_DWARF: {
            switch (iClass) {
                case CLASS_ROGUE: {
                    WRK_SetAllBaseAttributes(oCharacter, WRK_DR_STR, WRK_DR_DEX, WRK_DR_WIL, WRK_DR_MAG, WRK_DR_INT, WRK_DR_CON);
                    WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_HUMANOID);
                    break;
                }
                case CLASS_WARRIOR: {
                    WRK_SetAllBaseAttributes(oCharacter, WRK_DW_STR, WRK_DW_DEX, WRK_DW_WIL, WRK_DW_MAG, WRK_DW_INT, WRK_DW_CON);
                    WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_HUMANOID);
                    break;
                }
            } // ! switch class
            break;
        } // ! case dwarf

        // Qunari (Sten)
        case RACE_QUNARI: {
            if (iClass == CLASS_WARRIOR) {
                // Only one class here, Sten is a warrior
                WRK_SetAllBaseAttributes(oCharacter, WRK_QN_STR, WRK_QN_DEX, WRK_QN_WIL, WRK_QN_MAG, WRK_QN_INT, WRK_QN_CON);
                WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_QUNARI);
            }
            break;
        } // ! case qunari

        // Animal
        case RACE_ANIMAL: {
            if (iClass == CLASS_DOG) {
                WRK_SetAllBaseAttributes(oCharacter, WRK_DG_STR, WRK_DG_DEX, WRK_DG_WIL, WRK_DG_MAG, WRK_DG_INT, WRK_DG_CON);
                WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_DOG);
            }
            break;
        } // ! case animal

        // Golem (Shale)
        case RACE_GOLEM: {
            // NOTE: CLASS_SHALE (16) is not the correct class
            if (iClass == CLASS_WARRIOR && GetName(oCharacter) == "Shale") {
                WRK_SetAllBaseAttributes(oCharacter, WRK_SH_STR, WRK_SH_DEX, WRK_SH_WIL, WRK_SH_MAG, WRK_SH_INT, WRK_SH_CON);
                WRK_GiveAttributePoints(oCharacter, fSum-WRK_START_ATTR_SUM_SHALE);
            }
            break;
        } // ! case golem

        break;

    } // ! switch race
}