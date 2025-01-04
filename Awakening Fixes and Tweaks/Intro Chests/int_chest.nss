void main()
{
    object oChest = GetObjectByTag("int100ip_placed_treasure_1");
    int nRogue = HasAbility(OBJECT_SELF, 4020);
   
    if (nRogue == FALSE)
    {
        SetPlaceableState(oChest, 0);    
    }
}