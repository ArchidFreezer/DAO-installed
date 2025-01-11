#include "abi_templates"

// Spellscript Impact Damage and Effects
void _ApplyImpactDamageAndEffects(struct EventSpellScriptImpactStruct stEvent)
{
    // location impact vfx
    if (stEvent.oTarget != OBJECT_INVALID)
        stEvent.lTarget = GetLocation(stEvent.oTarget);

    // Can't set location vfx in abi or it triggers every ground punch, so we get to hard code this
    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_INSTANT, EffectVisualEffect(105420), stEvent.lTarget, 0.0f);
    
    // Crust vfx
    int nVfx = Ability_GetImpactObjectVfxId(stEvent.nAbility);

    // get objects in area of effect
    float fRadius = GetM2DAFloat(TABLE_ABILITIES_SPELLS, "aoe_param1", stEvent.nAbility);
    object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, stEvent.lTarget, fRadius);

    // cycle through objects
    int i, nSize = GetArraySize(oTargets);
    for (i = 0;i < nSize; i++) {
        object oTarget = oTargets[i];
        if (IsObjectHostile(stEvent.oCaster, oTarget)) {
            if (ResistanceCheck(stEvent.oCaster, oTarget, PROPERTY_ATTRIBUTE_STRENGTH, RESISTANCE_PHYSICAL) == FALSE) {
                float fDuration = GetRankAdjustedEffectDuration(oTarget, 10.0);
                effect eEffect = EffectParalyze(nVfx);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTarget, fDuration, stEvent.oCaster, stEvent.nAbility);
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

            // impact is apparently triggered every time shale punches the ground (reused from quake?), we only want to do anything on the last
            if (stEvent.nHit == 3)
                _ApplyImpactDamageAndEffects(stEvent);

            break;
        }
    }
}