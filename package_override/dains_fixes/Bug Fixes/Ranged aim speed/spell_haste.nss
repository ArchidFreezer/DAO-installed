#include "log_h"
#include "abi_templates"
#include "spell_constants_h"
#include "talent_constants_h"
#include "plt_tut_modal"

// add effects
void _ActivateModalAbility(struct EventSpellScriptImpactStruct stEvent)
{
    if(IsFollower(stEvent.oCaster))
        WR_SetPlotFlag(PLT_TUT_MODAL, TUT_MODAL_1, TRUE);
    
    effect[] eEffects;
    eEffects[0] = EffectModifyMovementSpeed(HASTE_MOVEMENT_SPEED_MODIFIER);
    eEffects[1] = EffectModifyProperty(PROPERTY_ATTRIBUTE_ATTACK_SPEED_MODIFIER, HASTE_ANIMATION_SPEED_MODIFIER);
    eEffects[1] = SetEffectEngineInteger(eEffects[1], EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
    eEffects[2] = EffectModifyProperty(PROPERTY_ATTRIBUTE_RANGED_AIM_SPEED, -0.2f, PROPERTY_ATTRIBUTE_ATTACK, -5.0f);

    // caster-only mana degeneration
    effect eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, (REGENERATION_STAMINA_COMBAT_DEGENERATION - 1.0f) );
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eEffect, stEvent.oCaster, 0.0f, stEvent.oCaster, stEvent.nAbility);

    Ability_ApplyUpkeepEffects(stEvent.oCaster, stEvent.nAbility, eEffects, stEvent.oTarget, TRUE);
}

// remove effects
void _DeactivateModalAbility(object oCaster, int nAbility)
{
    Log_Trace_Spell("_DeactivateModalAbility", "Deactivate modal ability.", nAbility, OBJECT_INVALID);

    // remove effects
    Effects_RemoveUpkeepEffect(oCaster, nAbility);
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            // hand through
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // we just hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));

            // Remove any previously existing effects from same spellid to avoid stacking
            Ability_PreventAbilityEffectStacking(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

            // activate ability
            _ActivateModalAbility(stEvent);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_DEACTIVATE:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptDeactivateStruct stEvent = Events_GetEventSpellScriptDeactivateParameters(ev);

            // is ability active?
            if (IsModalAbilityActive(stEvent.oCaster, stEvent.nAbility) == TRUE)
            {
                _DeactivateModalAbility(stEvent.oCaster, stEvent.nAbility);
            }

            // Setting Return Value (abort means we aborted the ability)
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_INVALID);

            break;
        }
    }
}