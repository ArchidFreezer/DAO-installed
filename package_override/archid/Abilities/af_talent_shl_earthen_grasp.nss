//*=============================================================================
// AB: script for Shale's Earthen Grasp
//*=============================================================================

#include "abi_templates"
#include "combat_h"

// per-target effects
void _ApplyDamageAndEffects(struct EventSpellScriptImpactStruct stEvent, object oTarget)
{
    float fWPMod = 0.12 * GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_WILLPOWER); // not affected by rank/difficulty
    float fDuration = fWPMod + GetRankAdjustedEffectDuration(oTarget, 6.0);

    if (!ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_STRENGTH, PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL))
    {
        effect eEffect = EffectParalyze(105421); // VFX - turning to stone
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);
    }
    else // slow otherwise
    {
        effect eEffect = EffectModifyMovementSpeed(0.65, TRUE); // -35% ms
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);

        eEffect = EffectModifyPropertyHostile(PROPERTY_ATTRIBUTE_ATTACK_SPEED_MODIFIER, 0.3); // +30% attack duration
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);
    }

    SendEventOnCastAt(oTarget, stEvent.oCaster, stEvent.nAbility);

}

// initial impact
void _ApplyImpact(struct EventSpellScriptImpactStruct stEvent)
{
    float fRadius = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", stEvent.nAbility);

    effect eVFX = EffectVisualEffect(105420); // VFX - dust cloud
    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eVFX, stEvent.lTarget, 0.0, stEvent.oCaster, stEvent.nAbility);

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

            if (stEvent.nHit == 3) // only apply at last impact
            {
                _ApplyImpact(stEvent);
            }

            break;
        }
    }
}