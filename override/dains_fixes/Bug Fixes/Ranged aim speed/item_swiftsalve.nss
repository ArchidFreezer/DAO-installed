#include "log_h"
#include "abi_templates"
#include "item_constants_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    effect eEffect;
    // remove stacking effects
    RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

    // movement speed
    eEffect = EffectModifyMovementSpeed(SWIFT_SALVE_MOVEMENT_INCREASE);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, SWIFT_SALVE_DURATION, stEvent.oCaster, stEvent.nAbility);

    // attack speed
    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_ATTACK_SPEED_MODIFIER, SWIFT_SALVE_ATTACK_INCREASE);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, SWIFT_SALVE_DURATION, stEvent.oCaster, stEvent.nAbility);

    // aim speed
    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_RANGED_AIM_SPEED, -0.1f);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, SWIFT_SALVE_DURATION, stEvent.oCaster, stEvent.nAbility);

    Ability_ApplyLocationImpactVFX(stEvent.nAbility, stEvent.lTarget);
    Ability_ApplyObjectImpactVFX(stEvent.nAbility, stEvent.oTarget);
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
            _HandleImpact(stEvent);

            break;
        }
    }
}