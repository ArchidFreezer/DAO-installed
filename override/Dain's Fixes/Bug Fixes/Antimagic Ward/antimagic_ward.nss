
#include "log_h"
#include "abi_templates"
#include "spell_constants_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    effect eEffect;

    // remove stacking effects
    RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

    // add spell ward
    eEffect = Effect(EFFECT_TYPE_SPELL_WARD);
    eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, ANTIMAGIC_WARD_DURATION, stEvent.oCaster, stEvent.nAbility);

    // add 100% spell resistance
    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_SPELLRESISTANCE, 100.0f);
    eEffect = SetEffectInteger(eEffect, 0, 1);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, ANTIMAGIC_WARD_DURATION, stEvent.oCaster, stEvent.nAbility);
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