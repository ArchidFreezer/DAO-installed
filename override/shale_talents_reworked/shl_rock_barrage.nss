//*=============================================================================
// AB: script for Shale's Rock Barrage
//*=============================================================================

//*=============================================================================
// What this ability does doesn't make a whole lot of sense,
// even when placed in the settings of the game (how does it work indoor???)
// Now has reduced duration, radius, delay interval, fewer projectiles.
// Code ripped from Archdemon's Spirit Smite.
//*=============================================================================

#include "ability_h"
#include "combat_damage_h"

const int SHALE_ROCK_BARRAGE = 300303;
const int SHALE_BARRAGE = 2002;

// initial impact
void _ApplyImpact(struct EventSpellScriptImpactStruct stEvent)
{
    // number of rocks determined by STR, max 10 min 5
    int nRockNum = Min(10, 5 + FloatToInt(GetAttributeModifier(stEvent.oCaster, PROPERTY_ATTRIBUTE_STRENGTH) / 10.0));

    float fDuration = (nRockNum - 1) * 0.5; // VFX duration depends on # of rocks

    effect eAoE = EffectAreaOfEffect(SHALE_BARRAGE, R"shl_rock_barrage.ncs", 105418); // VFX - earth shaking
    eAoE = SetEffectEngineFloat(eAoE, EFFECT_FLOAT_SCALE, 0.6f); // reduced VFX radius

    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eAoE, stEvent.lTarget, fDuration, stEvent.oCaster, stEvent.nAbility);

    object oCreator = OBJECT_SELF; // Shale

    // first location is target point and is always hit
    location lLoc1 = stEvent.lTarget;

    vector vPos1 = GetPositionFromLocation(lLoc1);

    // get random locations (6) within ~6.5m around target point // some trig involved here
    // Location 2
    vector vPos2;
    vPos2.x = vPos1.x + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
    vPos2.y = vPos1.y + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
    vPos2.z = vPos1.z;
    location lLoc2 = Location(GetArea(OBJECT_SELF), vPos2, 0.0);

    // Location 3
    vector vPos3;
    vPos3.x = vPos1.x + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
    vPos3.y = vPos1.y + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
    vPos3.z = vPos1.z;
    location lLoc3 = Location(GetArea(OBJECT_SELF), vPos3, 0.0);

    // Location 4
    vector vPos4;
    vPos4.x = vPos1.x + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
    vPos4.y = vPos1.y + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
    vPos4.z = vPos1.z;
    location lLoc4 = Location(GetArea(OBJECT_SELF), vPos4, 0.0);

    // Location 5
    vector vPos5;
    vPos5.x = vPos1.x + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
    vPos5.y = vPos1.y + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
    vPos5.z = vPos1.z;
    location lLoc5 = Location(GetArea(OBJECT_SELF), vPos5, 0.0);

    // additional projectiles based on STR
    location lLoc6;
    location lLoc7;
    location lLoc8;
    location lLoc9;
    location lLoc10;

    if (nRockNum > 5)
    {
        // Location 6
        vector vPos6;
        vPos6.x = vPos1.x + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
        vPos6.y = vPos1.y + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
        vPos6.z = vPos1.z;
        lLoc6 = Location(GetArea(OBJECT_SELF), vPos6, 0.0);
    }

    if (nRockNum > 6)
    {
        // Location 7
        vector vPos7;
        vPos7.x = vPos1.x + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
        vPos7.y = vPos1.y + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
        vPos7.z = vPos1.z;
        lLoc7 = Location(GetArea(OBJECT_SELF), vPos7, 0.0);
    }

    if (nRockNum > 7)
    {
        // Location 8
        vector vPos8;
        vPos8.x = vPos1.x + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
        vPos8.y = vPos1.y + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
        vPos8.z = vPos1.z;
        lLoc8 = Location(GetArea(OBJECT_SELF), vPos8, 0.0);
    }

    if (nRockNum > 8)
    {
        // Location 9
        vector vPos9;
        vPos9.x = vPos1.x + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
        vPos9.y = vPos1.y + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
        vPos9.z = vPos1.z;
        lLoc9 = Location(GetArea(OBJECT_SELF), vPos9, 0.0);
    }

    if (nRockNum > 9)
    {
        // Location 10
        vector vPos10;
        vPos10.x = vPos1.x + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
        vPos10.y = vPos1.y + 2.0 * RandFF(-1.0, 0.5) * (IntToFloat(Random(4)) + 1.5);
        vPos10.z = vPos1.z;
        lLoc10 = Location(GetArea(OBJECT_SELF), vPos10, 0.0);
    }

    event evBoom = Event(EVENT_TYPE_CUSTOM_EVENT_01); // impact and damage
    float fDelay = 0.0;

    // signal for rock impact, 0.4-0.6s delay interval
    evBoom = SetEventLocation(evBoom, 0, lLoc1);
    DelayEvent(fDelay, OBJECT_SELF, evBoom, "shl_rock_barrage");

    fDelay += RandFF(0.2, 0.4);
    evBoom = SetEventLocation(evBoom, 0, lLoc2);
    DelayEvent(fDelay, OBJECT_SELF, evBoom, "shl_rock_barrage");

    fDelay += RandFF(0.2, 0.4);
    evBoom = SetEventLocation(evBoom, 0, lLoc3);
    DelayEvent(fDelay, OBJECT_SELF, evBoom, "shl_rock_barrage");

    fDelay += RandFF(0.2, 0.4);
    evBoom = SetEventLocation(evBoom, 0, lLoc4);
    DelayEvent(fDelay, OBJECT_SELF, evBoom, "shl_rock_barrage");

    fDelay += RandFF(0.2, 0.4);
    evBoom = SetEventLocation(evBoom, 0, lLoc5);
    DelayEvent(fDelay, OBJECT_SELF, evBoom, "shl_rock_barrage");

    if (nRockNum > 5)
    {
        fDelay += RandFF(0.2, 0.4);
        evBoom = SetEventLocation(evBoom, 0, lLoc6);
        DelayEvent(fDelay, OBJECT_SELF, evBoom, "shl_rock_barrage");
    }

    if (nRockNum > 6)
    {
        fDelay += RandFF(0.2, 0.4);
        evBoom = SetEventLocation(evBoom, 0, lLoc7);
        DelayEvent(fDelay, OBJECT_SELF, evBoom, "shl_rock_barrage");
    }

    if (nRockNum > 7)
    {
        fDelay += RandFF(0.2, 0.4);
        evBoom = SetEventLocation(evBoom, 0, lLoc8);
        DelayEvent(fDelay, OBJECT_SELF, evBoom, "shl_rock_barrage");
    }

    if (nRockNum > 8)
    {
        fDelay += RandFF(0.2, 0.4);
        evBoom = SetEventLocation(evBoom, 0, lLoc9);
        DelayEvent(fDelay, OBJECT_SELF, evBoom, "shl_rock_barrage");
    }

    if (nRockNum > 9)
    {
        fDelay += RandFF(0.2, 0.4);
        evBoom = SetEventLocation(evBoom, 0, lLoc10);
        DelayEvent(fDelay, OBJECT_SELF, evBoom, "shl_rock_barrage");
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
            // Get structure containing event parameters
            struct EventSpellScriptPendingStruct stEvent = Events_GetEventSpellScriptPendingParameters(ev);

            // Setting return value
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure containing event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // Hand through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            // VFX - rocks popping out of ground
            // this used to be off-synced sometimes when cast out of combat
            // because of autodraw flag
            ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, 105422, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            // Get structure containing event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            _ApplyImpact(stEvent); // apply initial impact

            break;
        }

        case EVENT_TYPE_CUSTOM_EVENT_01: // rock shower
        {
            location lLoc = GetEventLocation(ev, 0);
            object oCaster = GetEventCreator(ev);

            effect eVFX = EffectVisualEffect(105423); // VFX - rocks crashing down
            Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_INSTANT, eVFX, lLoc, 0.0, oCaster, SHALE_ROCK_BARRAGE);

            effect eEffect;

            // grab everyone within 1.2m of impact location
            object[] oTargets = GetObjectsInShape(OBJECT_TYPE_CREATURE, SHAPE_SPHERE, lLoc, 1.2, 0.0, 0.0, TRUE);
            int nSize = GetArraySize(oTargets);

            // loop through targets
            int i = 0;
            for(i = 0; i < nSize; i++)
            {
                int nAprType = GetAppearanceType(oTargets[i]);
                float fHeight = GetM2DAFloat(TABLE_APPEARANCE, "HEIGHT", nAprType);

                // impact damage
                float fDamage = 30.0 + 0.5 * GetAttributeModifier(oCaster, PROPERTY_ATTRIBUTE_STRENGTH);
                effect eDamage;

                if (fHeight >= 6.0) // High Dragons / Archdemon take 30% damage
                    eDamage = EffectDamage(fDamage * 0.3);
                else
                    eDamage = EffectDamage(fDamage);

                // damage
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eDamage, oTargets[i], 0.0f, oCaster, SHALE_ROCK_BARRAGE);

                // only creatures not immune to knockdown are affected
                if (!IsImmuneToEffectType(oTargets[i], EFFECT_TYPE_KNOCKDOWN))
                {
                    if (!ResistanceCheck(oCaster, oTargets[i], PROPERTY_ATTRIBUTE_STRENGTH, PROPERTY_ATTRIBUTE_RESISTANCE_PHYSICAL))
                    {
                        eEffect = EffectKnockdown(oCaster, 0, SHALE_ROCK_BARRAGE);
                        eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_USE_INTERPOLATION_ANGLE, 2);
                        eEffect = SetEffectEngineVector(eEffect, EFFECT_VECTOR_ORIGIN, GetPositionFromLocation(lLoc));
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, oTargets[i], RandomFloat(), oCaster, SHALE_ROCK_BARRAGE);
                    }
                    else if (!ResistanceCheck(oCaster, oTargets[i], PROPERTY_ATTRIBUTE_STRENGTH, RESISTANCE_PHYSICAL))
                    {
                        eEffect = Effect(EFFECT_TYPE_KNOCKBACK); // another check against knockback
                        eEffect = SetEffectEngineInteger(eEffect, EFFECT_INTEGER_USE_INTERPOLATION_ANGLE, 2);
                        eEffect = SetEffectEngineVector(eEffect, EFFECT_VECTOR_ORIGIN, GetPositionFromLocation(lLoc));
                        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eEffect, oTargets[i], 0.0f, oCaster, SHALE_ROCK_BARRAGE);
                    }
                }

                if (IsObjectHostile(oCaster, oTargets[i]))
                {
                    // update impact threat each impact
                    AI_Threat_UpdateAbilityImpact(oTargets[i], oCaster, SHALE_ROCK_BARRAGE);
                }

                SendEventOnCastAt(oTargets[i], oCaster, SHALE_ROCK_BARRAGE, IsObjectHostile(oCaster, oTargets[i]));
            }

            break;
        }
    }
}