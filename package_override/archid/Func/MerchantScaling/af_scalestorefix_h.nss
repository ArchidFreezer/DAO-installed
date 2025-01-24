/*
 * This code id from the Merchant Scaling Tweaks mod
 * https://www.nexusmods.com/dragonage/mods/6211
 *
 * It is included here to allow for other scripts to be recompiled to merge mods
 */
void ScaleStoreEdited(object oStore, int bReset = FALSE)
{
    // check for duplicate specialization books
    int nSpecialization;
    object [] oItems = GetItemsInInventory(oStore, GET_ITEMS_OPTION_ALL);
    int nSize = GetArraySize(oItems);
    int nCount = 0;
    string acvId;
    for (nCount = 0; nCount < nSize; nCount++)
    {
        nSpecialization = GetLocalInt(oItems[nCount], ITEM_SPECIALIZATION_FLAG);
        if (nSpecialization > 0)
        {
            acvId = GetM2DAString(TABLE_ACHIEVEMENTS, "AchievementID", nSpecialization);
            if (GetHasAchievement(acvId) == TRUE)
            {
                DestroyObject(oItems[nCount]);
            }
        }
    }

    // Remove backpack items from store if party's inventory size is already maximized.
    if (GetMaxInventorySize() >= 125)
    {
        RemoveItemsByTag(oStore, "gen_im_misc_backpack");
    }

    // Only scale the merchant the first time opened.
    /*if (GetLocalInt(oStore, "MERCHANT_IS_SCALED") && !bReset)
    {
        return;
    }*/

    SetLocalInt(oStore, "MERCHANT_IS_SCALED", 1);

    int nStoreBase = GetLocalInt(oStore, "MERCHANT_LEVEL_OVERRIDE");
    int nStoreLevel; 
    int nPlayer = GetLevel(GetHero());
    if (nStoreBase > 0)  
    {
        nStoreLevel = nStoreBase;
    } else
    {
        nStoreLevel = nPlayer;
    }
    int nStoreLevelModifier = GetLocalInt(oStore, "MERCHANT_LEVEL_MODIFIER");

    // modify and enforce range
    nStoreLevel += nStoreLevelModifier;
    nStoreLevel = Max(nStoreLevel, 1);
    nStoreLevel = Min(nStoreLevel, 45);

    int nItemType;
    int nMaterialProgression;
    int nColumn;
    int nOldMaterial;
    int nNewMaterial;
    float fHighChance = GetLocalFloat(oStore, "MERCHANT_HIGH_CHANCE");
    int nHighModifier = 3;

    nCount = 0;
    for (nCount = 0; nCount < nSize; nCount++)
    {
        // if appropriate type (armor, shield, melee weapon, ranged weapon, STAFF)
        nItemType = GetItemType(oItems[nCount]);

        if ((nItemType == ITEM_TYPE_ARMOUR) || (nItemType == ITEM_TYPE_SHIELD) || (nItemType == ITEM_TYPE_WEAPON_MELEE) || (nItemType == ITEM_TYPE_WEAPON_RANGED) || (nItemType == ITEM_TYPE_WEAPON_WAND))
        {
            SetLocalInt(oItems[nCount], "ITEM_RUNE_ENABLED", 1); 
            
            // if not unique         
            if (GetItemUnique(oItems[nCount]) == FALSE)
            {
                // get material progression
                nMaterialProgression = GetItemMaterialProgression(oItems[nCount]);

                if (nMaterialProgression > 0)
                {
                    if (RandomFloat() < fHighChance)
                    {
                        nStoreLevel += nHighModifier;
                    }

                    nStoreLevel = Max(1, nStoreLevel);
                    nStoreLevel = Min(45, nStoreLevel);

                    // find material column
                    nColumn = ((nStoreLevel - 1) / 3) + 1;

                    nColumn = Max(1, nColumn);
                    nColumn = Min(15, nColumn);

                    // get material
                    nOldMaterial = GetItemMaterialType(oItems[nCount]);
                    nNewMaterial = GetM2DAInt(TABLE_MATERIAL, "Material" + ToString(nColumn), nMaterialProgression);

                    // set new material if better (89 = materialtypes from m2da_base)
                    int nNewMatLevel = GetM2DAInt(89, "Material", nNewMaterial);
                    int nOldMatLevel = GetM2DAInt(89, "Material", nOldMaterial);
                    if (nNewMatLevel > nOldMatLevel)
                    {
                        SetItemMaterialType(oItems[nCount], nNewMaterial);
                    }
                }
            }
        }
    }
}