// -----------------------------------------------------------------------------
// sys_treasure_h
// -----------------------------------------------------------------------------
/*
    Treasure System
*/
// -----------------------------------------------------------------------------
// Owner: PeterT
// -----------------------------------------------------------------------------


#include "core_h"
#include "sys_classify_h"
#include "sys_rewards_h"
#include "2da_constants_h"
#include "sys_areabalance"

const int TS_MATERIAL_COLUMN_MIN = 1;
const int TS_MATERIAL_COLUMN_MAX = 15;
const int TS_MONEY_MULTIPLIER = 6;
const int TS_LEVEL_MIN = 1;
const int TS_LEVEL_MAX = 45;

const int TS_GLOBAL_MONEY_DROP_CHANCE = 30; //percent

const string TS_OVERRIDE_RANK = "TS_OVERRIDE_RANK";
const string TS_OVERRIDE_CATEGORY = "TS_OVERRIDE_CATEGORY";
const string TS_OVERRIDE_MONEY = "TS_OVERRIDE_MONEY";
const string TS_OVERRIDE_ITEM_NUM = "TS_OVERRIDE_ITEM";
const string TS_OVERRIDE_HIGH_CHANCE = "TS_OVERRIDE_HIGH";
const string TS_OVERRIDE_EQUIPMENT_CHANCE = "TS_OVERRIDE_EQUIPMENT";
const string TS_OVERRIDE_OBJECT_TYPE = "TS_OVERRIDE_SCALING";
const string TS_OVERRIDE_STEALING = "TS_OVERRIDE_STEALING";
const string TS_OVERRIDE_REACTIVE = "TS_OVERRIDE_REACTIVE";
const string TS_TREASURE_GENERATED = "TS_TREASURE_GENERATED";

const string TS_COLUMN_LOW_TABLE = "TS_LowTable";
const string TS_COLUMN_HIGH_TABLE = "TS_HighTable";
const string TS_COLUMN_MONEY = "TS_Money";
const string TS_COLUMN_ITEM_NUM = "TS_ItemNum";
const string TS_COLUMN_HIGH_CHANCE = "TS_HighChance";
const string TS_COLUMN_EQUIPMENT_CHANCE = "TS_EquipmentChance";

const string TS_COLUMN_PREFIX = "Prefix";
const string TS_COLUMN_RESOURCE = "Resource";
const string TS_COLUMN_STACK_SIZE = "StackSize";
const string TS_COLUMN_DO_NOT_DROP = "DoNotDrop";

const string TS_OBJECT_CREATURE = "Cre";
const string TS_OBJECT_PLACEABLE = "Plc";

const resource rMoney = R"gen_im_copper.uti";

const float REACTIVE_MANA_FACTOR = 1.0f;
const float REACTIVE_TIER1_VALUE = 0.4f;
const float REACTIVE_TIER2_VALUE = 0.3f;
const float REACTIVE_TIER3_VALUE = 0.2f;
const float REACTIVE_TIER4_VALUE = 0.1f;

const float REACTIVE_HEALTH_BASE_CHANCE = 0.1f;
const float REACTIVE_MANA_BASE_CHANCE = 0.1f;
const float REACTIVE_INJURY_BASE_CHANCE = 0.2;
const resource REACTIVE_TIER1_HEALTH = R"gen_im_qck_health_101.uti";
const resource REACTIVE_TIER2_HEALTH = R"gen_im_qck_health_201.uti";
const resource REACTIVE_TIER3_HEALTH = R"gen_im_qck_health_301.uti";
const resource REACTIVE_TIER4_HEALTH = R"gen_im_qck_health_401.uti";
const resource REACTIVE_TIER1_MANA = R"gen_im_qck_mana_101.uti";
const resource REACTIVE_TIER2_MANA = R"gen_im_qck_mana_201.uti";
const resource REACTIVE_TIER3_MANA = R"gen_im_qck_mana_301.uti";
const resource REACTIVE_TIER4_MANA = R"gen_im_qck_mana_401.uti";

int TS_GetRank(object oTarget);
int TS_GetCategory(object oTarget);
int TS_GetLevel(object oTarget, int nRank);
int TS_GetScaledMoney(int nLevel, int nDropSize);
void TS_ScaleItem(object oItem, int nLevel);
int TS_GetItemNum(float fItemNum, int nObjectType);

void TS_GenerateMoney(object oTarget, int nRank, int nLevel, int nMoneyOverride = 0);
void TS_GenerateItems(object oTarget, int nRank, int nCategory, int nLevel, int nObjectType = OBJECT_TYPE_CREATURE, float fNumOverride = 0.0f, float fChanceOverride = 0.0f, int bStolen = FALSE);
void TS_GenerateEquipment(object oTarget, int nRank, float fOverride = 1.0f);
void TS_ScaleInventory(object oTarget, int nLevel);
int TS_GetHealthPotions(object oTarget);
int TS_GetManaPotions(object oTarget);

void TreasureGenerate(object oTarget);
void TreasureStolen(object oTarget, object oThief);

// get target's treasure rank
int TS_GetRank(object oTarget)
{
    int nRank = GetLocalInt(oTarget, TS_OVERRIDE_RANK);
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Override nRank = " + ToString(nRank), OBJECT_SELF);
    #endif

    // if not overridden
    if (nRank == 0)
    {
        int nObjectType = GetObjectType(oTarget);
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nObjectType = " + ToString(nObjectType), OBJECT_SELF);
        #endif

        if (nObjectType == OBJECT_TYPE_CREATURE)
        {
            nRank = GetCreatureRank(oTarget);
        } else if (nObjectType == OBJECT_TYPE_PLACEABLE)
        {
            nRank = GetPlaceableTreasureRank(oTarget);
        }
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nRank = " + ToString(nRank), OBJECT_SELF);
        #endif
    }

    return nRank;
}

// get target's treasure category
int TS_GetCategory(object oTarget)
{
    int nCategory = GetLocalInt(oTarget, TS_OVERRIDE_CATEGORY);
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Override nCategory = " + ToString(nCategory), OBJECT_SELF);
    #endif

    // if not overridden
    if (nCategory == 0)
    {
        int nObjectType = GetObjectType(oTarget);
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nObjectType = " + ToString(nObjectType), OBJECT_SELF);
        #endif

        if (nObjectType == OBJECT_TYPE_CREATURE)
        {
            nCategory = GetCreatureTreasureCategory(oTarget);
        } else if (nObjectType == OBJECT_TYPE_PLACEABLE)
        {
            nCategory = GetPlaceableTreasureCategory(oTarget);
        }
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nCategory = " + ToString(nCategory), OBJECT_SELF);
        #endif
    }

    return nCategory;
}

int TS_GetLevel(object oTarget, int nRank)
{
    int nLevel = GetLevel(oTarget);
    if (nLevel < 1)
    {
        nLevel = AB_GetAreaTargetLevel(oTarget);
        nLevel += GetM2DAInt(TABLE_AUTOSCALE, "nLevelScale", nRank);
        if (nLevel < 1)
        {
            nLevel = 1;
        }
    }
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  nLevel = " + ToString(nLevel));
    #endif

    return nLevel;
}

// get single-drop money scaled to level and drop size
int TS_GetScaledMoney(int nLevel, int nDropSize)
{
    int nMoney = TS_MONEY_MULTIPLIER * nLevel * nLevel;
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    Initial nMoney = " + ToString(nMoney));
    #endif

    // money base
    nMoney *= nDropSize;
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    Semi-Final nMoney = " + ToString(nMoney));
    #endif

    // 80-120%
    nMoney = FloatToInt(nMoney * (0.8f + (RandomFloat() * 0.4f)));
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    Final nMoney = " + ToString(nMoney));
    #endif

    return nMoney;
}

// scale the material of an item
void TS_ScaleItem(object oItem, int nLevel)
{
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    Scaling " + GetTag(oItem));
    #endif

    // if appropriate type (armor, shield, melee weapon, ranged weapon)
    int nItemType = GetItemType(oItem);
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      nItemType = " + ToString(nItemType));
    #endif
    if ((nItemType == ITEM_TYPE_ARMOUR) || (nItemType == ITEM_TYPE_SHIELD) || (nItemType == ITEM_TYPE_WEAPON_MELEE) || (nItemType == ITEM_TYPE_WEAPON_RANGED))
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Item is scalable.");
        #endif

        // if not unique
        if (GetItemUnique(oItem) == FALSE)
        {
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Item is not unique.");
            #endif

            // get material progression
            int nMaterialProgression = GetItemMaterialProgression(oItem);
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      nMaterialProgression = " + ToString(nMaterialProgression));
            #endif
            if (nMaterialProgression > 0)
            {
                // find randomized level
                int nRandomLevel = nLevel + Random(7) - 3;
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Initial nRandomLevel = " + ToString(nRandomLevel));
                #endif

                nRandomLevel = Max(TS_LEVEL_MIN, nRandomLevel);
                nRandomLevel = Min(TS_LEVEL_MAX, nRandomLevel);
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Final nRandomLevel = " + ToString(nRandomLevel));
                #endif

                // find material column
                int nColumn = ((nRandomLevel - 1) / 3) + 1;
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      nColumn = " + ToString(nColumn));
                #endif

                nColumn = Max(TS_MATERIAL_COLUMN_MIN, nColumn);
                nColumn = Min(TS_MATERIAL_COLUMN_MAX, nColumn);
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Min-Max nColumn = " + ToString(nColumn));
                #endif

                // get material
                int nMaterial = GetM2DAInt(TABLE_MATERIAL, "Material" + ToString(nColumn), nMaterialProgression);
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      nMaterial = " + ToString(nMaterial));
                #endif

                // set material
                SetItemMaterialType(oItem, nMaterial);
            }
        }
    }
}

// new item number system
int TS_GetItemNum(float fItemNum, int nObjectType)
{
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Generating Item Num");
    #endif
    int nItemNum = 0;
    int nCount = 0;
    int nMax = FloatToInt(fItemNum) + 1;
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nMax = " + ToString(nMax));
    #endif
    float fRandom;

    for (nCount = 0; nCount < nMax; nCount++)
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    fItemNum = " + ToString(fItemNum));
        #endif

        fRandom = RandomFloat();
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      fRandom = " + ToString(fRandom));
        #endif
        if (fRandom <= fItemNum)
        {
            fItemNum -= fRandom;
            nItemNum++;
        }
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      nItemNum = " + ToString(nItemNum));
        #endif

        fItemNum -= 1.0f;

        if (fItemNum <= 0.0f)
        {
            nCount = nMax;
        }
    }

    // placeables will always have at least one thing in them
    if ((nItemNum < 1) && (nObjectType == OBJECT_TYPE_PLACEABLE))
    {
        nItemNum = 1;
    }

    return nItemNum;
}

// generate money based on rank and level
void TS_GenerateMoney(object oTarget, int nRank, int nLevel, int nMoneyOverride = 0)
{
    // if money is not turned off
    if (nMoneyOverride >= 0)
    {
        int nMoney = nMoneyOverride;
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nMoney = " + ToString(nMoney));
        #endif

        nMoney = TS_GetScaledMoney(nLevel, nMoney);

        if (nMoney > 0)
        {
            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {
                AddCreatureMoney(nMoney, oTarget, FALSE);
            } else
            {
                CreateItemOnObject(rMoney, oTarget, nMoney);
            }
        }
    }
}

// generate items on the target
void TS_GenerateItems(object oTarget, int nRank, int nCategory, int nLevel, int nObjectType = OBJECT_TYPE_CREATURE, float fNumOverride = 0.0f, float fChanceOverride = 0.0f, int bStolen = FALSE)
{
    // if minor items are not turned off
    if (fNumOverride >= 0.0f)
    {
        // max number of items
        int nItemNum;
        if (fNumOverride == 0.0f) // if not overridden
        {
            float fItemNum = GetM2DAFloat(TABLE_AUTOSCALE, TS_COLUMN_ITEM_NUM, nRank);
            nItemNum = TS_GetItemNum(fItemNum, nObjectType);
        } else
        {
            nItemNum = TS_GetItemNum(fNumOverride, nObjectType);
        }
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  fNumOverride = " + ToString(fNumOverride));
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nItemNum = " + ToString(nItemNum));
        #endif

        // chance of item being a higher level
        float fHighChance;
        if (fChanceOverride >= 0.0f) // if not overridden
        {
            fHighChance = GetM2DAFloat(TABLE_AUTOSCALE, TS_COLUMN_HIGH_CHANCE, nRank);
        } else
        {
            fHighChance = fChanceOverride;
        }
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  fChanceOverride = " + ToString(fChanceOverride));
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  fHighChance = " + ToString(fHighChance));
        #endif

        // get treasure table constructors
        string sPrefix = GetM2DAString(TABLE_CATEGORY, TS_COLUMN_PREFIX, nCategory);
        string sLowTable = GetM2DAString(TABLE_AUTOSCALE, TS_COLUMN_LOW_TABLE, nRank);
        string sHighTable = GetM2DAString(TABLE_AUTOSCALE, TS_COLUMN_HIGH_TABLE, nRank);
        string sObjectTable;
        if (nObjectType == OBJECT_TYPE_PLACEABLE)
        {
            sObjectTable = TS_OBJECT_PLACEABLE;
        } else
        {
            sObjectTable = TS_OBJECT_CREATURE;
        }

        string sConstructor;
        int nLineNum;
        int nLine;
        resource rItem;
        int nStackSize;
        object oItem;
        object [] oItemsToDrop;

        // If the first line in the treasure table is money then try to create one instance of it before going into the loop
        // There is a global chance a treasure drop will be money
        if(GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
        {
            string sPreConstructor = sPrefix + sObjectTable + sLowTable;
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    PRE sConstructor = " + sConstructor);
            #endif
            resource rFirstItem = GetM2DAResource(-1, TS_COLUMN_RESOURCE, 0, sPreConstructor);
            // Qwinn:  Another instance of my !IsPartyMember(oTarget)) replaced with !bStolen
            // if(rFirstItem == rMoney && !bStolen)
            if(rFirstItem == rMoney && !IsPartyMember(oTarget))
            {
                // first, determine the global chance of having money for this table
                int nRand = Random(100) + 1;
                if(nRand <= TS_GLOBAL_MONEY_DROP_CHANCE)
                {
                    nStackSize = GetM2DAInt(-1, TS_COLUMN_STACK_SIZE, 0, sPreConstructor);
                    nStackSize = TS_GetScaledMoney(nLevel, nStackSize);
                    AddCreatureMoney(nStackSize, oTarget, FALSE);
                }
            }
        }

        // create each item
        int nCount = 0;
        for (nCount = 0; nCount < nItemNum; nCount++)
        {
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Creating item " + ToString(nCount));
            #endif
            sConstructor = sPrefix + sObjectTable;

            // is it a high item
            if (RandomFloat() <= fHighChance)
            {
                sConstructor += sHighTable;
            } else
            {
                sConstructor += sLowTable;
            }

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    sConstructor = " + sConstructor);
            #endif

            nLineNum = GetM2DARows(-1, sConstructor);
            nLine = Random(nLineNum);
            nLine = GetM2DARowIdFromRowIndex(-1, nLine, sConstructor); // converting row to proper id (for PRC 2da expansions)
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nLineNum = " + ToString(nLineNum));
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nLine = " + ToString(nLine));
            #endif

            rItem = GetM2DAResource(-1, TS_COLUMN_RESOURCE, nLine, sConstructor);
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    rItem = " + ResourceToString(rItem));
            #endif



            // money is treated differently
            if (rItem == rMoney)
            {
                // if(GetObjectType(oTarget) == OBJECT_TYPE_CREATURE && !bStolen)
                // Qwinn:  rumor has it stealing was fixed in official 1.04.  I can only imagine it was due to the above && !bStolen,
                // which is not in my 2.0 mod.  My mod had && !IsPartyMember(oTarget) instead.  It is this difference, I think, that
                // made their fix fix stealing but not dog fetch.  Reimplementing my version.
                
                if(GetObjectType(oTarget) == OBJECT_TYPE_CREATURE && !IsPartyMember(oTarget))
                {
                    // First, make sure no other items were creates. If other items are about to drop then avoid adding money
                    oItemsToDrop = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK);
                    if(GetArraySize(oItemsToDrop) > 0) // items were created
                        continue; // skip money creation
                }

                // get money amount
                nStackSize = GetM2DAInt(-1, TS_COLUMN_STACK_SIZE, nLine, sConstructor);
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nStackSize = " + ToString(nStackSize));
                #endif
                nStackSize = TS_GetScaledMoney(nLevel, nStackSize);

                int bNotify = IsPartyMember(oTarget);

                if (nObjectType == OBJECT_TYPE_CREATURE)
                {
                    #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Creature");
                    #endif
                    AddCreatureMoney(nStackSize, oTarget, bNotify);
                } else
                {
                    #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Placeable");
                    #endif
                    CreateItemOnObject(rMoney, oTarget, nStackSize);
                }
            } else
            {
                // PREVENT NON-MONEY TREASURE IF CREATURE ALREADY HAS MONEY
                // Qwinn: Adding check to make sure oTarget isn't a party member stealing. See line 991 of this script.
                if(GetObjectType(oTarget) == OBJECT_TYPE_CREATURE && GetCreatureMoney(oTarget) > 0 && !IsPartyMember(oTarget))
                    continue;

                // get stack size
                nStackSize = GetM2DAInt(-1, TS_COLUMN_STACK_SIZE, nLine, sConstructor);
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    nStackSize = " + ToString(nStackSize));
                #endif

                if (nStackSize > 1)
                {
                    // round up
                    float fRandom = (RandomFloat() * 0.2f) + 0.8f;
                    #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      fRandom = " + ToString(fRandom));
                    #endif
                    int nRandomSize = Max(1, (FloatToInt(fRandom * nStackSize)));
                    if (IntToFloat(nRandomSize) < (nStackSize * fRandom))
                    {
                        nRandomSize++;
                    }
                    nStackSize = Max(nRandomSize, 1);
                } else
                {
                    nStackSize = 1;
                }
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Final nStackSize = " + ToString(nStackSize));
                #endif

                // create item
                oItem = CreateItemOnObject(rItem, oTarget, nStackSize);

                // scale item
                TS_ScaleItem(oItem, nLevel);
            }
        }
    }
}

// drop a single piece of equipment
void TS_GenerateEquipment(object oTarget, int nRank, float fOverride = 0.0f)
{
    if (fOverride >= 0.0f)
    {
        // get chance to drop
        float fChance;
        if (fOverride == 0.0f) // if not overridden
        {
            fChance = GetM2DAFloat(TABLE_AUTOSCALE, TS_COLUMN_EQUIPMENT_CHANCE, nRank);
        } else
        {
            fChance = fOverride;
        }
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"fOverride = " + ToString(fOverride));
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"fChance = " + ToString(fChance));
        #endif

        // if there are equipped items
        object[] oEquip = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_EQUIPPED);
        int nEquipNum = GetArraySize(oEquip);

        if (nEquipNum > 0)
        {
            // chance of equipment dropping
            float fRandom = RandomFloat();
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"fRandom = " + ToString(fRandom));
            #endif
            if (fRandom <= fChance)
            {
                // pick a single random piece of equipment
                int nEquip = Random(nEquipNum);

                // if item is droppable
                int nItemType = GetBaseItemType(oEquip[nEquip]);
                if (GetM2DAInt(TABLE_ITEMS, TS_COLUMN_DO_NOT_DROP, nItemType) == FALSE)
                {
                    // set item droppable
                    SetItemDroppable(oEquip[nEquip], TRUE);
                    #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(), "Setting Droppable -  " + GetTag(oEquip[nEquip]));
                    #endif
                }
            }
        }
    }
}

void TS_ScaleInventory(object oTarget, int nLevel)
{
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Scaling Inventory");
    #endif

    int nFlag;
    if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
    {
        nFlag = GET_ITEMS_OPTION_BACKPACK;
    } else
    {
        nFlag = GET_ITEMS_OPTION_ALL;
    }
    object[] oItems = GetItemsInInventory(oTarget, nFlag);
    int nMax = GetArraySize(oItems);
    int nCount = 0;
    for (nCount = 0; nCount < nMax; nCount++)
    {
        TS_ScaleItem(oItems[nCount], nLevel);
    }
}

int TS_GetStackSizes(object[] oItems)
{
    int nSize = 0;
    int nCount = 0;
    int nMax = GetArraySize(oItems);
    for (nCount = 0; nCount < nMax; nCount++)
    {
        nSize += GetItemStackSize(oItems[nCount]);
    }

    return nSize;
}

int TS_GetHealthPotions(object oTarget)
{
    int nHealthCount = 0;
    object[] oPotions;

    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_health_101", TRUE);
    nHealthCount += TS_GetStackSizes(oPotions);
    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_health_201", TRUE);
    nHealthCount += TS_GetStackSizes(oPotions);
    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_health_301", TRUE);
    nHealthCount += TS_GetStackSizes(oPotions);
    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_health_401", TRUE);
    nHealthCount += TS_GetStackSizes(oPotions);
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      nHealthCount = " + ToString(nHealthCount));
    #endif

    return nHealthCount;
}

int TS_GetInjuryPotions(object oTarget)
{
    int nInjuryCount = 0;
    object[] oPotions;

    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_injury_101", TRUE);
    nInjuryCount += TS_GetStackSizes(oPotions);
    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_injury_201", TRUE);
    nInjuryCount += TS_GetStackSizes(oPotions);
    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_injury_301", TRUE);
    nInjuryCount += TS_GetStackSizes(oPotions);
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      nInjuryCount = " + ToString(nInjuryCount));
    #endif

    return nInjuryCount;
}

int TS_GetManaPotions(object oTarget)
{
    int nManaCount = 0;
    object[] oPotions;

    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_mana_101", TRUE);
    nManaCount += TS_GetStackSizes(oPotions);
    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_mana_201", TRUE);
    nManaCount += TS_GetStackSizes(oPotions);
    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_mana_301", TRUE);
    nManaCount += TS_GetStackSizes(oPotions);
    oPotions = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "gen_im_qck_mana_401", TRUE);
    nManaCount += TS_GetStackSizes(oPotions);
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      nManaCount = " + ToString(nManaCount));
    #endif

    return nManaCount;
}

// generate normal treasure
void TreasureGenerate(object oTarget)
{
    // is target a valid object
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Treasure generation for target = " + ToString(oTarget));
    #endif
    if (IsObjectValid(oTarget) == TRUE)
    {
        // has treasure already been generated
        int bTreasureGenerated = GetLocalInt(oTarget, TS_TREASURE_GENERATED);
        if (bTreasureGenerated == FALSE)
        {
            // make sure treasure doesnt generate again
            SetLocalInt(oTarget, TS_TREASURE_GENERATED, TRUE);

            // get rank and group
            int nRank = TS_GetRank(oTarget);
            int nCategory = TS_GetCategory(oTarget);
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Rank = " + ToString(nRank) + ", Category = " + ToString(nCategory));
            #endif
            int nLevel = TS_GetLevel(oTarget, nRank);

            // if valid rank
            if (nRank > 0)
            {
                TS_ScaleInventory(oTarget, nLevel);

                int nObjectTypeOverride = GetLocalInt(oTarget, TS_OVERRIDE_OBJECT_TYPE);
                if (nObjectTypeOverride == 0)
                {
                    nObjectTypeOverride = GetObjectType(oTarget);
                }

                // generate gold
                int nMoneyOverride = GetLocalInt(oTarget, TS_OVERRIDE_MONEY);
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Money Override = " + ToString(nMoneyOverride));
                #endif
                if (nMoneyOverride > 0)
                {
                    TS_GenerateMoney(oTarget, nRank, nLevel, nMoneyOverride);
                }

                // reactive potion drops
                if (nObjectTypeOverride == OBJECT_TYPE_CREATURE)
                {
                    #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Checking creature for reactive health drops.");
                    #endif

                    // if hostile to the player
                    object oPC = GetHero();
                    float fReactiveOverride = GetLocalFloat(oTarget, TS_OVERRIDE_REACTIVE);
                    #ifdef DEBUG
                    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    fReactiveOverride = " + ToString(fReactiveOverride));
                    #endif
                    if ((IsObjectHostile(oTarget, oPC) == TRUE) && (fReactiveOverride >= 0.0f))
                    {
                        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    Creature is hostile to party.");

                        int nHealthCount = 0;
                        int nManaCount = 0;

                        // check to make sure it isnt already dropping health/mana potions
                        nHealthCount = TS_GetHealthPotions(oTarget);
                        nManaCount = TS_GetManaPotions(oTarget);
                        #ifdef DEBUG
                        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Target has " + ToString(nHealthCount) + " health and " + ToString(nManaCount) + " mana");
                        #endif
                        if ((nHealthCount + nManaCount) <= 0)
                        {
                            // get number of health/mana potions
                            nHealthCount = TS_GetHealthPotions(oPC);
                            nManaCount = TS_GetManaPotions(oPC);
                            #ifdef DEBUG
                            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Player has " + ToString(nHealthCount) + " health and " + ToString(nManaCount) + " mana");
                            #endif

                            // if the player doesn't already have the maximum number of potions
                            int nDifficulty = GetGameDifficulty();
                            int nDifficultyLimit = GetM2DAInt(TABLE_DIFFICULTY, "ReactiveLimit", nDifficulty);
                            #ifdef DEBUG
                            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      nDifficulty " + ToString(nDifficulty) + " with limit " + ToString(nDifficultyLimit));
                            #endif

                            if (nHealthCount < nDifficultyLimit || nManaCount < nDifficultyLimit)
                            {
                                nDifficultyLimit = Max(nDifficultyLimit, 1); // to prevent divide by 0 errors

                                // base chance
                                float fBaseChance = (1.0 - (Min(nHealthCount, nManaCount) / nDifficultyLimit)) / 4.0;

                                //float fBaseChance = IntToFloat(nDifficultyLimit - Min(nHealthCount,nManaCount)) / nDifficultyLimit;

                                // factor
                                float fFactor = GetM2DAFloat(TABLE_DIFFICULTY, "ReactiveChance", nDifficulty);

                                // item chance
                                float fItemChance = GetM2DAFloat(TABLE_AUTOSCALE, "TS_ItemNum", nRank);
                                fItemChance = MaxF(fItemChance, 1.0);

                                // drop chance
                                float fDropChance = fBaseChance * fFactor * fItemChance;
                                if (fReactiveOverride > 0.0f)
                                {
                                    fDropChance = fReactiveOverride;
                                }

                                #ifdef DEBUG
                                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        Base Chance = " + ToString(fBaseChance));
                                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        Factor = " + ToString(fFactor));
                                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        Item Chance = " + ToString(fItemChance));
                                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        Drop Chance = " + ToString(fDropChance));
                                #endif

                                if (RandomFloat() < fDropChance)
                                {
                                    int nTier = GetM2DAInt(TABLE_AUTOSCALE, "nReactiveTier", nRank);
                                    #ifdef DEBUG
                                    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        Tier = " + ToString(nTier));
                                    #endif
                                    if (nTier > 0)
                                    {
                                        // the chance of health dropping increases as the player has less potions
                                        // the chance goes between REACTIVE_HEALTH_BASE_CHANCE up to 50%, the less potions, the higher the chance
                                        float fHealthChance = (1.0 - (nHealthCount / nDifficultyLimit)) / 2.0;
                                        if(fHealthChance < REACTIVE_HEALTH_BASE_CHANCE) fHealthChance = REACTIVE_HEALTH_BASE_CHANCE;
                                        //float fHealthChance = REACTIVE_HEALTH_BASE_CHANCE + ((1.0f - REACTIVE_HEALTH_BASE_CHANCE - REACTIVE_MANA_BASE_CHANCE) * (1.0f - (IntToFloat(nHealthCount) / Max(nManaCount + nHealthCount, 1))));
                                        #ifdef DEBUG
                                        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        fHealthChance = " + ToString(fHealthChance));
                                        #endif
                                        int bMana = (RandomFloat() > fHealthChance);
                                        #ifdef DEBUG
                                        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        bMana = " + ToString(bMana));
                                        #endif

                                        if(GetLevel(GetHero()) >= 10 && GetLevel(GetHero()) < 15)
                                        {
                                            int nRandIncChance = Random(100) + 1;
                                            if(nRandIncChance <= 50)
                                                nTier++; // 50% chance for a higher tier level 10+
                                        }
                                        else if(GetLevel(GetHero()) >= 15)
                                        {
                                            int nRandIncChance = Random(100) + 1;
                                            if(nRandIncChance <= 75)
                                                nTier++; // 75% chance for a higher tier level 15+
                                        }


                                        resource rPotion;
                                        if (nTier >= 4)
                                        {
                                            #ifdef DEBUG
                                            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        Potent potion spawned.");
                                            #endif

                                            if (bMana)
                                            {
                                                rPotion = REACTIVE_TIER4_MANA;
                                            } else
                                            {
                                                rPotion = REACTIVE_TIER4_HEALTH;
                                            }
                                        } else if (nTier == 3)
                                        {
                                            #ifdef DEBUG
                                            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        Greater potion spawned.");
                                            #endif

                                            if (bMana)
                                            {
                                                rPotion = REACTIVE_TIER3_MANA;
                                            } else
                                            {
                                                rPotion = REACTIVE_TIER3_HEALTH;
                                            }
                                        } else if (nTier == 2)
                                        {
                                            #ifdef DEBUG
                                            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        Normal potion spawned.");
                                            #endif

                                            if (bMana)
                                            {
                                                rPotion = REACTIVE_TIER2_MANA;
                                            } else
                                            {
                                                rPotion = REACTIVE_TIER2_HEALTH;
                                            }
                                        } else
                                        {
                                            #ifdef DEBUG
                                            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"        Lesser potion spawned.");
                                            #endif

                                            if (bMana)
                                            {
                                                rPotion = REACTIVE_TIER1_MANA;
                                            } else
                                            {
                                                rPotion = REACTIVE_TIER1_HEALTH;
                                            }
                                        }
                                        if(bMana && nManaCount < nDifficultyLimit)
                                            CreateItemOnObject(rPotion, oTarget);
                                        if(!bMana && nHealthCount < nDifficultyLimit)
                                            CreateItemOnObject(rPotion, oTarget);

                                        // there is a chance for an extra injury potion in normal or casual difficulty
                                        if(GetGameDifficulty() <= GAME_DIFFICULTY_NORMAL)
                                        {
                                           // Only if party has no injury potion and has injuries
                                           int bHasInjury = FALSE;
                                           object [] arParty = GetPartyList();
                                           int nPartySize = GetArraySize(arParty);
                                           effect[] eInjuries;
                                           object oCurrent;
                                           int x;
                                           for(x = 0; x < nPartySize; x++)
                                           {
                                               oCurrent = arParty[x];
                                               eInjuries = Injury_GetInjuryEffects(oCurrent);
                                               if(GetArraySize(eInjuries) > 0)
                                               {
                                                   bHasInjury = TRUE;
                                                   break;
                                               }
                                           }

                                           int nInjuryPotionCount = TS_GetInjuryPotions(oPC);
                                           float fRand = RandomFloat();
                                           if(nInjuryPotionCount == 0 && bHasInjury && fRand <= REACTIVE_INJURY_BASE_CHANCE)
                                           {
                                                CreateItemOnObject(R"gen_im_qck_injury_101.uti", oTarget);
                                           }


                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // if valid category
                if (nCategory > 0)
                {
                    // generate items
                    float fItemNumOverride = GetLocalFloat(oTarget, TS_OVERRIDE_ITEM_NUM);
                    float fItemQualityOverride = GetLocalFloat(oTarget, TS_OVERRIDE_HIGH_CHANCE);
                    TS_GenerateItems(oTarget, nRank, nCategory, nLevel, nObjectTypeOverride, fItemNumOverride, fItemQualityOverride);
                }

                // PREVENT NON-MONEY TREASURE IF CREATURE ALREADY HAS MONEY
                if(GetCreatureMoney(oTarget) > 0)
                    return;

                // if a creature, generate equipment
                if (nObjectTypeOverride == OBJECT_TYPE_CREATURE)
                {
                    // generate equipment
                    float fEquipmentOverride = GetLocalFloat(oTarget, TS_OVERRIDE_EQUIPMENT_CHANCE);
                    TS_GenerateEquipment(oTarget, nRank, fEquipmentOverride);
                }


            }
        } else
        {
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Treasure already generated for this object.");
            #endif
        }
    } else
    {
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Object is not valid.");
        #endif
    }
}

// generate stolen treasure
void TreasureStolen(object oTarget, object oThief)
{
    // is target a valid object
    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Treasure generation for " + ToString(oThief) + " stealing from " + ToString(oTarget));
    #endif
    if (IsObjectValid(oTarget) == TRUE)
    {
        int bStolen = FALSE;

        // check override
        int nStealingOverride = GetLocalInt(oTarget, TS_OVERRIDE_STEALING);
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Stealing Override = " + ToString(nStealingOverride));
        #endif
        if (nStealingOverride >= 0)
        {
            // get rank and group
            int nRank = TS_GetRank(oTarget);
            int nCategory = TS_GetCategory(oTarget);
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Rank = " + ToString(nRank) + ", Category = " + ToString(nCategory));
            #endif
            int nLevel = TS_GetLevel(oTarget, nRank);

            // if rank and category are valid
            if ((nRank > 0) && (nCategory > 0))
            {
                bStolen = TRUE;

                // generate items
                TS_GenerateItems(oThief, nRank, nCategory, nLevel, OBJECT_TYPE_CREATURE, 1.0f, 0.0, TRUE);
            }

            if (nStealingOverride > 0)
            {
                bStolen = TRUE;

                // look up item in 2DA
                resource rItem = GetM2DAResource(TABLE_STEALING, TS_COLUMN_RESOURCE, nStealingOverride);
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Override Item = " + ResourceToString(rItem));
                #endif

                // create item
                object oItem = CreateItemOnObject(rItem, oThief, 1);

                // scale item
                TS_ScaleItem(oItem, nLevel);
            }
        }

        // get inventory list
        object [] oStealables = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK);
        int nMax = GetArraySize(oStealables);
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"  Items in Backpack = " + ToString(nMax));
        #endif

        // cycle through all items
        int nCount = 0;
        for (nCount = 0; nCount < nMax; nCount++)
        {
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"    Examining " + GetTag(oStealables[nCount]));
            #endif

            // is item stealable?
            if (IsItemStealable(oStealables[nCount]) == TRUE)
            {
                bStolen = TRUE;

                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_LOOT, GetCurrentScriptName(),"      Stealable.");
                #endif

                // move item
                MoveItem(oTarget, oThief, oStealables[nCount]);
            }
        }

        // feedback message
        if (bStolen == TRUE)
        {
            UI_DisplayMessage(oThief, 3502);
        } else
        {
            UI_DisplayMessage(oThief, 3514);
        }
    }
}