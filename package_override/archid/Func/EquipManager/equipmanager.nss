#include "sys_itemsets_h"
#include "wrappers_h"
#include "effect_enchantment_h"
#include "plt_tut_fatigue"
#include "plt_tut_armor_archer"
#include "plt_mnp000pt_generic"

const int TABLE_EQUIP_MGR = 6610003;

void HandleEquip(event ev) {
    ItemSet_Update(OBJECT_SELF);
    object oItem = GetEventObject(ev, 0);
    int nSlot = GetEventInteger(ev,0);
    if (nSlot == INVENTORY_SLOT_CHEST) {
        int nItemType = GetBaseItemType(oItem);
        // Game equips things before plot flags are loaded...
        if (GetGameMode() != GM_LOADING) {
            if (nItemType == BASE_ITEM_TYPE_ARMOR_HEAVY || nItemType == BASE_ITEM_TYPE_ARMOR_MASSIVE) {
                WR_SetPlotFlag(PLT_TUT_ARMOR_ARCHER, TUT_ARMOR_ARCHER_1, TRUE);
                WR_SetPlotFlag(PLT_TUT_FATIGUE, TUT_FATIGUE_1, TRUE);
            } else if (nItemType == BASE_ITEM_TYPE_ARMOR_LIGHT || nItemType == BASE_ITEM_TYPE_ARMOR_MEDIUM)
                WR_SetPlotFlag(PLT_TUT_FATIGUE, TUT_FATIGUE_1, TRUE);
        }
    } else if (nSlot == INVENTORY_SLOT_MAIN || (nSlot == INVENTORY_SLOT_OFFHAND && GetItemType(oItem) == ITEM_TYPE_WEAPON_MELEE))
        if (HasEnchantments(OBJECT_SELF))
            EffectEnchantment_HandleEquip(oItem, OBJECT_SELF);

    RecalculateDisplayDamage(OBJECT_SELF);
}

void HandleUnequip(event ev) {
    ItemSet_Update(OBJECT_SELF);
    object oItem = GetEventObject(ev, 0);
    int nSlot = GetEventInteger(ev,0);
    if (nSlot == INVENTORY_SLOT_CHEST)
        Gore_RemoveAllGore(OBJECT_SELF);
    else if (nSlot == INVENTORY_SLOT_MAIN || (nSlot == INVENTORY_SLOT_OFFHAND && GetItemType(oItem) == ITEM_TYPE_WEAPON_MELEE))
        if (HasEnchantments(OBJECT_SELF))
            EffectEnchantment_HandleUnEquip(oItem, OBJECT_SELF);

    int[] abi = GetConditionedAbilities(OBJECT_SELF, 0xC7);
    int i, nSize = GetArraySize(abi);
    for (i = 0; i < nSize; i++)
        Effects_RemoveUpkeepEffect(OBJECT_SELF,abi[i]);

    RecalculateDisplayDamage(OBJECT_SELF);
}

int CheckCriterion(int nRow, string sCol, int nComparison) {
    int nVal = GetM2DAInt(TABLE_EQUIP_MGR, sCol, nRow);
    return nVal == -1 || nVal == nComparison;
}

// amalgamation of player_core and rules_core
void main() {
    // Get event deets
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    // Only care about followers here + event type sanity check
    if (GetFollowerState(OBJECT_SELF) == FOLLOWER_STATE_INVALID || (nEventType != EVENT_TYPE_EQUIP && nEventType != EVENT_TYPE_UNEQUIP)) {
        HandleEvent(ev);
        return;
    }

    if (nEventType == EVENT_TYPE_EQUIP)
        HandleEquip(ev);
    else
        HandleUnequip(ev);

    int nSlot = GetEventInteger(ev, 0);
    int nGM = GetGameMode();

    // initialise listeners
    int nListeners = 0;
    string[] arListeners;

    // Parse m2da
    int i, nRows = GetM2DARows(TABLE_EQUIP_MGR);
    for (i = 0; i < nRows; i++) {
        int nRow = GetM2DARowIdFromRowIndex(TABLE_EQUIP_MGR, i);
        if (CheckCriterion(nRow, "ItemSlot", nSlot))
            if (CheckCriterion(nRow, "Event", nEventType))
                if (CheckCriterion(nRow, "GameMode", nGM))
                    arListeners[nListeners++] = GetM2DAString(TABLE_EQUIP_MGR, "Script", nRow);
    }

    // Handle listeners
    for (i = 0; i < nListeners; i++)
        HandleEvent_String(ev, arListeners[i]);
}