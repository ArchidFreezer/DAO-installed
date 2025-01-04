// -----------------------------------------------------------------------------
// spell_singletarget
// -----------------------------------------------------------------------------
/*
    Generic Single Target Spell
*/
// -----------------------------------------------------------------------------
// georg zoeller
// -----------------------------------------------------------------------------

#include "log_h"
#include "abi_templates"
#include "spell_constants_h"

void _ApplySpellEffects(struct EventSpellScriptImpactStruct stEvent, object oTarget)
{
    effect eEffect;

    float fDamage = (100.0f + GetCreatureSpellPower(stEvent.oCaster)) * CONE_OF_COLD_DAMAGE_FACTOR;
    eEffect = EffectDamage(fDamage, DAMAGE_TYPE_COLD);
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTarget, 0.0f, stEvent.oCaster, stEvent.nAbility);

    float fDuration = GetRankAdjustedEffectDuration(oTarget, CONE_OF_COLD_DURATION);

    // remove stacking effects
    RemoveStackingEffects(oTarget, stEvent.oCaster, stEvent.nAbility);

    // physical resistance
    if (ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_SPELLPOWER, RESISTANCE_PHYSICAL) == FALSE)
    {
        // frozen
        eEffect = EffectParalyze();
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);

        // petrify
        eEffect = Effect(EFFECT_TYPE_PETRIFY);
        eEffect = SetEffectInteger(eEffect, 0, 1);
        eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, CONE_OF_COLD_FROZEN_VFX);
    } else
    {
        // slow
        eEffect = EffectModifyMovementSpeed(CONE_OF_COLD_SPEED_PENALTY, TRUE);
        eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_VFX, CONE_OF_COLD_SLOW_VFX);
    }
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);

}

//------------------------------------------------------------------------------
// Spellscript Impact Damage and Effects
//------------------------------------------------------------------------------
void _ApplyImpactDamageAndEffects(struct EventSpellScriptImpactStruct stEvent)
{
    // cone vfx
    effect eCone = EffectConeCasting(Ability_GetImpactLocationVfxId(stEvent.nAbility));
    ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eCone, stEvent.oCaster, 1.5f, stEvent.oCaster, 0 /*intentional*/);

    // cone details
    float fAoEParam1 = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", stEvent.nAbility);
    float fAoEParam2 = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param2", stEvent.nAbility);
    if (fAoEParam2 <= 0.0f)
    {
        fAoEParam2 = 5.0f;
    }
    stEvent.lTarget = GetLocation(stEvent.oCaster);

    effect eEffect;

    // cycle through objects in cone
    object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_CONE, stEvent.lTarget, fAoEParam1, fAoEParam2);
    int nCount = 0;
    int nMax = GetArraySize(oTargets);
    for (nCount = 0; nCount < nMax; nCount++)
    {
        // do not affect caster
        if (oTargets[nCount] != stEvent.oCaster)
        {
            if (CheckSpellResistance(oTargets[nCount], stEvent.oCaster, stEvent.nAbility) == FALSE)
            {
                SetIndividualImpactAOEEvent(stEvent.oCaster,oTargets[nCount],stEvent.nAbility,stEvent.lTarget,500);
            }
            else
            {
                UI_DisplayMessage(oTargets[nCount], UI_MESSAGE_RESISTED);
            }
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
            // Get a structure with the event parameters
            struct EventSpellScriptPendingStruct stEvent = Events_GetEventSpellScriptPendingParameters(ev);

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_PENDING",Log_GetAbilityNameById(stEvent.nAbility));

            // Setting Return Value
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_CAST",Log_GetAbilityNameById(stEvent.nAbility));

            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            Log_Trace(LOG_CHANNEL_COMBAT_ABILITY, GetCurrentScriptName() + ".EVENT_TYPE_SPELLSCRIPT_IMPACT",Log_GetAbilityNameById(stEvent.nAbility));

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
            break;
        }

    }
}