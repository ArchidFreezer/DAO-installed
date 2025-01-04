void main()
{
    object oChest = GetObjectByTag("genip_chest_iron");
    object oChest2 = GetObjectByTag("genip_chest_wood_1", 1);
    int nRogue = HasAbility(OBJECT_SELF, 4020);

    if (nRogue == FALSE)
    {
        SetPlaceableState(oChest, 0); 
        SetPlaceableState(oChest2, 0);
    }
}