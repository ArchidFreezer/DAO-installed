//*=============================================================================
// AB: script for Shale's Killing Blow
//*=============================================================================

//*=============================================================================
// Reworked. Final Blow already uses this mechanic. Don't need 2 fighters with
// an empty stamina bar in a fight. Damage now goes up when target's HP goes
// down, but only when below 50% HP.
//*=============================================================================

#include "abi_templates"
#include "combat_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    effect eEffect;

    object oWeapon = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);

    int nResult = COMBAT_RESULT_CRITICALHIT; // autohit, autocrit

    // +10 AP, 150% crit damage
    float fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult, 10.0) * 1.5;

    float fHPPercent = _GetRelativeResourceLevel(stEvent.oTarget, PROPERTY_DEPLETABLE_HEALTH);

    if (fHPPercent < 0.5)
    {
        float fFactor = 1.0 + 0.15 / fHPPercent;

        if (IsCreatureBossRank(stEvent.oTarget))
            fDamage *= MinF(2.0, fFactor); // capped at 2 for bosses at 15% HP
        else
            fDamage *= MinF(4.0, fFactor); // capped at 4 for non-bosses at 5% HP
    }

    eEffect = EffectImpact(fDamage, oWeapon, 0, stEvent.nAbility);
    Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eEffect);
    // this VFX needs to be played on Shale so it'd actually look like target impact VFX ingame
    ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oCaster, 105403, EFFECT_DURATION_TYPE_INSTANT, 0.0, stEvent.nAbility);

    // no-save knockdown if not immune
    if (!IsImmuneToEffectType(stEvent.oTarget, EFFECT_TYPE_KNOCKDOWN))
    {
        eEffect = EffectKnockdown(stEvent.oCaster, 0, stEvent.nAbility);

        if (IsHumanoid(stEvent.oTarget))
        {
            eEffect = SetEffectEngineFloat(eEffect, EFFECT_FLOAT_KNOCKBACK_DISTANCE, -0.05f);
        }
        else
        {
            eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_DONT_INTERPOLATE, TRUE);
        }

        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, RandomFloat(), stEvent.oCaster, stEvent.nAbility);
    }
    else // knockback otherwise
    {
        eEffect = Effect(EFFECT_TYPE_KNOCKBACK);
        eEffect = SetEffectEngineFloat(eEffect, EFFECT_FLOAT_KNOCKBACK_DISTANCE, 2.0f);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);
    }

    SendEventOnCastAt(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

    // penalty to attack and stamina regen for 15s
    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_ATTACK, -10.0,
                                   PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, REGENERATION_STAMINA_COMBAT_DEGENERATION,
                                   PROPERTY_ATTRIBUTE_REGENERATION_STAMINA, REGENERATION_STAMINA_COMBAT_DEGENERATION);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, 15.0f, stEvent.oCaster, stEvent.nAbility);

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