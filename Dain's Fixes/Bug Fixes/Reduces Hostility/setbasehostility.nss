void main()
{
    object[] arParty = GetPartyPoolList();
    int i;
    for (i = 0; i < GetArraySize(arParty); i++)
        SetCreatureProperty(arParty[i], PROPERTY_SIMPLE_THREAT_DECREASE_RATE, 0.0, PROPERTY_VALUE_BASE);
}