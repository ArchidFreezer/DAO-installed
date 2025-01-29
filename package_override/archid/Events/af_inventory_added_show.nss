/*
* Post event listener for: EVENT_TYPE_INVENTORY_ADDED
*/
#include "af_logging_h"

const int MOD_OPTIONS = 6610007;
const int AF_LOGGROUP_ITEMRECEIVE = 8;

void main() {
    if (IsFollower(OBJECT_SELF) && GetM2DAInt(TABLE_OPTIONS, "enabled", 11)) {
        event ev = GetCurrentEvent();
        object oItem = GetEventObject(ev, 0);
        string sMsg = GetName(oItem);

        afLogDebug("Showing floaty for " + sMsg, AF_LOGGROUP_ITEMRECEIVE);
        // Add material if equippable
        if ((GetM2DAInt(6, "EquippableSlots", GetBaseItemType(oItem)) & 243) > 0) {
            int nMaterial = GetM2DAInt(89, "Material", GetItemMaterialType(oItem));
            if (nMaterial > 0) {
                string sName = GetTlkTableString(GetM2DAInt(159, "NameStrRef", nMaterial));
                if (GetStringLength(sName) > 0)
                    sMsg += " (" + sName + ")";
            }
        }

        int nColor = GetM2DAInt(MOD_OPTIONS, "colour", 1);
        float fDuration = GetM2DAFloat(MOD_OPTIONS, "duration", 1);

        DisplayFloatyMessage(OBJECT_SELF, sMsg, FLOATY_MESSAGE, nColor, fDuration);
    }
}