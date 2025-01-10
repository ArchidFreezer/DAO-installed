// -----------------------------------------------------------------------------
// spell_aoe_instant
// -----------------------------------------------------------------------------
/*
    Script for Area of Effect spells that have an instant effect.
*/
// -----------------------------------------------------------------------------
// petert
// -----------------------------------------------------------------------------

#include "log_h"
#include "abi_templates"
#include "spell_constants_h"

// Georg:
// Hardcoded # of maximum AOE targets. This is to prevent the engine from getting
// stuck on a TMI if you'd hit a lot of areas at once
const int MAX_AOE_TARGETS = 30;

void _ApplySpellEffects(struct EventSpellScriptImpactStruct stEvent, object oTarget)
{
    effect eEffect;

    // if hostile
    if (IsObjectHostile(stEvent.oCaster, oTarget) == TRUE)
    {
        if (IsMagicUser(oTarget) == TRUE)
        {
            float fDrain = -1.0f * (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * MANA_CLEANSE_FACTOR;
            eEffect = EffectModifyManaStamina(fDrain);
            eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, Ability_GetImpactObjectVfxId(stEvent.nAbility));
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);
        }
    }
}

// Spellscript Impact Damage and Effects
void _ApplyImpactDamageAndEffects(struct EventSpellScriptImpactStruct stEvent)
{
    // only work for sphere spells
    int nAoEType = GetM2DAInt(TABLE_ABILITIES_SPELLS, "aoe_type", stEvent.nAbility);
    if (nAoEType == 1)
    {
        // location impact vfx
        if (stEvent.oTarget != OBJECT_INVALID)
        {
            stEvent.lTarget = GetLocation(stEvent.oTarget);
        }
        Ability_ApplyLocationImpactVFX(stEvent.nAbility, stEvent.lTarget);

        float fRadius = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", stEvent.nAbility);

        // get objects in area of effect
        object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, stEvent.lTarget, fRadius);

        // caster vfx
        effect eEffect = EffectVisualEffect(MANA_CLASH_CASTER_VFX);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, stEvent.oCaster, 0.0f, stEvent.oCaster, stEvent.nAbility);

        // cycle through objects
        int nCount = 0;
        int nMax = Min(GetArraySize(oTargets), MAX_AOE_TARGETS);
        for (nCount = 0; nCount < nMax; nCount++)
        {
            if (CheckSpellResistance(oTargets[nCount], stEvent.oCaster, stEvent.nAbility) == FALSE)
            {
                // per-spell effects
                SetIndividualImpactAOEEvent(stEvent.oCaster,oTargets[nCount],stEvent.nAbility,stEvent.lTarget);
            } else
            {
                UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
            }
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

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_PENDING", Log_GetAbilityNameById(stEvent.nAbility));

            // Setting Return Value
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_CAST",Log_GetAbilityNameById(stEvent.nAbility));

            // hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));

            // AbiAoEImpact(stEvent.lTarget,  stEvent.oCaster, stEvent.nAbility);
            _ApplyImpactDamageAndEffects(stEvent);

            break;
        }
        case EVENT_TYPE_SPELLSCRIPT_INDIVIDUAL_IMPACT:
        {
            struct EventSpellScriptImpactStruct stEvent;
            stEvent.nAbility = GetEventInteger(ev,0);
            stEvent.oCaster = GetEventObject(ev, 0);
            stEvent.lTarget = Location(GetEventObject(ev,2),Vector(GetEventFloat(ev,0),GetEventFloat(ev,1),GetEventFloat(ev,2)), 0.0f);
            _ApplySpellEffects(stEvent,GetEventObject(ev,1));
        }
    }
}