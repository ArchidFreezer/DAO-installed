#include "ability_h"
#include "combat_damage_h"
#include "events_h"
#include "monster_constants_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    location lCaster = GetLocation(stEvent.oCaster);

    // quake vfx
    effect eQuakeVFX = EffectVisualEffect(GOLEM_QUAKE_VFX);
    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_INSTANT, eQuakeVFX, lCaster, 0.0f, stEvent.oCaster, stEvent.nAbility);

    effect eShake = EffectScreenShake(SCREEN_SHAKE_TYPE_BROODMOTHER_SCREEM);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eShake, stEvent.oCaster, 0.2, stEvent.oCaster, stEvent.nAbility);

    // knockback effect
    effect eKnockback = Effect(1057);
    // damage
    effect eDamage = EffectDamage(0.3*(100 + GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_STRENGTH)));

    // get creatures in area
    object [] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, lCaster, GOLEM_QUAKE_RADIUS);
    int nNum = GetArraySize(oTargets);
    int i;
    for (i = 0; i < nNum; i++) {
        object oTarget = oTargets[i];
        // aoe doesn't harm itself
        if (oTarget != stEvent.oCaster) {
            // physical resistance
            if (ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_STRENGTH, RESISTANCE_PHYSICAL) == FALSE)
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eKnockback, oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);

            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eDamage, oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);
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
            struct EventSpellScriptPendingStruct stEvent = Events_GetEventSpellScriptPendingParameters(ev);

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

            // Handle impact
            _HandleImpact(stEvent);

            SendEventOnCastAt(stEvent.oTarget,stEvent.oCaster, stEvent.nAbility, TRUE);

            break;
        }
    }
}