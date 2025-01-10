#include "abi_templates"
#include "monster_constants_h"
#include "spell_constants_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    // impact vfx
    Ability_ApplyObjectImpactVFX(stEvent.nAbility, stEvent.oTarget);

    // remove stacking effects
    RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

    // damage over time
    float fDamage = (100.0f + GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_DEXTERITY)) * POISON_SPIT_DAMAGE_FACTOR;
    if(GetCreatureRank(stEvent.oCaster) == CREATURE_RANK_BOSS) // queen spider hack
        fDamage *= 1.5;

    ApplyEffectDamageOverTime(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility, fDamage, POISON_SPIT_DAMAGE_DURATION, DAMAGE_TYPE_NATURE);
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            struct EventSpellScriptPendingStruct stEvent = Events_GetEventSpellScriptPendingParameters(ev);

            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // Hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));

            // Handle impact
            _HandleImpact(stEvent);

            SendEventOnCastAt(stEvent.oTarget,stEvent.oCaster, stEvent.nAbility, TRUE);

            break;
        }
    }
}