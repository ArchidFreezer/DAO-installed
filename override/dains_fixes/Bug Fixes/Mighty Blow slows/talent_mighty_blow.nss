#include "abi_templates"
#include "combat_h"
#include "talent_constants_h"
#include "effects_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    object oWeapon  = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, stEvent.oCaster);

    // if the attack hit
    int nResult = Combat_GetAttackResult(stEvent.oCaster, stEvent.oTarget, oWeapon, 10.0f, stEvent.nAbility);
    if (IsCombatHit(nResult) == TRUE)
    {
        nResult = COMBAT_RESULT_CRITICALHIT;
        float fDamage = Combat_Damage_GetAttackDamage(stEvent.oCaster, stEvent.oTarget, oWeapon, nResult, 0.0f);

        // apply impact
        effect eEffect = EffectImpact(fDamage, oWeapon,0, stEvent.nAbility);
        Combat_HandleAttackImpact(stEvent.oCaster, stEvent.oTarget, nResult, eEffect);

        // 5 second slow
        effect eSlow = EffectModifyMovementSpeed(0.5, TRUE);
        eSlow = SetEffectEngineInteger(eSlow, EFFECT_INTEGER_VFX, 1105);
        float fDuration = GetRankAdjustedEffectDuration(stEvent.oTarget, 5.0);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eSlow, stEvent.oTarget, fDuration, stEvent.oCaster);

        if (IsCreatureSpecialRank(stEvent.oTarget) == FALSE)
        {
            eEffect = Effect(EFFECT_TYPE_HEAVY_IMPACT);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);
        }
    }
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
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_CAST",Log_GetAbilityNameById(stEvent.nAbility));
            #endif

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

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));
            #endif

            _HandleImpact(stEvent);

            break;
        }
    }
}