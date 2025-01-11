#include "abi_templates"
#include "spell_constants_h"
#include "plt_cod_aow_spellcombo5"

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
    if (IsFollower(oCaster))
        WR_SetPlotFlag(PLT_COD_AOW_SPELLCOMBO5, COD_AOW_SPELLCOMBO_5_COMBUSTION, TRUE);
}

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    if (GetHasEffects(stEvent.oTarget, EFFECT_TYPE_INVALID, ABILITY_SPELL_WALL_OF_FORCE)) {
        RemoveEffectsByParameters(stEvent.oTarget, EFFECT_TYPE_INVALID, ABILITY_SPELL_WALL_OF_FORCE);

        ForceExplosion(stEvent.oTarget, stEvent.oCaster);
    } else if (!Combat_ShatterCheck(stEvent.oTarget, stEvent.oCaster)) {
        RemoveStackingEffects(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility);

        float fDuration = GetRankAdjustedEffectDuration(stEvent.oTarget, CRUSHING_PRISON_DURATION);
        float fFactor = fDuration / CRUSHING_PRISON_DURATION;

        effect eEffect = SetEffectEngineInteger(Effect(EFFECT_TYPE_DRAINING), EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
        /*effect eEffect = IsCreatureBossRank(stEvent.oTarget) ?
            EffectVisualEffect(Ability_GetImpactObjectVfxId(stEvent.nAbility)) :
            SetEffectEngineInteger(Effect(EFFECT_TYPE_DRAINING), EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));*/

        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);

        float fDamage = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * CRUSHING_PRISON_DAMAGE_FACTOR * fFactor;
        ApplyEffectDamageOverTime(stEvent.oTarget, stEvent.oCaster, stEvent.nAbility, fDamage, fDuration, DAMAGE_TYPE_SPIRIT);
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
            int bResult = COMMAND_RESULT_SUCCESS;

            object oCaster = GetEventObject(ev, 0);
            object oTarget = GetEventObject(ev, 1);

            if (!IsObjectHostile(oCaster, oTarget) && !GetHasEffects(oTarget, EFFECT_TYPE_INVALID, ABILITY_SPELL_WALL_OF_FORCE))
                bResult = COMMAND_RESULT_FAILED_NO_VALID_TARGET;

            Ability_SetSpellscriptPendingEventResult(bResult);

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