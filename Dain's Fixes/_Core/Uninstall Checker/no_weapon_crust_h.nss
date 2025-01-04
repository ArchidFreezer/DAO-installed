#include "effects_h"

const int nDummyPrp = 393679558;

object[] GetWeapons(object oCreature = OBJECT_SELF) {
    object[] oWeapons;
    int n = 0;
    object oMain = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oCreature);
    if (GetItemType(oMain) == ITEM_TYPE_WEAPON_MELEE)
        oWeapons[n++] = oMain;
    object oOff = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oCreature);
    if (GetItemType(oOff) == ITEM_TYPE_WEAPON_MELEE)
        oWeapons[n] = oOff;
    return oWeapons;
}

int HasDummyVfx(object oWeapon) {
    return GetItemPropertyPower(oWeapon, nDummyPrp, FALSE) > 0;
}

int HasVfx(object oWeapon) {
    int[] arProps = GetItemProperties(oWeapon, TRUE);
    int i, nSize = GetArraySize(arProps);
    for (i = 0; i < nSize; i++) {
        int nProp = arProps[i];
        if (nProp != nDummyPrp && GetM2DAInt(TABLE_ITEMPRPS, "VFX", nProp) > 0 && GetM2DAInt(TABLE_ITEMPRPS, "IPType", nProp) == 2)
            return TRUE;
    }
    return FALSE;
}

void AddDummyVfx(object oObj = OBJECT_SELF) {
    switch (GetObjectType(oObj)) {
        case OBJECT_TYPE_CREATURE: {
            object[] oWeapons = GetWeapons(oObj);
            int i, nSize = GetArraySize(oWeapons);
            for (i = 0; i < nSize; i++)
                AddDummyVfx(oWeapons[i]);
            break;
        }
        case OBJECT_TYPE_ITEM: {
            if (!HasDummyVfx(oObj))
                AddItemProperty(oObj, nDummyPrp, 999);
            break;
        }
    }
}

void RemoveDummyVfx(object oObj = OBJECT_SELF) {
    switch (GetObjectType(oObj)) {
        case OBJECT_TYPE_CREATURE: {
            object[] oWeapons = GetWeapons(oObj);
            int i, nSize = GetArraySize(oWeapons);
            for (i = 0; i < nSize; i++)
                RemoveDummyVfx(oWeapons[i]);
            break;
        }
        case OBJECT_TYPE_ITEM: {
            if (HasDummyVfx(oObj))
                RemoveItemProperty(oObj, nDummyPrp);
            break;
        }
    }
}

void DelayHide() {
    event evi = Event(EVENT_TYPE_INVALID);
    DelayEvent(1.5, OBJECT_SELF, evi, "no_weapon_crust");
}

int CheckVfx(object oWeapon) {
    if (HasVfx(oWeapon)) {
        if (HasDummyVfx(oWeapon)) {
            // Check dummy is last item property
            int[] arProps = GetItemProperties(oWeapon, FALSE);
            if (arProps[GetArraySize(arProps) - 1] != nDummyPrp) {
                RemoveDummyVfx(oWeapon);
                AddDummyVfx(oWeapon);
            }
            return FALSE;
        } else {
            DelayHide();
            return TRUE;
        }
    } else {
        RemoveDummyVfx(oWeapon);
        return FALSE;
    }
}