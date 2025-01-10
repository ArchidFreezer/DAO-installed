#include "fastmove_h"
#include "no_weapon_crust_h"
#include "effect_lucky_h"

// RemoveEffect does nothing if effect is provided by an item; need to unequip and re-equip
void ReallyRemoveEffect(object oCreature, effect ef) {
    object oCreator = GetEffectCreator(ef);
    if (GetObjectType(oCreator) == OBJECT_TYPE_ITEM) {
        int nSlot = GetItemEquipSlot(oCreator);
        UnequipItem(oCreature, oCreator);
        EquipItem(oCreature, oCreator, nSlot);
    } else {
        RemoveEffect(oCreature, ef);
    }
}

void RemoveLuck(object oCreature) {
    effect[] effects = GetEffects(oCreature, EFFECT_TYPE_LUCK);
    int i, nSize = GetArraySize(effects);
    for (i = 0; i < nSize; i++) {
        effect ef = effects[i];
        Lucky_HandleRemoveEffect(ef, oCreature);
        ReallyRemoveEffect(oCreature, ef);
    }
}

void RemoveMorale(object oCreature) {
    effect[] effects = GetEffects(oCreature, EFFECT_TYPE_ADDABILITY);
    int i, nSize = GetArraySize(effects);
    for (i = 0; i < nSize; i++) {
        effect ef = effects[i];
        int int0 = GetEffectInteger(ef, 0);
        if (int0 == 150005 || int0 == 150006) {
            ReallyRemoveEffect(oCreature, ef);
        }
    }
}

void RemoveNewTele(object oCreature) {
    effect[] effects = GetEffects(oCreature, 891111795);
    int i, nSize = GetArraySize(effects);
    for (i = 0; i < nSize; i++) {
        effect ef = effects[i];
        if (i == 0) {
            int nProp = GetEffectInteger(ef, 0);
            float fChange = -1*GetEffectFloat(ef, 0);
            UpdateCreatureProperty(oCreature, nProp, fChange, PROPERTY_VALUE_MODIFIER);
        }
        ReallyRemoveEffect(oCreature, ef);
    }
}

void RemoveAura(object oCreature, int nType) {
    effect[] effects = GetEffects(oCreature, nType);
    int i, nSize = GetArraySize(effects);
    for (i = 0; i < nSize; i++) {
        object oCreator = GetEffectCreator(effects[i]);
        RemoveEffectsByParameters(OBJECT_SELF, EFFECT_TYPE_AOE, 0, oCreator);
    }
}    

void main() {
    object[] arParty = GetPartyPoolList();
    int bLucky = GetM2DAInt(TABLE_ITEMPRPS, "Int1", 1508) != 1;
    int bMorale = GetM2DAInt(TABLE_ITEMPRPS, "effect", 110500) != 1031;
    int bWpnCrust = GetM2DAInt(TABLE_ITEMPRPS, "IPType", 393679558) != 2;
    int bDualTele = GetM2DAInt(TABLE_ITEMPRPS, "effect", 6085) != 891111795;
    int bWND = GetM2DAInt(TABLE_ITEMPRPS, "effect", 1501) != 957819684;
    int bGCA = GetM2DAInt(TABLE_ITEMPRPS, "effect", 1502) != 204363167;
    
    int i, nSize = GetArraySize(arParty);
    for (i = 0; i < nSize; i++) {
        object oChar = arParty[i];
        // Always remove haste in case 2da has changed. Heartbeat will reactivate it
        removeHaste(oChar);
        if (bLucky) RemoveLuck(oChar);
        if (bMorale) RemoveMorale(oChar);
        if (bWpnCrust) RemoveDummyVfx(oChar);
        if (bDualTele) RemoveNewTele(oChar);
        if (bWND) RemoveAura(oChar, 957819684);
        if (bGCA) RemoveAura(oChar, 204363167);
    }
}