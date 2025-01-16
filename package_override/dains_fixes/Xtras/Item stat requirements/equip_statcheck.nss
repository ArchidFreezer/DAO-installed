#include "2da_constants_h"
#include "effect_constants_h"
#include "effect_modify_property_h"

void DelayUnequip(object oItem, int nSlot) {
    event ev = Event(EVENT_TYPE_INVALID);
    ev = SetEventObject(ev, 0, oItem);
    ev = SetEventInteger(ev, 0, nSlot);
    DelayEvent(0.0, OBJECT_SELF, ev, "equip_statcheck");
}

void CheckSlot(int nSlot) {
    object oItem = GetItemInEquipSlot(nSlot);
    if (IsObjectValid(oItem) && !IsItemIrremovable(oItem) && !CanUseItem(OBJECT_SELF, oItem)) {
        // Unequipping while still in inventory screen causes the game engine to bug out and show items incorrectly, so we have to delay it
        DelayUnequip(oItem, nSlot);
    }
}

void CheckAllItemRequirements() {
    CheckSlot(INVENTORY_SLOT_MAIN);
    CheckSlot(INVENTORY_SLOT_OFFHAND);
    CheckSlot(INVENTORY_SLOT_CHEST);
    CheckSlot(INVENTORY_SLOT_HEAD);
    CheckSlot(INVENTORY_SLOT_CLOAK);
    CheckSlot(INVENTORY_SLOT_GLOVES);
    CheckSlot(INVENTORY_SLOT_BOOTS);
    CheckSlot(INVENTORY_SLOT_SHALE_CHEST);
    CheckSlot(INVENTORY_SLOT_SHALE_RIGHTARM);
}

void CheckWeaponRequirements() {
    CheckSlot(INVENTORY_SLOT_MAIN);
    CheckSlot(INVENTORY_SLOT_OFFHAND);
}

void CheckShaleArmour() {
    CheckSlot(INVENTORY_SLOT_SHALE_CHEST);
}

void CheckAttributeRequirements(event ev) {
    object oItem = GetEventObject(ev, 0);
    int nEventType = GetEventType(ev);
    int[] aProps = GetItemProperties(oItem, TRUE);
    int i, nSize = GetArraySize(aProps);
    for (i = 0; i < nSize; i++) {
        int nProp = aProps[i];
        int nEffect = GetM2DAInt(TABLE_ITEMPRPS, "effect", nProp);
        float fPower = GetItemPropertyPower(oItem, nProp, TRUE) * GetM2DAFloat(TABLE_ITEMPRPS, "Float0", nProp);
        int nInt0 = GetM2DAInt(TABLE_ITEMPRPS, "Int0", nProp);
        if (nEffect == EFFECT_TYPE_MODIFY_PROPERTY || nEffect == EFFECT_TYPE_MODIFYATTRIBUTE) {
            if (nEventType == EVENT_TYPE_EQUIP ? fPower < 0.0 : nEventType == EVENT_TYPE_UNEQUIP ? fPower > 0.0 : FALSE) {
                if (nInt0 == EFFECT_MODIFY_PROPERTY_ATTRIBUTE_ALL || nInt0 == (HasAbility(OBJECT_SELF, ABILITY_SPELL_COMBAT_MAGIC) ? PROPERTY_ATTRIBUTE_MAGIC : PROPERTY_ATTRIBUTE_STRENGTH)) {
                    CheckAllItemRequirements();
                    break;
                } else if (nInt0 == PROPERTY_ATTRIBUTE_DEXTERITY) {
                    CheckWeaponRequirements();
                } else if (nInt0 == PROPERTY_ATTRIBUTE_CONSTITUTION) {
                    CheckShaleArmour();
                }
            }
        } else if (nEffect == EFFECT_TYPE_ADDABILITY && nInt0 == ABILITY_TRAIT_HIGH_MORALE && nEventType == EVENT_TYPE_UNEQUIP && !HasAbility(OBJECT_SELF, ABILITY_SPELL_COMBAT_MAGIC)) {
            CheckAllItemRequirements();
            break;
        }
    }
}

void main() {
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    if (nEventType == EVENT_TYPE_INVALID) {
        object oItem = GetEventObject(ev, 0);
        // Check if subsequent equipment changes made the item useable again and it hasn't been unequipped otherwise
        if (!CanUseItem(OBJECT_SELF, oItem) && GetItemEquipSlot(oItem) != INVENTORY_SLOT_INVALID) {
            UnequipItem(OBJECT_SELF, oItem);
            DisplayFloatyMessage(OBJECT_SELF, "Unequipping " + GetName(oItem), FLOATY_MESSAGE, 0xff0000, 2.0);
            CheckAttributeRequirements(ev);
        }
    } else {
        CheckAttributeRequirements(ev);
    }
}