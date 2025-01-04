#include "abi_templates"
#include "effect_constants_h"
#include "talent_constants_h"
#include "plt_tut_modal"

// add effects
void _ActivateModalAbility(struct EventSpellScriptImpactStruct stEvent)
{
    effect[] eEffects;
    event eHeartbeat;

    if(IsFollower(stEvent.oCaster))
    {
        WR_SetPlotFlag(PLT_TUT_MODAL, TUT_MODAL_1, TRUE);
    }

    eEffects[0] = EffectAreaOfEffect(2003, R"shale_aoe_duration.ncs", 105417);
    eEffects[0] = SetEffectEngineFloat(eEffects[0], EFFECT_FLOAT_SCALE, GetM2DAFloat(TABLE_VFX_PERSISTENT, "RADIUS", 2003));
    eEffects[1] = EffectModifyProperty(PROPERTY_ATTRIBUTE_DEFENSE, 10.0, PROPERTY_ATTRIBUTE_ARMOR, -5.0);
    if (HasAbility(stEvent.oCaster, 300302 /* Earthen Grasp */)) {
        // Probably would've made more sense to put crit mod above, but I'm copying how vanilla does it apart from threat value
        eEffects[2] = EffectModifyProperty(PROPERTY_ATTRIBUTE_MELEE_CRIT_MODIFIER, -10.0, PROPERTY_ATTRIBUTE_MISSILE_SHIELD, 60.0, PROPERTY_SIMPLE_THREAT_DECREASE_RATE, 4.0);
    } else {
        eEffects[2] = EffectModifyProperty(PROPERTY_ATTRIBUTE_MELEE_CRIT_MODIFIER, -10.0, PROPERTY_ATTRIBUTE_MISSILE_SHIELD, 50.0);
    }
    
    int nVfx = Ability_GetImpactObjectVfxId(stEvent.nAbility);
    eEffects[1] = SetEffectEngineInteger(eEffects[1], EFFECT_INTEGER_VFX, nVfx);
    Ability_ApplyUpkeepEffects(stEvent.oCaster, stEvent.nAbility, eEffects, stEvent.oTarget);
}

// remove effects
void _DeactivateModalAbility(object oCaster, int nAbility)
{
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