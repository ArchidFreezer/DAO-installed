#include "log_h"
#include "abi_templates"
#include "spell_constants_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    // remove stacking effects
    RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

    // curse
    effect eEffect = Effect(EFFECT_TYPE_CURSE_OF_MORTALITY);
    eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, CURSE_OF_MORTALITY_DURATION, stEvent.oCaster, stEvent.nAbility);

    // health regeneration
    eEffect = EffectDecreaseProperty(PROPERTY_ATTRIBUTE_REGENERATION_HEALTH, CURSE_OF_MORTALITY_HEALTH_REGENERATION_PENALTY,
                                   PROPERTY_ATTRIBUTE_REGENERATION_HEALTH_COMBAT, CURSE_OF_MORTALITY_HEALTH_REGENERATION_PENALTY);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, CURSE_OF_MORTALITY_DURATION, stEvent.oCaster, stEvent.nAbility);

    // spirit dot
    float fDamage = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * CURSE_OF_MORTALITY_DAMAGE_FACTOR;
    ApplyEffectDamageOverTime(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility, fDamage, CURSE_OF_MORTALITY_DURATION, DAMAGE_TYPE_SPIRIT);

    SendEventOnCastAt(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
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
            if (CheckSpellResistance(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility) == FALSE)
            {
                _HandleImpact(stEvent);
            } else
            {
                UI_DisplayMessage(stEvent.oTarget, UI_MESSAGE_RESISTED);
            }

            break;
        }
    }
}