#include "2da_constants_h"
#include "events_h"        
#include "global_objects_h"

const int ABILITY_GUITYPE_SKILL = 13;
const int PROPERTY_SIMPLE_SPECIALIZATION_POINTS = 38;   

object[] GetEquippedItems(object oCreature, int[] arEquipSlots, int[] arWeaponSets)
{
    object[] arItems;

    int nIndex = 0;
    int nRows = GetM2DARows(-1, "mof_removable_equipment");

    int i = 0;
    for (i = 0; i < nRows; i++) {
        int nEquipSlot = GetM2DAInt(-1, "EquipSlot", i, "mof_removable_equipment");
        int nWeaponSet = GetM2DAInt(-1, "WeaponSet", i, "mof_removable_equipment");

        if (nWeaponSet == -1) nWeaponSet = INVALID_WEAPON_SET;
        object oItem = GetItemInEquipSlot(nEquipSlot, oCreature, nWeaponSet);

        if (IsObjectValid(oItem)) {
            arItems[nIndex] = oItem;
            arEquipSlots[nIndex] = nEquipSlot;
            arWeaponSets[nIndex] = nWeaponSet;
            ++nIndex;
        }
    }
    return arItems;
}

void EquipItems(object oCreature, object[] arItems, int[] arEquipSlots, int[] arWeaponSets)
{
    int i;
    for (i = 0; i < GetArraySize(arItems); i++) {
        EquipItem(oCreature, arItems[i], arEquipSlots[i], arWeaponSets[i]);
    }
}

void UnequipItems(object oCreature, object[] arItems)
{
    int i;
    for (i = 0; i < GetArraySize(arItems); i++) {
        UnequipItem(oCreature, arItems[i]);
    }
}

void AdjustCreatureProperty(object oCreature, int nProperty, float fDelta, int nValueType = PROPERTY_VALUE_TOTAL)
{
    float fOldValue = GetCreatureProperty(oCreature, nProperty, nValueType);
    float fNewValue = fOldValue + fDelta;
    SetCreatureProperty(oCreature, nProperty, fNewValue, nValueType);
}

void FixCharacterLevelUpPoints(object oCreature)
{
    if (IsFollower(oCreature)) {
        // Fix: Manual of Focus doesn't test whether The Warden has more than one permanent skill.
        if (IsHero(oCreature)) {
            if (GetAbilityCount(oCreature, ABILITY_TYPE_SKILL, ABILITY_GUITYPE_SKILL) > 1)
                AdjustCreatureProperty(oCreature, PROPERTY_SIMPLE_SKILL_POINTS, -1.0f);
        }
    }

    // Fix: Manual of Focus doesn't test whether the permanent 'Dirty Fighting' talent is removed.
    if (GetCreatureCoreClass(oCreature) == CLASS_ROGUE) {
        if (HasAbility(oCreature, ABILITY_TALENT_DIRTY_FIGHTING))
            AdjustCreatureProperty(oCreature, PROPERTY_SIMPLE_TALENT_POINTS, -1.0f);
    }
}

void main()
{
    event ev = GetCurrentEvent();

    if (!IsEventValid(ev))
        return;

    switch (GetEventType(ev))
    {
        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            object oTarget = GetEventObject(ev, 1);

            int[] arEquipSlots, arWeaponSets;
            object[] arItems = GetEquippedItems(oTarget, arEquipSlots, arWeaponSets);

            UnequipItems(oTarget, arItems);
            HandleEvent(ev, R"gxa_item.ncs");
            EquipItems(oTarget, arItems, arEquipSlots, arWeaponSets);
            FixCharacterLevelUpPoints(oTarget);
            break;
        }
        default:
            HandleEvent(ev, R"gxa_item.ncs");
    }
}