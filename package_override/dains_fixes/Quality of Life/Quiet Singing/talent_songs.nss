// -----------------------------------------------------------------------------
// spell_modalsingletarget.nss
// -----------------------------------------------------------------------------
/*
    Generic Ability Script for modal single target abilities
*/
// -----------------------------------------------------------------------------
// PeterT
// -----------------------------------------------------------------------------

#include "log_h"
#include "abi_templates"
#include "talent_constants_h"
#include "ability_summon_h"
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

    // -------------------------------------------------------------------------
    // Handle Spells
    // -------------------------------------------------------------------------
    switch (stEvent.nAbility)
    {
        case ABILITY_TALENT_CRY_OF_VALOR:
        {
            float fStamina = SONG_OF_VALOR_STAMINA_REGENERATION_BONUS + (GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_INTELLIGENCE) * SONG_OF_VALOR_ATTRIBUTE_FACTOR);
            eEffects[0] = EffectModifyProperty(PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, fStamina,
                                               PROPERTY_ATTRIBUTE_REGENERATION_STAMINA, fStamina * SONG_OF_VALOR_EXPLORE_FACTOR);
            eEffects[0] = SetEffectEngineInteger(eEffects[0], EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));

            break;
        }

        case ABILITY_TALENT_DEMORALIZE:
        {
            float fCritical = SONG_OF_COURAGE_CRITICAL_BASE + (GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_INTELLIGENCE) * SONG_OF_COURAGE_CRITICAL_FACTOR);
            float fAttack = SONG_OF_COURAGE_ATTACK_BASE + (GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_INTELLIGENCE) * SONG_OF_COURAGE_ATTACK_FACTOR);
            float fDamage = SONG_OF_COURAGE_DAMAGE_BASE + (GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_INTELLIGENCE) * SONG_OF_COURAGE_DAMAGE_FACTOR);
            eEffects[0] = EffectModifyProperty(PROPERTY_ATTRIBUTE_MELEE_CRIT_MODIFIER, fCritical,
                                               PROPERTY_ATTRIBUTE_RANGED_CRIT_MODIFIER, fCritical);
            eEffects[0] = SetEffectEngineInteger(eEffects[0], EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
            eEffects[1] = EffectModifyProperty(PROPERTY_ATTRIBUTE_ATTACK, fAttack,
                                               PROPERTY_ATTRIBUTE_DAMAGE_BONUS, fDamage);

            break;
        }
    }

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