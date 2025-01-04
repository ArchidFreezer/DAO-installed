#include "2da_constants_h"

void CheckItem(object oItem) {
    int nBaseType = GetBaseItemType(oItem);
    if (nBaseType > 0 && GetLocalInt(oItem, "ITEM_RUNE_ENABLED") == 0 && (GetM2DAInt(TABLE_ITEMS, "EquippableSlots", nBaseType) & 243) > 0 && GetM2DAInt(TABLE_ITEMS, "RuneCount", nBaseType) > -100) {
        SetLocalInt(oItem, "ITEM_RUNE_ENABLED", 1);
        // # of slots depends on material, so change it to force game engine to update item
        int nMat = GetItemMaterialType(oItem);
        SetItemMaterialType(oItem, 0);
        SetItemMaterialType(oItem, nMat);
    }
}

void main() {
    event ev = GetCurrentEvent();
    if (GetEventType(ev) == EVENT_TYPE_INVALID) /* prcscr */ {
        object[] arParty = GetPartyPoolList();
        int i, nSize = GetArraySize(arParty);
        for (i = 0; i < nSize; i++) {
            int nOpts = i ? GET_ITEMS_OPTION_EQUIPPED : GET_ITEMS_OPTION_ALL;
            object[] arItems = GetItemsInInventory(arParty[i], nOpts);
            int j, nItemSize = GetArraySize(arItems);
            for (j = 0; j < nItemSize; j++) {
                CheckItem(arItems[j]);
            }
        }
    } else /* inventory added */ {
        object oItem = GetEventObject(ev, 0);
        CheckItem(oItem);
    }
}