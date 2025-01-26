//*=============================================================================
// AB: script for Shale's Quake
//*=============================================================================

#include "abi_templates"
#include "combat_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    location lCaster = GetLocation(stEvent.oCaster);

    effect eEffect = EffectScreenShake(SCREEN_SHAKE_TYPE_BROODMOTHER_SCREEM);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, stEvent.oCaster, 0.2, stEvent.oCaster, stEvent.nAbility);

    // damage per impact
    float fDamage = 20.0 + 0.3 * GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_STRENGTH);
    effect eDamage = EffectDamage(fDamage);

    // get creatures in area
    object [] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, lCaster, 5.0, 0.0, 0.0, TRUE);
    int nCount = 0;
    int nNum = GetArraySize(oTargets);
    for (nCount = 0; nCount < nNum; nCount++)
    {
        // not caster
        if (oTargets[nCount] != stEvent.oCaster)
        {
            // size check to exclude Broodmother and High Dragons from the slow
            int nAprType = GetAppearanceType(oTargets[nCount]);
            float fSize = GetM2DAFloat(TABLE_APPEARANCE, "PERSPACE", nAprType);

            // apply damage
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eDamage, oTargets[nCount], 0.0f, stEvent.oCaster, stEvent.nAbility);

            // physical resistance against slip // stun is cheesy...
            if (!ResistanceCheck(stEvent.oCaster, oTargets[nCount], PROPERTY_ATTRIBUTE_STRENGTH, PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL))
            {
                eEffect = Effect(EFFECT_TYPE_SLIP);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTargets[nCount], 0.0f, stEvent.oCaster, stEvent.nAbility);
            }
            else if (fSize < 1.7 && !ResistanceCheck(stEvent.oCaster, oTargets[nCount], PROPERTY_ATTRIBUTE_STRENGTH, PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL))
            {
                // another check against slow
                eEffect = EffectModifyMovementSpeed(0.75, TRUE); // stacks multiplicatively
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTargets[nCount], 1.0 + RandomFloat(), stEvent.oCaster, stEvent.nAbility);
            }

            if (IsObjectHostile(stEvent.oCaster, oTargets[nCount]))
            {
                // update impact threat each impact
                AI_Threat_UpdateAbilityImpact(oTargets[nCount], stEvent.oCaster, stEvent.nAbility);
            }

            SendEventOnCastAt(oTargets[nCount], stEvent.oCaster, stEvent.nAbility, IsObjectHostile(stEvent.oCaster, oTargets[nCount]));
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

            // Handle impact
            _HandleImpact(stEvent);

            break;
        }
    }
}