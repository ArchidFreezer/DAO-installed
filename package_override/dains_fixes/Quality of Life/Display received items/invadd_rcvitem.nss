const int TABLE_OPTS = 278334417;

void main() {
    if (IsFollower(OBJECT_SELF)) {
        event ev = GetCurrentEvent();
        object oItem = GetEventObject(ev, 0);
        string sMsg = GetName(oItem);
        /* not doing this, picks up qty already in inventory too
        int nStackSize = GetItemStackSize(oItem);
        if (nStackSize > 1) {
            sMsg = sMsg + " (" + ToString(nStackSize) + ")";
        }*/
        // Add material if equippable
        if ((GetM2DAInt(6, "EquippableSlots", GetBaseItemType(oItem)) & 243) > 0) {
            int nMaterial = GetM2DAInt(89, "Material", GetItemMaterialType(oItem));
            if (nMaterial > 0) {
                string sName = GetTlkTableString(GetM2DAInt(159, "NameStrRef", nMaterial));
                if (GetStringLength(sName) > 0)
                    sMsg += " (" + sName + ")";
            }
        }
        
        int nColor = GetM2DAInt(TABLE_OPTS, "color", 1);
        float fDuration = GetM2DAFloat(TABLE_OPTS, "duration", 1);

        DisplayFloatyMessage(OBJECT_SELF, sMsg, FLOATY_MESSAGE, nColor, fDuration);
    }
}