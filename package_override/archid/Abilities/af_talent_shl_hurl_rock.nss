//*=============================================================================
// AB: script for Shale's Hurl Rock (basically ogre/golem hurl)
//*=============================================================================

#include "abi_templates"
#include "combat_h"

// per-target effects
void _ApplyDamageAndEffects(struct EventSpellScriptImpactStruct stEvent, object oTarget, float fDamage, float fDistance)
{
    effect eEffect;

    // damage goes up as distance to impact center goes down, up to 150% at center
    // capped below just in case radius is >> 6
    float fFactor = MaxF(0.66, 1.0 + 0.5 * (6.0 - fDistance) / 6.0);
    fDamage *= fFactor;
    eEffect = EffectDamage(fDamage);

    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);

    // knockdown only within 3m of center
    if (fDistance <= 3.0 && !ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_STRENGTH, PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL))
    {
        // knockdown
        eEffect = EffectKnockdown(oTarget, 0, stEvent.nAbility);
        eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_USE_INTERPOLATION_ANGLE, 2);
        eEffect = SetEffectEngineVector(eEffect, EFFECT_VECTOR_ORIGIN, GetPositionFromLocation(stEvent.lTarget));
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, RandomFloat(), stEvent.oCaster, stEvent.nAbility);
    }
    // only send event to enemies
    SendEventOnCastAt(oTarget, stEvent.oCaster, stEvent.nAbility, IsObjectHostile(stEvent.oCaster, oTarget));
}

// initial impact
void _ApplyImpact(struct EventSpellScriptImpactStruct stEvent)
{
    float fRadius = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", stEvent.nAbility);

    // location impact vfx
    Ability_ApplyLocationImpactVFX(stEvent.nAbility, stEvent.lTarget);

    // calculate base damage here
    float fDamage = 32.0f + 1.4f * GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_STRENGTH);

    // get objects in area of effect
    object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, stEvent.lTarget, fRadius, 0.0, 0.0, TRUE);

    // cycle through objects
    int nCount = 0;
    int nMax = GetArraySize(oTargets);
    for (nCount = 0; nCount < nMax; nCount++)
    {
        float fDistance = GetDistanceBetweenLocations(stEvent.lTarget, GetLocation(oTargets[nCount]));

        // per-target effects
        _ApplyDamageAndEffects(stEvent, oTargets[nCount], fDamage, fDistance);
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