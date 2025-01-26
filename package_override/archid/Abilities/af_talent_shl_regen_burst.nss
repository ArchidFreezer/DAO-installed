//*=============================================================================
// AB: script for Shale's Regenerating Burst
//*=============================================================================

#include "abi_templates"
#include "combat_h"

// per-target effects
void _ApplyDamageAndEffects(struct EventSpellScriptImpactStruct stEvent, object oTarget)
{
    float fConMod = GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_CONSTITUTION);

    // both damage and stun duration scale with CON
    float fDamage = MinF(200.0, MaxF(1.0, 3.0 * fConMod));
    float fStunDur = 0.045 * fConMod + GetRankAdjustedEffectDuration(oTarget, 4.0);

    effect eEffect = EffectDamage(fDamage);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTarget, 0.0, stEvent.oCaster, stEvent.nAbility);

    // all checks against CON
    // knockdown if not immune
    if (!IsImmuneToEffectType(oTarget, EFFECT_TYPE_KNOCKDOWN))
    {
        if (!ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_CONSTITUTION, PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL))
        {
            eEffect = EffectKnockdown(stEvent.oCaster, 0, stEvent.nAbility);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, RandomFloat(), stEvent.oCaster, stEvent.nAbility);
        }
    }
    else if (!ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_CONSTITUTION, PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL))
    {
        eEffect = Effect(EFFECT_TYPE_KNOCKBACK); // knockback otherwise
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTarget, 0.0, stEvent.oCaster, stEvent.nAbility);
    }

    // and a mental check against stun
    if (!ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_CONSTITUTION, PROPERTY_ATTRIBUTE_RESISTANCE_MENTAL))
    {
        eEffect = EffectStun();
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fStunDur, stEvent.oCaster, stEvent.nAbility);
    }

    SendEventOnCastAt(oTarget, stEvent.oCaster, stEvent.nAbility);
}

// initial impact
void _ApplyImpact(struct EventSpellScriptImpactStruct stEvent)
{
    float fRadius = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", stEvent.nAbility);

    // add HP/stamina regen scaling with CON and remaining resource %
    float fConMod = GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_CONSTITUTION);
    float fHPLvl = _GetRelativeResourceLevel(stEvent.oCaster, PROPERTY_DEPLETABLE_HEALTH);
    float fStamLvl = _GetRelativeResourceLevel(stEvent.oCaster, PROPERTY_DEPLETABLE_MANA_STAMINA);
    float fHPRegen = 1.0 + 0.12 * fConMod + MaxF(0.0, (0.5 - fHPLvl) * 10.0); // basically means +1 for every 10% below 50%
    float fStamRegen = 0.5 + 0.08 * fConMod + MaxF(0.0, (0.5 - fStamLvl) * 5.0); // basically means +0.5 for every 10% below 50%

    effect eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_REGENERATION_HEALTH, fHPRegen,
                                          PROPERTY_ATTRIBUTE_REGENERATION_HEALTH_COMBAT, fHPRegen);
    eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, 90093); // VFX - regen glow
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, 20.0, stEvent.oCaster, stEvent.nAbility);

    eEffect = EffectModifyProperty(PROPERTY_ATTRIBUTE_REGENERATION_STAMINA, fStamRegen,
                                   PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, fStamRegen);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, 20.0, stEvent.oCaster, stEvent.nAbility);

    // get objects in area of effect
    object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, stEvent.lTarget, fRadius, 0.0, 0.0, TRUE);

    // cycle through objects
    int nCount = 0;
    int nMax = GetArraySize(oTargets);
    for (nCount = 0; nCount < nMax; nCount++)
    {
        if (IsObjectHostile(stEvent.oCaster, oTargets[nCount])) // hostiles only
        {
            // per-target effects
            _ApplyDamageAndEffects(stEvent, oTargets[nCount]);
        }
    }
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev); // CAST (directly from engine) or COMMAND_PENDING (re-directed by rules_core)

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // Setting Return Value
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 105408, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            _ApplyImpact(stEvent);

            break;
        }
    }
}