void main()
{
    object[] arParty = GetPartyPoolList();
    int i;
    for (i = 0; i < GetArraySize(arParty); i++)
        SetCreatureProperty(arParty[i], 51, 100.0, PROPERTY_VALUE_BASE);
}