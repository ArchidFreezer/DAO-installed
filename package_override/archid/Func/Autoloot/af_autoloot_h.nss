#include "var_constants_h"

const int LOOT_RETURN_OK = 1;
const int LOOT_RETURN_INV_FULL = 2;
const int LOOT_RETURN_EMPTY = 3;

int HasImportantItems(object oObject) {
    object[] arInv = GetItemsInInventory(oObject);
    int nSize = GetArraySize(arInv);
    int i;
    for (i = 0; i < nSize; i++) {
        object oItem = arInv[i];
        if (IsPlot(oItem) || GetLocalInt(oItem, ITEM_SEND_ACQUIRED_EVENT))
            return TRUE;
    }
    return FALSE;
}

int HasLootableItems(object oObject) {
    if (GetCreatureMoney(oObject) > 0)
        return TRUE;

    object[] arInv = GetItemsInInventory(oObject);
    int nSize = GetArraySize(arInv);
    int i;
    for (i = 0; i < nSize; i++) {
        object oItem = arInv[i];
        if (GetTag(oItem) == "gen_im_copper" || IsItemDroppable(oItem) || GetObjectType(oObject) == OBJECT_TYPE_PLACEABLE)
            return TRUE;
    }

    return FALSE;
}

int ItemFitsInInventory(object oItem, object oTarget) {
    if (GetObjectType(oTarget) != OBJECT_TYPE_CREATURE || !IsFollower(oTarget) || IsPlot(oItem))
        return TRUE;

    if (GetMaxInventorySize() - GetArraySize(GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, "", TRUE)) > 0)
        return TRUE;

    int nMaxStack = GetMaxItemStackSize(oItem);
    if (nMaxStack == 1)
        return FALSE;

    // To arrive at this point we must have a full inventory and a stackable item
    int nStackSize = GetItemStackSize(oItem);
    object[] arInv = GetItemsInInventory(oTarget, GET_ITEMS_OPTION_BACKPACK, 0, GetTag(oItem));
    int i;
    int nInvStackSize = 0;
    for (i = 0; i < GetArraySize(arInv); i++)
        nInvStackSize += GetItemStackSize(arInv[i]);
    nInvStackSize = nInvStackSize % nMaxStack;
    if (nInvStackSize == 0)
        return FALSE;

    return nInvStackSize + nStackSize <= nMaxStack;
}

int LootObject(object oSource, object oTarget) {
    object[] arInv = GetItemsInInventory(oSource);
    int nRes = LOOT_RETURN_OK;
    int nMoney = 0;
    int nMoved = 0;
    int i, nSize = GetArraySize(arInv);
    for (i = 0; i < nSize; i++) {
        object oItem = arInv[i];
        if (GetTag(oItem) == "gen_im_copper") {
            nMoney += GetItemStackSize(oItem);
            DestroyObject(oItem);
            nMoved++;
        } else if (IsItemDroppable(oItem) || GetObjectType(oSource) == OBJECT_TYPE_PLACEABLE) {
            if (ItemFitsInInventory(oItem, oTarget)) {
                MoveItem(oSource, oTarget, oItem);
                // MoveItem fires inventory added to the recipient, but not inventory removed to the source...
                event eInvRemoved = Event(EVENT_TYPE_INVENTORY_REMOVED);
                eInvRemoved = SetEventObject(eInvRemoved, 0, oItem);
                eInvRemoved = SetEventInteger(eInvRemoved, 0, IsFollower(oTarget));
                SignalEvent(oSource, eInvRemoved);
                nMoved++;
            } else
                nRes = LOOT_RETURN_INV_FULL;
        }
    }
    if (GetObjectType(oSource) == OBJECT_TYPE_CREATURE) {
        int nCorpseCash = GetCreatureMoney(oSource);
        if (nCorpseCash > 0) {
            nMoney += nCorpseCash;
            SetCreatureMoney(0, oSource, FALSE);
            nMoved++;
        }
    }
    if (nMoney > 0) {
        if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            AddCreatureMoney(nMoney, oTarget);
        else
            CreateItemOnObject(R"gen_im_copper.uti", oTarget, nMoney);
    }
    if (nRes == LOOT_RETURN_OK && nMoved == 0)
        nRes = LOOT_RETURN_EMPTY;
    return nRes;
}