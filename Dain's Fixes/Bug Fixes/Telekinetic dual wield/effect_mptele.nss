// effect_modify_property_telekinesis
// Like effect_modify_property but multiple effects do not stack
// Very important: all simultaneous effects must be identical. Guaranteed since this comes from enchantments but not generally

void main() {
    effect ef = GetCurrentEffect();
    int nType = GetEffectType(ef);
    if (!GetHasEffects(OBJECT_SELF, nType)) {
        int nProp = GetEffectInteger(ef, 0);
        int nMult = GetEventType(GetCurrentEvent()) == EVENT_TYPE_APPLY_EFFECT ? 1 : -1;
        float fChange = nMult*GetEffectFloat(ef, 0);
        UpdateCreatureProperty(OBJECT_SELF, nProp, fChange, PROPERTY_VALUE_MODIFIER);
    }
}