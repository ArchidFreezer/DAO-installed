#include "log_h"
#include "abi_templates"
#include "effects_h"
#include "talent_constants_h"
#include "plt_tut_modal"

// add effects
void _ActivateModalAbility(struct EventSpellScriptImpactStruct stEvent)
{
    // effects
    effect[] eEffects;

    if(IsFollower(stEvent.oCaster))
    {
        WR_SetPlotFlag(PLT_TUT_MODAL, TUT_MODAL_1, TRUE);
    }

    // Only handle Beyond the Veil
    if (stEvent.nAbility == 401100)
    {
        int nVfx = 401100;
        eEffects[0] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DISPLACEMENT, 50.0f);
        eEffects[1] = EffectModifyProperty(PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, -10.0f);

        // Soulbrand
        if (HasAbility(stEvent.oCaster, 401101))
        {
            nVfx = 401101;
            eEffects[2] = EffectModifyProperty(PROPERTY_ATTRIBUTE_SPELLRESISTANCE, HasAbility(stEvent.oCaster, 401103) ? 45.0f : 20.0f);
        }

        // Blessing of the Fade
        if (HasAbility(stEvent.oCaster, 401103))
        {
            nVfx = 401103;
            eEffects[3] = EffectModifyProperty(PROPERTY_ATTRIBUTE_ATTACK_SPEED_MODIFIER, -0.2f);
            eEffects[4] = EffectModifyMovementSpeed(1.2f);
        }

        // VFX
        eEffects[0] = SetEffectEngineInteger(eEffects[0], EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(nVfx));
    }

    #ifdef DEBUG
    Log_Trace_Spell("_ActivateModalAbility", "Activating modal ability.", stEvent.nAbility, OBJECT_INVALID);
    #endif

    Ability_ApplyUpkeepEffects(stEvent.oCaster, stEvent.nAbility, eEffects, stEvent.oTarget);

    #ifdef DEBUG
    Log_Trace_Spell("_ActivateModalAbility", "Modal ability activated.", stEvent.nAbility, OBJECT_INVALID);
    #endif
}

// remove effects
void _DeactivateModalAbility(object oCaster, int nAbility)
{
    #ifdef DEBUG
    Log_Trace_Spell("_DeactivateModalAbility", "Deactivate modal ability.", nAbility, OBJECT_INVALID);
    #endif

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

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));
            #endif

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