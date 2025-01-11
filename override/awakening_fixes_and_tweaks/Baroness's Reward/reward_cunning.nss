void main()
{
    object oPC = GetHero();
    float fCunning = GetCreatureProperty(oPC, PROPERTY_ATTRIBUTE_INTELLIGENCE, PROPERTY_VALUE_BASE);
    SetCreatureProperty(oPC, PROPERTY_ATTRIBUTE_INTELLIGENCE, (fCunning + 3.0f), PROPERTY_VALUE_BASE);
}