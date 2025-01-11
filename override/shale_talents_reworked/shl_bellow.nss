//*=============================================================================
// AB: script for Shale's Bellow
//*=============================================================================

#include "abi_templates"
#include "combat_h"

// per-target effects
void _ApplyDamageAndEffects(struct EventSpellScriptImpactStruct stEvent, object oTarget)
{
    float fConMod = GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_CONSTITUTION);
    float fStunDur = 0.03 * fConMod + GetRankAdjustedEffectDuration(oTarget, 3.5);
    float fDazeDur = 0.045 * fConMod + GetRankAdjustedEffectDuration(oTarget, 10.0);
    effect eEffect;

    if (!ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_CONSTITUTION, PROPERTY_ATTRIBUTE_RESISTANCE_MENTAL))
    {
        eEffect = EffectStun();
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fStunDur, stEvent.oCaster, stEvent.nAbility);

        // can't resist daze if stunned
        eEffect = EffectDaze();
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDazeDur, stEvent.oCaster, stEvent.nAbility);
    }
    else if (!ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_CONSTITUTION, PROPERTY_ATTRIBUTE_RESISTANCE_MENTAL))
    {
        eEffect = EffectDaze();
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDazeDur, stEvent.oCaster, stEvent.nAbility);
    }

    SendEventOnCastAt(oTarget, stEvent.oCaster, stEvent.nAbility);

}

// initial impact
void _ApplyImpact(struct EventSpellScriptImpactStruct stEvent)
{
    float fRadius = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", stEvent.nAbility);

    ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oCaster, 105402, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

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