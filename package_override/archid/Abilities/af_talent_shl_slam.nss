//*=============================================================================
// AB: script for Shale's Slam
//*=============================================================================

#include "abi_templates"
#include "combat_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    effect eEffect;

    object oWeapon = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);

    int nResult = COMBAT_RESULT_CRITICALHIT; // autohit, autocrit

    // normal crit damage
    float fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult, 0.0);

    eEffect = EffectImpact(fDamage, oWeapon, 0, stEvent.nAbility);
    Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eEffect);
    // this VFX needs to be played on Shale so it'd actually look like target impact VFX ingame
    ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oCaster, 105400, EFFECT_DURATION_TYPE_INSTANT, 0.0, stEvent.nAbility);

    // knockback effect
    eEffect = Effect(EFFECT_TYPE_KNOCKBACK);
    eEffect = SetEffectEngineFloat(eEffect, EFFECT_FLOAT_KNOCKBACK_DISTANCE, 2.0f);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);

    // brief stun
    if (!ResistanceCheck(stEvent.oCaster, stEvent.oTarget, PROPERTY_ATTRIBUTE_STRENGTH, PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL))
    {
        eEffect = EffectStun();
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, RandomFloat() + 1.0, stEvent.oCaster, stEvent.nAbility);
    }

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

            // we just hand this through to cast_impact
            int nTarget = PROJECTILE_TARGET_INVALID;
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult, nTarget);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            _HandleImpact(stEvent);

            break;
        }
    }
}