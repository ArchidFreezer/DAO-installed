// -----------------------------------------------------------------------------
// sys_itemsets_h
// -----------------------------------------------------------------------------
/*
    Item Set System
*/
// -----------------------------------------------------------------------------
// owner: PeterT
// -----------------------------------------------------------------------------

#include "ui_h"
#include "2da_constants_h"
#include "effects_h"

void ItemSet_SetEffectArray(object oCreature, int nSet);
int[] ItemSet_GetFlagArray(object oItem);
void ItemSet_RemoveFlagProperty(object oCreature, int nFlag);
void ItemSet_AddFlagProperty(object oCreature, int nFlag);
void ItemSet_Unequipped(object oCreature, object oItem);
void ItemSet_Equipped(object oCreature, object oItem);
int[] ItemSet_GetSetItemSlots(int nFlag);
int ItemSet_ItemsHaveFlag(object oCreature, int nFlag);
void ItemSet_Update(object oCreature);

const int ABILITY_ITEM_SET = 200253;

void ItemSet_SetEffectArray(object oCreature, int nSet)
{
    effect eEffect;

    // first property
    int nProperty = GetM2DAInt(TABLE_ITEM_SETS, "Prop1", nSet);
    float fPropertyValue = GetM2DAFloat(TABLE_ITEM_SETS, "Prop1Value", nSet);
    #ifdef DEBUG
    LogTrace(LOG_CHANNEL_TEMP, "        nProperty = " + ToString(nProperty));
    LogTrace(LOG_CHANNEL_TEMP, "        fPropertyValue = " + ToString(fPropertyValue));
    #endif
    if (nProperty > 0)
    {
        if (fPropertyValue != 0.0f)
        {
            eEffect = EffectModifyProperty(nProperty, fPropertyValue);
        } else
        {
            eEffect = Effect(nProperty);
        }
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oCreature, 0.0f, oCreature, ABILITY_ITEM_SET);
    }

    // second property
    nProperty = GetM2DAInt(TABLE_ITEM_SETS, "Prop2", nSet);
    fPropertyValue = GetM2DAFloat(TABLE_ITEM_SETS, "Prop2Value", nSet);
    #ifdef DEBUG
    LogTrace(LOG_CHANNEL_TEMP, "        nProperty = " + ToString(nProperty));
    LogTrace(LOG_CHANNEL_TEMP, "        fPropertyValue = " + ToString(fPropertyValue));
    #endif
    if (nProperty > 0)
    {
        if (fPropertyValue != 0.0f)
        {
            eEffect = EffectModifyProperty(nProperty, fPropertyValue);
        } else
        {
            eEffect = Effect(nProperty);
        }
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, oCreature, 0.0f, oCreature, ABILITY_ITEM_SET);
    }
}

void ItemSet_Update(object oCreature)
{
    #ifdef DEBUG
    LogTrace(LOG_CHANNEL_TEMP, "Forcing Item Set Update");
    #endif

    // remove all flag effects
    effect[] eEffects = GetEffectsByAbilityId(oCreature, ABILITY_ITEM_SET);
    RemoveEffectArray(oCreature, eEffects);

    // get equipped items
    object[] oItems;
    oItems[0] = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oCreature);
    oItems[1] = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oCreature);
    oItems[2] = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oCreature);
    oItems[3] = GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oCreature);
    oItems[4] = GetItemInEquipSlot(INVENTORY_SLOT_GLOVES, oCreature);
    oItems[5] = GetItemInEquipSlot(INVENTORY_SLOT_BOOTS, oCreature);
    oItems[6] = GetItemInEquipSlot(INVENTORY_SLOT_BELT, oCreature);
    oItems[7] = GetItemInEquipSlot(INVENTORY_SLOT_RING1, oCreature);
    oItems[8] = GetItemInEquipSlot(INVENTORY_SLOT_RING2, oCreature);
    oItems[9] = GetItemInEquipSlot(INVENTORY_SLOT_NECK, oCreature);
    oItems[10] = GetItemInEquipSlot(INVENTORY_SLOT_RANGEDAMMO, oCreature);
    oItems[11] = GetItemInEquipSlot(INVENTORY_SLOT_DOG_COLLAR, oCreature);
    oItems[12] = GetItemInEquipSlot(INVENTORY_SLOT_DOG_WARPAINT, oCreature);
    oItems[13] = GetItemInEquipSlot(INVENTORY_SLOT_SHALE_CHEST, oCreature); // shale armor
    oItems[14] = GetItemInEquipSlot(INVENTORY_SLOT_SHALE_RIGHTARM, oCreature); // shale weapon
    oItems[15] = GetItemInEquipSlot(INVENTORY_SLOT_CLOAK, oCreature);
    oItems[16] = GetItemInEquipSlot(INVENTORY_SLOT_BITE, oCreature);
    oItems[17] = GetItemInEquipSlot(INVENTORY_SLOT_SHALE_SHOULDERS, oCreature);
    oItems[18] = GetItemInEquipSlot(INVENTORY_SLOT_SHALE_LEFTARM, oCreature);
    // Compatibility with No Helmet Hack which puts helmets in the cloak slot
    if (!IsObjectValid(oItems[3]))
        oItems[3] = oItems[15];

    #ifdef DEBUG
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[0] = " + GetTag(oItems[0]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[1] = " + GetTag(oItems[1]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[2] = " + GetTag(oItems[2]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[3] = " + GetTag(oItems[3]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[4] = " + GetTag(oItems[4]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[5] = " + GetTag(oItems[5]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[6] = " + GetTag(oItems[6]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[7] = " + GetTag(oItems[7]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[8] = " + GetTag(oItems[8]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[9] = " + GetTag(oItems[9]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[10] = " + GetTag(oItems[10]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[11] = " + GetTag(oItems[11]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[12] = " + GetTag(oItems[12]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[13] = " + GetTag(oItems[13]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[14] = " + GetTag(oItems[14]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[15] = " + GetTag(oItems[15]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[16] = " + GetTag(oItems[16]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[17] = " + GetTag(oItems[17]));
    LogTrace(LOG_CHANNEL_TEMP, "  oItems[18] = " + GetTag(oItems[18]));
    #endif

    // construct slot array
    int nSlotArray;
    int nMax = 19;
    int nCount = 0;
    int nCountValue = 1;
    for (nCount = 0; nCount < nMax; nCount++)
    {
        // if item in this slot is valid
        if (IsObjectValid(oItems[nCount]) == TRUE)
        {
            nSlotArray += nCountValue;
        }

        nCountValue *= 2;
    }
    #ifdef DEBUG
    LogTrace(LOG_CHANNEL_TEMP, "  nSlotArray = " + ToString(nSlotArray));
    #endif

    // if there are items equipped
    if (nSlotArray > 0)
    {
        int nItemSet;
        int nSetArray;
        int bValid;
        int nCount2;
        int nCount2Value;
        int nItemSet2;

        // go through each item
        //nMax = 19;
        nCount = 0;
        nCountValue = 1;
        for (nCount = 0; nCount < nMax; nCount++)
        {
            #ifdef DEBUG
            LogTrace(LOG_CHANNEL_TEMP, "  nCount = " + ToString(nCount));
            LogTrace(LOG_CHANNEL_TEMP, "    nSlotArray = " + ToString(nSlotArray));
            LogTrace(LOG_CHANNEL_TEMP, "    nCountValue = " + ToString(nCountValue));
            #endif

            // if this slot is in the slot array
            if ((nSlotArray & nCountValue) == nCountValue)
            {
                #ifdef DEBUG
                LogTrace(LOG_CHANNEL_TEMP, "    nCountValue valid.");
                #endif

                // get item set
                nItemSet = GetLocalInt(oItems[nCount], ITEM_SET);
                #ifdef DEBUG
                LogTrace(LOG_CHANNEL_TEMP, "    nItemSet = " + ToString(nItemSet));
                #endif
                if (nItemSet > 0)
                {
                    // get set array
                    nSetArray = GetM2DAInt(TABLE_ITEM_SETS, "Slots", nItemSet);
                    #ifdef DEBUG
                    LogTrace(LOG_CHANNEL_TEMP, "    nSetArray = " + ToString(nSetArray));
                    #endif

                    // if contained within slot array
                    if ((nSlotArray & nSetArray) == nSetArray)
                    {
                        #ifdef DEBUG
                        LogTrace(LOG_CHANNEL_TEMP, "      nSetArray valid.");
                        #endif

                        // remove current slot from consideration
                        nSlotArray -= nCountValue;

                        // check each component item
                        bValid = TRUE;
                        nCount2Value = nCountValue * 2;
                        for (nCount2 = nCount + 1; nCount2 < nMax; nCount2++)
                        {
                            #ifdef DEBUG
                            LogTrace(LOG_CHANNEL_TEMP, "      nCount2 = " + ToString(nCount2));
                            LogTrace(LOG_CHANNEL_TEMP, "        nSetArray = " + ToString(nSetArray));
                            LogTrace(LOG_CHANNEL_TEMP, "        nCount2Value = " + ToString(nCount2Value));
                            #endif

                            // if a valid item in the set
                            if ((nSetArray & nCount2Value) == nCount2Value)
                            {
                                // if same set, subtract from slot array
                                if (GetLocalInt(oItems[nCount2], ITEM_SET) == nItemSet)
                                {
                                    #ifdef DEBUG
                                    LogTrace(LOG_CHANNEL_TEMP, "        Item set matches.");
                                    #endif
                                    nSlotArray -= nCount2Value;
                                } else
                                {
                                    bValid = FALSE;
                                }
                            }

                            nCount2Value *= 2;

                            if (nCount2Value > nSetArray)
                            {
                                nCount2 = nMax;
                            }
                        }

                        if (bValid == TRUE)
                        {
                            // if bValid TRUE, apply effect
                            #ifdef DEBUG
                            LogTrace(LOG_CHANNEL_TEMP, "      Set requirements met.");
                            #endif
                            ItemSet_SetEffectArray(oCreature, nItemSet);
                        }
                    } else
                    {
                        // remove this slot
                        nSlotArray -= nCountValue;
                    }
                } else
                {
                    // remove this slot
                    nSlotArray -= nCountValue;
                }
            }

            // if there are no more items to examine
            if (nSlotArray <= 0)
            {
                nCount = nMax;
            }

            nCountValue *= 2;
        }
    }
    #ifdef DEBUG
    LogTrace(LOG_CHANNEL_TEMP, "  Completed");
    #endif
}