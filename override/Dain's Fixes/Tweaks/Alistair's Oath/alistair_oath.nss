void main() {
    object oAlistair = GetObjectByTag("gen00fl_alistair");

    if (!IsFollower(oAlistair) && !IsObjectValid(GetItemInEquipSlot(INVENTORY_SLOT_NECK, oAlistair))) {
        CreateItemOnObject(R"gen_im_acc_amu_war.uti", oAlistair);
        object oItem = GetItemPossessedBy(oAlistair, "gen_im_acc_amu_war");
        RemoveItemProperty(oItem, 10018);
        AddItemProperty(oItem, 6030, 1);
        EquipItem(oAlistair, oItem);
    }
}