void main()
{
    object oPC = GetHero();
    float fMagic = GetCreatureProperty(oPC, PROPERTY_ATTRIBUTE_MAGIC, PROPERTY_VALUE_BASE);
    SetCreatureProperty(oPC, PROPERTY_ATTRIBUTE_MAGIC, (fMagic + 3.0f), PROPERTY_VALUE_BASE);
}
