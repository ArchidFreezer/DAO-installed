#include "2da_data_h"
#include "2da_constants_h"
#include "events_h"
#include "ability_h"

void reactivateAbility(int nAbility) {
    int nAbilityType = GetAbilityType(nAbility);
    event ev = Event(EVENT_TYPE_SPELLSCRIPT_IMPACT);
    ev = SetEventObject(ev, 0, OBJECT_SELF);
    ev = SetEventObject(ev, 1, OBJECT_SELF);
    ev = SetEventInteger(ev, 0, nAbility);
    ev = SetEventInteger(ev, 1, nAbilityType);
    ev = SetEventLocation(ev, 0, GetLocation(OBJECT_SELF));
    Ability_DoRunSpellScript(ev, nAbility, nAbilityType);
    SetCooldown(OBJECT_SELF, nAbility, 0.0f);
}

void deactivateAbility(object oCreature, int nAbility) {
    int nAbilityType = Ability_GetAbilityType(nAbility);
    event ev = EventSpellScriptDeactivate(oCreature, nAbility, nAbilityType);
    Ability_DoRunSpellScript(ev, nAbility, nAbilityType);
}

void delayReactivate(object oCreature, int nAbility) {
    event ev = SetEventInteger(Event(EVENT_TYPE_INVALID), 0, nAbility);
    DelayEvent(0.05, oCreature, ev, "reapply_buffs");
}

void toggleAbility(object oCreature, int nAbility) {
    if (HasAbility(oCreature, nAbility)) {
        if (IsModalAbilityActive(oCreature,nAbility)) {
            deactivateAbility(oCreature, nAbility);
            delayReactivate(oCreature, nAbility);
        }
    }
}

void toggleAllAbilities(object oCreature) {
    toggleAbility(oCreature, ABILITY_TALENT_CRY_OF_VALOR);
    toggleAbility(oCreature, ABILITY_TALENT_DEMORALIZE);
    toggleAbility(oCreature, ABILITY_SPELL_FROSTWALL);
    toggleAbility(oCreature, ABILITY_SPELL_MIND_FOCUS);
    toggleAbility(oCreature, ABILITY_SPELL_FLAMING_WEAPONS);
    toggleAbility(oCreature, ABILITY_SPELL_ARCANE_MIGHT);
}

void main() {
    event ev = GetCurrentEvent();
    if (GetEventType(ev) == EVENT_TYPE_INVALID) {
        int nAbi = GetEventInteger(ev, 0);
        if (nAbi > 0) {
            reactivateAbility(nAbi);
            return;
        }
    }

    object[] arParty = GetPartyList(GetHero());
    int i, nPartySize = GetArraySize(arParty);
    for (i = 0; i < nPartySize; i++) {
        toggleAllAbilities(arParty[i]);
    }
}