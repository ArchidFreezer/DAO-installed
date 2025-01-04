void main()
{
    object oPC = GetHero();
    float fHealth = GetCreatureProperty(oPC, PROPERTY_ATTRIBUTE_CONSTITUTION, PROPERTY_VALUE_BASE);
    SetCreatureProperty(oPC, PROPERTY_ATTRIBUTE_CONSTITUTION, (fHealth + 3.0f), PROPERTY_VALUE_BASE);
}
