// -----------------------------------------------------------------------------
// talent_single_target.nss
// -----------------------------------------------------------------------------
/*
    Generic Ability Script for single target abilities
*/
// -----------------------------------------------------------------------------
// georg / petert
// -----------------------------------------------------------------------------

#include "log_h"
#include "abi_templates"
#include "sys_traps_h"
#include "spell_constants_h"
#include "plt_cod_aow_spellcombo2"
#include "plt_cod_aow_spellcombo5"
#include "plt_cod_aow_spellcombo8"

void ForceExplosion(object oTarget, object oCaster)
{
    // play vfx
    effect eEffect = EffectVisualEffect(FORCE_EXPLOSION_VFX);
    location lTarget = GetLocation(oTarget);
    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_INSTANT, eEffect, lTarget);

    // apply damage
    float fSpellpower = GetCreatureSpellPower(oCaster);
    float fDamage = (100.0f + fSpellpower) * FORCE_EXPLOSION_DAMAGE_FACTOR;
    eEffect = EffectDamage(fDamage);
    effect eVFX = EffectVisualEffect(FORCE_EXPLOSION_IMPACT_VFX);
    effect eKnockdown = EffectKnockdown(oTarget, 0, ABILITY_SPELL_CRUSHING_PRISON);
    object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, lTarget, FORCE_EXPLOSION_RADIUS);
    int nCount = 0;
    int nMax = GetArraySize(oTargets);
    for (nCount = 0; nCount < nMax; nCount++)
    {
        if (oTargets[nCount] != oTarget)
        {
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eKnockdown, oTargets[nCount], 0.0f, oCaster, ABILITY_SPELL_CRUSHING_PRISON);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTargets[nCount], 0.0f, oCaster, ABILITY_SPELL_CRUSHING_PRISON);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eVFX, oTargets[nCount], 0.0f, oCaster, ABILITY_SPELL_CRUSHING_PRISON);
        }
    }

    // combo effect codex - shockwave
    if (IsFollower(oCaster) == TRUE)
    {
        WR_SetPlotFlag(PLT_COD_AOW_SPELLCOMBO5, COD_AOW_SPELLCOMBO_5_COMBUSTION, TRUE);
    }
}

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    // -------------------------------------------------------------------------
    // VAR BLOCK
    // -------------------------------------------------------------------------
    int    nScalingVector   = SCALING_VECTOR_DURATION;
    int    nAttackingValue  = PROPERTY_ATTRIBUTE_SPELLPOWER;
    int    nResistance      = RESISTANCE_INVALID;
    float  fDuration        = 0.0f;
    float  fScaledValue     = 0.0f;
    int    nEffect          = 0;
    int    nHandler         = SPELL_HANDLER_CUSTOM;
    effect eDamage;
    effect eEffect;
    effect[] eEffects;
    int bHostile = FALSE;

    // make sure there is a location, just in case
    if (IsObjectValid(stEvent.oTarget) == TRUE)
    {
        stEvent.lTarget = GetLocation(stEvent.oTarget);
    }

    // -------------------------------------------------------------------------
    // Handle Spells
    // -------------------------------------------------------------------------
    switch (stEvent.nAbility)
    {
        case ABILITY_SPELL_WINTERS_GRASP:
        {
            // impact vfx
            Ability_ApplyObjectImpactVFX(stEvent.nAbility, stEvent.oTarget);

            float fDamage = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * WINTERS_GRASP_DAMAGE_FACTOR;
            eEffect = EffectDamage(fDamage, DAMAGE_TYPE_COLD);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);

            // adjust duration based on rank
            float fDuration = GetRankAdjustedEffectDuration(stEvent.oTarget, WINTERS_GRASP_DURATION);

            // remove stacking effects
            RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

            // physical resistance
            if (ResistanceCheck(stEvent.oCaster, stEvent.oTarget, PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
            {
                // frozen
                eEffect = EffectParalyze(WINTERS_GRASP_FROZEN_VFX);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);
                
                // petrify
                eEffect = Effect(EFFECT_TYPE_PETRIFY);
                eEffect = SetEffectInteger(eEffect, 0, 0);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);
            } else
            {
                // vfx
                eEffect = EffectVisualEffect(WINTERS_GRASP_SLOW_VFX);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);

                // slow
                eEffect = EffectModifyMovementSpeed(WINTERS_GRASP_SPEED_PENALTY, TRUE);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);
            }

            bHostile = TRUE;
            break;
        }
    }
    if(bHostile) // sending only for hostile spells
        SendEventOnCastAt(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility, bHostile);
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